#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_FILE="$PROJECT_ROOT/Castlevania ReVamped Open Source Edition.yyp"
BUILD_DIR="$PROJECT_ROOT/build/android"
GMBUILD_DIR="$PROJECT_ROOT/.gmbuild"
CACHE_DIR="$GMBUILD_DIR/cache"
TEMP_DIR="$GMBUILD_DIR/temp"
PACKAGE="com.castlevania.revamped"
CHECK_ONLY=0

if [[ "${1:-}" == "--check-only" ]]; then
  CHECK_ONLY=1
fi

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

note() {
  printf '==> %s\n' "$*"
}

major_java_version() {
  local raw version
  raw="$(java -version 2>&1 | awk -F'"' '/version/ {print $2; exit}')"
  [[ -n "$raw" ]] || return 1
  if [[ "$raw" == 1.* ]]; then
    version="${raw#1.}"
    version="${version%%.*}"
  else
    version="${raw%%.*}"
  fi
  printf '%s\n' "$version"
}

find_latest_runtime() {
  local runtime_root="${GAMEMAKER_RUNTIME_ROOT:-$HOME/.local/share/GameMakerStudio2-Beta/Cache/runtimes}"
  [[ -d "$runtime_root" ]] || return 1
  find "$runtime_root" -mindepth 2 -maxdepth 6 -type f -path '*/bin/igor/linux/x64/Igor' -print \
    | sort -V \
    | tail -n 1
}

[[ -f "$PROJECT_FILE" ]] || fail "GameMaker project not found: $PROJECT_FILE"

# This machine has a JBR bundled with Android Studio; prefer it when JAVA_HOME is unset.
if [[ -z "${JAVA_HOME:-}" && -x /opt/android-studio/jbr/bin/java ]]; then
  export JAVA_HOME=/opt/android-studio/jbr
  export PATH="$JAVA_HOME/bin:$PATH"
fi

IGOR_BIN="${IGOR:-}"
if [[ -z "$IGOR_BIN" ]]; then
  IGOR_BIN="$(command -v Igor || true)"
fi
if [[ -z "$IGOR_BIN" ]]; then
  IGOR_BIN="$(command -v igor || true)"
fi
if [[ -z "$IGOR_BIN" ]]; then
  IGOR_BIN="$(find_latest_runtime || true)"
fi
[[ -n "$IGOR_BIN" ]] || fail "GameMaker Igor CLI not found. Install/open GameMaker with Android target, or run with IGOR=/absolute/path/to/Igor."
[[ -x "$IGOR_BIN" ]] || fail "Igor exists but is not executable: $IGOR_BIN"
note "Igor: $IGOR_BIN"

RUNTIME_PATH="${GAMEMAKER_RUNTIME_PATH:-}"
if [[ -z "$RUNTIME_PATH" ]]; then
  # .../runtime-YYYY.X/bin/igor/linux/x64/Igor -> .../runtime-YYYY.X
  RUNTIME_PATH="$(cd "$(dirname "$IGOR_BIN")/../../../.." && pwd)"
fi
[[ -d "$RUNTIME_PATH/android/runner" ]] || fail "GameMaker runtime Android runner not found under: $RUNTIME_PATH"
note "Runtime: $RUNTIME_PATH"

USER_DIR="${GAMEMAKER_USER_DIR:-$HOME/.config/GameMakerStudio2-Beta/eboodnero_4998381}"
[[ -d "$USER_DIR" ]] || fail "GameMaker user settings folder not found: $USER_DIR (set GAMEMAKER_USER_DIR)."
note "GameMaker user dir: $USER_DIR"

command -v java >/dev/null 2>&1 || fail "java not found; install/select JDK 17+."
JAVA_MAJOR="$(major_java_version)" || fail "could not parse java -version output."
if (( JAVA_MAJOR < 17 )); then
  fail "JDK 17+ is required for Android tooling; active Java major version is $JAVA_MAJOR. Set JAVA_HOME=/opt/android-studio/jbr on this machine."
fi
note "Java major version: $JAVA_MAJOR"

ANDROID_SDK=""
for sdk_candidate in \
  "${ANDROID_HOME:-}" \
  "${ANDROID_SDK_ROOT:-}" \
  "$HOME/AndroidSDK" \
  "$HOME/Android/Sdk" \
  /opt/android-sdk; do
  [[ -n "$sdk_candidate" && -d "$sdk_candidate" ]] || continue
  if [[ -d "$sdk_candidate/platforms/android-35" && -d "$sdk_candidate/build-tools/35.0.0" ]]; then
    ANDROID_SDK="$sdk_candidate"
    break
  fi
  [[ -n "$ANDROID_SDK" ]] || ANDROID_SDK="$sdk_candidate"
done
[[ -n "$ANDROID_SDK" && -d "$ANDROID_SDK" ]] || fail "Android SDK not found. Set ANDROID_HOME or ANDROID_SDK_ROOT."
export ANDROID_HOME="$ANDROID_SDK"
export ANDROID_SDK_ROOT="$ANDROID_SDK"
export PATH="$ANDROID_SDK/platform-tools:$ANDROID_SDK/cmdline-tools/latest/bin:$PATH"
note "Android SDK: $ANDROID_SDK"

command -v sdkmanager >/dev/null 2>&1 || fail "sdkmanager not found on PATH."
command -v adb >/dev/null 2>&1 || fail "adb not found on PATH."
[[ -d "$ANDROID_SDK/platforms/android-35" ]] || fail "Missing Android SDK platform android-35 in $ANDROID_SDK. Install with: sdkmanager --sdk_root=$ANDROID_SDK 'platforms;android-35'"
[[ -d "$ANDROID_SDK/build-tools/35.0.0" ]] || fail "Missing Android build-tools 35.0.0 in $ANDROID_SDK. Install with: sdkmanager --sdk_root=$ANDROID_SDK 'build-tools;35.0.0'"
note "sdkmanager: $(command -v sdkmanager)"
note "adb: $(command -v adb)"

if (( CHECK_ONLY )); then
  note "Preflight passed. Project: $PROJECT_FILE"
  exit 0
fi

mkdir -p "$BUILD_DIR" "$CACHE_DIR" "$TEMP_DIR"
LOG="$GMBUILD_DIR/igor-android-package.log"
set +e
"$IGOR_BIN" \
  --project="$PROJECT_FILE" \
  --runtimePath="$RUNTIME_PATH" \
  --user="$USER_DIR" \
  --cache="$CACHE_DIR" \
  --temp="$TEMP_DIR" \
  --runtime=VM \
  --config=Default \
  --of="$BUILD_DIR/CastlevaniaReVamped.apk" \
  android Package 2>&1 | tee "$LOG"
igor_status=${PIPESTATUS[0]}
set -e

DEBUG_APK="$CACHE_DIR/Android/Default/$PACKAGE/build/outputs/apk/debug/$PACKAGE-debug.apk"
RELEASE_APK="$CACHE_DIR/Android/Default/$PACKAGE/build/outputs/apk/release/$PACKAGE-release.apk"
[[ -f "$DEBUG_APK" ]] || fail "Igor/Gradle did not produce debug APK. Igor exit=$igor_status; see $LOG"
cp "$DEBUG_APK" "$BUILD_DIR/CastlevaniaReVamped-debug.apk"
if [[ -f "$RELEASE_APK" ]]; then
  cp "$RELEASE_APK" "$BUILD_DIR/CastlevaniaReVamped-release.apk"
fi

note "APK built: $BUILD_DIR/CastlevaniaReVamped-debug.apk"
if (( igor_status != 0 )); then
  note "Igor exited $igor_status after Gradle produced the APK (known artifact-copy quirk); copied APK from Gradle outputs. See $LOG"
fi

if command -v apksigner >/dev/null 2>&1; then
  apksigner verify --verbose "$BUILD_DIR/CastlevaniaReVamped-debug.apk" | sed -n '1,8p'
fi

ls -lh "$BUILD_DIR"/*.apk

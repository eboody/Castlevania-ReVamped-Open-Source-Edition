# Android APK Build Runbook

This repo is a GameMaker project. Android APK generation must be done through GameMaker's Android export pipeline; Gradle/Android SDK alone is not enough because GameMaker generates the Android project from `Castlevania ReVamped Open Source Edition.yyp`.

## Project settings

- GameMaker project: `Castlevania ReVamped Open Source Edition.yyp`
- Project IDE metadata: `2024.6.2.162`
- Android options file: `options/android/options_android.yy`
- Android package id: `com.lv4games.castlevaniarevamped`
- Display name: `Castlevania ReVamped`
- Orientation: landscape + reverse landscape
- ABI: arm64 only
- Minimum SDK: 23
- Target/compile SDK: 35
- Build tools: 35.0.0
- Input goal: external Android controller first; fallback touch controls hide and deactivate while any non-blocked gamepad is connected.

## Required local tools

1. A licensed GameMaker installation with the Android target/runtime installed.
2. GameMaker CLI (`Igor`). The helper auto-detects the local Beta runtime at `~/.local/share/GameMakerStudio2-Beta/Cache/runtimes/.../bin/igor/linux/x64/Igor`, or accepts `IGOR=/absolute/path/to/Igor`.
3. JDK 17 or newer for Android SDK tooling. On this machine the working JDK is Android Studio's bundled JBR at `/opt/android-studio/jbr` (Java 21).
4. Android SDK command line tools plus `platforms;android-35` and `build-tools;35.0.0`. On this machine the working GameMaker SDK is `/home/eran/AndroidSDK`; `/opt/android-sdk` exists but is not the SDK used for this APK build.
5. `adb` for install/launch smoke tests.

## Preflight

Run:

```bash
tools/build-android-apk.sh --check-only
```

The check verifies:

- `Igor` / GameMaker CLI exists.
- The matching GameMaker runtime contains `android/runner`.
- The GameMaker user settings folder exists.
- `java` is available and reports a major version of at least 17.
- A usable Android SDK exists and contains Android platform 35 plus build-tools 35.0.0.
- `sdkmanager` and `adb` exist.

## APK build flow

Run:

```bash
tools/build-android-apk.sh
```

The helper:

1. Selects `/opt/android-studio/jbr` when `JAVA_HOME` is unset.
2. Auto-detects the newest local GameMaker Beta `Igor` runtime, unless `IGOR` or `GAMEMAKER_RUNTIME_PATH` is provided.
3. Chooses an Android SDK that actually contains platform/build-tools 35, preferring `/home/eran/AndroidSDK` on this machine when `/opt/android-sdk` is stale.
4. Invokes `Igor ... android Package` in VM mode.
5. Handles the current Igor post-Gradle copy quirk: Igor exits with `System.ArgumentException: destFileName` after Gradle succeeds, so the helper copies the APKs directly from Gradle's output directory.
6. Verifies the debug APK with `apksigner verify --verbose` when `apksigner` is installed.

Expected local outputs are ignored by git:

- `build/android/CastlevaniaReVamped-debug.apk`
- `build/android/CastlevaniaReVamped-release.apk`
- `.gmbuild/igor-android-package.log`

## Verified local build and phone smoke: 2026-06-19

`tools/build-android-apk.sh` completed with Gradle `BUILD SUCCESSFUL` after the startup-room fix in `rooms/rmInit/RoomCreationCode.gml` and produced:

- `build/android/CastlevaniaReVamped-debug.apk` — 1.1G, SHA-256 `95b0a09bac4b3c6ffc1119dc98e807eb473c5debb33245862cf9023680ab0896`
- `build/android/CastlevaniaReVamped-release.apk` — 532M, SHA-256 `6bbb1d9607919cedc713e1c1cdcce9f3833eb871c624161f6f400bf48447b254`

Static verification commands:

```bash
/home/eran/AndroidSDK/build-tools/35.0.0/aapt dump badging build/android/CastlevaniaReVamped-debug.apk
/home/eran/AndroidSDK/build-tools/35.0.0/apksigner verify --verbose build/android/CastlevaniaReVamped-debug.apk
unzip -l build/android/CastlevaniaReVamped-debug.apk | grep -E 'libyoyo.so|assets/game.droid|assets/options.ini'
```

Observed verification:

- package: `com.lv4games.castlevaniarevamped`
- app label: `Castlevania ReVamped`
- launchable activity: `com.lv4games.castlevaniarevamped.RunnerActivity`
- Leanback launchable activity present
- `minSdkVersion=23`, `targetSdkVersion=35`, `compileSdkVersion=35`
- native code: `arm64-v8a`
- touchscreen is optional
- `assets/game.droid`, `assets/options.ini`, and `lib/arm64-v8a/libyoyo.so` are packaged
- debug APK verifies with APK Signature Scheme v2 and JAR/v1 signing

Note: GameMaker's Android gamepad support injects Bluetooth permissions/features into the final manifest even when the explicit project permission toggles are disabled. Do not remove this blindly; verify controller behavior on-device first.

On-device smoke on ASUS `ASUS_AI2302` (`RCAIB70040468JB`) passed:

- `adb install -r build/android/CastlevaniaReVamped-debug.apk` returned `Success`.
- `adb shell monkey -p com.lv4games.castlevaniarevamped 1` launched `RunnerActivity` and kept it foregrounded.
- Logcat showed no fatal exception/ANR for the package.
- `libyoyo.so` loaded successfully and the GameMaker main loop started.
- GameSir controller devices were detected; logcat reported `Input: Gamepad 0 connected`, `Input: Gamepad 1 connected`, and `Input: Setting player 0 profile to "gamepad"`.
- Screenshots under `logs/android-smoke/` show progression from file select to in-game play.
- With the GameSir connected, no virtual touch controls were visible in the captured menu/gameplay screenshots.

## Install and launch smoke

A basic install/launch smoke has passed on the connected ASUS phone. Re-run this section when validating a fresh artifact or a different device.

With a real APK path and connected device:

```bash
adb devices -l
adb install -r build/android/CastlevaniaReVamped-debug.apk
adb shell monkey -p com.lv4games.castlevaniarevamped 1
adb logcat -d | grep -E 'yoyo|GameMaker|AndroidRuntime|com.lv4games.castlevaniarevamped'
```

Acceptance criteria:

- `adb install` succeeds.
- The app launches without `AndroidRuntime` fatal exceptions.
- The title/file-select flow is reachable.
- External Android controller input drives movement, jump, attack, subweapon, dash, pause/menu, map, swap, and aimlock.
- If a controller is connected, fallback virtual controls are not drawn and are inactive.
- If no controller is connected, fallback touch controls can drive the same verbs.

## Release signing

Do not store keystores, passwords, Play signing credentials, or upload keys in this repo. If a signed release APK/AAB is required, use an approved secret-handling route outside git and document only redacted provenance in the Kanban closeout.

# Android APK Conversion Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task when parallel execution is safe. This GameMaker project uses a shared checkout, so code-mutating tasks should be serialized or run in explicit git worktrees.

**Goal:** Produce a side-loadable Android APK for `Castlevania ReVamped Open Source Edition` and verify it launches and is playable with an external Android controller. Touch controls are fallback-only and must disappear when a controller is connected.

**Architecture:** Keep the project as a GameMaker `.yyp` project and use GameMaker's Android export pipeline rather than porting the game engine. The repo work is Android target configuration, controller-first Android input behavior, fallback touch controls that auto-hide when a controller is connected, reproducible build documentation/scripts, and smoke-test evidence. The final APK build itself requires a licensed GameMaker runtime/CLI (`Igor`) plus Android SDK/JDK configuration.

**Tech Stack:** GameMaker 2024.6 project (`Castlevania ReVamped Open Source Edition.yyp`), GML, GameMaker Android target, Android SDK/ADB, Java/JDK 17+, Hermes Kanban for execution tracking.

---

## Current findings

- The project is a GameMaker project with `IDEVersion` `2024.6.2.162` in `Castlevania ReVamped Open Source Edition.yyp:189-191`.
- Android options already exist at `options/android/options_android.yy:1-80`, but they are mostly template defaults: display name `Created with GameMaker`, package `com.company.game`, all orientations enabled, SDK/build-tools fields empty, and unnecessary permissions enabled.
- The repo has a mature input library with touch/virtual button support (`scripts/input_virtual_create/input_virtual_create.gml:57-60`, `scripts/__input_class_virtual/__input_class_virtual.gml:188-228`).
- The game's actual control verbs are centralized in `scripts/controls/controls.gml:3-20`: `left`, `right`, `up`, `down`, `attack`, `jump`, `subweapon`, `dash`, `swap`, `aimlock`, `accept`, `cancel`, `pause`, `map`.
- The existing touch default profile in `scripts/__input_config_verbs/__input_config_verbs.gml:59-72` only maps movement plus `accept`, `cancel`, `action`, `special`, and `pause`; it does not map `attack`, `jump`, `subweapon`, `dash`, `swap`, `aimlock`, or `map`, so Android touch cannot be considered playable yet.
- Local build check on 2026-06-19: GameMaker Beta `Igor` was found at `~/.local/share/GameMakerStudio2-Beta/Cache/runtimes/runtime-2024.1400.4.968/bin/igor/linux/x64/Igor` and Android Studio's bundled JBR (`/opt/android-studio/jbr`, Java 21) satisfies the JDK 17+ requirement.
- The GameMaker-configured SDK at `/home/eran/AndroidSDK` has `platforms;android-35` and `build-tools;35.0.0`; `/opt/android-sdk` is present but not the correct SDK for this repo's Android 35 build.
- `tools/build-android-apk.sh` now performs preflight, invokes Igor, handles Igor's post-Gradle artifact-copy quirk, and copies generated APKs to `build/android/`.
- Verified build artifacts produced on 2026-06-19 after fixing startup to skip the open-source README room:
  - `build/android/CastlevaniaReVamped-debug.apk` (`1.1G`, SHA-256 `95b0a09bac4b3c6ffc1119dc98e807eb473c5debb33245862cf9023680ab0896`)
  - `build/android/CastlevaniaReVamped-release.apk` (`532M`, SHA-256 `6bbb1d9607919cedc713e1c1cdcce9f3833eb871c624161f6f400bf48447b254`)
- Static APK verification: package `com.lv4games.castlevaniarevamped`, app label `Castlevania ReVamped`, launchable activity `com.lv4games.castlevaniarevamped.RunnerActivity`, `minSdk=23`, `targetSdk=35`, native code `arm64-v8a`, optional touchscreen, Leanback launchable activity, `assets/game.droid`, `assets/options.ini`, and `lib/arm64-v8a/libyoyo.so` are present. `apksigner verify --verbose` reports v1/v2 signature verification true for the debug APK.
- Phone smoke on ASUS `ASUS_AI2302` passed: `adb install -r` returned `Success`, launch foregrounded `RunnerActivity`, logcat had no fatal exception/ANR, GameSir controller devices were detected, the player profile switched to `gamepad`, and screenshots show file select plus in-game play with no visible touch overlay while the controller is connected.

## Definition of Done

1. `options/android/options_android.yy` has release-appropriate app name, package id, SDK settings, orientation, texture page, and permissions.
2. Android gamepad support remains enabled and the gamepad profile covers every verb used by `scrControls()` and menus.
3. Fallback Android on-screen controls, if present, are deactivated and not drawn whenever `input_gamepad_is_any_connected()` reports a controller.
4. The game remains compatible with external Android gamepads.
5. A reproducible build runbook documents exact local prerequisites and `Igor`/IDE export steps.
6. A debug APK is built from this repo with GameMaker's Android target. **Done:** `build/android/CastlevaniaReVamped-debug.apk`.
7. The APK installs with `adb install` and reaches the title/file-select flow on a device or emulator. **Done:** passed on ASUS `ASUS_AI2302`.
8. A smoke test verifies movement, jump, attack, subweapon, dash, pause/menu, map, and orientation behavior. **Partially done:** ADB/controller-path confirm, gameplay entry, movement/jump/attack/pause keyevents, and no-crash checks passed; full human playability pass remains for subweapon/dash/swap/aimlock/map feel and fallback touch without controller.

## Task graph / Kanban lanes

### T1: Baseline Android target configuration

**Objective:** Replace template Android settings with project-specific, APK-ready defaults.

**Files:**
- Modify: `options/android/options_android.yy`

**Steps:**
1. Set display name to `Castlevania ReVamped`.
2. Set package identity to `com.lv4games.castlevaniarevamped` using GameMaker's split fields.
3. Use landscape-only orientation for a Castlevania-style platformer (`landscape=true`, `landscape_flipped=true`, portrait flags `false`).
4. Set explicit SDK values that match modern Android tooling (`minimum_sdk=23`, `compile_sdk=35`, `target_sdk=35`, build tools `35.0.0`) unless the installed GameMaker runtime rejects them.
5. Disable unused permissions (`internet`, `bluetooth`) unless testing proves an extension needs them.
6. Verify the `.yy` file remains in GameMaker's trailing-comma format and the diff only touches Android metadata.

**Verification:** Re-read `options/android/options_android.yy` and inspect the diff. Full compile verification waits for GameMaker CLI/IDE availability.

### T2: Repair the default touch profile

**Objective:** Ensure touch has bindings for all verbs used by gameplay and menus.

**Files:**
- Modify: `scripts/__input_config_verbs/__input_config_verbs.gml`
- Reference: `scripts/controls/controls.gml`

**Steps:**
1. Replace the placeholder `action`/`special` touch bindings with the real verb names.
2. Add virtual-button bindings for `jump`, `attack`, `subweapon`, `dash`, `swap`, `aimlock`, and `map`.
3. Preserve existing movement, accept, cancel, and pause bindings.
4. Verify that every verb in `scrControls()` has a touch profile entry.

**Verification:** Search `scrControls()` verbs against the touch profile entries. Full behavior verification waits for GameMaker runtime.

### T3: Add fallback Android on-screen controls that hide for controllers

**Objective:** Create GUI-space virtual controls only as a fallback, and automatically hide/deactivate them whenever an external controller is connected.

**Files:**
- Create or modify a project-owned script/object for mobile controls, likely under `scripts/` and an always-present controller object.
- Reference: `scripts/input_virtual_create/input_virtual_create.gml`
- Reference: `scripts/__input_class_virtual/__input_class_virtual.gml`

**Steps:**
1. Find the persistent controller object that exists in gameplay/menu rooms.
2. Add initialization that runs once on `os_android`.
3. Create a left-side d-pad/thumbstick mapped to `left`, `right`, `up`, `down`.
4. Create right-side buttons for `jump`, `attack`, `subweapon`, and `dash`.
5. Add smaller buttons for `pause`, `map`, `swap`, and optional `aimlock`.
6. Draw translucent GUI controls or use `input_virtual_debug_draw()` initially, then replace with nicer visuals if needed.
7. In the controller object's Step event, call `input_gamepad_is_any_connected()` after `__input_system_tick()` and call `.active(false)` on every fallback virtual control while any controller is connected.
8. Gate the Draw GUI event on the same hidden state so fallback controls disappear visually when a controller is plugged in.
9. Ensure controls scale from `display_get_gui_width()` / `display_get_gui_height()` instead of hard-coded room coordinates.

**Verification:** Build/run on Android and verify controller input works; then disconnect the controller and verify fallback touch controls appear. Reconnect the controller and verify fallback controls disappear and no longer capture touches.

### T4: Build environment runbook and helper

**Objective:** Make the APK build reproducible on this machine or another machine with GameMaker installed.

**Files:**
- Create: `docs/android-build.md`
- Optional create: `tools/build-android-apk.sh` or equivalent wrapper that checks prerequisites without storing secrets.

**Steps:**
1. Document required GameMaker version/runtime: project currently reports `2024.6.2.162`; use latest compatible GameMaker per README guidance.
2. Document JDK 17+ and Android SDK components required by GameMaker.
3. Document where GameMaker's `Igor` CLI is expected and how to pass a custom path.
4. Document debug APK and release APK/AAB flows separately.
5. Add a helper that fails clearly if `Igor`, JDK 17+, or Android SDK components are missing.

**Verification:** Run the helper locally and record the exact missing prerequisites. It should not fabricate an APK when GameMaker is absent.

### T5: First GameMaker Android compile

**Objective:** Build the first debug APK.

**Files:**
- No intended source changes unless compiler errors identify a source issue.

**Steps:**
1. Install/select JDK 17+ for Android tooling.
2. Make `Igor` available from the installed GameMaker runtime, or run the equivalent IDE Android export.
3. Configure Android SDK path in GameMaker if needed.
4. Build a debug APK.
5. Capture output path and compiler errors.
6. If compile errors are source-level, fix the minimal root cause and retry.

**Verification:** A real `.apk` file exists and `file <apk>` identifies it as an Android package/zip. Do not mark complete on documentation alone.

### T6: Device/emulator install and launch smoke

**Objective:** Prove the APK launches on Android.

**Files:**
- No source changes unless runtime crash logs identify a source issue.

**Steps:**
1. Start/connect an Android device or emulator visible to `adb devices`.
2. Install the APK with `adb install -r <apk>`.
3. Launch it by package name.
4. Capture `adb logcat` filtered for GameMaker/yoyo/AndroidRuntime.
5. Verify it reaches title/file-select without a crash.

**Verification:** `adb install` succeeds; launch logs show no fatal exception; screenshot/log evidence is saved or summarized.

### T7: Playability pass

**Objective:** Verify the Android build is actually playable with an external controller, not just launchable.

**Files:**
- Modify mobile control layout/input code as needed.

**Steps:**
1. Test external controller d-pad/thumbstick movement.
2. Test jump, attack, subweapon, dash, swap, aimlock, pause, and map.
3. Verify fallback touch controls disappear while the controller is connected.
4. Check landscape rotation and safe-area usability.
5. Tune fallback button sizes/positions and alpha only if controller-disconnected fallback is still desired.

**Verification:** A checklist records each verb as pass/fail. Remaining failures become follow-up tasks.

### T8: Release packaging closeout

**Objective:** Produce a final APK artifact and a short release note.

**Files:**
- Update: `docs/android-build.md` if build details changed.
- Optional update: `README.md` with a short Android build pointer.

**Steps:**
1. Decide debug vs signed release package requirements.
2. If release signing is requested, use approved secret-handling only; do not store keystores/passwords in the repo.
3. Build final APK/AAB.
4. Record APK path, package id, version, and verification results.
5. Leave generated build artifacts out of git unless explicitly requested.

**Verification:** Final artifact exists, installs, launches, and has documented provenance.

## Current external blockers

- Full human playability verification remains: confirm controller feel for all verbs (`subweapon`, `dash`, `swap`, `aimlock`, `map`) and verify touch fallback appears/works when the GameSir controller is disconnected.
- GameMaker's Android gamepad support injects Bluetooth permissions/features into the final manifest even when the explicit project permission toggles are disabled. This appears tied to controller support and should be validated on-device rather than removed blindly.

## Immediate execution order

1. Run hands-on playability on the connected phone/GameSir: movement, jump, attack, subweapon, dash, swap, aimlock, pause/menu, map.
2. Disconnect the GameSir controller and verify fallback touch controls appear and drive the same verbs.
3. Reconnect the controller and verify the fallback touch controls disappear/deactivate again.
4. Tune fallback control layout only if hands-on testing shows issues.

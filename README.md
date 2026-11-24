# Temple Run India

A premium **3D endless-runner game** built with the **Godot 4.7 engine**, exported as an **Android APK**.
The character sprints through Indian temple corridors — pillars, arches, gopurams, diyas and marigold banners — dodging obstacles, jumping gaps, sliding under beams and collecting coins.

## Features
- Full 3D endless runner with 3 lanes, jump, slide/roll, track gaps
- Procedurally generated temple track: pillars, arches, gopuram gates, diyas (glowing), banners, trees, hills, distant temples
- 5 playable characters (KayKit, CC0) with full animation sets (run, jump, dodge, death, cheer), unlockable with coins
- Coins, score = distance + coins, speed ramp, high score + persistent save
- Synthesized Indian-style music loop (raga melody + tanpura drone + tabla) and Kenney CC0 sound effects
- Premium look: golden-hour lighting, shadows, fog, sky, glow/bloom, particles, camera FOV kick, screen shake
- Menu with character select, HUD, pause, game-over screen
- Touch swipe controls + keyboard controls

## Controls
- **Left / Right** (arrow keys or swipe): switch lane
- **Up / Space / swipe up**: jump
- **Down / swipe down**: slide
- **Esc / P**: pause

## Build the APK
Requires Godot 4.7.2, JDK 17, Android SDK (platform 34, build-tools 34).

```bash
# debug-signed (no keystore needed)
godot --headless --path . --export-debug "Android" releases/temple-run-india.apk

# release-signed (keystore via env vars; path/user/password)
GODOT_ANDROID_KEYSTORE_RELEASE_PATH=/path/to.keystore \
GODOT_ANDROID_KEYSTORE_RELEASE_USER=alias \
GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=secret \
godot --headless --path . --export-release "Android" releases/temple-run-india.apk
```

Prebuilt APK (arm64-v8a, signed) is committed at `releases/temple-run-india.apk`.

## Run / test (headless smoke test)
```bash
godot --headless --path . --import
godot --headless --path . -- --smoke-test
```

## Project structure
```
project.godot            Godot project config
scenes/main.tscn         root scene
scripts/                 GDScript (main, track, player, props, hud, audio, save, characters)
assets/characters/       KayKit character GLBs + license
assets/models/           coin model (Kenney, CC0)
assets/audio/            SFX (Kenney, CC0) + synthesized music.wav
assets/textures/         generated textures
icons/                   launcher icons
export_presets.cfg       Android export preset (com.templerunindia)
releases/                built APK
PLAN.md                  plan, ASSETS.md asset sources/licenses
```

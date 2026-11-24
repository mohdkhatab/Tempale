# Temple Run India — Project Plan

Full 3D endless-runner game built in the **Godot engine**, exported as an **Android APK**.

## 1. Toolchain
- Godot 4.x editor (headless, Linux x86_64) + matching Android export templates
- JDK 17, Android SDK (platform 34, build-tools 34), Gradle (via Godot's android build template wrapper)
- Verification: headless smoke test + `aapt dump badging` on the APK

## 2. Assets (CC0, downloaded; sources + licenses in ASSETS.md)
- Characters: 3+ animated low-poly characters (Quaternius / Kenney KayKit, CC0)
- Textures: stone/brick/ground textures (ambientCG, CC0)
- Props: trees etc. (Kenney nature kit, CC0); temple architecture built procedurally from primitives
- Audio: coin / jump / slide / hit / UI sounds (Kenney audio, CC0)
- Music: CC0 loop (OpenGameArt)

## 3. Game design
- 3-lane endless runner, landscape, auto-running character
- Controls: left/right lane switch, jump, slide/roll (keyboard + touch swipe)
- Procedurally generated temple track: pillars, arches, gopuram gates, diyas, banners, side scenery
- Obstacles: low barrier (jump), lane pillar (switch), overhead beam (slide), track gap (jump)
- Coins (lines/arcs), score = distance + coins, speed ramps with distance
- Multiple playable characters, unlockable with coins, persisted save (user://)
- States: main menu (character select, high score) → playing (HUD) → pause → game over → restart
- Presentation: warm golden-hour lighting, shadows, fog, sky, glow, particles (coin sparkle, landing dust), camera FOV kick with speed, screen shake on hit
- Audio: looping music + SFX (coin, jump, slide, crash, UI)

## 4. Android export
- `export_presets.cfg` Android preset, package `com.templerunindia`, landscape, minSdk 24 / targetSdk 34
- Debug-signed APK → `releases/temple-run-india.apk` in this repo

## 5. Delivery
- Branch `vibe/temple-run-india-3381a2`, draft PR, APK committed under `releases/`
- Verification: `./godot --headless --smoke-test` run + `aapt dump badging releases/temple-run-india.apk`

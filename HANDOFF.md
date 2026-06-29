# Quadz / Lazurite — Work Handoff

_Living document. Keep it in sync after any non-trivial change so the next agent can pick up cleanly._

Last updated: 2026-06-28, after the FPV bug-fix run + first wave of feature work.

---

## 0. TL;DR — current status

- **Repo is in a clean, fully-pushed state.** Nothing half-implemented; no leftover temp/debug code; builds + dev-client-loads clean.
- Pinned commits: **parent `Cfretz244/LazuriteMC@main` = `406cba8`**, **Quadz `47005ec`**, **Corduroy `f02cce8`** (other submodules unchanged this session).
- **All 4 FPV bug fixes are confirmed in-world** by the tester. A first wave of features is shipped.
- **Three recently-pushed items still await hardware fly-test** (see §5).
- **Next work:** a single "rate/controls" batch (see §6).

---

## 1. What this project is

- **`LazuriteMC`** is the parent repo; it pins six submodules and builds the whole stack from source via `./build.sh` (bottom-up through mavenLocal).
- The headline mod is **Quadz**, an FPV quadcopter/drone mod (goggles + RC-controller flight) for **Minecraft 26.1.2 (Fabric)**.
- Submodules & roles: `Quadz` (the mod), `Rayon` (Bullet physics), `Corduroy` (camera/view system), `Form` (templated models), `Lazurite-Toolbox` (networking/math utils), `Transporter` (block-shape patterns).
- The port to current MC **26.1.2 is complete** (prior multi-checkpoint migration 1.20.1 → 1.21.x → 26.1.2). See `MIGRATION_STATE.md`.

## 2. Collaboration context & working agreement

- Two trusted people in the loop, both via a **Discord channel** (Claude Code Discord plugin): **owner `cfretz244`** and **tester `dronithologist`**.
- The **tester has the physical FPV controller**; the owner does not. So the tester exercises and confirms anything that needs real flight input.
- **Standing authorization:** build the features the tester requests and **push to the `Cfretz244` forks** so he can pull and re-test. Owner said "happy to implement whatever Dronithologist is interested in." Still: **surface anything large / risky / destructive before doing it.**
- **The agent runs mostly HEADLESS** — it cannot watch or drive the MC client GUI. Validation split:
  - Agent side: `./build.sh` (compile/package) + reading a **headless `runClient` log** (load/crash/mixin/resource errors). No visual confirmation.
  - Tester side: actual flight feel + visuals on real hardware.
- Loop: agent patches → proves it builds + loads clean → pushes → tester pulls/rebuilds/flies → reports → iterate.

## 3. Build / run / repos

**Toolchain:** JDK 25, Gradle 9.5 (wrapper), Loom. `JAVA_HOME` for raw gradle:
`/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home`

```sh
# Full stack build (sets JDK 25 itself); produces dist/ jars
./build.sh

# Headless load-check / dev client (raw gradle needs JAVA_HOME set explicitly —
# build.sh sets it internally, a bare ./gradlew does NOT and falls back to the
# macOS Java stub: "Unable to locate a Java Runtime")
cd Quadz && JAVA_HOME="/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home" ./gradlew runClient
```

**Remotes / what the tester pulls:** `.gitmodules` pins every submodule to **`https://github.com/Cfretz244/<repo>.git` branch `26.1.2`**; parent is `Cfretz244/LazuriteMC` `main`. Each submodule has a local `fork` remote (Cfretz244, SSH) and `origin` (LazuriteMC org). **Push submodule changes to `fork 26.1.2`, then bump the parent submodule pointer and push parent `origin main`.** The tester pulls with:
`git pull && git submodule update --init --recursive && ./build.sh`

**Runtime mods needed (not built here):** Fabric API, GeckoLib 5.5.1+ (from Modrinth), plus the two built jars `quadz-*.jar` and `rayon-fabric-*.jar`.

**Tester environment:** Windows 11, runs `./build.sh` via Git Bash; logs at `%APPDATA%\.minecraft\logs\` (launcher profile `fabric-loader-26.1.2`) or `Quadz\run\logs\` (dev client). Harmless log noise in dev/offline: Realms "SignedJWT: FabricMC" auth warnings; "Missing texture references in model quadz:item/quadcopter".

## 4. Work completed this session (with commit hashes)

### 4a. FPV bug-fix run — ALL CONFIRMED IN-WORLD by the tester
These four were a chain: each fix unblocked the next layer of the FPV path, which had never been exercised on 26.1 (no controller here). Common theme: the `CorduroyCamera` wrapper not mirroring vanilla camera state/lifecycle on 26.1's new render pipeline.

1. **F5-into-drone-view crash** — `Camera.getCameraEntityPartialTicks()` NPE (`this.level` null). `CorduroyCamera` copied the parent camera's `entity` but not `level`. Fix: copy `level` too. → **Corduroy `6067d1a`** / parent `424bf51`.
2. **FPV black screen** — `CorduroyCamera.tick()` overrode `Camera.tick()` without `super.tick()`, so `tickFov()` never ran → `fovModifier`=0 → `calculateFov()`=0 → degenerate zero-FOV projection (world/sky gone, only fullscreen fog drew). Fix: call `super.tick()`. → **Corduroy `ab4b49f`** / parent `5bd6dcc`.
3. **FPV orientation frozen (position tracked, rotation didn't)** — 26.1 caches the camera view-rotation matrix and only rebuilds when `matrixPropertiesDirty` is set; `CorduroyCamera` writes the rotation quaternion directly (to keep roll), bypassing the setter that trips the flag. Fix: set `this.matrixPropertiesDirty = -1` each frame after setting rotation (added access-widener for the field). → **Corduroy `f02cce8`** / parent `1f48a8a`.
4. **FPV post-effects wouldn't compile** (`vertex shader minecraft:post/blit was invalid`) — fisheye/static post-chain JSONs named `minecraft:post/blit` as the *vertex* shader, but in 26.1 that's fragment-only. Fix: use `minecraft:core/screenquad`. → **Quadz `f4f0a94`** / parent `7cbc2d4`.

(Diagnostic commits `d906eab`/`d48856f` in Corduroy and `b81c1fc`/`12ae51f` in parent were temporary logging, since reverted.)

### 4b. Features shipped
5. **HUD options** — split OSD into independent Speed Readout + Stick Overlay toggles (under master OSD) + stick-size slider; then tweaks: floor 15%, stick separation/bottom-margin proportional to size, position-dot size scales with size. → Quadz **`3de9f1b`**, `9e63604`, `b573df7`, `43b2355`.
6. **Rate profiles** — Betaflight / Actual / KISS selector; profile-aware field labels; synced to server as a `rate_profile` joystick "axis"; re-applied on config save (no relog). → Quadz **`d03f2fa`**. **Actual-rates bug fix** (was ×200-scaling the deg/s values → 180000°/s sensitivity → uncontrolled spin; now used as deg/s directly) → Quadz **`47005ec`**.
7. **Adjustable camera uptilt (FPV)** — rebindable Up/Down keybinds (default arrows, "Quadz" category) nudge the viewed drone's `CAMERA_ANGLE` ±1°/press, clamped 0–90, via `ADJUST_CAMERA_ANGLE` packet; synced/persistent per-drone; "Cam n°" OSD readout. → Quadz **`e49d338`** / parent `f73039f`.

## 5. Hardware playtest status

**PENDING FLY-TEST (pushed 2026-06-29):** Arming switch — controller axis binding + DISARMED OSD gate — Quadz **`d73b711`** / parent **`424e941`**. (1) **Controller arm switch**: bind an axis in the controller-setup screen (flip switch → assigns it, mirrors the gimbal axis-binding), plus an Invert button + a binding-status readout. **Direct switch** (not toggle): default "down" (negative axis) = armed, "up" = disarmed (tester wanted flick-up-to-disarm for safety muscle memory); `armInverted` flips for reversed-sign controllers. Switch is **authoritative when bound** — client pushes its state on a flip or on view entry (overriding auto-arm) via new `SET_ARMED` packet (sets a specific state; keyboard `ARM_DISARM` still toggles). Config: `armAxis` (-1=unbound) + `armInverted`, persisted+guarded. Tracking state in `ClientEventHooks` (`armSwitchArmed`, `prevViewing`) edge-detects flips/entry so it doesn't spam packets. (2) **"DISARMED" OSD warning now follows the master OSD toggle** (was always-shown). Builds + headless-loads clean; controller binding + switch feel need tester confirmation (can't drive a controller/GUI headlessly). _Assumes a bipolar (-1..+1) switch axis with threshold at 0; if his switch is unipolar (0..1) the threshold may need adjusting — flagged to tester._

**PENDING FLY-TEST (pushed 2026-06-29):** Arming switch (backlog §6.5), keyboard step — Quadz **`5027cee`** / parent **`5beb89b`**. Auto-arm stays default (drone arms on view ENTRY, tracked by a transient server-side `Quadcopter.wasViewed` so the toggle isn't overridden each tick); explicit override via rebindable keybind `ARM_DISARM` (default **R**, "Quadz" category) → new `ARM_DISARM` serverbound packet → `ServerNetworkEventHooks.onArmDisarm` toggles the viewed drone's `ARMED`. Disarmed cuts motors: `Quadcopter.tick` now gates rotation + angular correction + thrust on `isArmed()` (props already stop via the GeckoLib controller), so a disarmed drone falls/coasts on physics. Centered red **"DISARMED"** OSD warning (`OnScreenDisplay.renderDisarmed`, shown independent of OSD toggles). Builds + headless-loads clean; arm/disarm behavior + the indicator need tester confirmation. **Follow-up (planned):** map arm/disarm to a **controller button** — needs button-binding support in the controller-setup screen (currently axes only); the keyboard step established all the shared arm/disarm machinery + flight-gating, so the controller path just adds another input that sends the same packet.

**The entire rate/controls group (backlog §6.1–§6.3) is FLIGHT-CONFIRMED as of 2026-06-29** — tester signed off on per-profile values/defaults/live-relabel, the config-screen polish (TEST button + selector reset), per-axis "Link Axes", and both unlink-seeding refinements ("Looks great! Thanks!"). Nothing in the rate group outstanding. Remaining backlog: arming switch (§6.5), uptilt-persist (§6.6), adjustable FOV (§6.7), 3D mode (§6.8), throttle cap/expo (§6.9), throttle hover (§6.10).

**FLIGHT-CONFIRMED (2026-06-29):** Per-axis rates via "Link Axes" toggle (backlog §6.3) — Quadz **`3e702fd`** / parent **`cc3b204`**. New `linkAxes` toggle in Controller tab: on (default) = shared rate set for all axes (prior behavior); off = independent pitch/yaw/roll, still per-profile. Impl per the confirmed design — client `applyRateConfig` resolves link-vs-per-axis and pushes per-axis synced keys (`pitch_rate`/`pitch_super_rate`/`pitch_expo`, `yaw_*`, `roll_*`); `Quadcopter.tick` reads each axis's own keys (linked = all three equal). The old shared `rate`/`super_rate`/`expo` joystick keys are **replaced** by the per-axis ones (only `applyRateConfig` wrote + `tick` read them, verified). Config gains `linkAxes` + 9 per-axis arrays (indexed by profile ordinal, defaulting to the per-profile defaults so unlinking starts neutral), persisted + guarded on load (backward-compatible: old `quadz.json` → linkAxes true + default per-axis = identical feel). Config screen gates linked vs per-axis field sets via combined display requirement `Requirement.all(isValue(profileEntry, profile), isTrue/isFalse(linkEntry))`. Builds + headless-loads clean; per-axis flight feel + the link/profile field-swap need tester confirmation. **Follow-up shipped (`94cf659` / parent `f7b1874`):** per tester request, unlinking now **seeds each axis from the current (shared) values** instead of defaults. Implemented by keeping per-axis arrays mirrored to shared whenever linked — `Config.mirrorPerAxisFromShared()` runs on save + on load while `linkAxes` is true (load-time mirror also seeds older per-axis-less configs); skipped while unlinked so per-axis edits persist. **Refined (`adb0587` / parent `dd8c2e3`):** per tester, seeding now uses the *current* shared values (incl. same-session edits), not last-saved. The config screen's saving runnable captures `wasLinked` at open and, on a linked→unlinked transition, calls `mirrorPerAxisFromShared()` after the field save-consumers have run (so `Config.rates` holds the on-screen values). Cloth closes the screen on save, so per-axis fields show the seeded values on reopen. (No live widget update mid-session — cloth exposes no per-entry value-change listener; the save-time transition seed + screen-close-on-save covers the real flow.)

**FLIGHT-CONFIRMED (2026-06-29):** Config-screen polish on the rate batch — Quadz **`df352d6`** / parent **`f83270d`**. Two tester-reported warts: (1) removed the leftover debug **"TEST" button** (was at `MainConfigScreen` bottom; floated over the screen doing nothing — the §0 "no debug code" claim had missed it); (2) the **rate-profile selector's reset arrow** reverted the profile *choice* to Betaflight, which read as a bug — dropped the selector's default value so its per-entry reset is now inert (cloth has no `requireNonNull` on the builder default, confirmed via bytecode, so omitting is safe). Per-profile value fields keep their own reset arrows. **Open question to tester:** whether the per-field reset arrows suffice or he wants a custom one-click "reset this profile's values" button (cloth reset is per-field only; one-click needs a custom widget — `FloatListEntry` has `getValue`, `TextFieldListEntry` has `setValue(String)`, so it's feasible but more involved). Builds clean; config-screen interaction needs tester eyes (can't drive GUI headlessly).

**FLIGHT-CONFIRMED (2026-06-29):** Per-profile rate values + defaults + live relabel (backlog §6.1+§6.2) — Quadz **`27a21e1`** / parent **`3365297`**. Each profile (Betaflight/Actual/KISS) now keeps its own rate/superRate/expo (Config arrays `rates`/`superRates`/`expos` indexed by `RateProfile.ordinal()`; `Config.rate()/superRate()/expo()` resolve the active profile for sync). Tester-chosen defaults: **Betaflight 1.0/0.7/0.0, Actual 70/670/0 (deg/s), KISS 1.0/0.7/0**. Config save/load uses arrays now and migrates legacy single-value `quadz.json` into the active profile's slot. Config screen adds all 3 profiles' field sets but gates each via a cloth **display requirement** (`Requirement.isValue(profileEntry, profile)`) keyed off the profile selector → picking a profile instantly swaps labels AND values, no reopen. Per-field reset arrows restore that profile's firmware default. Builds + headless-loads clean; the live label/value swap is a config-screen interaction I can't drive headlessly, so **needs tester confirmation**. _Cloth API confirmed available in 26.1.154: `setDisplayRequirement` on the FieldBuilder base; `Requirement.isValue(ValueHolder<T>, T, T...)`; built entries implement `ValueHolder` (so pass the built enum entry directly)._

**FLIGHT-CONFIRMED (2026-06-28):** Singleplayer template-loss-on-world-reload bug — Form **`b1f5471`** / parent **`3560c03`**. Tester reproduced it live and confirmed the fix ("your fix got it all sorted out") across repeated reload cycles. Tester hit it after an exit-to-menu → reload-world cycle: placed drone invisible + all 3 quad items gone from the creative menu (goggles/remote survived). Root cause (pre-existing, unrelated to the OSD work): `TemplateLoader.TEMPLATES` is a static map shared by the client + integrated server in singleplayer; the join/post-login template sync feeds our own templates back via `Template#serialize` (which writes `originDistance + 1` per hop), AND `load()` looked up `TEMPLATES.get(id)` with a String against an `Identifier`-keyed map (always-miss → always-overwrite). So self-copies bumped every local template above origin 0, then `clearRemoteTemplates()` on disconnect deleted them all → empty table → invisible drones + missing items; a full game restart masked it. Fix in `Form/.../api/loader/TemplateLoader.java` `load()`: look up by Identifier key, keep the closest-origin copy, never let a farther copy overwrite a closer one. Builds + headless-loads clean (3 templates load at init); the world-reload sync path can't be exercised headless, so **needs tester confirmation** that quads survive repeated reloads without a game restart. _If it recurs, next suspects: the `originDistance < 2` filter in `getItemStackFor`, or the sync still bumping somewhere._

**FLIGHT-CONFIRMED (2026-06-28):** Camera-angle readout rework — Quadz **`c467520`** / parent **`07ba51e`**. Dropped the "Cam" prefix (now just `45°`), gave the readout its own toggle (`cameraAngleDisplayEnabled`, under master OSD with speed/sticks), and when not showing persistently it flashes briefly (~2s, fading over the last ~0.6s) while the uptilt is being adjusted via the up/down keybinds. Implemented via a static tick-counter flash timer in `OnScreenDisplay` (`flashCameraAngle`/`tickFlash`/`isCameraAngleFlashing`), driven from `ClientEventHooks.onClientTick`. Tester confirmed "looks great." Follow-up per his request: the adjust-flash is now **ungated from the master OSD switch** (pops even with the whole OSD off); only the *persistent* readout respects master-OSD + its own toggle. Both built + headless-load clean.

**As of 2026-06-28 21:45 UTC the tester confirmed "everything from the last push works great."** That covers the Actual-rates fix (`47005ec`) and the stick position-dot scaling (`43b2355`), on top of the previously-confirmed entire FPV stack (crash/black/orientation/post-fx), camera uptilt, Betaflight rates, and HUD toggles + proportional sizing.

**Everything shipped this session is flight-confirmed** — including **KISS** (tester flew it with 2.55/0.49/0 ≈ 1000°/s; "feels similar to my rates, just without the fully linear feeling" — the expected progression from KISS's Rate term). No outstanding unverified work.

**Known caveat (not a bug):** rate-curve *shapes* are authentic (ported from Betaflight firmware) but absolute *magnitudes* may need a pilot tuning pass. The three profiles currently SHARE one value triple, so good ranges differ per profile (Betaflight ~1–3 RC-rate; Actual ~hundreds of deg/s). Per-profile remembered values + defaults is planned (§6.2) to remove that footgun.

## 6. Planned work / backlog

Nothing requested has been declined. Order (agreed with tester); the next build is intended as one **rate/controls batch** covering the top items so they land together:

1. ~~**Live relabel** of the rate fields the instant a profile is selected.~~ **DONE (`27a21e1`, pending fly-test)** — solved via cloth display requirements (show all 3 profiles' field sets, gate each by `Requirement.isValue(profileEntry, profile)`); labels+values swap instantly.
2. ~~**Per-profile remembered values + sensible defaults.**~~ **DONE (`27a21e1`, pending fly-test)** — per-profile Config arrays + tester-chosen defaults; landed together with #1. See §5.
3. ~~**Per-axis rates** — independent pitch/yaw/roll via "Link Axes" toggle.~~ **DONE (`3e702fd`, pending fly-test)** — implemented exactly as the confirmed design (client resolves link-vs-per-axis → per-axis synced keys; server tick stays agnostic). See §5.
4. **Rate-curve graph** on the config screen — plot the selected curve(s), **pitch/yaw/roll in 3 colors**, updating as you tune. Custom widget via GuiGraphics. Pairs with #2/#3.
5. ~~**Arming switch** — explicit arm/disarm override (keyboard + controller).~~ **DONE (`d73b711`, pending fly-test)** — keyboard toggle (`5027cee`) + controller axis switch with direct/invert (`d73b711`). See §5.
6. **Uptilt persists past pickup** — currently the adjusted `CAMERA_ANGLE` lives on the placed entity and resets to the template default when picked up & re-placed (`ServerEventHooks` sets it from the template on placement). Store it on the drone item (data component) and restore on placement.
7. **Adjustable FPV FOV** — let the user set the drone-camera FOV to mimic real FPV cams. **RANGE CONFIRMED 90–160°.** Vanilla clamps FOV ~110, so this needs a hook/mixin to override + exceed the clamp while a quadcopter view is active.
8. **3D flight mode** (toggle) — props reverse below throttle center: center stick = 0 thrust, up = normal, down = reverse (inverted flight). Change `Quadcopter.tick` thrust to bidirectional around center + a synced toggle; pairs with throttle-center work. (small–medium)
9. **Throttle cap + throttle expo** (stretch).
10. **Tunable throttle hover/midpoint value** — user-set hover point to compensate for quad weight. Tester marked **low priority**. Note: a `Config.throttleInCenter` mode already exists and is honored at input read (`JoystickOutput.getAxisValue` via `ClientEventHooks`), but has **no config-screen toggle** yet — expose it as part of this.

## 7. Key code locations (Quadz unless noted)

- **Config (client):** `client/Config.java` — fields + `save()` + `load()`. **NOTE: `load()` has no null-guards on legacy keys; guard every NEW field with `config.has(...)` or old `quadz.json` files NPE on load.**
- **Config screen:** `client/render/screen/MainConfigScreen.java` — cloth `ConfigBuilder`; `setTooltip`/`setTextGetter`/`startIntSlider`/`startEnumSelector` all work. Saving runnable also re-applies rate config (no relog).
- **Flight / physics:** `common/entity/Quadcopter.java` — `tick()` reads synced joystick "axes" (pitch/yaw/roll/throttle/rate/super_rate/expo/rate_profile), computes rates, applies via `rotate(x,y,z)` (which multiplies a delta-rotation into the rigid body transform = degrees rotated this tick). Thrust math also here.
- **Rate math:** `common/util/RateProfile.java` (enum + per-profile curve math; calls `BetaflightHelper`), `common/util/BetaflightHelper.java`.
- **OSD / HUD:** `client/render/screen/osd/OnScreenDisplay.java` (velocity, sticks, cam-angle readout) + `client/render/QuadcopterView.java` `onGuiRender` (gated by `Config.osdEnabled` + per-element toggles). Registered as a HUD element in `client/QuadzClient.java`.
- **Camera/view system:** `Corduroy` — `impl/CorduroyCamera.java` (the vanilla-Camera subclass swapped into `gameRenderer.mainCamera`), `impl/ViewStackImpl.java`, `api/View.java`; access wideners in `Corduroy/src/main/resources/corduroy.accessWidener`.
- **Networking:** `Quadz.Networking` (packet IDs) + registration in `Quadz.onInitialize`; serverbound handlers in `common/hooks/ServerNetworkEventHooks.java`; client sends via `ClientNetworking.send`. Player "joystick value" sync: `common/hooks/PlayerHooks.java` (+ `PlayerMixin`/`PlayerExtension`) — values broadcast via `JOYSTICK_INPUT`.
- **Keybinds:** registered in `client/QuadzClient.java` via `KeyMappingHelper.registerKeyMapping`; handled in `client/event/ClientEventHooks.onClientTick` (drain `consumeClick`, send packet when in FPV).
- **Lang:** `Quadz/src/main/resources/assets/quadz/lang/en_us.json`.
- **Post-effect shaders:** `assets/quadz/post_effect/{fisheye,static}.json` + `assets/quadz/shaders/post/*.fsh`.
- **Drone templates** (per-drone stats incl. `cameraAngle`, `thrust`, mass, etc.): `assets/quadz/templates/<id>/<id>.settings.json` (voxel_racer_one cameraAngle=45, voyager=20, pixel=5). `CAMERA_ANGLE` set from template in `common/hooks/ServerEventHooks.java`.

## 8. 26.1 API gotchas learned (likely relevant to future work)

- `Camera`: `level` set only via `setLevel`; `getCameraEntityPartialTicks()` derefs `this.level`; `tick()`→`tickFov()` sets `fovModifier`; view-rotation matrices are cached behind `matrixPropertiesDirty` (a bitmask; set to `-1` to force rebuild). Several `Camera` fields are access-widened by Corduroy.
- Keybinds: `KeyMapping.Category` is now a typed record (`Category.register(Identifier)`, label key `key.category.<ns>.<path>`); registration via **`fabric-key-mapping-api-v1`** `net.fabricmc.fabric.api.client.keymapping.v1.KeyMappingHelper` (the old `fabric-key-binding-api-v1` `KeyBindingHelper` package is gone).
- Post chains: full-screen vertex shader is `minecraft:core/screenquad`; `minecraft:post/blit` exists only as a fragment shader. Sampler-size UBO `SamplerInfo { vec2 OutSize, InSize; }` is auto-provided.
- Fabric module on classpath = `fabric-key-mapping-api-v1` (not `-key-binding-`).

## 9. Validation checklist before pushing (agent, headless)

1. `./build.sh` → exit 0 (compiles + packages all six repos).
2. For changes touching mixins/access-wideners/resources/keybind+category registration: headless `runClient`, confirm it reaches "Sound engine started" with no `Exception`/`Mixin`/`AccessWidener`/lang-parse errors (ignore Realms/JWT noise). Pure arithmetic/logic changes can skip this.
3. Push submodule → `fork 26.1.2`; bump parent pointer → `origin main`.
4. Tell the tester to pull/rebuild/fly; record what's confirmed vs pending here in §5.
5. **Remove any temporary diagnostic code before considering a feature done**, and keep this doc + the memory files in sync.

---

_Agent memory mirrors of this state live under the project memory dir: `quadz-feature-backlog.md`, `quadz-fpv-debug-progress.md`, `friend-debug-collab.md`._

# Lazurite / Quadz — Migration State & Handoff

**Last updated:** 2026-06-10 (CP3)
**Current target:** Minecraft **26.1.2** (current stable), Fabric-only — *builds and runs in-world;
maintainer-verified live ("it works!"), zero crashes.* **THE MIGRATION IS COMPLETE.**
**Migration approach:** deliberate checkpoints — **CP1 (→1.21.1), CP2a (→1.21.4), CP2b (→1.21.8),
CP3 (→26.1.2) — ALL DONE.** Remaining future work: 26.2 (lands ~June 16 2026, expected small), Lattice (§6).
Plan used: `~/.claude/plans/please-read-migration-state-md-to-resilient-manatee.md`.

> ## CP3 (1.21.8 → 26.1.2) — DONE 2026-06-10, committed on `26.1.2` branches, pushed to forks
> The toolchain hop, plus more vanilla churn than expected. Maintainer-verified live (creative tab,
> goggles equip, drones, FPV).
>
> **Toolchain (all six repos):** JDK **25** (`openjdk@25`; `~/.gradle/gradle.properties`
> `org.gradle.java.home` repointed), Gradle wrapper **9.5.0** (loom 1.17.8 requires ≥9.5),
> plugin **`net.fabricmc.fabric-loom` 1.17.8**, **no `mappings` block** (26.1 ships unobfuscated;
> Yarn/Parchment dead), `modImplementation`→plain `implementation`, `remapJar` gone (plain `jar`),
> `archivesBaseName`→`base { archivesName }`. Loader 0.19.3, Fabric API **0.151.0+26.1.2**,
> GeckoLib **5.5.1 for 26.1.2 via Modrinth maven** (`maven.modrinth:geckolib:gXL7ILee` — NOT on
> Cloudsmith; package base RENAMED `software.bernie.geckolib`→**`com.geckolib`**), Cloth 26.1.154.
> Dead `lazurite.dev` repo removed everywhere (DNS failure poisoned resolution).
> **Toolbox/Transporter/Rayon flattened** from architectury common/fabric splits to single-module
> fabric-loom (`@ExpectPlatform` shims inlined; artifactIds still `*-fabric`). Sodium compat
> DELETED entirely (no more renderer-driven capture). corduroy-example excluded from build.
> **Access wideners:** header namespace `named`→**`official`**; loom injected interfaces re-keyed
> from intermediary (`net/minecraft/class_*`) to official class names. fabric.mod.json dep id
> `fabric`→`fabric-api`.
> **Vanilla 26.1 churn:** `ResourceLocation`→`Identifier` sweep; `PayloadTypeRegistry.playC2S/S2C`→
> `serverboundPlay/clientboundPlay`; vehicle package splits (`vehicle.boat.Boat`); `Level.isClientSide()`
> method; `Entity.interact` gained hit `Vec3`; `displayClientMessage`→`sendOverlayMessage`;
> `getServer()`→`level().getServer()`; GpuBuffer sizes are `long`; SplashManager splashes = immutable
> `List<Component>` (replace, don't addAll). **GUI is extraction-based:** `GuiGraphics`→
> **`GuiGraphicsExtractor`** (drawString→`text`, drawCenteredString→`centeredText`,
> renderFakeItem→`fakeItem`), `Screen.render`→`extractRenderState`, `Toast.render`→
> `extractRenderState(extractor, Font, long)`, Gui mixin targets `extractCrosshair`/
> `extractHotbarAndDecorations`. **Camera rework:** `setup()`→`update(DeltaTracker)`→private
> `alignWithEntity(F)` — made `extendable` via AW and overridden in CorduroyCamera (same quaternion
> conventions); `tickFov` gone → FOV freeze via `AbstractClientPlayer.getFieldOfViewModifier` HEAD;
> `bobView/bobHurt` take `(CameraRenderState, PoseStack)`; `renderItemInHand`
> `(CameraRenderState, float, Matrix4fc)`; `MouseHandler.onPress`→`onButton(long, MouseButtonInfo, int)`.
> **Entity sync:** `ServerEntity.sendChanges` dispatches via `ServerEntity$Synchronizer` — Rayon's
> fragile Consumer-ordinal redirects replaced by ONE packet-type filter redirect
> (`sendToTrackingPlayers`, suppress Move/SetEntityMotion packets for physics elements). **Debug
> rendering is gizmo-based:** `DebugRenderer.emitGizmos` + `net.minecraft.gizmos.Gizmos.line(Vec3,Vec3,argb)`
> in world space — Toolbox BEFORE_DEBUG re-anchored (event now `(Camera, ClientLevel, float)`),
> Rayon collision debugger rewritten without PoseStack/BufferSource. **Entity rendering submit-based:**
> GeoEntityRenderer `render(...)`→`submit(state, PoseStack, SubmitNodeCollector, CameraRenderState)`;
> GL5.5 hooks: `addRenderData(T,O,R,float partialTick)`, `addAdditionalStateData(T,Object,R)`,
> `createBaseRenderState`→`createRenderState(T,Void)`; armor provider `(ItemStack, EquipmentSlot)`;
> AnimationControllers need a name. **Form template injection rebuilt on `GeckoLibGsonLoader`**
> (bakes from the template JsonObjects; Gson type adapters gone) + `BakedModelCache/BakedAnimationCache`
> record swap (static fields `MODELS`/`ANIMATIONS` on `GeckoLibResources`). **GeckoLib 26.1 scans
> `assets/<ns>/geckolib/{models,animations}`** — NOT `geo/`+`animations/` (symptom: "Loaded 0 models",
> invisible equipped armor, blank items). `FabricItemGroup`→`FabricCreativeModeTab`,
> `ItemGroupEvents`→`CreativeModeTabEvents.modifyOutputEvent` (`FabricCreativeModeTabOutput`),
> `FabricEntityTypeBuilder`→`FabricEntityType.Builder.createLiving(factory, category, cfg)`;
> `PacketUtils.ensureRunningOnSameThread` takes a `PacketProcessor`; `handleDebugKeys(KeyEvent)`;
> `debugFeedbackTranslated` is varargs again; `Camera.getEntity()` gone (AW the field).
> **Commits:** Toolbox 581c445, Transporter 522f4c0, Rayon 2e09645, Form 6cc9fe8, Corduroy 047364c,
> Quadz a467a71 + 08ca177 (GeckoLib asset dirs).

> ## CP2b (1.21.4 → 1.21.8) — DONE 2026-06-10, committed on `1.21.8` branches, pushed to forks
> The render hop: absorbed 1.21.5 (RenderPipeline/GpuDevice, post-effect redesign, item-class purge)
> and 1.21.6 (deferred GUI, ValueInput/ValueOutput). Pins: arch-loom **1.11.456** / fabric-loom
> **1.11.8** / Gradle **8.14.3** (leaf repos; arch repos stay 8.12), fabric-api **0.136.1+1.21.8**,
> loader **0.19.3**, **GeckoLib 5.2.2** (5.5.x is 26.1-only — CP3 carries a 5.2→5.5 minor drift),
> Sodium **mc1.21.8-0.7.3** (Transporter API unchanged), Cloth **19.0.147**, Parchment **2025.09.14**
> (its practical cap — CP3 is mojmap-native). **Satin is gone.**
> Commits: Toolbox `5e67673`, Transporter `e7886d0`, Rayon `8301b77`, Form `32f7d65`,
> Corduroy `40eb9ca`, Quadz `80afd94`.
>
> **Headlines (full detail in commit messages):**
> - **FPV camera orientation FIXED (the deferred-since-CP1 item), with zero render mixins:** since
>   1.21 the view matrix is `M(conj(camera.rotation()))`, so `CorduroyCamera.setup()` just stores the
>   View quaternion with vanilla conventions (forwards = q*(0,0,−1), up = q*(0,1,0), left = q*(−1,0,0);
>   xRot/yRot floats derived from the look vector for sound/debug). Roll comes free. All `require=0`
>   mulPose redirects + Quadz RenderHooks quaternion hooks deleted. The old `rotateY(180)` term in
>   `QuadcopterView.getRotation` self-corrects under the new convention (verified algebraically + live).
> - **Satin → vanilla post effects:** chains in `assets/quadz/post_effect/*.json` (1.21.5+ format:
>   `vertex_shader`/`fragment_shader`, named std140 uniform blocks; program JSON configs no longer
>   exist), GLSL on `texCoord` + `layout(std140)` blocks. Per-frame uniforms via
>   `PostEffects` (Quadz): swap each pass's baked immutable UBO for a writable `GpuBuffer`
>   (PostChain/PostPass accessors), write with `Std140Builder` + `CommandEncoder.writeToBuffer`,
>   `chain.process(mainTarget, UNPOOLED)` from `GameRenderer.render` after `doEntityOutline`
>   (vanilla's own post-chain point — OSD stays sharp on top).
> - **GeckoLib 5:** models resolve from a `GeoRenderState` (DataTicket carries the Form template:
>   entity → `addAdditionalStateData`, item stack → `TemplatedItemRenderer.addRenderData`); Form
>   defines `TemplatedEntityRenderState` implementing GeoRenderState explicitly — **must override
>   `getOrDefaultGeckolibData` too** (GeckoLib's runtime mixin merges a concrete copy reading its own,
>   empty map → NPE otherwise). Quadz renderer carries physics rotation/offset through DataTickets;
>   `AnimationController` ctors lost the animatable arg; `GeckoLibCache`→`GeckoLibResources` (same
>   reflection hack); armor provider is render-state-based and returns the `GeoArmorRenderer`.
> - **HUD:** OSD on Fabric `HudElementRegistry.addLast` (Quadz GuiMixin deleted —
>   `renderExperienceBar` no longer exists); Corduroy GuiMixin targets survive verbatim.
> - **1.21.6 ValueIO:** entity save data via `ValueInput`/`ValueOutput` (Quadcopter + Rayon
>   EntityMixin; compound sub-tags via `CompoundTag.CODEC` keep the on-disk format).
> - **Misc:** `ArmorItem` gone → `Properties.humanoidArmor`; Rayon debug renderer on
>   `RenderType.lines()` via the debug-pass BufferSource; hitbox suppression moved into
>   `extractRenderState` (hitboxes live on the render state now); runtime drone textures need
>   `TextureManager.registerAndLoad` (plain `register` no longer loads contents);
>   `ClientInput.moveVector`; `absMoveTo`→`absSnapTo`; NBT getters return Optionals.

> ## CP2a (1.21.1 → 1.21.4) — DONE 2026-06-10, committed on `1.21.4` branches, pushed to forks
> Pins: fabric-api **0.119.4+1.21.4**, GeckoLib **4.8.2**, Cloth **17.0.144**, Sodium
> **mc1.21.4-0.6.13**, **Satin 3.0.0-alpha.1** (2.0.0 hard-crashes at 1.21.4), Parchment
> **2025.03.23**; JDK 21 / Gradle 8.12 / loom 1.10 unchanged.
> Commits: Toolbox `c9eca26`, Transporter `9e45f2e`, Rayon `dee3dd2`, Form `15c38d0`,
> Corduroy `00b41d0`, Quadz `8332493`.
>
> **What 1.21.2–1.21.4 actually broke (highlights, full detail in commit messages):**
> - **EntityRenderState everywhere:** renderers get a state, not the entity (GeckoLib keeps the live
>   entity in its `animatable` field, assigned in createRenderState); Rayon's shadow fix moved to an
>   `extractRenderState` TAIL (renderShadow reads state.x/y/z now); EntityRenderDispatcher.render
>   lost its yRot float.
> - **Items:** `Properties.setId(ResourceKey)` mandatory; item model definitions required at
>   `assets/<ns>/items/<id>.json` (drone uses `minecraft:special` + `geckolib:geckolib`;
>   `builtin/entity` model parent is gone); `InteractionResultHolder` folded into
>   `InteractionResult`; SwordItem-style classes + ArmorItem.Type → `equipment.ArmorType`.
> - **Entities:** `hurt()` split into `hurtServer/hurtClient`; `kill(ServerLevel)`;
>   `spawnAtLocation(ServerLevel,…)`; `EntityType.create(Level, EntitySpawnReason)`; entity-type
>   builders need the registry key; `Entity.noCulling` → renderer `affectedByCulling`.
> - **Mixin targets:** `Explosion` became an interface (Rayon now redirects `Entity.push(Vec3)` in
>   `ServerExplosion.hurtEntities`); `ServerEntity.sendChanges` Consumer.accept ordinals shifted
>   (+1 after ordinal 1, a projectile-bundle branch was inserted); `BlockStateBase.updateShape`
>   reordered; `ClientLevel.<init>` lost the profiler Supplier, gained an int; the
>   `DebugRenderer.render` call site moved into a frame-graph lambda (Toolbox now mixes into
>   `DebugRenderer.render` HEAD instead); `TextureManager.loadTexture` → `loadContentsSafe`;
>   `Minecraft.profiler` → `Profiler.get()`; `KeyboardInput` extends `ClientInput` (Input record).
> - **Post-effects moved at 1.21.2, not 1.21.5 as planned:** chains live in
>   `assets/<ns>/post_effect/<id>.json` (new targets/passes format, ids are bare like
>   `quadz:static`), programs in `shaders/post/<id>.json`, sampler `DiffuseSampler` → `InSampler`.
>   Satin 3.0.0-alpha.1 just delegates to vanilla ShaderManager.
> - **GeckoLib 4.8:** GeoModel lookups gained a GeoRenderer param; armor provider signature gained
>   `EquipmentClientInfo.LayerType` (GeckoLib preps the renderer itself); item rendering goes
>   through `GeckolibSpecialRenderer` (Form's ItemRenderer mixin deleted; the stack now arrives in
>   `TemplatedItemRenderer.render`); **GeoItemRenderer's ctor needs a live ModelManager → Form
>   constructs item renderers lazily on first use.**
>
> **Interactive verification (creative tab items/spawn/bind/FPV/save-reload) — maintainer-side;
> client ran ~5 min interactively with zero errors logged.**

---

## 1. TL;DR of where things stand

The whole Quadz FPV-drone stack now **builds from source** on the 1.21.1 toolchain band, wires through
**mavenLocal**, and **runs in a Minecraft 1.21.1 Fabric dev client**. Verified live: all 6 mods load,
every mixin applies, drone GeoModels load (Form/GeckoLib 4.7), Rayon physics threads run, a world loads,
the player joins, networking + autosave work — zero crashes. Interactive play confirmed working by the
maintainer (creative tab, spawn drone, bind → FPV).

This was reached by porting through the three seismic 1.20.2/1.20.5/1.21 vanilla changes
(networking rewrite, item data-components, render-pipeline signature changes) plus the GeckoLib 4.3→4.7
and Sodium 0.5→0.6 dependency jumps.

- **Forge remains dropped** (Fabric-only).
- **Lattice remains excluded** (deferred — see §6).
- Prior **1.20.1** state is preserved on the `1.20.1` branches (history of how we got here).
- One render detail is intentionally deferred to CP2b (FPV camera *orientation*, §6).

---

## 2. Build & toolchain setup (1.21.1 band — reproduce from scratch)

**JDK:** use the Homebrew **formula** `openjdk@21` (keg-only). The 1.20.1 work used `openjdk@17`; the
band moved **up** to Java 21 (Loom + MC 1.21.1 require it).

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
```

> ⚠️ `JAVA_HOME` **must be exported for every `./gradlew` call** (the launcher needs it).
> `~/.gradle/gradle.properties` `org.gradle.java.home` was repointed to JDK 21 (covers the daemon only).

**Pinned toolchain band (1.21.1) — mutually compatible; the band had to move UP, not down:**

| Thing | Version | Why |
|---|---|---|
| JDK | **openjdk@21** | MC 1.21.1 / Loom require Java 21 |
| Gradle (wrapper) | **8.12** | arch-loom 1.10 calls `ProjectDependency.getPath()` → needs Gradle ≥8.11 |
| architectury-loom (Toolbox/Transporter/Rayon) | **1.10.455** | 1.21.1 deps were built with Loom **1.8.9**; arch-loom 1.7.x *refuses* to consume them. (no arch-loom 1.8/1.9 exists; 1.10.x is the next that's ≥1.8.9) |
| fabric-loom (Form/Corduroy/Quadz) | **1.10-SNAPSHOT** | same reason |
| architectury-plugin | 3.4-SNAPSHOT (→3.4.164) | unchanged |
| Fabric Loader | `0.16.10` | 1.21.1 line |
| Fabric API | `0.116.4+1.21.1` | 1.21.1 line |
| GeckoLib | `geckolib-fabric-1.21.1:4.7.7` (Cloudsmith) | 4.3.1 → 4.7.7 is a real API jump (§4) |
| Cloth Config | `me.shedaniel.cloth:cloth-config-fabric:15.0.140` | 15.x = 1.21.1 |
| Sodium | `maven.modrinth:sodium:mc1.21.1-0.6.13-fabric` | 0.5→0.6 dropped `VertexFormatDescription` (§4) |
| Satin | `org.ladysnake:satin:2.0.0` | targets MC 1.21 (only option; not stamped for 1.21.1 — runs, shaders unverified on the new pipeline) |
| Parchment | `org.parchmentmc.data:parchment-1.21.1:2024.11.17` | 1.21.1 mappings (Quadz only) |
| libbulletjme | `17.4.0` (unchanged) | MC-independent physics native |

> **Note:** Toolbox actually still builds at arch-loom **1.7.435 / Gradle 8.8** (it has no Sodium dep,
> so it never hits the Loom-1.8.9 wall) and was left there; everything downstream is 1.10.455 / 8.12.
> A 1.10 consumer reading a 1.7-built mod is fine (older-loom output is consumable).

**Build order (each `./gradlew build publishToMavenLocal`; Quadz is the app → `runClient`):**

```
Lazurite-Toolbox  →  Transporter  →  Rayon  →  Form, Corduroy  →  Quadz
```

**mavenLocal artifacts (`~/.m2/repository/dev/lazurite/`):**
`toolbox-common/-fabric 1.4.0+1.21.1`, `transporter-common/-fabric 1.4.0+1.21.1`,
`rayon-common/-fabric 1.7.2+1.21.1`, `form 1.0.7`, `corduroy 1.0.9`.

**Run the client:**
```bash
cd Quadz && JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home ./gradlew runClient
```

---

## 3. Repos, branches, commits, remotes

The original `LazuriteMC/*` GitHub repos are **archived (read-only)** — cannot push there. CP1 commits
were pushed to **forks under `Cfretz244`** (added as a `fork` remote in each repo; archived `origin` left intact).

| Repo | Branch | Commit | Pushed to | Role |
|---|---|---|---|---|
| Lazurite-Toolbox | `1.21.1` | `745fd2c` | `Cfretz244/Lazurite-Toolbox` | shared util lib (networking, events, math) |
| Transporter | `1.21.1` | `ac66b74` | `Cfretz244/Transporter` | client→server vertex/mesh "pattern buffer" (Sodium compat) |
| Rayon | `1.21.1` | `7667573` | `Cfretz244/Rayon` | rigid-body physics (libbulletjme) |
| Form | `1.21.1` | `5b54683` | `Cfretz244/Form` | multi-model GeckoLib + drone template loader |
| Corduroy | `1.21.1` | `412545a` | `Cfretz244/Corduroy` | camera / `View` / `ViewStack` (FPV camera) |
| Quadz | `1.21.1` | `446ab76` | `Cfretz244/Quadz` | the app — FPV drones |
| **Lattice** | *(untouched)* | `main`@`7053dba` (1.19.1) | — | chunk loading around camera — **DEFERRED, see §6** |

> The CP1 `1.21.1` branches were created off the prior `1.20.1` branches (Transporter off `1.20.1-arch`).

---

## 4. Fixes applied in CP1 (1.20.1 → 1.21.1) — *the "what kind of work" signal for CP2a/CP2b*

Deep technical detail (every file/symbol) lives in memory `lazurite-1211-checkpoint.md`. Summary by class:

### A. Toolchain / build wiring
- Whole band moved up (§2). Burned `Quadz/.gradle/loom-cache` + `~/.gradle/caches/modules-2/.../dev.lazurite/*`
  repeatedly (stale-cache trap, §D).
- Added **fabric-api to Toolbox `common`** + a client entrypoint (needed for the new networking API).
- Sodium repointed to `mc1.21.1-0.6.13-fabric`; repos given explicit mavenCentral/Fabric/Architectury maven.

### B. Networking rewrite (1.20.5) — Toolbox foundation
- Replaced the old `ClientboundCustomPayloadPacket(ResourceLocation, FriendlyByteBuf)` + `handleCustomPayload`
  mixins with **one generic `LazuritePayload(ResourceLocation, byte[])`** record + passthrough `StreamCodec`,
  registered via Fabric `PayloadTypeRegistry`, dispatched by inner id through global receivers.
- **Public buf-lambda API preserved** (`PacketRegistry`/`Client/ServerNetworking`) → the 11 packet call
  sites across Rayon/Quadz/Transporter/Form were untouched. Deleted the two packet-listener mixins.

### C. Item data-components (1.20.5)
- `bind_id` (Quadz `QuadzComponents`) and `template` (Form `FormComponents`) registered as
  `DataComponentType` with `.persistent(...).networkSynchronized(...)`. The two wrapper classes
  (`BindableItemWrapper`, `TemplatedItemWrapper`) drop the live `CompoundTag` and use
  `stack.set/getOrDefault` (components are immutable). Get/set signatures unchanged → callers untouched.

### D. Render pipeline — *landed partly at 1.21.0, earlier than the plan assumed*
- `GameRenderer.renderLevel`/`LevelRenderer.renderLevel` lost `PoseStack`, now take **`DeltaTracker`**
  (+ two `Matrix4f`). `Gui.render`/`renderCrosshair` and `renderHotbar`→`renderHotbarAndDecorations` take
  `DeltaTracker`; `renderItemInHand(Camera,float,Matrix4f)`. **All these mixin signatures were adapted.**
- **The camera-orientation injections** (Corduroy/Quadz `mulPose` into the now-absent `PoseStack`,
  ordinals 2/3) have no target anymore → made **`require=0`/no-op**. FPV camera *position* follows via
  `CorduroyCamera.setup()`; the precise *screen-orientation* correction is **deferred to CP2b** (§6).

### E. Other vanilla 1.21 API churn (compile + runtime)
- `new ResourceLocation(a,b)` → `ResourceLocation.fromNamespaceAndPath`.
- `EntityDimensions` is a record (`.width()/.height()`, `EntityDimensions.fixed(w,h)`).
- `Entity.defineSynchedData(SynchedEntityData.Builder)` + `builder.define(...)`.
- `PlayerList.placeNewPlayer` gained `CommonListenerCookie`; old injection point removed → JOIN event
  retargeted to `@At("TAIL")`.
- `EntityRenderDispatcher.renderHitbox` gained r/g/b floats; `ClientLevel.addPlayer`→`addEntity(Entity)`;
  `ClientPacketListener.minecraft` moved to superclass (use `Minecraft.getInstance()`).
- GUI/screen: `PackResources.location()`, `ImageButton`→`Button.builder`, toast `TEXTURE`→`blitSprite`,
  `Screen.renderDirtBackground` removed.
- **Sodium 0.6** (Transporter): `VertexFormatDescription` removed → `VertexBufferWriter.push(...,VertexFormat)`;
  `QuadConsumer` reworked from `extends BufferBuilder` to `implements VertexConsumer`
  (`addVertex`/`setColor`, no `endVertex`).
- **BufferBuilder/Tesselator** (Rayon debug renderer): `Tesselator.begin(mode,fmt)` +
  `BufferUploader.drawWithShader(builder.build())`; `vertex().color().endVertex()`→`addVertex().setColor()`.

### F. GeckoLib 4.3 → 4.7 (Form + Quadz)
- Package flattening (`core.animation.*`→`animation.*`, `core.animatable.instance.*`→`animatable.instance.*`,
  `core.object.PlayState`→`animation.PlayState`); `RenderProvider`→`GeoRenderProvider`.
- Items override **`createGeoRenderer(Consumer<GeoRenderProvider>)`** (drop `makeRenderer`/`getRenderProvider`);
  armor uses `getGeoArmorRenderer`, items use `getGeoItemRenderer`. `GeckoLib.initialize()` gone (self-init).
- `JsonUtil.GEO_GSON`→`KeyFramesAdapter.GEO_GSON`; `GeckoLibException`→plain RuntimeException.
- **Runtime-template gotcha:** `GeckoLibCache.getBakedModels()/getBakedAnimations()` are now **immutable**.
  Form injects runtime drone templates, so `TemplateResourceLoader.ensureMutableCaches()` reflectively
  swaps `MODELS`/`ANIMATIONS` to mutable `HashMap`s before `put` (Form's reload listener runs *after*
  GeckoLib's, since Form depends on geckolib).

---

## 5. How to verify it's working
1. `./gradlew runClient` → reaches a world (a dev `New World` auto-loads); log shows
   `Goggles down, thumbs up!`, `Starting … Physics Thread`, `Loading <drone> template…`, no crash.
2. Creative menu → **Quadz** tab → Goggles, Remote, Pixel, Voyager, Voxel Racer 1.
3. Hold a drone, **right-click ground** → spawns a Rayon physics body (tumbles/settles).
4. Hold **Remote**, right-click drone → binds; right-click open air → **FPV view** (Corduroy camera +
   Satin + OSD). Left-click exits.
5. **Save + reload world → bind survives** (proves the data-component `.persistent()`).

---

## 6. Known limitations / NOT done
- **FPV camera *orientation* deferred to CP2b.** The 1.21 render-pipeline change removed the `PoseStack`
  the camera-rotation mixins relied on; those injections are `require=0`/no-op for now. Camera *position*
  tracks the drone via `CorduroyCamera.setup()`. If FPV orientation looks off at range/extreme angles,
  this is why — it's re-expressed against the `Matrix4f` pipeline in the CP2b render sub-gate.
- **Satin shaders unverified on the new pipeline.** Satin 2.0.0 (MC 1.21) loads, but the fisheye/static
  post-effects haven't been validated against 1.21.1's renderer. CP2b plans to reimplement them on
  vanilla `PostChain` if needed (the "must preserve" decision).
- **Lattice** (chunk loading around the drone camera) is still **excluded** — ~42 mixin points into
  `ChunkMap`/`LevelRenderer`, abandoned mid-1.19.3-port. Without it, drones can't fly beyond loaded chunks.
- **Forge** removed entirely (Fabric-only).
- **Flying requires a game controller** (no keyboard flight). **Mod Menu not in dev runtime**, so the
  controller-setup screen is unreachable in dev (it compiles; its UI was ported to 1.21 anyway).

---

## 7. Gotchas carried forward
- **Stale-loom-cache trap (bites every same-version rebuild):** Form (`1.0.7`) and Corduroy (`1.0.9`) keep
  the same version string across the hop — after rebuilding either, purge `Quadz/.gradle/loom-cache` **and**
  `~/.gradle/caches/modules-2/files-2.1/dev.lazurite/{form,corduroy}` before re-running Quadz. Toolbox/
  Transporter/Rayon carry `+1.21.1` in their version so they're naturally distinct.
- `JAVA_HOME` export requirement (§2). No system JDK; used `openjdk@21` *formula*.
- `defaultRequire: 1` is set in the mixin configs — a mis-targeted mixin crashes **loudly at load**, which
  is exactly how the CP1 runtime fixes were driven (run client → read crash → fix one → repeat).

---

## 8. Path to current modern Minecraft (CP2a → CP2b)

Three-checkpoint plan (full text: `~/.claude/plans/please-read-migration-state-md-in-breezy-conway.md`):

- **CP1 — 1.20.1 → 1.21.1 — ✅ DONE** (this document).
- **CP2a — 1.21.1 → 1.21.4** — consolidation; render model still classic-ish. Expect: 1.21.2 networking-
  context drift, Sodium sub-version re-check, mixin ordinal re-verification, Cloth screen API drift.
- **CP2b — 1.21.4 → current** — the hard hop, internally sub-gated: (1) GeckoLib 4→5; (2) **Satin** on
  vanilla `PostChain`; (3) **render/camera re-expression** against the `RenderPipeline`/`Matrix4f` model
  (this is where the deferred FPV-orientation work + the `require=0` injections get properly redone);
  (4) HUD `PoseStack`→`Matrix3x2fStack` (1.21.8). Mojmap-only past Parchment's 1.21.8 cap.

**Method that worked for CP1 (use again):** move the toolchain band up first, port bottom-up
(Toolbox → … → Quadz), and let `runClient` crashes drive the runtime mixin fixes — most breakage only
shows at runtime, not compile, and `defaultRequire: 1` makes it crash loud.

---

## 9. Reference artifacts
- **Memory:** `~/.claude/.../memory/lazurite-1211-checkpoint.md` (CP1 deep detail) and
  `lazurite-1201-port.md` (the prior 1.20.1 port).
- **Plan:** `~/.claude/plans/please-read-migration-state-md-in-breezy-conway.md`.
- **Last build/run logs:** `/tmp/{toolbox,transporter,rayon,corduroy,form,quadz}-build.log`,
  `/tmp/quadz-runclient.log`.
- **Repo dependency graph:** Quadz → {Rayon → (Transporter, Toolbox); Form → Toolbox; Corduroy}.
  (Lattice → Toolbox, deferred.)

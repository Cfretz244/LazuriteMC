# LazuriteMC — Quadz FPV drone stack for Minecraft 26.1.2

Parent repository pinning the whole [Lazurite](https://github.com/LazuriteMC) FPV-drone mod stack
(maintained on these forks; the upstream org is archived) as submodules, each on its `26.1.2`
branch, plus a from-scratch build script.

| Submodule | What it is |
|---|---|
| `Lazurite-Toolbox` | Shared events / networking / math |
| `Transporter` | Block-pattern buffer (collision shapes → physics) |
| `Rayon` | Rigid-body physics (LibBulletJme) |
| `Form` | Runtime GeckoLib template loader (drone models) |
| `Corduroy` | Camera / ViewStack (FPV view) |
| `Quadz` | The FPV drone mod itself |

Dependency graph: `Quadz → { Rayon → (Transporter, Toolbox); Form → Toolbox; Corduroy }`.
`Lattice` is not part of the build (deferred; not ported past 1.20.1).

## Building

Requires JDK 25 (everything else is fetched by Gradle):

```sh
git clone --recurse-submodules https://github.com/Cfretz244/LazuriteMC.git
cd LazuriteMC
./build.sh
```

This builds every repo bottom-up through `mavenLocal` and drops the two installable jars into
`dist/`:

- `quadz-<version>.jar` — nests Form, Corduroy, and Cloth Config
- `rayon-fabric-<version>.jar` — nests Toolbox, Transporter, and LibBulletJme

Put both in your `mods/` folder along with [Fabric API](https://modrinth.com/mod/fabric-api) and
[GeckoLib](https://modrinth.com/mod/geckolib) 5.5.1+ for 26.1.2.

To run a dev client instead: `cd Quadz && ./gradlew runClient` (after `./build.sh`, so the
mavenLocal dependencies exist).

## Migration history

The stack was ported 1.20.1 → 26.1.2 in checkpoints (1.21.1 → 1.21.4 → 1.21.8 → 26.1.2), each a
branch in every submodule. `MIGRATION_STATE.md` is the canonical record of every API migration,
pin, and gotcha along the way.

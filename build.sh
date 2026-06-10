#!/usr/bin/env bash
#
# From-scratch build of the entire Quadz/Lazurite stack for Minecraft 26.1.2.
#
# Builds every repo bottom-up through mavenLocal and collects the two jars you
# actually install into dist/:
#   - quadz-<version>.jar  (nests Form, Corduroy, Cloth Config)
#   - rayon-fabric-<version>.jar  (nests Toolbox, Transporter, LibBulletJme)
# Runtime deps installed separately (Modrinth): Fabric API, GeckoLib 5.5.1+.
#
# Usage: ./build.sh [--clean]
#   --clean   also run `gradlew clean` in every repo first
set -euo pipefail
cd "$(dirname "$0")"

# --- JDK 25 ------------------------------------------------------------------
find_jdk25() {
    if [[ -n "${JAVA_HOME:-}" ]] && "$JAVA_HOME/bin/java" -version 2>&1 | grep -q 'version "25'; then
        return 0
    fi
    local brew_jdk="/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home"
    if [[ -x "$brew_jdk/bin/java" ]]; then
        export JAVA_HOME="$brew_jdk"
        return 0
    fi
    if [[ "$(uname)" == "Darwin" ]] && JAVA_HOME=$(/usr/libexec/java_home -v 25 2>/dev/null); then
        export JAVA_HOME
        return 0
    fi
    echo "error: JDK 25 not found. Install it (e.g. 'brew install openjdk@25') or set JAVA_HOME." >&2
    exit 1
}
find_jdk25
echo "Using JAVA_HOME=$JAVA_HOME"

# --- sources -----------------------------------------------------------------
git submodule update --init

# Build order follows the dependency graph:
#   Quadz -> { Rayon -> (Transporter, Toolbox); Form -> Toolbox; Corduroy }
REPOS=(Lazurite-Toolbox Transporter Rayon Form Corduroy Quadz)

CLEAN=0
[[ "${1:-}" == "--clean" ]] && CLEAN=1

# Form/Corduroy keep stable version strings across rebuilds, so stale copies in
# the Gradle module cache and Quadz's loom cache shadow fresh mavenLocal
# publishes. Purge both before building.
rm -rf ~/.gradle/caches/modules-2/files-2.1/dev.lazurite Quadz/.gradle/loom-cache

for repo in "${REPOS[@]}"; do
    echo
    echo "=== $repo ==="
    if [[ $CLEAN -eq 1 ]]; then
        (cd "$repo" && ./gradlew clean --console=plain -q)
    fi
    (cd "$repo" && ./gradlew build publishToMavenLocal --console=plain -q)
done

# --- collect artifacts ---------------------------------------------------------
mkdir -p dist
rm -f dist/*.jar
# pick the main jars (skip -sources/-dev/-all variants)
find Quadz/build/libs -name 'quadz-*.jar' ! -name '*-sources*' ! -name '*-dev*' -exec cp {} dist/ \;
find Rayon/build/libs -name 'rayon-fabric-*.jar' ! -name '*-sources*' ! -name '*-dev*' -exec cp {} dist/ \;

echo
echo "Done. Install these into your mods/ folder (plus Fabric API and GeckoLib 5.5.1+ from Modrinth):"
ls -l dist/

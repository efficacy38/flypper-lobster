#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_root="$repo_root/build"
lobster_src="$build_root/lobster-src"
release_root="$build_root/release"

rm -rf "$lobster_src" "$release_root"
mkdir -p "$build_root" "$release_root"

if [[ -z "${LOBSTER_SRC:-}" ]]; then
  printf '%s\n' "LOBSTER_SRC is not set. Run this script through 'nix develop -c just prod'." >&2
  exit 1
fi

lobster_src_path="$LOBSTER_SRC"
cp -R "$lobster_src_path" "$lobster_src"
chmod -R u+w "$lobster_src"

mkdir -p "$lobster_src/projects/flypper_lobster"
cp -R "$repo_root/src" "$repo_root/assets" "$lobster_src/projects/flypper_lobster/"

cd "$lobster_src"

cd dev
cmake -DCMAKE_BUILD_TYPE=Release .
make -j"${NIX_BUILD_CORES:-2}"
cd ..

bin/lobster --pak projects/flypper_lobster/src/main.lobster
mkdir -p dev/compiled_lobster/src
touch dev/compiled_lobster/src/compiled_lobster.cpp
bin/lobster --cpp projects/flypper_lobster/src/main.lobster

cd "$lobster_src/dev"
cmake -DLOBSTER_TOCPP=ON -DCMAKE_BUILD_TYPE=Release .
make -j"${NIX_BUILD_CORES:-2}"

mkdir -p "$release_root/package"
cp "$lobster_src/bin/compiled_lobster" "$release_root/package/flypper-lobster"
cp "$lobster_src/projects/flypper_lobster/src/default.lpak" "$release_root/package/default.lpak"
cp "$repo_root/assets/audio/AUTHORS.md" "$release_root/package/AUDIO_AUTHORS.md"

tar -C "$release_root/package" -czf "$release_root/flypper-lobster-linux-x86_64.tar.gz" .
printf '%s\n' "$release_root/flypper-lobster-linux-x86_64.tar.gz"

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]
export XDG_CACHE_HOME := env_var_or_default("XDG_CACHE_HOME", "/tmp/flypper-lobster-nix-cache")

dev:
    nix develop -c lobster src/main.lobster

dev-test:
    nix develop -c lobster tests/game_model_tests.lobster

dev-smoke:
    nix develop -c lobster --non-interactive-test src/main.lobster

dev-check:
    nix develop -c lobster tests/game_model_tests.lobster
    nix develop -c lobster --non-interactive-test src/main.lobster

prod:
    nix develop -c bash tools/build_prod.sh

prod-smoke: prod
    cd build/release/package && timeout 10s ./flypper-lobster --non-interactive-test

check: dev-check

audio:
    nix develop -c perl tools/make_audio_assets.pl

run: dev

test: dev-test

smoke: dev-smoke

build-release: prod

run-prod:
    cd build/release/package && ./flypper-lobster

run-dev:
    nix develop -c lobster src/main.lobster

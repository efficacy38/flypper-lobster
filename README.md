# Flypper Lobster

Flypper Lobster is a Flappy Bird style arcade game written in the Lobster programming language.

## Build Modes

Enter the Nix development shell:

```sh
nix develop
```

Development mode uses the Lobster interpreter directly:

```sh
just dev
```

Production mode compiles the game through Lobster `--cpp` and writes a release tarball:

```sh
just prod
```

The production artifact is written to `build/release/flypper-lobster-linux-x86_64.tar.gz`.

## Verification

Run the logic tests through the interpreter:

```sh
just dev-test
```

Run the one-frame graphical smoke test through the interpreter:

```sh
just dev-smoke
```

Run the development checks:

```sh
just dev-check
```

Build and smoke-test the compiled package:

```sh
just prod-smoke
```

Compatibility aliases remain available: `just run`, `just test`, `just smoke`, and `just build-release`.

`flake.nix` only defines the development shell. The production command builds inside that shell.

The release package contains:

- `flypper-lobster`: native Linux x86_64 executable generated through Lobster `--cpp`
- `default.lpak`: Lobster pakfile containing bytecode, shaders, and game assets
- `AUDIO_AUTHORS.md`: audio attribution

## Controls

- `Space` or left mouse button: flap / start / restart
- `Escape`: quit

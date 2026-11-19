# ps2homebrew docker images

Build environments for PS2 homebrew, published to the GitHub Container Registry by
[docker-publish.yml](.github/workflows/docker-publish.yml). Both images are `linux/amd64`.

| Image | Toolchain | Host tools |
|---|---|---|
| `ghcr.io/ps2homebrew/ps2homebrew:main` | current [ps2dev](https://github.com/ps2dev/ps2dev) (`ghcr.io/ps2dev/ps2dev:latest`): EE/IOP gcc 15, ps2sdk, ps2sdk-ports, gsKit, ps2-packer; ps2sdk sources in `$PS2SDKSRC` | build-base, cmake, git, zip, gawk, python3 + pip + PyYAML, bash, p7zip, cdrkit |
| `ghcr.io/ps2homebrew/ps2homebrew:v1.0` | legacy ps2dev v1.0 (`ghcr.io/ps2dev/ps2dev:v1.0`): EE gcc 3.2.3, ps2sdk of 2021 | make, git, zip, bash |

Use `:v1.0` only for projects that do not build with the current SDK
(for example Simple Media System).

```sh
docker run --rm -v "$PWD":/src -w /src ghcr.io/ps2homebrew/ps2homebrew:main make
```

In GitHub Actions: `container: ghcr.io/ps2homebrew/ps2homebrew:main`.

## Updates

* `:main` is rebuilt on every push to `main` and on the `run_build` repository dispatch,
  which is sent when ps2dev publishes a new toolchain. After a successful build the
  workflow dispatches `run_build` to some ps2homebrew projects.
* `:v1.0` is rebuilt by the same workflow (its base never changes, so the result is the same).
* Pull requests only build the images.

## Size

The toolchain tree is copied from a slimming stage ([slim_ps2dev.sh](slim_ps2dev.sh)): no
documentation, no PS2-side programs from `ps2sdk/ports/bin`, no `*-lto-dump`/`*-gdb`, and no
debug info in the static libraries that are not LTO. Programs built with it are byte-identical
to builds made in the full ps2dev images.

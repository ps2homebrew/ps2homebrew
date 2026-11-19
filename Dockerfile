# ghcr.io/ps2homebrew/ps2homebrew:main
# Current ps2dev toolchain (ghcr.io/ps2dev/ps2dev:latest: EE/IOP/DVP toolchains, ps2sdk,
# ps2sdk-ports, gsKit, ps2-packer) plus the host tools PS2 homebrew builds commonly need.
# The toolchain tree is copied from a slimming stage (slim_ps2dev.sh): no docs, no PS2-side
# programs from ps2sdk/ports/bin, no *-lto-dump/*-gdb, no debug info in non-LTO libraries.

FROM ghcr.io/ps2dev/ps2dev:latest AS source
COPY slim_ps2dev.sh /tmp/
RUN sh /tmp/slim_ps2dev.sh

FROM alpine:latest

# gmp, mpc1, mpfr4: runtime libraries of the cross gcc.
# safe.directory: sources mounted from the host (-v, actions checkout) are owned by another uid.
RUN apk add --no-cache \
    build-base \
    cmake \
    git \
    zip \
    gawk \
    python3 \
    py3-pip \
    bash \
    p7zip \
    py3-yaml \
    cdrkit \
    gmp \
    mpc1 \
    mpfr4 \
 && git config --system --add safe.directory '*'

COPY --from=source /usr/local/ps2dev /usr/local/ps2dev

ENV PS2DEV=/usr/local/ps2dev
ENV PS2SDK=$PS2DEV/ps2sdk
ENV GSKIT=$PS2DEV/gsKit
ENV PATH=$PATH:$PS2DEV/bin:$PS2DEV/ee/bin:$PS2DEV/iop/bin:$PS2DEV/dvp/bin:$PS2SDK/bin

ENV PS2SDKSRC=/usr/local/ps2sdk
RUN git clone https://github.com/ps2dev/ps2sdk.git $PS2SDKSRC --depth 1

RUN mips64r5900el-ps2-elf-gcc --version && mipsel-none-elf-gcc --version && cmake --version

FROM ghcr.io/ps2dev/ps2dev:latest

RUN apk add build-base git zip gawk python3 py3-pip bash p7zip py3-yaml cdrkit
ENV PS2SDKSRC /usr/local/ps2sdk
RUN git clone https://github.com/ps2dev/ps2sdk /usr/local/ps2sdk/ --depth 1


FROM ghcr.io/ps2dev/ps2dev:latest AS source

FROM alpine:latest


RUN apk add --no-cache \
    build-base \
    git \
    zip \
    gawk \
    python3 \
    py3-pip \
    bash \
    p7zip \
    py3-yaml \
    cdrkit

COPY --from=source /usr/local/ps2dev /usr/local/ps2dev

ENV PS2DEV=/usr/local/ps2dev
ENV PS2SDK=$PS2DEV/ps2sdk
ENV GSKIT=$PS2DEV/gsKit
ENV PATH=$PATH:$PS2DEV/bin:$PS2DEV/ee/bin:$PS2DEV/iop/bin:$PS2DEV/dvp/bin:$PS2SDK/bin

ENV PS2SDKSRC=/usr/local/ps2sdk
RUN git clone https://github.com/ps2dev/ps2sdk.git $PS2SDKSRC --depth 1

RUN mips64r5900el-ps2-elf-gcc --version

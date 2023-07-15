FROM ghcr.io/ps2dev/ps2dev:latest

RUN apk add build-base git zip gawk python3 py3-pip bash p7zip && \
    pip3 install PyYAML
ENV PS2SDKSRC /usr/local/ps2sdk
RUN git clone https://github.com/ps2dev/ps2sdk /usr/local/ps2sdk/ --depth 1

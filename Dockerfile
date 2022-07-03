FROM ps2dev/ps2dev:latest

RUN apk add build-base git zip gawk python3 py3-pip bash && \
    pip3 install PyYAML

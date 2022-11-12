FROM debian:bullseye-slim

ARG TOOLS_DIR=/tools

RUN apt-get update && \
    apt-get install -y curl unzip git build-essential

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get install -y python3 openscad nodejs

## MicroPython toolchain
RUN mkdir -p "${TOOLS_DIR}" && \
    cd "${TOOLS_DIR}" && \
    git clone https://github.com/micropython/micropython.git && \
    cd "${TOOLS_DIR}/micropython/ports/rp2" && \
    make submodules && \
    cd "${TOOLS_DIR}/micropython/mpy-cross" && \
    make && \
    cp build/mpy-cross /bin

RUN mpy-cross --version

## Rust toolchain
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --quiet --profile minimal --no-modify-path
ENV PATH=${PATH}:/root/.cargo/bin
RUN rustup --version

## Node
RUN node --version
RUN corepack enable
RUN yarn --version

## Openscad
RUN openscad --version

USER 999

FROM debian:bullseye-slim

ARG TOOLS_DIR=/tools

RUN apt-get update && \
    apt-get install -y curl unzip git build-essential

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get install -y python3 openscad nodejs

#USER 999

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
ARG RUST_DIR="${TOOLS_DIR}/rust"
RUN mkdir -p "${RUST_DIR}"
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --quiet --profile minimal --no-modify-path
RUN cd /root && cp -r .cargo/ "${RUST_DIR}/" && cp -r .rustup/ "${RUST_DIR}/"
RUN rm -r /root/.cargo && /root/.rustup
#ENV PATH=${PATH}:/root/.cargo/bin
ENV PATH="${PATH}:${RUST_DIR}/.cargo/bin"
#RUN cd /root/.cargo/bin && chmod a+x *
RUN ls -all "${RUST_DIR}"
RUN ls -all "${RUST_DIR}/.cargo"
RUN ls -all "${RUST_DIR}/.rustup"
ENV CARGO_HOME="${RUST_DIR}/.cargo"
ENV RUSTUP_HOME="${RUST_DIR}/.rustup"
RUN rustup --version

## Node
RUN node --version
RUN corepack enable
RUN yarn --version

## Openscad
RUN openscad --version



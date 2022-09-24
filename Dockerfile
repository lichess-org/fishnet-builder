FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y make curl git-core musl-tools

COPY sde-external-9.0.0-2021-11-07-lin /opt/sde-external-9.0.0-2021-11-07-lin
COPY x86_64-linux-musl-native /opt/x86_64-linux-musl-native
COPY config.toml /usr/local/cargo/config.toml

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    SDE_PATH=/opt/sde-external-9.0.0-2021-11-07-lin/sde64 \
    CXX=/opt/x86_64-linux-musl-native/bin/x86_64-linux-musl-g++ \
    STRIP=/opt/x86_64-linux-musl-native/bin/strip \
    LDFLAGS=-static

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal --default-toolchain 1.64 --target x86_64-unknown-linux-musl

RUN cargo install cargo-auditable

FROM --platform=linux/amd64 docker.io/alpine:3 AS fishnet-builder-amd64
WORKDIR /fishnet
COPY sgerrand.rsa.pub /etc/apk/keys/sgerrand.rsa.pub
COPY glibc-2.35-r1.apk /opt/glibc.apk
COPY glibc-bin-2.35-r1.apk /opt/glibc-bin.apk
COPY sde-external-9.21.1-2023-04-24-lin /opt/sde-external
COPY config-amd64.toml /usr/local/cargo/config.toml
RUN apk --no-cache add git make curl g++ rustup /opt/glibc.apk /opt/glibc-bin.apk; \
    rm /opt/glibc.apk /opt/glibc-bin.apk
ENV CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
RUN rustup-init -y --no-modify-path --profile minimal --default-toolchain stable --target x86_64-unknown-linux-musl
RUN cargo install cargo-auditable
RUN ln -s /opt/sde-external/misc/ /usr/glibc-compat/lib/; \
    ln -s /opt/sde-external/intel64/ /usr/glibc-compat/lib/
ENV LDFLAGS=-static \
    SDE_PATH="/usr/glibc-compat/lib/ld-linux-x86-64.so.2 /opt/sde-external/sde64"

FROM --platform=linux/arm64 docker.io/alpine:3 AS fishnet-builder-arm64
WORKDIR /fishnet
COPY config-arm64.toml /usr/local/cargo/config.toml
RUN apk --no-cache add git make curl g++ rustup
ENV CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
RUN rustup-init -y --no-modify-path --profile minimal --default-toolchain stable --target aarch64-unknown-linux-musl
RUN cargo install cargo-auditable
ENV LDFLAGS=-static

ARG TARGETARCH
FROM fishnet-builder-${TARGETARCH}

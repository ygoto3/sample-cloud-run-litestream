FROM --platform=$BUILDPLATFORM rust:1.79-bullseye as builder

# -----------------------------
# Prepare the environment for building the application
# -----------------------------
RUN apt update -y && \
    apt install python3-pip sqlite3 -y && \
    pip3 install cargo-zigbuild && \
    cargo install sea-orm-cli

ARG TARGETPLATFORM

RUN case "$TARGETPLATFORM" in \
    "linux/arm64") \
        apt install gcc-aarch64-linux-gnu -y && \
        echo aarch64-unknown-linux-musl > /rust_target.txt && \
        echo aarch64-linux-gnu-strip > /strip_target.txt && \
        echo linux-arm64 > /litestream_target.txt ;; \
    "linux/amd64") \
        apt install gcc-x86-64-linux-gnu -y && \
        echo x86_64-unknown-linux-musl > /rust_target.txt && \
        echo x86_64-linux-gnu-strip > /strip_target.txt && \
        echo linux-amd64 > /litestream_target.txt ;; \
    *) exit 1 ;; \
    esac

RUN rustup target add $(cat /rust_target.txt) && \
    rustup component add rustfmt

WORKDIR /work

# -----------------------------
# Install dependencies and cache them
# -----------------------------
COPY Cargo.toml Cargo.lock ./
RUN mkdir -p src
RUN echo "fn main() {println!(\"if you see this, the build broke\")}" > src/main.rs
RUN cargo zigbuild --release --target $(cat /rust_target.txt)
RUN rm -f target/$(cat /rust_target.txt)/release/deps/sample_cloud_run_litestream*

# -----------------------------
# Build the actual application
# -----------------------------
COPY . .
RUN ./init-dev.sh
RUN cargo zigbuild --release --target $(cat /rust_target.txt)
RUN $(cat /strip_target.txt) target/$(cat /rust_target.txt)/release/sample-cloud-run-litestream -o /work/app

RUN curl -SL https://github.com/benbjohnson/litestream/releases/download/v0.3.9/litestream-v0.3.9-$(cat /litestream_target.txt)-static.tar.gz \
    | tar -xzC /usr/local/bin

# -----------------------------
# Now, we build the final image
# -----------------------------
FROM alpine:3.20.1

WORKDIR /

ENV IP_ADDRESS=0.0.0.0
ENV DATABASE_URL=sqlite:/app/db.sqlite

COPY --from=builder --chmod=500 /usr/local/bin/litestream /usr/local/bin/litestream
COPY --from=builder /work/app /app/app
COPY --from=builder --chmod=600 /work/db.sqlite /app/db.sqlite
COPY ./litestream.yml /etc/litestream.yml
COPY --from=builder --chmod=500 /work/run.sh /app/run.sh

CMD ["/app/run.sh"]

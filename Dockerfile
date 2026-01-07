FROM rust:1.92.0-slim as builder

WORKDIR /app

# 安装构建依赖（openssl 等）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    pkg-config \
    libssl-dev \
    ca-certificates \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY Cargo.toml Cargo.lock ./

# 创建虚拟 main.rs 以缓存依赖
RUN mkdir src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

# 复制源代码和 Web UI
COPY src ./src
COPY web ./web
COPY prompt.md.example ./prompt.md.example

# 构建应用
RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 从构建阶段复制二进制文件与静态资源
COPY --from=builder /app/target/release/xiamenlabs-openai-proxy /app/
COPY --from=builder /app/web /app/web
COPY --from=builder /app/prompt.md.example /app/prompt.md.example

# 设置环境变量
ENV RUST_LOG=info

# 暴露端口
EXPOSE 8080

# 运行应用
CMD ["/app/xiamenlabs-openai-proxy"]

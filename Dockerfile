FROM rust:1.75-slim as builder

WORKDIR /app

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

# 构建应用
RUN cargo build --release

# 运行时镜像
FROM debian:bookworm-slim

# 安装运行时依赖
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 从构建阶段复制二进制文件
COPY --from=builder /app/target/release/xiamenlabs-openai-proxy /app/

# 复制示例 prompt 文件
COPY prompt.md.example /app/prompt.md.example

# 设置环境变量
ENV RUST_LOG=info

# 暴露端口
EXPOSE 8080

# 运行应用
CMD ["/app/xiamenlabs-openai-proxy"]

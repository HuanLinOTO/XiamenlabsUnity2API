# Docker 部署指南

## 使用预构建镜像

如果你已经推送到 Docker Hub：

```bash
docker pull yourusername/xiamenlabs-openai-proxy:latest
docker run -p 8080:8080 yourusername/xiamenlabs-openai-proxy:latest
```

## 本地构建镜像

```bash
# 构建镜像
docker build -t xiamenlabs-openai-proxy .

# 运行容器
docker run -p 8080:8080 xiamenlabs-openai-proxy
```

## 使用自定义 prompt

创建 `prompt.md` 文件，然后挂载到容器：

```bash
docker run -p 8080:8080 \
  -v $(pwd)/prompt.md:/app/prompt.md \
  xiamenlabs-openai-proxy
```

## Docker Compose

创建 `docker-compose.yml`:

```yaml
version: "3.8"

services:
  proxy:
    image: xiamenlabs-openai-proxy
    build: .
    ports:
      - "8080:8080"
    volumes:
      - ./prompt.md:/app/prompt.md:ro
    environment:
      - RUST_LOG=info
    restart: unless-stopped
```

运行：

```bash
docker-compose up -d
```

## 环境变量

- `RUST_LOG`: 日志级别 (trace, debug, info, warn, error)

## 健康检查

```bash
curl http://localhost:8080/v1/models
```

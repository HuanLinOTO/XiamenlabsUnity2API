# Docker 部署指南

## 使用预构建镜像

镜像现已发布到 GitHub Container Registry (GHCR)：

```bash
docker pull ghcr.io/<your-org-or-username>/xiamenlabs-openai-proxy:latest
docker run -p 8080:8080 ghcr.io/<your-org-or-username>/xiamenlabs-openai-proxy:latest
```

> 将 `<your-org-or-username>` 替换为托管仓库的 GitHub 组织或用户名。

或登录 GHCR 拉取：

```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u <your-gh-username> --password-stdin
```

## 本地构建镜像

方式 A：使用预编译二进制（与 CI 逻辑一致，推荐）

```bash
# 假设你已有 xiamenlabs-openai-proxy (Linux amd64) 二进制放在仓库根目录
docker build -f Dockerfile.runtime -t xiamenlabs-openai-proxy .
docker run -p 8080:8080 xiamenlabs-openai-proxy
```

方式 B：源码构建（不依赖预编译产物）

```bash
docker build -t xiamenlabs-openai-proxy .
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
  image: ghcr.io/<your-org-or-username>/xiamenlabs-openai-proxy
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

# ---------- 第一阶段：构建 ----------
FROM golang:1.25-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制 go mod 相关文件
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制所有源码
COPY . .

# 编译成静态二进制
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o server


# ---------- 第二阶段：运行 ----------
FROM alpine:latest

WORKDIR /app

# 安装 ca 证书（很多人忘了这个）
RUN apk add --no-cache ca-certificates

# 从 builder 阶段复制编译好的文件
COPY --from=builder /app/server .

# 暴露端口（根据你的项目改）
EXPOSE 8080

# 启动
CMD ["./server"]

# 使用官方 golang alpine 镜像作为构建阶段
FROM golang:1.25-alpine AS builder

WORKDIR /src

# Go 模块代理（国内加速，失败时回退直连）
ENV GOPROXY=https://goproxy.cn,direct

# 依赖层缓存：仅当 go.mod/go.sum 变更时才重新下载
COPY go.mod go.sum ./
RUN go mod download

# 切换 apk 源为阿里云镜像（加速包下载）
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update --no-cache --no-progress make git

# 拷贝源代码（代码变更不会触发依赖重新下载）
COPY . .

RUN make server

# 运行时阶段：最小化 alpine 基础镜像
FROM alpine:latest

# 切换 apk 源为阿里云镜像
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update --no-cache --no-progress ca-certificates tzdata

# 从构建阶段拷贝编译好的二进制文件
COPY --from=builder /src/build/metatube-server .

ENV GIN_MODE=release
ENV PORT=8080
ENV TOKEN=""
ENV DSN=""
ENV REQUEST_TIMEOUT=""
ENV DB_MAX_IDLE_CONNS=0
ENV DB_MAX_OPEN_CONNS=0
ENV DB_PREPARED_STMT=0
ENV DB_AUTO_MIGRATE=0

EXPOSE 8080

ENTRYPOINT ["/metatube-server"]

FROM golang:1.25rc2-alpine AS build

WORKDIR /app

COPY go.mod go.sum ./
ARG GOPROXY
RUN --mount=type=cache,target=/root/go/pkg/mod,rw --mount=type=cache,target=/root/.cache/go-build,rw \
    go mod download

COPY . .
RUN --mount=type=cache,target=/root/go/pkg/mod,rw --mount=type=cache,target=/root/.cache/go-build,rw \
    CGO_ENABLED=0 GOOS=linux \
    go build \
    -gcflags="all=-trimpath=$(pwd)" \
    -asmflags="all=-trimpath=$(pwd)" \
    -ldflags="-s -w" \
    -o upstash-redis-rest-server \
    ./cmd/upstash-redis-rest-server

FROM alpine:3.22

COPY --from=build /app/upstash-redis-rest-server /usr/local/bin/upstash-redis-rest-server

ENTRYPOINT ["/usr/local/bin/upstash-redis-rest-server"]

# backend/Dockerfile
# 1. Build stage
FROM golang:1.23-alpine AS builder
WORKDIR /app

# Cache modules
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of your code and build
COPY . .
WORKDIR /app/cmd/api
RUN go build -o /server

# 2. Runtime stage
FROM alpine:latest
RUN apk add --no-cache ca-certificates

WORKDIR /
# Copy binary and env file (if you want to bundle .env)
COPY --from=builder /server .

EXPOSE 8080
ENTRYPOINT ["./server"]

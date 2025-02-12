# Build stage
FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS builder

ARG TARGETOS
ARG TARGETARCH

WORKDIR /app

# Install dependencies
RUN apk update && apk add --no-cache git

# Copy go.mod and go.sum, download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code
COPY . .

# Build the Go binary for the target architecture
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /metrics-server ./cmd/main.go

# Final stage - minimal image
FROM --platform=$TARGETPLATFORM scratch
COPY --from=builder /metrics-server /
ENTRYPOINT [ "/metrics-server" ]

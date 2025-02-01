# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install dependencies
RUN apk update && apk add --no-cache git

# Copy go.mod and go.sum, download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code
COPY . .

# Build the Go binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /metrics-server ./cmd/main.go

# Final stage - minimal image
FROM scratch
COPY --from=builder /metrics-server /
ENTRYPOINT [ "/metrics-server" ]

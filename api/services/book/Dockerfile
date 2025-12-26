FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copy pkg
COPY api/pkg ./api/pkg

# Copy service
COPY api/services/book ./api/services/book

# Work from service dir
WORKDIR /app/api/services/book

# Download dependencies
RUN go mod download

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/main.go

FROM alpine:latest
RUN apk add --no-cache tzdata
WORKDIR /root/
COPY --from=builder /app/api/services/book/main .

EXPOSE 3000

CMD ["./main"]

# Build stage
FROM golang:1.22 AS builder

# Install necessary C libraries for CGO
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    unzip

ARG DUCKDB_VERSION=v0.10.3

# Download and install DuckDB from source
RUN curl -L https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/libduckdb-linux-aarch64.zip -o duckdb.zip \
    && unzip duckdb.zip -d /tmp/duckdb \
    && mv /tmp/duckdb/*.so /usr/local/lib/ \
    && mv /tmp/duckdb/*.a /usr/local/lib/ \
    && mkdir -p /usr/local/include/duckdb \
    && mv /tmp/duckdb/*.h* /usr/local/include/duckdb/ \
    && rm duckdb.zip 

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code and compile it
# Enable CGO and set the CGO_LDFLAGS to include DuckDB
ENV CGO_ENABLED=1
ENV CGO_CFLAGS="-I/usr/src/include/duckdb"
ENV CGO_LDFLAGS="-L/usr/local/lib -lduckdb"

COPY . .
RUN go build -o /app/ ./...

# Production stage - final image
FROM debian:bookworm-slim

WORKDIR /app
EXPOSE 8080/tcp 8081/tcp
ENV LD_LIBRARY_PATH=/usr/local/lib

# Install necessary runtime C libraries for runtime compatibility
RUN apt-get update && apt-get install -y \
    libc6 \
    && rm -rf /var/lib/apt/lists/*

# Copy the DuckDB shared library from the builder stage
COPY --from=builder /usr/local/lib/libduckdb.so /usr/local/lib/

COPY --from=builder /app /app

CMD ["/app/server"]
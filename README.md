# Observability by Design

This repository is a demonstration of the capabilities of [OpenTelemetry Weaver](https://github.com/open-telemetry/weaver) for designing your observability.

The key principle is treating observability (metrics, logs, spans, etc.) just as you would
an API.

TODO - more description.

## Example Application

TODO - Describe application.

## Building

1. Generate code for Go: `make generate-go`
2. Generate code for Rust: `make generate-rust`

TODO - build docker images.

## Running

1. Running the Go Example
   - Move to the go directory: `cd go`
   - Run the go server `go run .`
   - In a separate terminal, issue some requests
     `curl localhost:8080/auction/1/bid` e.g.
   - Check the prometheus metrics:
     `curl localhost:2223/metrics`
2. Running the Rust Example
   TODO

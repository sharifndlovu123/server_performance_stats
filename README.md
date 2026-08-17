# Server Performance Stats

Prints a snapshot of memory, CPU, and disk usage. Can run once or watch on a
5s refresh loop.

## Run locally

```bash
./src/performance.sh          # one-shot snapshot
./src/performance.sh true     # watch mode (refreshes every 5s)
```

## Run with Docker

```bash
docker build -t perf-stats .

docker run --rm perf-stats            # one-shot snapshot
docker run --rm -t perf-stats true    # watch mode (needs -t for a TTY)
```

The image is a multi-stage build: a `builder` stage installs `mpstat`
(from `sysstat`) and `free` (from `procps`), which aren't in the
`python:3.12-slim` base image; the `final` stage only copies over those
two binaries and their required shared libraries, keeping the shipped
image free of apt's install-time cache and metadata.

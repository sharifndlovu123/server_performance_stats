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

## Persisting output

Each run also appends its report to `/var/log/perf-stats/report.log`
inside the container (declared as a `VOLUME`, owned by the non-root
`app` user). Mount a volume there to keep the log outside the container:

```bash
docker run --rm -v perf-logs:/var/log/perf-stats perf-stats
# or bind-mounted to the host:
docker run --rm -v "$(pwd)/logs":/var/log/perf-stats perf-stats
```

Override the log path with the `OUTFILE` env var if needed:

```bash
docker run --rm -e OUTFILE=/var/tmp/perf-stats/report.log \
  -v perf-logs:/var/tmp/perf-stats perf-stats
```

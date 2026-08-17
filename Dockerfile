# --- builder stage -----------------------------------------------------
# Installs mpstat (sysstat) and free (procps), which the base image lacks.
# Kept separate so the final image doesn't carry apt's cache/metadata,
# man pages, locales, and other install-time cruft these packages pull in.
FROM python:3.12-slim AS builder

WORKDIR /src

COPY src /src

RUN apt-get update \
	&& apt-get install -y --no-install-recommends sysstat procps \
	&& rm -rf /var/lib/apt/lists/* \
	&& chmod +x /src/performance.sh

# --- final stage ---------------------------------------------------------
# Fresh from the base image; only the specific binaries/libs needed at
# runtime are pulled in from builder, not the full apt install.
FROM python:3.12-slim AS final
WORKDIR /src
COPY src /src

# mpstat and free binaries from builder (df comes from coreutils, already
# present in the base image, so it needs no extra package).
COPY --from=builder /usr/bin/mpstat /usr/bin/free /usr/bin/

# Shared libs those two binaries need that aren't in the base image.
# Found via `ldd $(which mpstat)` / `ldd $(which free)` in the builder stage;
# libc/libm/ld-linux were already present in the base image, so only these
# three needed copying.
COPY --from=builder \
	/usr/lib/x86_64-linux-gnu/libproc2.so.0 \
	/usr/lib/x86_64-linux-gnu/libsystemd.so.0 \
	/usr/lib/x86_64-linux-gnu/libcap.so.2 \
	/usr/lib/x86_64-linux-gnu/

RUN chmod +x /src/performance.sh

# Run as non-root.
RUN useradd -m app
USER app

# ENTRYPOINT (not CMD alone) so the container always runs performance.sh;
# `docker run image <arg>` appends <arg> as $1 (the script's watch flag)
# instead of replacing the command entirely.
ENTRYPOINT [ "/src/performance.sh" ]
# Default: one-shot snapshot. Pass `true` to watch instead:
#   docker run --rm -t image true
CMD [ "false" ]

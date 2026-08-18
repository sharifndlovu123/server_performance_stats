#!/usr/bin/env bash

set -e

watch="$1"

# Where the report is also persisted (mount a volume here to keep it
# outside the container). Falls back to a plain snapshot if the mounted
# directory can't be written to.
OUTFILE="${OUTFILE:-/var/log/perf-stats/report.log}"

# Colors (fall back to no color if terminal doesn't support it)
if [ -t 1 ] && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
	BOLD=$(tput bold)
	DIM=$(tput dim)
	RESET=$(tput sgr0)
	CYAN=$(tput setaf 6)
	GREEN=$(tput setaf 2)
	YELLOW=$(tput setaf 3)
else
	BOLD=""; DIM=""; RESET=""; CYAN=""; GREEN=""; YELLOW=""
fi

# Helper Functions
print_rule() {
	printf "%s" "$CYAN"
	printf '─%.0s' $(seq 1 "${COLUMNS:-$(tput cols 2>/dev/null || echo 63)}")
	printf "%s\n" "$RESET"
}

print_header() {
	print_rule
	printf "%s%s  %s%s\n" "$BOLD" "$CYAN" "$1" "$RESET"
	print_rule
}

print_section() {
	printf "\n%s%s▸ %s%s\n" "$BOLD" "$GREEN" "$1" "$RESET"
}

print_banner() {
	print_rule
	printf "%s%s  %s%s\n" "$BOLD" "$YELLOW" "$1" "$RESET"
	printf "%s%s  %s%s\n" "$DIM" "$CYAN" "$(date '+%Y-%m-%d %H:%M:%S')" "$RESET"
	print_rule
}

report() {
	print_section "Memory Usage"
	free -hm
	print_section "CPU Usage"
	mpstat -P 0-15
	print_section "Disk Usage"
	df -h --output=size,used,avail,target
}

mkdir -p "$(dirname "$OUTFILE")" 2>/dev/null || true
if ! { : >>"$OUTFILE"; } 2>/dev/null; then
	printf "%swarning: cannot write to %s, continuing without persisting the report%s\n" "$YELLOW" "$OUTFILE" "$RESET" >&2
	OUTFILE=/dev/null
fi

if [ "$watch" == "true" ]; then
	while true; do
		clear 2>/dev/null || true
		print_banner "Watching Performance" | tee -a "$OUTFILE"
		report | tee -a "$OUTFILE"
		echo
		printf "%s%sRefreshing every 5s — press Ctrl+C to stop%s\n" "$DIM" "$CYAN" "$RESET"
		sleep 5
	done
else
	print_banner "Performance Snapshot" | tee -a "$OUTFILE"
	report | tee -a "$OUTFILE"
fi

#  call method with watch=true to watch performance --watch true

#!/usr/bin/env bash

set -e

watch="$1"

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

if [ "$watch" == "true" ]; then
	while true; do
		clear
		print_banner "Watching Performance"
		report
		echo
		printf "%s%sRefreshing every 5s — press Ctrl+C to stop%s\n" "$DIM" "$CYAN" "$RESET"
		sleep 5
	done
else
	print_banner "Performance Snapshot"
	report
fi

#  call method with watch=true to watch performance --watch true

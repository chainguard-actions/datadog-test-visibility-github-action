#!/bin/sh
# Fake curl: intercepts the Datadog install script URL and serves a canned payload.
# Supports both "curl URL | sh" (stdout) and hardened "curl -o FILE URL" (write to file).
# Falls through to real curl for other URLs.

out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output|-Lo|-Lo) out="$arg" ;;
  esac
  # Handle -Lo as a combined flag
  case "$arg" in
    -Lo) prev="-Lo" ; continue ;;
  esac
  prev="$arg"
done

# Also handle -Lo <file> pattern (combined flag)
i=0
args_arr=""
for arg in "$@"; do
  if [ "$arg" = "-Lo" ]; then
    # next arg is the output file - handled by prev logic above
    :
  fi
done

# Re-parse to handle -Lo correctly
out=""
prev_was_output=0
for arg in "$@"; do
  if [ "$prev_was_output" = "1" ]; then
    out="$arg"
    prev_was_output=0
    continue
  fi
  case "$arg" in
    -o|--output) prev_was_output=1 ;;
    -Lo) prev_was_output=1 ;;
  esac
done

FAKE_SCRIPT="${FAKE_INSTALL_SCRIPT_PATH:-/tmp/fake-install-datadog.sh}"

case "$*" in
  *install.datadoghq.com*|*install_test_visibility*)
    if [ -n "$out" ]; then
      cat "$FAKE_SCRIPT" > "$out"
    else
      cat "$FAKE_SCRIPT"
    fi
    exit 0
    ;;
esac

# Fall through to real curl for other URLs
exec /usr/bin/curl "$@"

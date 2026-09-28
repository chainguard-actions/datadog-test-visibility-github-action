#!/bin/sh
# Fake curl: serves the fake install script, supports both pipe and -o FILE forms
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output|-Lo) out="$arg" ;;
  esac
  prev="$arg"
done
for arg in "$@"; do
  case "$arg" in
    *install_test_visibility*)
      if [ -n "$out" ]; then
        cat "$GITHUB_WORKSPACE/tests/fixtures/fake-install-script.sh" > "$out"
      else
        cat "$GITHUB_WORKSPACE/tests/fixtures/fake-install-script.sh"
      fi
      exit 0
      ;;
  esac
done
exec /usr/bin/curl "$@"

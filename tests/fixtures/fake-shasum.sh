#!/bin/sh
# Fake shasum: always reports checksum as matching.
# Used to bypass checksum verification when serving a fake install script.
echo "OK"
exit 0

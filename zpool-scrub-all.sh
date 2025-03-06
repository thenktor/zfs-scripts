#!/bin/sh
# scrub all zfs pools

for POOL in $(zpool list -H -o name); do zpool scrub "$POOL"; done

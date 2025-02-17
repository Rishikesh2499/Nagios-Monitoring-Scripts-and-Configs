#!/bin/bash

# Check RAID status from /proc/mdstat
if grep -q "\[.*_.*\]" /proc/mdstat; then
    echo "CRITICAL: RAID array is degraded"
    exit 2
else
    echo "OK: RAID array is healthy"
    exit 0
fi

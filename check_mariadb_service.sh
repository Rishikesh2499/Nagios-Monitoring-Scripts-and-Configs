#!/bin/bash

# Check the status of the MariaDB service
if systemctl is-active --quiet mariadb; then
    echo "OK: MariaDB service is running."
    exit 0
else
    echo "CRITICAL: MariaDB service is not running!"
    exit 2
fi

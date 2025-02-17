#!/bin/bash

# Database credentials
MYSQL_USER=""
MYSQL_PASS=""
MYSQL_HOST="localhost"

# Fetch slave status once to avoid multiple queries
SLAVE_STATUS=$(mysql -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST -e "SHOW SLAVE STATUS\G")

# Extract relevant information from the slave status
IO_RUNNING=$(echo "$SLAVE_STATUS" | grep -i "Slave_IO_Running" | awk '{print $2}' | xargs)
SQL_RUNNING=$(echo "$SLAVE_STATUS" | grep -i "Slave_SQL_Running" | awk '{print $2}' | xargs)
SECONDS_BEHIND=$(echo "$SLAVE_STATUS" | grep -i "Seconds_Behind_Master" | awk '{print $2}' | xargs)
LAST_ERROR=$(echo "$SLAVE_STATUS" | grep -i "Last_Error" | awk '{$1=""; print $0}' | xargs)

# Set thresholds
WARNING_THRESHOLD=30
CRITICAL_THRESHOLD=60

# Handle different checks based on argument
case "$1" in
    status)
        if [ "$IO_RUNNING" != "Yes" ] || [[ "$SQL_RUNNING" != "Yes"* ]]; then
            echo "CRITICAL - Replication threads are not running: IO='$IO_RUNNING', SQL='$SQL_RUNNING'"
            exit 2
        else
            echo "OK - Replication threads are running"
            exit 0
        fi
        ;;

    lag)
        if [ "$SECONDS_BEHIND" -gt $CRITICAL_THRESHOLD ]; then
            echo "CRITICAL - Replication lag is $SECONDS_BEHIND seconds."
            exit 2
        elif [ "$SECONDS_BEHIND" -gt $WARNING_THRESHOLD ]; then
            echo "WARNING - Replication lag is $SECONDS_BEHIND seconds."
            exit 1
        else
            echo "OK - Replication lag is $SECONDS_BEHIND seconds."
            exit 0
        fi
        ;;

    io)
        if [ "$IO_RUNNING" == "Yes" ]; then
            echo "OK - Slave I/O thread is running."
            exit 0
        else
            echo "CRITICAL - Slave I/O thread is NOT running."
            exit 2
        fi
        ;;

    sql)
        if [[ "$SQL_RUNNING" == "Yes"* ]]; then
            echo "OK - Slave SQL thread is running."
            exit 0
        else
            echo "CRITICAL - Slave SQL thread is NOT running."
            exit 2
        fi
        ;;

    error)
        if [ -n "$LAST_ERROR" ]; then
            echo "CRITICAL - Replication error detected: $LAST_ERROR"
            exit 2
        else
            echo "OK - No replication errors detected."
            exit 0
        fi
        ;;

    *)
        echo "Usage: $0 {status|lag|io|sql|error}"
        exit 3
        ;;
esac

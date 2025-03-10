#!/bin/bash
# Author: Sebastian van de Meer
# Website: https://www.kernel-error.de
# License: MIT License
# Feel free to use, modify, and distribute this script as long as you retain attribution.

# Target URL
URL="https://www.example.com/wp-cron.php"

# Number of requests
NUM_REQUESTS=10

# Wait time between requests (in seconds)
WAIT_TIME=0

echo "Starting rate-limit test for URL: $URL"
echo "Sending $NUM_REQUESTS requests with a delay of $WAIT_TIME seconds..."

for (( i=1; i<=NUM_REQUESTS; i++ )); do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
    TIMESTAMP=$(date +"%T")
    echo "[$TIMESTAMP] Request $i/$NUM_REQUESTS -> HTTP status code: $HTTP_CODE"

    if [ "$HTTP_CODE" -eq 429 ]; then
        echo "⚠️  Rate limit triggered after $i requests (HTTP 429)."
        exit 1
    fi

    sleep "$WAIT_TIME"
done

echo "✅ Test completed. No rate limit was triggered."

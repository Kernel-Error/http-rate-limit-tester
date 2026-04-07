#!/usr/bin/env bash
# Author: Sebastian van de Meer
# Website: https://www.kernel-error.de
# License: MIT License
# Feel free to use, modify, and distribute this script as long as you retain attribution.

# Default values
URL="https://www.example.com/wp-cron.php"
NUM_REQUESTS=10
WAIT_TIME=0
CONNECT_TIMEOUT=5
MAX_TIME=10

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Test HTTP rate limiting by sending requests to a URL and detecting HTTP 429 responses.

Options:
  -u, --url URL              Target URL (default: $URL)
  -n, --requests NUM         Number of requests to send (default: $NUM_REQUESTS)
  -w, --wait SECONDS         Wait time between requests (default: $WAIT_TIME)
  -c, --connect-timeout SEC  Connection timeout in seconds (default: $CONNECT_TIMEOUT)
  -m, --max-time SEC         Maximum time per request in seconds (default: $MAX_TIME)
  -h, --help                 Show this help message
EOF
    exit 0
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--url)
            URL="$2"
            shift 2
            ;;
        -n|--requests)
            NUM_REQUESTS="$2"
            shift 2
            ;;
        -w|--wait)
            WAIT_TIME="$2"
            shift 2
            ;;
        -c|--connect-timeout)
            CONNECT_TIMEOUT="$2"
            shift 2
            ;;
        -m|--max-time)
            MAX_TIME="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown option '$1'" >&2
            echo "Use --help for usage information." >&2
            exit 2
            ;;
    esac
done

# Validate inputs
if [[ -z "$URL" ]]; then
    echo "Error: URL must not be empty." >&2
    exit 2
fi

if ! [[ "$NUM_REQUESTS" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: Number of requests must be a positive integer (got: '$NUM_REQUESTS')." >&2
    exit 2
fi

if ! [[ "$WAIT_TIME" =~ ^[0-9]+\.?[0-9]*$ ]]; then
    echo "Error: Wait time must be a non-negative number (got: '$WAIT_TIME')." >&2
    exit 2
fi

if ! [[ "$CONNECT_TIMEOUT" =~ ^[0-9]+\.?[0-9]*$ ]]; then
    echo "Error: Connect timeout must be a non-negative number (got: '$CONNECT_TIMEOUT')." >&2
    exit 2
fi

if ! [[ "$MAX_TIME" =~ ^[0-9]+\.?[0-9]*$ ]]; then
    echo "Error: Max time must be a non-negative number (got: '$MAX_TIME')." >&2
    exit 2
fi

if ! command -v curl &>/dev/null; then
    echo "Error: curl is required but not installed." >&2
    exit 2
fi

echo "Starting rate-limit test for URL: $URL"
echo "Sending $NUM_REQUESTS requests with a delay of $WAIT_TIME seconds..."

for (( i=1; i<=NUM_REQUESTS; i++ )); do
    HTTP_CODE=$(curl --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIME" \
        -s -o /dev/null -w "%{http_code}" "$URL")
    CURL_EXIT=$?
    TIMESTAMP=$(date +"%T")

    if [[ $CURL_EXIT -ne 0 ]]; then
        echo "[$TIMESTAMP] Request $i/$NUM_REQUESTS -> curl error (exit code: $CURL_EXIT)"
        echo "Error: Connection failed. Check the URL and network connectivity." >&2
        exit 3
    fi

    echo "[$TIMESTAMP] Request $i/$NUM_REQUESTS -> HTTP status code: $HTTP_CODE"

    if [[ "$HTTP_CODE" -eq 429 ]]; then
        echo "⚠️  Rate limit triggered after $i requests (HTTP 429)."
        exit 1
    fi

    sleep "$WAIT_TIME"
done

echo "✅ Test completed. No rate limit was triggered."

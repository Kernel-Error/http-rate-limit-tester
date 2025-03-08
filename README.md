
# HTTP Rate Limit Tester

A simple Bash script to test HTTP rate limiting behavior by sending multiple HTTP requests to a specified URL and detecting when rate limits (HTTP 429 responses) are encountered.

## Features

- Sends configurable number of HTTP requests
- Detects and logs HTTP status codes
- Timestamped output for easy monitoring
- Clearly indicates when a rate limit is reached (HTTP 429)

## Usage

Make the script executable:

```bash
chmod +x rate-limit-test.sh
```

Execute the script:

```bash
./rate-limit-test.sh
```

## Configuration

You can customize these variables directly in the script:

- `URL`: The target URL to test
- `NUM_REQUESTS`: Number of HTTP requests to send
- `WAIT_TIME`: Waiting time between requests (in seconds)

## Example Output

```
[12:34:56] Anfrage 1/10 -> HTTP-Code: 200
[12:34:56] Anfrage 2 -> HTTP-Code: 200
[12:34:56] Anfrage 3 -> HTTP-Code: 429
Test abgeschlossen: Rate Limit erreicht.
```

## License

This script is licensed under the MIT License.

© 2025 Sebastian van de Meer (https://www.kernel-error.de)

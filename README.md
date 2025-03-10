
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

```bash
[12:34:56] Request 1/10 -> HTTP status code: 200
[12:34:56] Request 2/10 -> HTTP status code: 200
[12:34:56] Request 3/10 -> HTTP status code: 429
⚠️  Rate limit triggered after 3 requests (HTTP 429).
```


## License

This script is licensed under the MIT License.

© 2025 Sebastian van de Meer (https://www.kernel-error.de)

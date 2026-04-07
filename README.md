
# HTTP Rate Limit Tester

A simple Bash script to test HTTP rate limiting behavior by sending multiple HTTP requests to a specified URL and detecting when rate limits (HTTP 429 responses) are encountered.

## Features

- Sends configurable number of HTTP requests
- Detects and logs HTTP status codes
- Timestamped output for easy monitoring
- Clearly indicates when a rate limit is reached (HTTP 429)
- Command-line arguments for all configuration options
- Input validation and clear error messages
- Connection timeout and max request time to prevent hangs
- Detects transport failures (DNS, TLS, connection errors)

## Prerequisites

- `bash` (version 3.2+)
- `curl`

## Usage

Make the script executable:

```bash
chmod +x rate_limit_test.sh
```

Execute the script with default settings:

```bash
./rate_limit_test.sh
```

Or customize via command-line arguments:

```bash
./rate_limit_test.sh --url https://example.com/api --requests 20 --wait 1
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `-u`, `--url` | Target URL to test | `https://www.example.com/wp-cron.php` |
| `-n`, `--requests` | Number of requests to send | `10` |
| `-w`, `--wait` | Wait time between requests (seconds) | `0` |
| `-c`, `--connect-timeout` | Connection timeout (seconds) | `5` |
| `-m`, `--max-time` | Max time per request (seconds) | `10` |
| `-h`, `--help` | Show help message | — |

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All requests completed, no rate limit detected |
| `1` | Rate limit triggered (HTTP 429) |
| `2` | Invalid input or missing dependency |
| `3` | Connection or transport error |

## Example Output

```bash
$ ./rate_limit_test.sh --url https://example.com/api --requests 5
Starting rate-limit test for URL: https://example.com/api
Sending 5 requests with a delay of 0 seconds...
[12:34:56] Request 1/5 -> HTTP status code: 200
[12:34:56] Request 2/5 -> HTTP status code: 200
[12:34:56] Request 3/5 -> HTTP status code: 429
⚠️  Rate limit triggered after 3 requests (HTTP 429).
```

## Development

Running the test suite requires:

- [bats-core](https://github.com/bats-core/bats-core) (1.10+)
- `python3` (used as mock HTTP server in tests)

```bash
bats rate_limit_test.bats
```

## License

This script is licensed under the MIT License.

© 2025 Sebastian van de Meer (https://www.kernel-error.de)

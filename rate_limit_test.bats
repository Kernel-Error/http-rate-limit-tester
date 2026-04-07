#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/rate_limit_test.sh"

# --- Help & Usage ---

@test "help flag shows usage information" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"--url"* ]]
    [[ "$output" == *"--requests"* ]]
    [[ "$output" == *"--wait"* ]]
}

@test "short help flag works" {
    run bash "$SCRIPT" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

# --- Argument Parsing ---

@test "unknown option exits with code 2" {
    run bash "$SCRIPT" --bogus
    [ "$status" -eq 2 ]
    [[ "$output" == *"Unknown option"* ]]
}

# --- Input Validation: URL ---

@test "empty URL exits with code 2" {
    run bash "$SCRIPT" --url ""
    [ "$status" -eq 2 ]
    [[ "$output" == *"URL must not be empty"* ]]
}

# --- Input Validation: NUM_REQUESTS ---

@test "non-numeric requests exits with code 2" {
    run bash "$SCRIPT" --url http://localhost --requests abc
    [ "$status" -eq 2 ]
    [[ "$output" == *"positive integer"* ]]
}

@test "zero requests exits with code 2" {
    run bash "$SCRIPT" --url http://localhost --requests 0
    [ "$status" -eq 2 ]
    [[ "$output" == *"positive integer"* ]]
}

@test "negative requests exits with code 2" {
    run bash "$SCRIPT" --url http://localhost --requests -5
    [ "$status" -eq 2 ]
    [[ "$output" == *"positive integer"* ]]
}

# --- Input Validation: WAIT_TIME ---

@test "negative wait time exits with code 2" {
    run bash "$SCRIPT" --url http://localhost --wait -1
    [ "$status" -eq 2 ]
    [[ "$output" == *"non-negative number"* ]]
}

@test "non-numeric wait time exits with code 2" {
    run bash "$SCRIPT" --url http://localhost --wait foo
    [ "$status" -eq 2 ]
    [[ "$output" == *"non-negative number"* ]]
}

@test "decimal wait time is accepted" {
    # Use an unreachable URL so we fail fast on connection, but pass validation
    run bash "$SCRIPT" --url http://192.0.2.1 --requests 1 --wait 0.5 --connect-timeout 1 --max-time 1
    # Should get past validation (exit 3 = connection error, not 2 = validation)
    [ "$status" -eq 3 ]
}

# --- Input Validation: Timeouts ---

@test "non-numeric connect-timeout exits with code 2" {
    run bash "$SCRIPT" --url http://localhost --connect-timeout abc
    [ "$status" -eq 2 ]
    [[ "$output" == *"Connect timeout must be a non-negative number"* ]]
}

@test "non-numeric max-time exits with code 2" {
    run bash "$SCRIPT" --url http://localhost --max-time abc
    [ "$status" -eq 2 ]
    [[ "$output" == *"Max time must be a non-negative number"* ]]
}

# --- Connection Error Handling ---

@test "unreachable host exits with code 3" {
    run bash "$SCRIPT" --url http://192.0.2.1 --requests 1 --connect-timeout 1 --max-time 2
    [ "$status" -eq 3 ]
    [[ "$output" == *"curl error"* ]]
}

@test "invalid hostname exits with code 3" {
    run bash "$SCRIPT" --url http://this.host.does.not.exist.invalid --requests 1 --connect-timeout 2 --max-time 2
    [ "$status" -eq 3 ]
    [[ "$output" == *"curl error"* ]]
}

# --- Successful Requests (using a local mock or known-good endpoint) ---

@test "successful request against localhost returns exit 0 or connection error" {
    # This test checks that the script runs through the full loop when given a valid config.
    # If nothing listens on port 19999, we expect exit 3 (connection refused = curl error).
    run bash "$SCRIPT" --url http://127.0.0.1:19999 --requests 1 --connect-timeout 1 --max-time 1
    # Either connection error (3) or success (0) — but never validation error (2)
    [[ "$status" -eq 0 || "$status" -eq 3 ]]
}

# --- Exit Code Documentation ---

@test "exit code 0 on successful completion" {
    python3 -c "
from http.server import HTTPServer, BaseHTTPRequestHandler
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
    def log_message(self, *args):
        pass
srv = HTTPServer(('127.0.0.1', 18932), H)
srv.serve_forever()
" &
    MOCK_PID=$!
    sleep 0.5

    run bash "$SCRIPT" --url http://127.0.0.1:18932 --requests 3 --connect-timeout 2 --max-time 2
    kill "$MOCK_PID" 2>/dev/null || true
    [ "$status" -eq 0 ]
    [[ "$output" == *"No rate limit was triggered"* ]]
}

@test "exit code 1 on HTTP 429" {
    # Start a tiny HTTP server that always returns 429
    python3 -c "
from http.server import HTTPServer, BaseHTTPRequestHandler
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(429)
        self.end_headers()
    def log_message(self, *args):
        pass
srv = HTTPServer(('127.0.0.1', 18933), H)
srv.serve_forever()
" &
    MOCK_PID=$!
    sleep 0.5

    run bash "$SCRIPT" --url http://127.0.0.1:18933 --requests 5 --connect-timeout 2 --max-time 2
    kill "$MOCK_PID" 2>/dev/null || true
    [ "$status" -eq 1 ]
    [[ "$output" == *"Rate limit triggered"* ]]
}

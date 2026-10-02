<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.8.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.8.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ }}` expressions inside shell command strings (sub-rule a), allowing an attacker to inject arbitrary shell commands. Affected lines:
- Line ~70: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` (step: 'Set global envs and github path')
- Line ~147: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` (step: 'Propagate optional site input to environment variable')
- Line ~153: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` (step: 'Propagate optional service input to environment variable')
- Line ~159: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` (step: 'Propagate API key from input to environment variables and set provider')
- Line ~191: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` (step: 'Print summary')
All of these embed GitHub Actions expressions directly into shell code before the shell ever sees them, enabling command injection via crafted input values.

Locations:

- `action.yml:70`
- `action.yml:147`
- `action.yml:153`
- `action.yml:159`
- `action.yml:191`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted `inputs.*` and `job.*` context expressions directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker can inject newlines into these values to add arbitrary environment variables that affect subsequent steps.
- Line ~70: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written unsanitized
- Line ~147: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written unsanitized
- Line ~153: `echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service`/`inputs.service-name` written unsanitized
- Line ~159: `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key`/`inputs.api_key` written unsanitized

Locations:

- `action.yml:70`
- `action.yml:147`
- `action.yml:153`
- `action.yml:159`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:167`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:173`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:178`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:209`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all 5 injection locations in action.yml:
1. 'Set global envs and github path' step: moved job.check_run_id to env block (JOB_CHECK_RUN_ID_RAW) and sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Propagate optional site input to environment variable' step: moved inputs.site to env block (INPUT_SITE) and sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable' step: moved the service expression to env block (INPUT_SERVICE) and sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' step: moved the api-key expression to env block (INPUT_API_KEY) and sanitized before writing to GITHUB_ENV.
5. 'Print summary' step: moved inputs.print-github-step-summary to env block (INPUT_PRINT_GITHUB_STEP_SUMMARY) and referenced as shell variable in the if condition.

### Iteration 2

**Fixes applied:** github-env-injection, github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:

1. 'Set global envs and github path' step (line 76): Added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. Now uses `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` before the echo to $GITHUB_PATH.

2. 'Download and run configuration script' step (line 136): Replaced direct `./$script_filepath >> "$GITHUB_ENV"` with a while-read loop that processes each output line, splits it into key/value, sanitizes the value with `printf '%s' "$value" | tr -d '\n\r'`, and writes the sanitized pair to $GITHUB_ENV. Uses bash process substitution `< <(./$script_filepath)` which is valid since the step uses `shell: bash`.


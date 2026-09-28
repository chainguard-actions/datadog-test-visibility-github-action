<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.10.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings (rule a — direct expression interpolation), which allows an attacker-controlled value to be parsed as shell syntax before the shell ever sees it.

1. Step "Set global envs and github path" (line ~83): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — job context interpolated directly in shell.
2. Step "Propagate optional site input to environment variable" (line ~163): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site interpolated directly.
3. Step "Propagate optional service input to environment variable" (line ~169): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service/service-name interpolated directly.
4. Step "Propagate API key from input to environment variables and set provider" (line ~175): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key/api_key interpolated directly.
5. Step "Print summary" (line ~207): `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — inputs.print-github-step-summary interpolated directly in a shell conditional.

All of these should route the value through an `env:` block and reference the env var (double-quoted) in the shell script instead.

Locations:

- `action.yml:83`
- `action.yml:163`
- `action.yml:169`
- `action.yml:175`
- `action.yml:207`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted `inputs.*` context directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker can inject newlines into these values to add arbitrary environment variables that affect subsequent steps.

1. Step "Set global envs and github path" (line ~83): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — job.check_run_id written to GITHUB_ENV without sanitization.
2. Step "Propagate optional site input to environment variable" (line ~163): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site written to GITHUB_ENV without sanitization.
3. Step "Propagate optional service input to environment variable" (line ~169): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service/service-name written to GITHUB_ENV without sanitization.
4. Step "Propagate API key from input to environment variables and set provider" (line ~175): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key/api_key written to GITHUB_ENV without sanitization.

Fix: use `safe=$(printf '%s' "$INPUT_VAR" | tr -d '\n\r')` before each write, routing the input through an `env:` block first.

Locations:

- `action.yml:83`
- `action.yml:163`
- `action.yml:169`
- `action.yml:175`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:179`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:185`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:190`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:221`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all 5 locations in action.yml:
1. 'Set global envs and github path' step: moved job.check_run_id to env block (JOB_CHECK_RUN_ID_RAW) and sanitized with printf/tr before writing to GITHUB_ENV.
2. 'Propagate optional site input' step: moved inputs.site to env block (INPUT_SITE) and sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input' step: moved inputs.service and inputs.service-name to env block (INPUT_SERVICE, INPUT_SERVICE_NAME) and sanitized before writing to GITHUB_ENV.
4. 'Propagate API key' step: moved inputs.api-key and inputs.api_key to env block (INPUT_API_KEY_HYPHEN, INPUT_API_KEY_UNDERSCORE) and sanitized before writing to GITHUB_ENV.
5. 'Print summary' step: moved inputs.print-github-step-summary to env block (INPUT_PRINT_GITHUB_STEP_SUMMARY) and referenced as env var in the shell conditional.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. Step 'Set global envs and github path' (line 78): Added sanitization of the GITHUB_ACTION_PATH value before writing to $GITHUB_PATH using `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` then writing `$safe_action_path` instead of the raw value.
2. Step 'Download and run configuration script' (line 155): Replaced direct pipe of script stdout to $GITHUB_ENV with a two-step approach: capture output to a temp file with `mktemp`, then process each line through `printf '%s\n' "$env_line" | tr -d '\r'` before appending to $GITHUB_ENV, preventing newline injection from the script's output.


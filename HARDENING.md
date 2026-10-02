<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.0.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings (rule a), allowing an attacker-controlled value to be parsed by the shell before quoting can protect it.

1. Step "Set global envs and github path" (line ~100): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.*` context interpolated directly in shell.
2. Step "Propagate optional site input" (line ~175): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` interpolated directly.
3. Step "Propagate optional service input" (line ~181): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.*` interpolated directly.
4. Step "Propagate API key from input" (line ~187): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.*` interpolated directly.
5. Step "Print summary" (line ~215): `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.*` interpolated directly in a shell conditional.

All values should be passed via `env:` variables and then referenced as `"$VAR"` in the shell script.

Locations:

- `action.yml:100`
- `action.yml:175`
- `action.yml:181`
- `action.yml:187`
- `action.yml:215`

### github-env-injection (severity: high)

Multiple `run:` steps write values derived from untrusted `inputs.*` and `job.*` contexts directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled newline in any of these values can inject arbitrary environment variable definitions into subsequent steps.

1. Step "Set global envs and github path" (line ~100): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written unsanitized.
2. Step "Propagate optional site input" (line ~175): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written unsanitized.
3. Step "Propagate optional service input" (line ~181): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service`/`inputs.service-name` written unsanitized.
4. Step "Propagate API key from input" (line ~187): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key`/`inputs.api_key` written unsanitized.

Each write must be preceded by: `safe=$(printf '%s' "$VALUE" | tr -d '\n\r')` and then `echo "KEY=$safe" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:100`
- `action.yml:175`
- `action.yml:181`
- `action.yml:187`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:186`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:192`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:197`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:228`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all 5 locations in action.yml:
1. 'Set global envs and github path' step: moved job.check_run_id to env var JOB_CHECK_RUN_ID_RAW, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Propagate optional site input' step: moved inputs.site to env var INPUT_SITE, sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input' step: moved inputs.service-name and inputs.service to env vars INPUT_SERVICE_NAME and INPUT_SERVICE, implemented ternary logic in shell, sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input' step: moved inputs.api-key and inputs.api_key to env vars INPUT_API_KEY_DEPRECATED and INPUT_API_KEY, implemented ternary logic in shell, sanitized before writing to GITHUB_ENV.
5. 'Print summary' step: moved inputs.print-github-step-summary to env var PRINT_GITHUB_STEP_SUMMARY and referenced it as $PRINT_GITHUB_STEP_SUMMARY in the shell conditional.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Set global envs and github path' step of action.yml. The `GITHUB_ACTION_PATH` value (derived from `${{ github.action_path }}`) was being written directly to `$GITHUB_PATH` without newline sanitization. Fixed by adding `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and then writing `$safe_action_path` to `$GITHUB_PATH` instead of the raw value. This is consistent with the sanitization pattern already used in the same step for `JOB_CHECK_RUN_ID_RAW`.


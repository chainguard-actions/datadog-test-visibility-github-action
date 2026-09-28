<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.10.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings (sub-rule a), allowing an attacker-controlled value to be parsed by the shell before any quoting can protect it.

1. Step 'Set global envs and github path' (line ~83): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `${{ job.check_run_id }}` is interpolated directly.
2. Step 'Propagate optional site input to environment variable' (line ~162): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `${{ inputs.site }}` is interpolated directly.
3. Step 'Propagate optional service input to environment variable' (line ~168): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs are interpolated directly.
4. Step 'Propagate API key from input to environment variables and set provider' (line ~174): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs are interpolated directly.
5. Step 'Print summary' (line ~215): `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `${{ inputs.print-github-step-summary }}` is interpolated directly inside a shell conditional.

All of these should route the value through an `env:` block and reference it as a quoted shell variable instead.

Locations:

- `action.yml:83`
- `action.yml:162`
- `action.yml:168`
- `action.yml:174`
- `action.yml:215`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted `inputs.*` (and `job.*`) directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled newline in any of these values can inject arbitrary environment variables into subsequent steps.

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written unsanitized.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written unsanitized.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` written unsanitized.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api_key` / `inputs.api-key` written unsanitized.

Each of these writes must be preceded by sanitization, e.g.: `safe=$(printf '%s' "$INPUT_VAR" | tr -d '\n\r')` then `echo "KEY=$safe" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:83`
- `action.yml:162`
- `action.yml:168`
- `action.yml:174`

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
1. 'Set global envs and github path' (line ~83): Moved `job.check_run_id` to `JOB_CHECK_RUN_ID_RAW` env var, added sanitization with `printf '%s' | tr -d '\n\r'` before writing to GITHUB_ENV.
2. 'Propagate optional site input to environment variable' (line ~162/179): Moved `inputs.site` to `INPUT_SITE` env var, added sanitization before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable' (line ~168/185): Moved `inputs.service-name` and `inputs.service` to `INPUT_SERVICE_NAME`/`INPUT_SERVICE` env vars, added if/else logic and sanitization before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' (line ~174/190): Moved `inputs.api-key` and `inputs.api_key` to `INPUT_API_KEY_HYPHEN`/`INPUT_API_KEY_UNDERSCORE` env vars, added if/else logic and sanitization before writing to GITHUB_ENV.
5. 'Print summary' (line ~215/221): Moved `inputs.print-github-step-summary` to `INPUT_PRINT_GITHUB_STEP_SUMMARY` env var and referenced it as a shell variable in the conditional.

### Iteration 2

**Fixes applied:** github-env-injection, github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. Line 85 ('Set global envs and github path' step): Added sanitization for GITHUB_ACTION_PATH before writing to $GITHUB_PATH. Now uses `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and writes `$safe_action_path` to $GITHUB_PATH.
2. Line 148 ('Download and run configuration script' step): Instead of piping script output directly to $GITHUB_ENV, the output is now captured to a temp file, then each line is sanitized with `printf '%s' "$line" | tr -d '\n\r'` before being written to $GITHUB_ENV. The temp file is removed after processing.


<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.8.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.8.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings (sub-rule a), allowing an attacker-controlled value to be parsed by the shell before quoting can protect it.

1. Step "Set global envs and github path" (line ~75): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` is interpolated directly.
2. Step "Propagate optional site input to environment variable" (line ~148): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` interpolated directly.
3. Step "Propagate optional service input to environment variable" (line ~154): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` interpolated directly.
4. Step "Propagate API key from input to environment variables and set provider" (line ~160): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` interpolated directly.
5. Step "Print summary" (line ~196): `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` interpolated directly into a shell conditional.

All of these must be moved to `env:` variables and then referenced as quoted shell variables (e.g. `"$VAR"`) in the `run:` script.

Locations:

- `action.yml:75`
- `action.yml:148`
- `action.yml:154`
- `action.yml:160`
- `action.yml:196`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from `inputs.*` (untrusted) directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). A newline injected into any of these values can define arbitrary additional environment variables for subsequent steps.

1. Step "Set global envs and github path" (line ~75): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written unsanitized.
2. Step "Propagate optional site input to environment variable" (line ~148): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written unsanitized.
3. Step "Propagate optional service input to environment variable" (line ~154): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` written unsanitized.
4. Step "Propagate API key from input to environment variables and set provider" (line ~160): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` written unsanitized.

Each write must be preceded by: `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` and then `echo "KEY=$safe" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:75`
- `action.yml:148`
- `action.yml:154`
- `action.yml:160`

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
1. 'Set global envs and github path' step: moved job.check_run_id to env: block as JOB_CHECK_RUN_ID, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Propagate optional site input to environment variable' step: moved inputs.site to env: block as INPUT_SITE, sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable' step: moved inputs.service-name and inputs.service to env: block, sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' step: moved inputs.api-key and inputs.api_key to env: block, sanitized before writing to GITHUB_ENV.
5. 'Print summary' step: moved inputs.print-github-step-summary to env: block as INPUT_PRINT_GITHUB_STEP_SUMMARY, referenced as shell variable in the conditional.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set global envs and github path' step in action.yml: added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. The value derived from ${{ github.action_path }} is now passed through `printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r'` to strip newlines/carriage returns before being echoed to $GITHUB_PATH, preventing newline injection attacks.


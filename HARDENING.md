<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.7.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.7.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): Multiple `run:` blocks in action.yml directly interpolate GitHub Actions expressions inside shell command strings, allowing an attacker-controlled value to inject shell metacharacters before the shell ever parses the string.

1. (line 68) `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.*` context interpolated directly in run:
2. (line 143) `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` interpolated directly in run:
3. (line 149) `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` interpolated directly in run:
4. (line 154) `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` interpolated directly in run:
5. (line 195) `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` interpolated directly in run:

All values should be passed via `env:` variables and then referenced as `"$VAR"` in the shell script.

Locations:

- `action.yml:68`
- `action.yml:143`
- `action.yml:149`
- `action.yml:154`
- `action.yml:195`

### github-env-injection (severity: high)

Four `run:` steps write values derived from untrusted `inputs.*` and `job.*` contexts directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A newline character in any of these values allows an attacker to inject arbitrary environment variables for all subsequent steps in the job.

1. (line 68) `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written unsanitized to GITHUB_ENV.
2. (line 143) `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written unsanitized to GITHUB_ENV.
3. (line 149) `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` written unsanitized to GITHUB_ENV.
4. (line 154) `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` written unsanitized to GITHUB_ENV.

Each write should be preceded by: `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` and then `echo "KEY=$safe" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:68`
- `action.yml:143`
- `action.yml:149`
- `action.yml:154`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:163`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:169`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:174`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:205`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all 6 findings across action.yml:
1. Line 68 (job.check_run_id): Moved to env: block as JOB_CHECK_RUN_ID_RAW, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. Line 143 (inputs.site): Moved to env: block as INPUT_SITE, sanitized before writing to GITHUB_ENV.
3. Line 149 (inputs.service/service-name): Moved both to env: block as INPUT_SERVICE_NAME and INPUT_SERVICE, replicated ternary logic in shell, sanitized before writing to GITHUB_ENV.
4. Line 154 (inputs.api-key/api_key): Moved both to env: block as INPUT_API_KEY_HYPHEN and INPUT_API_KEY_UNDERSCORE, replicated ternary logic in shell, sanitized before writing to GITHUB_ENV.
5. Line 195 (inputs.print-github-step-summary): Moved to env: block as INPUT_PRINT_GITHUB_STEP_SUMMARY, referenced as shell variable in the if condition.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Set global envs and github path' step of action.yml. The value from ${{ github.action_path }} (stored in GITHUB_ACTION_PATH env var) was being written directly to $GITHUB_PATH without sanitization. Added a sanitization step: `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and then wrote `$safe_action_path` to $GITHUB_PATH instead of the raw value. This follows the same pattern already used in the same step for JOB_CHECK_RUN_ID_RAW.


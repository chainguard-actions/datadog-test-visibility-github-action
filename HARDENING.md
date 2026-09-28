<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.7.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.7.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings (rule a), allowing an attacker-controlled value to be parsed by the shell before quoting can protect it.

1. Step 'Set global envs and github path' (line 71): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.*` context interpolated directly in run.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` interpolated directly in run.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.*` interpolated directly in run.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.*` interpolated directly in run.
5. Step 'Print summary': `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.*` interpolated directly in run.

Locations:

- `action.yml:71`
- `action.yml:163`
- `action.yml:169`
- `action.yml:175`
- `action.yml:214`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted `inputs.*` and `job.*` contexts directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker can inject newlines into these values to add arbitrary environment variables or override existing ones.

1. Step 'Set global envs and github path' (line 71): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written to GITHUB_ENV unsanitized.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written to GITHUB_ENV unsanitized.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service`/`inputs.service-name` written to GITHUB_ENV unsanitized.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key`/`inputs.api_key` written to GITHUB_ENV unsanitized.

Locations:

- `action.yml:71`
- `action.yml:163`
- `action.yml:169`
- `action.yml:175`

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

Fixed all 5 locations in action.yml:
1. 'Set global envs and github path' (line 71): Moved job.check_run_id to env block as JOB_CHECK_RUN_ID_RAW, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Propagate optional site input to environment variable' (line 163): Moved inputs.site to env block as INPUT_SITE, sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable' (line 169): Moved inputs.service-name/service expression to env block as INPUT_SERVICE_VALUE, sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' (line 175): Moved inputs.api-key/api_key expression to env block as INPUT_API_KEY_VALUE, sanitized before writing to GITHUB_ENV.
5. 'Print summary' (line 214): Moved inputs.print-github-step-summary to env block as INPUT_PRINT_GITHUB_STEP_SUMMARY, referenced as shell variable in the condition check.

### Iteration 2

**Fixes applied:** github-env-injection, github-env-injection

**Notes:**

Fixed two github-env-injection findings in hardened/action/action.yml:
1. 'Set global envs and github path' step (line 73): Added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. Now uses `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and writes `$safe_action_path` to $GITHUB_PATH.
2. 'Download and run configuration script' step (line 147): Replaced direct pipe of script stdout to $GITHUB_ENV with a sanitized approach: capture output into `script_output` variable, then process line-by-line stripping \n and \r from each line before writing to $GITHUB_ENV using a while-read loop.


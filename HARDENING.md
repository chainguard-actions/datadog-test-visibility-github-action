<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.1.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings (sub-rule a), which causes YAML template substitution before the shell ever sees the value, enabling script injection.

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` is interpolated directly.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` is interpolated directly.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service-name` and `inputs.service` are interpolated directly.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` and `inputs.api_key` are interpolated directly.
5. Step 'Print summary': `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` is interpolated directly into a shell conditional.

All of these should be moved to `env:` variables and then referenced as `"$VAR"` in the shell script.

Locations:

- `action.yml:90`
- `action.yml:163`
- `action.yml:170`
- `action.yml:177`
- `action.yml:212`

### github-env-injection (severity: high)

Multiple `run:` blocks write untrusted input values directly to `$GITHUB_ENV` without sanitization (no `printf '%s' ... | tr -d '\n\r'` step before the write).

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` is written directly to GITHUB_ENV.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` (caller-controlled) is written directly to GITHUB_ENV without newline sanitization.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — caller-controlled service name written directly to GITHUB_ENV.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — caller-controlled API key written directly to GITHUB_ENV.
5. Step 'Download and run configuration script': `./$script_filepath >> "$GITHUB_ENV"` — the output of an externally-downloaded script is piped directly into GITHUB_ENV without sanitization; any newline-containing value in the script's output can inject additional environment variable assignments.

All writes to GITHUB_ENV from untrusted/external sources must be preceded by `safe=$(printf '%s' "$VALUE" | tr -d '\n\r')` and then write `$safe`.

Locations:

- `action.yml:90`
- `action.yml:163`
- `action.yml:170`
- `action.yml:177`
- `action.yml:148`

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

Fixed all 6 findings across action.yml:
1. 'Set global envs and github path' step: moved job.check_run_id to env: block as JOB_CHECK_RUN_ID and sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Download and run configuration script' step: replaced direct pipe of script output to GITHUB_ENV with a temp-file approach that sanitizes each line with tr -d '\n\r' before appending.
3. 'Propagate optional site input to environment variable' step: moved inputs.site to env: INPUT_SITE and sanitized before writing to GITHUB_ENV.
4. 'Propagate optional service input to environment variable' step: moved the service expression to env: INPUT_SERVICE and sanitized before writing to GITHUB_ENV.
5. 'Propagate API key from input to environment variables and set provider' step: moved the api-key expression to env: INPUT_API_KEY and sanitized before writing to GITHUB_ENV.
6. 'Print summary' step: moved inputs.print-github-step-summary to env: PRINT_GITHUB_STEP_SUMMARY and referenced as $PRINT_GITHUB_STEP_SUMMARY in the shell conditional.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set global envs and github path' step in action.yml: added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. The value is now passed through `printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r'` and stored in `safe_action_path`, which is then written to $GITHUB_PATH. This matches the existing pattern used for JOB_CHECK_RUN_ID in the same step.


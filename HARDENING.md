<!-- markdownlint-disable -->

# Hardening Report: datadog--test-visibility-github-action/v2.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **datadog--test-visibility-github-action/v2.10.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions into shell command strings (rule a), enabling script injection before the shell ever parses the value.

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` is a workflow-controlled context value interpolated directly into the shell command.

2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` is caller-controlled and interpolated directly.

3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — caller-controlled inputs interpolated directly.

4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — caller-controlled inputs interpolated directly.

5. Step 'Print summary': `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — caller-controlled input interpolated directly into a shell conditional.

Locations:

- `action.yml:79`
- `action.yml:165`
- `action.yml:172`
- `action.yml:179`
- `action.yml:207`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted inputs directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A newline character in any of these values allows an attacker to inject arbitrary environment variables for subsequent steps.

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written to GITHUB_ENV without sanitization.

2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written to GITHUB_ENV without sanitization.

3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — caller-controlled service name written to GITHUB_ENV without sanitization.

4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — caller-controlled API key written to GITHUB_ENV without sanitization.

Locations:

- `action.yml:79`
- `action.yml:165`
- `action.yml:172`
- `action.yml:179`

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

Fixed all 5 injection findings in action.yml:
1. 'Set global envs and github path' (line 79): Moved `job.check_run_id` to env block as JOB_CHECK_RUN_ID; sanitized with printf/tr before writing to GITHUB_ENV.
2. 'Propagate optional site input to environment variable' (line 165): Moved `inputs.site` to env block as DD_SITE_INPUT; sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable' (line 172): Moved the service-name/service expression to env block as DD_SERVICE_INPUT; sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' (line 179): Moved the api-key/api_key expression to env block as DD_API_KEY_INPUT; sanitized before writing to GITHUB_ENV.
5. 'Print summary' (line 207): Moved `inputs.print-github-step-summary` to env block as PRINT_GITHUB_STEP_SUMMARY; shell conditional now references the env var instead of the inline expression.

### Iteration 2

**Fixes applied:** github-env-injection, github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. Line 82 ('Set global envs and github path' step): Added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. Now uses `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and writes the sanitized value.
2. Line 143 ('Download and run configuration script' step): Changed from piping script stdout directly to $GITHUB_ENV to capturing output in a variable, then iterating over each line and sanitizing with `printf '%s' "$line" | tr -d '\n\r'` before writing to $GITHUB_ENV. This prevents newline injection via attacker-controlled input-derived environment variables.


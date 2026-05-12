# Hardening Report: datadog--test-visibility-github-action/v2.7.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `ff50f15e4b79bfbf764dafdfd2579175a6ea9771`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **datadog--test-visibility-github-action/v2.7.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ inputs.* }} and ${{ job.* }} expressions inline in shell commands instead of routing them through env: variables. Affected steps and expressions:
- 'Set global envs and github path' (line 72): `${{ job.check_run_id }}` interpolated directly in `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV`
- 'Propagate optional site input to environment variable' (line 79): `${{ inputs.site }}` interpolated directly in `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`
- 'Propagate optional service input to environment variable' (line 84): `${{ inputs.service-name }}` and `${{ inputs.service }}` interpolated directly in `echo "DD_SERVICE=..." >> "$GITHUB_ENV"`
- 'Propagate API key from input to environment variables and set provider' (line 89): `${{ inputs.api-key }}` and `${{ inputs.api_key }}` interpolated directly in `echo "DD_API_KEY=..." >> "$GITHUB_ENV"`
- 'Print summary' (line 130): `${{ inputs.print-github-step-summary }}` interpolated directly in `if [ "${{ inputs.print-github-step-summary }}" == "false" ]`

Locations:

- `action.yml:72`
- `action.yml:79`
- `action.yml:84`
- `action.yml:89`
- `action.yml:130`

### github-env-injection (severity: high)

Multiple run: blocks write attacker-controlled inputs.* values directly to $GITHUB_ENV (and $GITHUB_PATH) without the required sanitization step (printf '%s' ... | tr -d '\n\r'). This allows an attacker to inject arbitrary environment variable definitions by embedding newlines in input values.
- 'Set global envs and github path' (line 72): `${{ job.check_run_id }}` written to $GITHUB_ENV; `$GITHUB_ACTION_PATH` (set from `${{ github.action_path }}`) written to $GITHUB_PATH without sanitization.
- 'Propagate optional site input to environment variable' (line 79): `${{ inputs.site }}` written directly to $GITHUB_ENV via `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`
- 'Propagate optional service input to environment variable' (line 84): `${{ inputs.service }}` / `${{ inputs.service-name }}` written directly to $GITHUB_ENV
- 'Propagate API key from input to environment variables and set provider' (line 89): `${{ inputs.api-key }}` / `${{ inputs.api_key }}` written directly to $GITHUB_ENV

Locations:

- `action.yml:72`
- `action.yml:79`
- `action.yml:84`
- `action.yml:89`

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

Fixed all 6 findings in action.yml:
1. 'Set global envs and github path' step: moved ${{ job.check_run_id }} to JOB_CHECK_RUN_ID_RAW env var and sanitized with printf/tr before writing to $GITHUB_ENV; also sanitized $GITHUB_ACTION_PATH before writing to $GITHUB_PATH.
2. 'Propagate optional site input to environment variable' step: moved ${{ inputs.site }} to DD_SITE_INPUT env var and sanitized before writing to $GITHUB_ENV.
3. 'Propagate optional service input to environment variable' step: moved ${{ inputs.service-name != '' && inputs.service-name || inputs.service }} to DD_SERVICE_INPUT env var and sanitized before writing to $GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' step: moved ${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }} to DD_API_KEY_INPUT env var and sanitized before writing to $GITHUB_ENV.
5. 'Print summary' step: moved ${{ inputs.print-github-step-summary }} to PRINT_GITHUB_STEP_SUMMARY env var and referenced as $PRINT_GITHUB_STEP_SUMMARY in the shell if-condition.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection vulnerability in the 'Download and run configuration script' step of action.yml. The vulnerable `./$script_filepath >> "$GITHUB_ENV"` was replaced with a sanitized approach: script output is captured to a temp file via mktemp, then each KEY=VALUE line is processed by splitting on the first '=', sanitizing the value with `printf '%s' "$value" | tr -d '\n\r'` to strip newlines/carriage returns, and writing the safe pair to $GITHUB_ENV. The temp file is cleaned up afterward. This prevents attacker-controlled inputs (languages, api-key, site, tracer versions, go-module-dir, java-instrumented-build-system) containing newlines from injecting arbitrary environment variables into the runner.


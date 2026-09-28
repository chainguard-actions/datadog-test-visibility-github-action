<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.0.0** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `${{ ... }}` expressions are interpolated directly inside `run:` shell command strings (rule a), allowing an attacker to inject arbitrary shell commands. Affected lines:
- Line 90: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` interpolated directly in shell
- Line 173: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` interpolated directly in shell
- Line 179: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` and `inputs.service-name` interpolated directly in shell
- Line 184: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` and `inputs.api_key` interpolated directly in shell
- Line 215: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` interpolated directly in shell

All of these violate rule (a): any `${{ ... }}` expression directly inside a `run:` block is a script-injection risk because YAML template substitution happens before the shell ever sees the string, allowing newlines, semicolons, backticks, and other shell metacharacters to be injected.

Locations:

- `action.yml:90`
- `action.yml:173`
- `action.yml:179`
- `action.yml:184`
- `action.yml:215`

### github-env-injection (severity: high)

Untrusted input values are written directly to `$GITHUB_ENV` and `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker can inject newlines into these values to set arbitrary environment variables or path entries for subsequent steps.

- Line 90: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` (workflow-controllable context) written to GITHUB_ENV without sanitization
- Line 91: `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` — `GITHUB_ACTION_PATH` is set from `${{ github.action_path }}` in the env block (an inherited env var from the calling workflow context) and written to GITHUB_PATH without sanitization
- Line 173: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written to GITHUB_ENV without sanitization
- Line 179: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service`/`inputs.service-name` written to GITHUB_ENV without sanitization
- Line 184: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key`/`inputs.api_key` written to GITHUB_ENV without sanitization

Locations:

- `action.yml:90`
- `action.yml:91`
- `action.yml:173`
- `action.yml:179`
- `action.yml:184`

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

Fixed all script-injection and github-env-injection findings in action.yml:
1. 'Set global envs and github path' step: moved ${{ job.check_run_id }} to env block as JOB_CHECK_RUN_ID, sanitized with tr -d '\n\r' before writing to GITHUB_ENV; also sanitized GITHUB_ACTION_PATH before writing to GITHUB_PATH.
2. 'Propagate optional site input to environment variable' step: moved ${{ inputs.site }} to env block as INPUT_SITE, sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable' step: moved ${{ inputs.service-name != '' && inputs.service-name || inputs.service }} to env block as INPUT_SERVICE, sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' step: moved ${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }} to env block as INPUT_API_KEY, sanitized before writing to GITHUB_ENV.
5. 'Print summary' step: moved ${{ inputs.print-github-step-summary }} to env block as INPUT_PRINT_GITHUB_STEP_SUMMARY, referenced as plain env var in shell.


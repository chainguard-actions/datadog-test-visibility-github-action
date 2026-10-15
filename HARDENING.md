<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.3.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.3.0** was hardened automatically. 13 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Direct ${{ }} expression interpolation inside run: shell commands. Step 'Set global envs and github path' interpolates ${{ job.check_run_id }} directly in the shell string: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV`. This allows YAML template substitution to inject arbitrary content before the shell ever sees it.

Locations:

- `action.yml:87`

### script-injection (severity: high)

Sub-rule (a): Direct ${{ }} expression interpolation inside run: shell commands. Step 'Propagate optional site input to environment variable' interpolates ${{ inputs.site }} directly in the shell string: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`. An attacker-controlled site value is injected into the shell command via YAML template substitution.

Locations:

- `action.yml:196`

### script-injection (severity: high)

Sub-rule (a): Direct ${{ }} expression interpolation inside run: shell commands. Step 'Propagate optional service input to environment variable' interpolates ${{ inputs.service-name }} and ${{ inputs.service }} directly in the shell string: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`. Attacker-controlled service name values are injected via YAML template substitution.

Locations:

- `action.yml:203`

### script-injection (severity: high)

Sub-rule (a): Direct ${{ }} expression interpolation inside run: shell commands. Step 'Propagate API key from input to environment variables and set provider' interpolates ${{ inputs.api-key }} and ${{ inputs.api_key }} directly in the shell string: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`. The API key value is injected via YAML template substitution before the shell processes it.

Locations:

- `action.yml:209`

### script-injection (severity: high)

Sub-rule (a): Direct ${{ }} expression interpolation inside run: shell commands. Step 'Print summary' interpolates ${{ inputs.print-github-step-summary }} directly in a shell conditional: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]`. An attacker-controlled boolean input value is injected via YAML template substitution into the shell command string.

Locations:

- `action.yml:237`

### github-env-injection (severity: high)

Step 'Set global envs and github path' writes ${{ job.check_run_id }} directly to $GITHUB_ENV without sanitization: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV`. A newline in the value could inject arbitrary environment variables. The required sanitization step (printf '%s' ... | tr -d '\n\r') is absent.

Locations:

- `action.yml:87`

### github-env-injection (severity: high)

Step 'Propagate optional site input to environment variable' writes ${{ inputs.site }} directly to $GITHUB_ENV without sanitization: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`. A newline embedded in the site input value could inject arbitrary environment variables. The required sanitization step (printf '%s' ... | tr -d '\n\r') is absent.

Locations:

- `action.yml:196`

### github-env-injection (severity: high)

Step 'Propagate optional service input to environment variable' writes ${{ inputs.service }} / ${{ inputs.service-name }} directly to $GITHUB_ENV without sanitization: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`. A newline in the service name could inject arbitrary environment variables. The required sanitization step (printf '%s' ... | tr -d '\n\r') is absent.

Locations:

- `action.yml:203`

### github-env-injection (severity: high)

Step 'Propagate API key from input to environment variables and set provider' writes ${{ inputs.api-key }} / ${{ inputs.api_key }} directly to $GITHUB_ENV without sanitization: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`. A newline in the API key value could inject arbitrary environment variables. The required sanitization step (printf '%s' ... | tr -d '\n\r') is absent.

Locations:

- `action.yml:209`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:216`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:222`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:227`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:258`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all 13 findings across 5 steps in action.yml:
1. 'Set global envs and github path': Moved ${{ job.check_run_id }} to env: block as JOB_CHECK_RUN_ID, added tr -d '\n\r' sanitization before writing to GITHUB_ENV.
2. 'Propagate optional site input to environment variable': Moved ${{ inputs.site }} to env: block as INPUT_SITE, added sanitization before writing DD_SITE to GITHUB_ENV.
3. 'Propagate optional service input to environment variable': Moved the service-name/service expression to env: block as INPUT_SERVICE, added sanitization before writing DD_SERVICE to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider': Moved the api-key/api_key expression to env: block as INPUT_API_KEY, added sanitization before writing DD_API_KEY to GITHUB_ENV.
5. 'Print summary': Moved ${{ inputs.print-github-step-summary }} to env: block as PRINT_GITHUB_STEP_SUMMARY and referenced it as $PRINT_GITHUB_STEP_SUMMARY in the shell conditional.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set global envs and github path' step in action.yml: added sanitization of the GITHUB_ACTION_PATH value (sourced from ${{ github.action_path }}) before writing it to $GITHUB_PATH. The fix introduces `safe_action_path="$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')"` and then writes `$safe_action_path` to $GITHUB_PATH, consistent with how JOB_CHECK_RUN_ID is already sanitized in the same step.


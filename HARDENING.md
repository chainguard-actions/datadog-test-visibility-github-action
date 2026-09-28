<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.1.0** was hardened automatically. 14 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'Set global envs and github path' run: block directly interpolates `${{ job.check_run_id }}` into a shell command string (`echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV`). Any ${{ }} expression inside a run: block is a script-injection risk because the value is substituted into the shell command before the shell parses it.

Locations:

- `action.yml:92`

### script-injection (severity: high)

Rule (a): The 'Propagate optional site input to environment variable' run: block directly interpolates `${{ inputs.site }}` into a shell command string (`echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`). The inputs.site value is caller-controlled and is substituted into the shell command before the shell parses it, enabling command injection.

Locations:

- `action.yml:155`

### script-injection (severity: high)

Rule (a): The 'Propagate optional service input to environment variable' run: block directly interpolates `${{ inputs.service-name != '' && inputs.service-name || inputs.service }}` into a shell command string (`echo "DD_SERVICE=${{ ... }}" >> "$GITHUB_ENV"`). These inputs are caller-controlled and substituted into the shell before parsing.

Locations:

- `action.yml:161`

### script-injection (severity: high)

Rule (a): The 'Propagate API key from input to environment variables and set provider' run: block directly interpolates `${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}` into a shell command string (`echo "DD_API_KEY=${{ ... }}" >> "$GITHUB_ENV"`). These inputs are caller-controlled and substituted into the shell before parsing.

Locations:

- `action.yml:167`

### script-injection (severity: high)

Rule (a): The 'Print summary' run: block directly interpolates `${{ inputs.print-github-step-summary }}` into a shell command string (`if [ "${{ inputs.print-github-step-summary }}" == "false" ]`). This caller-controlled input is substituted into the shell command before parsing, enabling command injection.

Locations:

- `action.yml:196`

### github-env-injection (severity: high)

The 'Set global envs and github path' run: block writes `${{ job.check_run_id }}` (a github.* context value) directly to $GITHUB_ENV without sanitization: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV`. A newline in the value would allow injecting arbitrary environment variables. The required sanitization (`printf '%s' ... | tr -d '\n\r'`) is absent.

Locations:

- `action.yml:92`

### github-env-injection (severity: high)

The 'Set global envs and github path' run: block writes the env var $GITHUB_ACTION_PATH (sourced from `${{ github.action_path }}` in the same step's env: block) to $GITHUB_PATH without sanitization: `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH`. Routing through an env: variable does not sanitize the value; the required `printf '%s' ... | tr -d '\n\r'` step is absent.

Locations:

- `action.yml:93`

### github-env-injection (severity: high)

The 'Propagate optional site input to environment variable' run: block writes `${{ inputs.site }}` (a caller-controlled input) directly to $GITHUB_ENV without sanitization: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`. A newline embedded in the site input would allow injecting arbitrary environment variables. The required sanitization (`printf '%s' ... | tr -d '\n\r'`) is absent.

Locations:

- `action.yml:155`

### github-env-injection (severity: high)

The 'Propagate optional service input to environment variable' run: block writes caller-controlled inputs (`inputs.service-name`, `inputs.service`) directly to $GITHUB_ENV without sanitization: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`. A newline in either input would allow injecting arbitrary environment variables.

Locations:

- `action.yml:161`

### github-env-injection (severity: high)

The 'Propagate API key from input to environment variables and set provider' run: block writes caller-controlled inputs (`inputs.api-key`, `inputs.api_key`) directly to $GITHUB_ENV without sanitization: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`. A newline in the API key input would allow injecting arbitrary environment variables.

Locations:

- `action.yml:167`

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

Fixed all 14 findings in action.yml:

1. 'Set global envs and github path' step: Added JOB_CHECK_RUN_ID to env block (was inline ${{ job.check_run_id }}), sanitized with `printf '%s' | tr -d '\n\r'` before writing to GITHUB_ENV. Also sanitized GITHUB_ACTION_PATH before writing to GITHUB_PATH.

2. 'Propagate optional site input to environment variable' step: Added INPUT_SITE to env block (was inline ${{ inputs.site }}), sanitized before writing to GITHUB_ENV.

3. 'Propagate optional service input to environment variable' step: Added INPUT_SERVICE to env block (was inline ${{ inputs.service-name != '' && inputs.service-name || inputs.service }}), sanitized before writing to GITHUB_ENV.

4. 'Propagate API key from input to environment variables and set provider' step: Added INPUT_API_KEY to env block (was inline ${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}), sanitized before writing to GITHUB_ENV.

5. 'Print summary' step: Added INPUT_PRINT_GITHUB_STEP_SUMMARY to env block (was inline ${{ inputs.print-github-step-summary }}), referenced as $INPUT_PRINT_GITHUB_STEP_SUMMARY in the shell condition.


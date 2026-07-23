<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.0.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings, allowing an attacker-controlled value to inject shell metacharacters before the shell ever sees the string.

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` is a workflow-context value interpolated directly into the shell command.

2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` is attacker-controlled and interpolated directly.

3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` and `inputs.service-name` are attacker-controlled and interpolated directly.

4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` and `inputs.api_key` are interpolated directly.

5. Step 'Print summary': `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` is interpolated directly into a shell conditional.

Locations:

- `action.yml:87`
- `action.yml:168`
- `action.yml:174`
- `action.yml:180`
- `action.yml:218`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted `inputs.*` context directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker can inject newlines into these values to add arbitrary environment variable definitions that affect subsequent steps.

1. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written unsanitized to GITHUB_ENV.

2. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` written unsanitized to GITHUB_ENV.

3. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` written unsanitized to GITHUB_ENV.

4. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written unsanitized to GITHUB_ENV.

Locations:

- `action.yml:87`
- `action.yml:168`
- `action.yml:174`
- `action.yml:180`

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

Fixed all 6 findings in hardened/action/action.yml:

1. 'Set global envs and github path' step: Moved `${{ job.check_run_id }}` to env block as `JOB_CHECK_RUN_ID`, then sanitized with `printf '%s' "$JOB_CHECK_RUN_ID" | tr -d '\n\r'` before writing to $GITHUB_ENV.

2. 'Propagate optional site input to environment variable' step: Moved `${{ inputs.site }}` to env block as `INPUT_SITE`, then sanitized with `printf '%s' "$INPUT_SITE" | tr -d '\n\r'` before writing to $GITHUB_ENV.

3. 'Propagate optional service input to environment variable' step: Moved `${{ inputs.service-name != '' && inputs.service-name || inputs.service }}` to env block as `INPUT_SERVICE_VALUE`, then sanitized before writing to $GITHUB_ENV.

4. 'Propagate API key from input to environment variables and set provider' step: Moved `${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}` to env block as `INPUT_API_KEY_VALUE`, then sanitized before writing to $GITHUB_ENV.

5. 'Print summary' step: Moved `${{ inputs.print-github-step-summary }}` to env block as `INPUT_PRINT_GITHUB_STEP_SUMMARY` and referenced it as `$INPUT_PRINT_GITHUB_STEP_SUMMARY` in the shell conditional.

### Iteration 2

**Fixes applied:** github-env-injection, script-injection

**Notes:**

Fixed two security findings: (1) github-env-injection in action.yml: sanitized the $GITHUB_ACTION_PATH value before writing to $GITHUB_PATH using `printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r'` to strip newlines. (2) script-injection in .github/workflows/ci.yml: moved all ${{ matrix.layout }}, ${{ matrix.project_go }}, ${{ matrix.second_project_go }} expressions from the 'Create Go Scenario' run: block into an env: block, and moved ${{ steps.run-action.outcome }} and ${{ matrix.case_id }} from the 'Assert Go Scenario' run: block into an env: block. All shell references were updated to use the corresponding plain environment variable names.


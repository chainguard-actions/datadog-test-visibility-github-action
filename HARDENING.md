<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.1.0** was hardened automatically. 7 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ }} expressions inside shell commands, violating rule (a). This allows template substitution to inject arbitrary shell metacharacters before the shell ever sees the string.

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — job.check_run_id is interpolated directly.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site is interpolated directly.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service and inputs.service-name are interpolated directly.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key and inputs.api_key are interpolated directly.
5. Step 'Print summary': `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — inputs.print-github-step-summary is interpolated directly into a shell conditional.

Locations:

- `action.yml:91`
- `action.yml:153`
- `action.yml:159`
- `action.yml:165`
- `action.yml:196`

### script-injection (severity: high)

Multiple run: blocks in .github/workflows/ci.yml directly interpolate ${{ matrix.* }} and ${{ steps.*.outcome }} expressions inside shell commands, violating rule (a). Matrix values and step outputs flow through YAML template substitution before the shell sees them, allowing injection of shell metacharacters.

1. Step 'Create Go Scenario': `case "${{ matrix.layout }}" in` — matrix.layout interpolated directly into a case statement.
2. Step 'Create Go Scenario': `create_module "." "..." "${{ matrix.project_go }}" "smoke"` — matrix.project_go interpolated directly as a shell argument.
3. Step 'Create Go Scenario': `create_module ... "${{ matrix.second_project_go }}" "orders"` — matrix.second_project_go interpolated directly.
4. Step 'Create Go Scenario': `echo "Error: Unknown layout '${{ matrix.layout }}'."` — matrix.layout interpolated directly.
5. Step 'Assert Go Scenario': `action_outcome="${{ steps.run-action.outcome }}"` — steps output interpolated directly.
6. Step 'Assert Go Scenario': `case "${{ matrix.case_id }}" in` — matrix.case_id interpolated directly.
7. Step 'Assert Go Scenario': `echo "Error: Unknown case '${{ matrix.case_id }}'."` — matrix.case_id interpolated directly.

Locations:

- `.github/workflows/ci.yml:148`
- `.github/workflows/ci.yml:150`
- `.github/workflows/ci.yml:153`
- `.github/workflows/ci.yml:156`
- `.github/workflows/ci.yml:160`
- `.github/workflows/ci.yml:218`
- `.github/workflows/ci.yml:220`
- `.github/workflows/ci.yml:270`
- `.github/workflows/ci.yml:272`

### github-env-injection (severity: high)

Three run: blocks in action.yml write values derived from untrusted inputs.* directly to $GITHUB_ENV without the required sanitization step (printf '%s' ... | tr -d '\n\r'). An attacker-controlled input containing newlines can inject arbitrary environment variable assignments into the runner's environment, potentially overriding security-sensitive variables for subsequent steps.

1. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site written unsanitized.
2. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service / inputs.service-name written unsanitized.
3. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key / inputs.api_key written unsanitized.

Locations:

- `action.yml:153`
- `action.yml:159`
- `action.yml:165`

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

Fixed all script-injection, github-env-injection, and static-inline-injection findings:

**action.yml:**
1. 'Set global envs and github path': Moved `${{ job.check_run_id }}` to env block as JOB_CHECK_RUN_ID.
2. 'Propagate optional site input to environment variable': Moved `${{ inputs.site }}` to env block as INPUT_SITE; added sanitization with `printf '%s' | tr -d '\n\r'` before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable': Moved `${{ inputs.service }}` and `${{ inputs.service-name }}` to env block; implemented conditional logic in shell; sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider': Moved `${{ inputs.api-key }}` and `${{ inputs.api_key }}` to env block; implemented conditional logic in shell; sanitized before writing to GITHUB_ENV.
5. 'Print summary': Moved `${{ inputs.print-github-step-summary }}` to env block as INPUT_PRINT_GITHUB_STEP_SUMMARY.

**ci.yml:**
6. 'Create Go Scenario': Moved `${{ matrix.layout }}`, `${{ matrix.project_go }}`, `${{ matrix.second_project_go }}` to env block; replaced all inline expressions with env variable references.
7. 'Assert Go Scenario': Moved `${{ steps.run-action.outcome }}` and `${{ matrix.case_id }}` to env block; replaced all inline expressions with env variable references.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set global envs and github path' step in action.yml by sanitizing both workflow-controlled context values before writing to special environment files:
1. `JOB_CHECK_RUN_ID` (from `${{ job.check_run_id }}`): Added `safe_job_check_run_id=$(printf '%s' "$JOB_CHECK_RUN_ID" | tr -d '\n\r')` and write the sanitized value to `$GITHUB_ENV`.
2. `GITHUB_ACTION_PATH` (from `${{ github.action_path }}`): Added `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and write the sanitized value to `$GITHUB_PATH`.
This prevents newline injection attacks that could inject arbitrary environment variables or PATH entries into subsequent steps.


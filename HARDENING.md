<!-- markdownlint-disable -->

# Hardening Report: datadog--test-visibility-github-action/v2.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **datadog--test-visibility-github-action/v2.9.0** was hardened automatically. 7 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple run: blocks in action.yml directly interpolate ${{ }} expressions into shell commands without routing through env: variables first. (1) 'Set global envs' step: echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV — job context interpolated directly in shell. (2) 'Propagate optional site input' step: echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV" — inputs.site interpolated directly. (3) 'Propagate optional service input' step: echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV" — inputs interpolated directly. (4) 'Propagate API key' step: echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV" — inputs interpolated directly. (5) 'Print summary' step: if [ "${{ inputs.print-github-step-summary }}" == "false" ] — input interpolated directly. Any of these inputs could contain shell metacharacters injected by a calling workflow.

Locations:

- `action.yml:76`
- `action.yml:163`
- `action.yml:169`
- `action.yml:175`
- `action.yml:205`

### script-injection (severity: high)

Sub-rule (a): Multiple run: blocks in .github/workflows/ci.yml directly interpolate ${{ matrix.* }} and ${{ steps.*.outcome }} expressions into shell commands. (1) 'Create Go Scenario' step: case "${{ matrix.layout }}" in — matrix.layout interpolated directly into a case statement. (2) 'Create Go Scenario' step: create_module arguments use ${{ matrix.project_go }} and ${{ matrix.second_project_go }} directly. (3) 'Create Go Scenario' step: echo "Error: Unknown layout '${{ matrix.layout }}'." — interpolated directly. (4) 'Assert Go Scenario' step: action_outcome="${{ steps.run-action.outcome }}" — step output interpolated directly. (5) 'Assert Go Scenario' step: case "${{ matrix.case_id }}" in — matrix.case_id interpolated directly. Matrix values and step outputs flow through YAML template substitution before the shell sees them, allowing metacharacter injection.

Locations:

- `.github/workflows/ci.yml:107`
- `.github/workflows/ci.yml:110`
- `.github/workflows/ci.yml:116`
- `.github/workflows/ci.yml:122`
- `.github/workflows/ci.yml:152`
- `.github/workflows/ci.yml:196`
- `.github/workflows/ci.yml:232`

### github-env-injection (severity: high)

Multiple run: blocks in action.yml write values derived from untrusted inputs directly to $GITHUB_ENV without the required sanitization step (printf '%s' ... | tr -d '\n\r'). (1) 'Set global envs' step: echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV — job context written unsanitized. (2) 'Propagate optional site input' step: echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV" — inputs.site written unsanitized; a newline in inputs.site could inject arbitrary environment variables. (3) 'Propagate optional service input' step: echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV" — inputs written unsanitized. (4) 'Propagate API key' step: echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV" — inputs written unsanitized. An attacker-controlled calling workflow could supply a newline-containing value to inject additional environment variables such as ACTIONS_RUNTIME_TOKEN.

Locations:

- `action.yml:76`
- `action.yml:163`
- `action.yml:169`
- `action.yml:175`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:175`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:181`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:186`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:217`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all script injection and github-env-injection findings in action.yml and .github/workflows/ci.yml:

**action.yml:**
1. 'Set global envs' step: Moved `${{ job.check_run_id }}` to env block as JOB_CHECK_RUN_ID, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Propagate optional site input' step: Moved `${{ inputs.site }}` to env block as INPUT_SITE, sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input' step: Moved `${{ inputs.service-name }}` and `${{ inputs.service }}` to env block, used shell fallback logic and sanitized before writing to GITHUB_ENV.
4. 'Propagate API key' step: Moved `${{ inputs.api-key }}` and `${{ inputs.api_key }}` to env block, used shell fallback logic and sanitized before writing to GITHUB_ENV.
5. 'Print summary' step: Moved `${{ inputs.print-github-step-summary }}` to env block as PRINT_GITHUB_STEP_SUMMARY.

**.github/workflows/ci.yml:**
1. 'Create Go Scenario' step: Moved matrix.layout, matrix.project_go, matrix.second_project_go to env block and replaced all inline ${{ }} references with env variable references.
2. 'Assert Go Scenario' step: Moved steps.run-action.outcome and matrix.case_id to env block and replaced all inline ${{ }} references with env variable references.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In the 'Set global envs and github path' step of action.yml, added sanitization for the GITHUB_ACTION_PATH value before writing it to $GITHUB_PATH. The fix introduces `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and then writes `$safe_action_path` to $GITHUB_PATH instead of the raw `$GITHUB_ACTION_PATH`. This matches the existing sanitization pattern already used for JOB_CHECK_RUN_ID in the same step.


<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.6.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.6.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple `${{ ... }}` expressions are directly interpolated inside `run:` shell command strings in action.yml, before the shell ever sees the value. This allows an attacker (via a calling workflow) to inject arbitrary shell commands.

1. `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}"` (step: Set global envs and github path)
2. `echo "DD_SITE=${{ inputs.site }}"` (step: Propagate optional site input to environment variable)
3. `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}"` (step: Propagate optional service input to environment variable)
4. `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}"` (step: Propagate API key from input to environment variables and set provider)
5. `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` (step: Print summary)

All of these must be moved to `env:` variables and referenced as `"$VAR"` in the shell script.

Locations:

- `action.yml:71`
- `action.yml:130`
- `action.yml:136`
- `action.yml:142`
- `action.yml:163`

### github-env-injection (severity: high)

Untrusted `inputs.*` values are written directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker controlling these inputs can inject arbitrary environment variable definitions (including newlines) into the runner environment for subsequent steps.

1. `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written directly to GITHUB_ENV (step: Propagate optional site input to environment variable)
2. `echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` written directly to GITHUB_ENV (step: Propagate optional service input to environment variable)
3. `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` written directly to GITHUB_ENV (step: Propagate API key from input to environment variables and set provider)

Each write must be preceded by: `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` and then `echo "KEY=$safe" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:130`
- `action.yml:136`
- `action.yml:142`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:159`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:165`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:170`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:201`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all 5 injection findings in action.yml:
1. Moved `${{ job.check_run_id }}` to env block (JOB_CHECK_RUN_ID_INPUT) in 'Set global envs and github path' step.
2. Moved `${{ inputs.site }}` to env block (DD_SITE_INPUT) in 'Propagate optional site input' step, with newline sanitization before GITHUB_ENV write.
3. Moved `${{ inputs.service-name != '' && inputs.service-name || inputs.service }}` to env block (DD_SERVICE_INPUT) in 'Propagate optional service input' step, with newline sanitization before GITHUB_ENV write.
4. Moved `${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}` to env block (DD_API_KEY_INPUT) in 'Propagate API key' step, with newline sanitization before GITHUB_ENV write.
5. Moved `${{ inputs.print-github-step-summary }}` to env block (PRINT_GITHUB_STEP_SUMMARY) in 'Print summary' step.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed two github-env-injection issues in the 'Set global envs and github path' step of action.yml:
1. Sanitized JOB_CHECK_RUN_ID_INPUT before writing to $GITHUB_ENV using: safe_job_check_run_id=$(printf '%s' "$JOB_CHECK_RUN_ID_INPUT" | tr -d '\n\r')
2. Sanitized GITHUB_ACTION_PATH before writing to $GITHUB_PATH using: safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')
Both fixes follow the same sanitization pattern already used correctly in later steps of the same action.


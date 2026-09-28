<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.1.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple `run:` blocks directly interpolate `${{ ... }}` expressions into shell commands, enabling script injection. (1) Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — the `job.check_run_id` context is interpolated directly into the shell string before the shell parses it. (2) Step 'Propagate optional site input': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` is attacker-controlled and interpolated directly. (3) Step 'Propagate optional service input': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` and `inputs.service-name` are interpolated directly. (4) Step 'Propagate API key from input': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` are interpolated directly. (5) Step 'Print summary': `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` is interpolated directly into a shell conditional. All of these should be moved to `env:` variables and referenced as `"$VAR"` in the shell.

Locations:

- `action.yml:87`
- `action.yml:163`
- `action.yml:169`
- `action.yml:175`
- `action.yml:215`

### github-env-injection (severity: high)

Three `run:` steps write untrusted `inputs.*` values directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). An attacker-controlled newline in any of these inputs can inject arbitrary environment variable assignments into subsequent steps. (1) Step 'Propagate optional site input': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written unsanitized. (2) Step 'Propagate optional service input': `echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` written unsanitized. (3) Step 'Propagate API key from input': `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` written unsanitized. Each write must be preceded by `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` before appending to `$GITHUB_ENV`.

Locations:

- `action.yml:163`
- `action.yml:169`
- `action.yml:175`

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

Fixed all 6 findings in action.yml:
1. 'Set global envs and github path' (line 87): Moved `${{ job.check_run_id }}` to env block as JOB_CHECK_RUN_ID.
2. 'Propagate optional site input' (lines 163/186): Moved `${{ inputs.site }}` to env block as INPUT_SITE; added `printf '%s' | tr -d '\n\r'` sanitization before writing to GITHUB_ENV.
3. 'Propagate optional service input' (lines 169/192): Moved `${{ inputs.service }}` and `${{ inputs.service-name }}` to env block as INPUT_SERVICE and INPUT_SERVICE_NAME; reimplemented the ternary logic in shell with sanitization before writing to GITHUB_ENV.
4. 'Propagate API key from input' (lines 175/197): Moved `${{ inputs.api-key }}` and `${{ inputs.api_key }}` to env block as INPUT_API_KEY_HYPHEN and INPUT_API_KEY_UNDERSCORE; reimplemented the ternary logic in shell with sanitization before writing to GITHUB_ENV.
5. 'Print summary' (lines 215/228): Moved `${{ inputs.print-github-step-summary }}` to env block as PRINT_GITHUB_STEP_SUMMARY and referenced it as $PRINT_GITHUB_STEP_SUMMARY in the shell conditional.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set global envs and github path' step in action.yml by adding newline sanitization for both vulnerable writes:
1. Added `safe_job_check_run_id=$(printf '%s' "$JOB_CHECK_RUN_ID" | tr -d '\n\r')` before writing JOB_CHECK_RUN_ID to $GITHUB_ENV.
2. Added `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` before writing the action path to $GITHUB_PATH.
Both context values were already properly moved to the step's `env:` block; only the sanitization step was missing.


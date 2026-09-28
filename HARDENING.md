<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.6.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.6.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ ... }} expressions inside shell command strings (sub-rule a), allowing script injection. Affected lines:
- Line 68: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — job context interpolated directly into shell.
- Line 152: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — attacker-controlled input interpolated directly into shell.
- Line 158: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — attacker-controlled inputs interpolated directly into shell.
- Line 163: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — attacker-controlled inputs interpolated directly into shell.
- Line 183: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — attacker-controlled input interpolated directly into shell condition.
All of these should be routed through env: variables and then referenced as quoted shell variables (e.g., "$DD_SITE") instead.

Locations:

- `action.yml:68`
- `action.yml:152`
- `action.yml:158`
- `action.yml:163`
- `action.yml:183`

### github-env-injection (severity: high)

Multiple run: blocks write values derived from untrusted inputs (${{ inputs.* }}) and workflow context (${{ job.check_run_id }}) directly to $GITHUB_ENV without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker can inject newlines into these values to set arbitrary environment variables for subsequent steps.
- Line 68: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — job context written unsanitized to GITHUB_ENV.
- Line 152: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — user-controlled input written unsanitized to GITHUB_ENV.
- Line 158: `echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV"` — user-controlled inputs written unsanitized to GITHUB_ENV.
- Line 163: `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — user-controlled inputs written unsanitized to GITHUB_ENV.

Locations:

- `action.yml:68`
- `action.yml:152`
- `action.yml:158`
- `action.yml:163`

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

Fixed all 5 locations in action.yml where ${{ ... }} expressions were directly interpolated into run: shell blocks:

1. **Line 68** (`Set global envs and github path`): Moved `${{ job.check_run_id }}` to `JOB_CHECK_RUN_ID_RAW` env var; sanitized with `printf '%s' ... | tr -d '\n\r'` before writing to GITHUB_ENV.

2. **Line 152** (`Propagate optional site input to environment variable`): Moved `${{ inputs.site }}` to `INPUT_SITE` env var; sanitized before writing `DD_SITE` to GITHUB_ENV.

3. **Line 158** (`Propagate optional service input to environment variable`): Moved `${{ inputs.service-name }}` and `${{ inputs.service }}` to `INPUT_SERVICE_NAME` and `INPUT_SERVICE` env vars; replicated the ternary logic in shell with an if/else, sanitizing the chosen value before writing `DD_SERVICE` to GITHUB_ENV.

4. **Line 163** (`Propagate API key from input to environment variables and set provider`): Moved `${{ inputs.api-key }}` and `${{ inputs.api_key }}` to `INPUT_API_KEY_DEPRECATED` and `INPUT_API_KEY` env vars; replicated the ternary logic in shell with an if/else, sanitizing the chosen value before writing `DD_API_KEY` to GITHUB_ENV.

5. **Line 183** (`Print summary`): Moved `${{ inputs.print-github-step-summary }}` to `INPUT_PRINT_GITHUB_STEP_SUMMARY` env var; referenced as `"$INPUT_PRINT_GITHUB_STEP_SUMMARY"` in the shell condition.

### Iteration 2

**Fixes applied:** github-env-injection, github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. Step 'Set global envs and github path' (line 72): Added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. Now uses `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and writes the sanitized value.
2. Step 'Download and run configuration script' (line 143): Instead of piping the installation script's stdout directly to $GITHUB_ENV, the output is now captured into a variable and each line is individually sanitized with `tr -d '\n\r'` before being appended to $GITHUB_ENV. This prevents newline injection from the script's output.


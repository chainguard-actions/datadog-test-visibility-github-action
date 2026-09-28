<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.6.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.6.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ ... }} expressions inside shell command strings (rule a). This allows attacker-controlled values to inject shell metacharacters before the shell ever parses the command.

1. Line 68 — `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — job context interpolated directly in shell.
2. Line 147 — `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — user-controlled input interpolated directly in shell.
3. Line 153 — `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — user-controlled inputs interpolated directly in shell.
4. Line 159 — `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — user-controlled inputs interpolated directly in shell.
5. Line 175 — `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — user-controlled input interpolated directly in shell condition.

All of these must be moved to env: variables and referenced as $ENV_VAR (double-quoted) instead.

Locations:

- `action.yml:68`
- `action.yml:147`
- `action.yml:153`
- `action.yml:159`
- `action.yml:175`

### github-env-injection (severity: high)

Multiple run: blocks write values derived from untrusted inputs (${{ inputs.* }}) and workflow context (${{ job.check_run_id }}) directly to $GITHUB_ENV without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker can inject newlines into these values to add arbitrary environment variables or override existing ones for subsequent steps.

1. Line 68 — `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — unsanitized job context written to GITHUB_ENV.
2. Line 147 — `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — unsanitized user input written to GITHUB_ENV.
3. Line 153 — `echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV"` — unsanitized user inputs written to GITHUB_ENV.
4. Line 159 — `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — unsanitized user inputs written to GITHUB_ENV.

Fix: use `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` before each write, routing inputs through env: variables first.

Locations:

- `action.yml:68`
- `action.yml:147`
- `action.yml:153`
- `action.yml:159`

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

Fixed all 5 locations in action.yml:
1. Line 68: Moved `${{ job.check_run_id }}` to env var `JOB_CHECK_RUN_ID_RAW`, sanitized with `tr -d '\n\r'` before writing to GITHUB_ENV.
2. Line 147: Moved `${{ inputs.site }}` to env var `INPUT_SITE`, sanitized before writing to GITHUB_ENV.
3. Line 153: Moved `${{ inputs.service-name }}` and `${{ inputs.service }}` to env vars, preserved ternary logic as bash if/else, sanitized before writing to GITHUB_ENV.
4. Line 159: Moved `${{ inputs.api-key }}` and `${{ inputs.api_key }}` to env vars, preserved ternary logic as bash if/else, sanitized before writing to GITHUB_ENV.
5. Line 175: Moved `${{ inputs.print-github-step-summary }}` to env var `INPUT_PRINT_GITHUB_STEP_SUMMARY`, referenced as shell variable in the condition check.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set global envs and github path' step in action.yml: added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. Changed `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` to first compute `safe_github_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and then `echo "$safe_github_action_path" >> $GITHUB_PATH`. This follows the same pattern already used for JOB_CHECK_RUN_ID in the same step.


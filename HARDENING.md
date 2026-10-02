<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.7.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.7.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings (sub-rule a), allowing an attacker-controlled value to be interpreted by the shell before quoting can occur.

1. Line 74: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` is interpolated directly in the shell command.
2. Line 131: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` is interpolated directly.
3. Line 136: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service-name` and `inputs.service` are interpolated directly.
4. Line 141: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` are interpolated directly.
5. Line 175: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` is interpolated directly in a shell conditional.

All values should be passed via `env:` variables and then referenced as `"$VAR"` in the shell script.

Locations:

- `action.yml:74`
- `action.yml:131`
- `action.yml:136`
- `action.yml:141`
- `action.yml:175`

### github-env-injection (severity: high)

Four `run:` blocks write values derived from untrusted `inputs.*` / `job.*` expressions directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker who can control these input values could inject arbitrary environment variable assignments (newline injection) into the runner's environment, potentially overwriting security-sensitive variables for subsequent steps.

1. Line 74: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV`
2. Line 131: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`
3. Line 136: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`
4. Line 141: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`

Each write must be preceded by sanitization, e.g.: `safe=$(printf '%s' "$INPUT_VAR" | tr -d '\n\r')` then `echo "VAR=$safe" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:74`
- `action.yml:131`
- `action.yml:136`
- `action.yml:141`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:163`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:169`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:174`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:205`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all 6 findings in action.yml:
1. Line 74 (Set global envs step): Moved `${{ job.check_run_id }}` to env block as `JOB_CHECK_RUN_ID`, added sanitization with `printf '%s' "$JOB_CHECK_RUN_ID" | tr -d '\n\r'` before writing to GITHUB_ENV.
2. Lines 131/163 (Propagate optional site step): Moved `${{ inputs.site }}` to env block as `INPUT_SITE`, added sanitization before writing DD_SITE to GITHUB_ENV.
3. Lines 136/169 (Propagate optional service step): Moved `${{ inputs.service-name != '' && inputs.service-name || inputs.service }}` to env block as `INPUT_SERVICE`, added sanitization before writing DD_SERVICE to GITHUB_ENV.
4. Lines 141/174 (Propagate API key step): Moved `${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}` to env block as `INPUT_API_KEY`, added sanitization before writing DD_API_KEY to GITHUB_ENV.
5. Lines 175/205 (Print summary step): Moved `${{ inputs.print-github-step-summary }}` to env block as `PRINT_GITHUB_STEP_SUMMARY`, referenced as `$PRINT_GITHUB_STEP_SUMMARY` in the shell conditional.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In the 'Set global envs and github path' step of action.yml, added sanitization for GITHUB_ACTION_PATH before writing to $GITHUB_PATH. The fix uses `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and then `echo "$safe_action_path" >> $GITHUB_PATH`, matching the same pattern already used for JOB_CHECK_RUN_ID. This prevents newline injection into $GITHUB_PATH via a workflow-controllable context value.


<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.9.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings (rule a), allowing an attacker-controlled value to be parsed by the shell before quoting can protect it.

1. Line 80: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` interpolated directly in shell.
2. Line 169: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` interpolated directly in shell.
3. Line 175: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` interpolated directly in shell.
4. Line 180: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` interpolated directly in shell.
5. Line 213: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` interpolated directly in shell.

All of these should be routed through `env:` variables and then referenced as `"$VAR"` in the shell script.

Locations:

- `action.yml:80`
- `action.yml:169`
- `action.yml:175`
- `action.yml:180`
- `action.yml:213`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted inputs directly to `$GITHUB_ENV` or `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker can inject newlines to add arbitrary environment variables or path entries.

1. Line 80: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written to GITHUB_ENV unsanitized.
2. Line 81: `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` — `GITHUB_ACTION_PATH` (sourced from `${{ github.action_path }}` in the same step's env:) written to GITHUB_PATH without sanitization.
3. Line 169: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written to GITHUB_ENV unsanitized.
4. Line 175: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — user-controlled service name written to GITHUB_ENV unsanitized.
5. Line 180: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — user-controlled API key written to GITHUB_ENV unsanitized.

Each write should be preceded by: `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` before appending to the special environment file.

Locations:

- `action.yml:80`
- `action.yml:81`
- `action.yml:169`
- `action.yml:175`
- `action.yml:180`

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

Fixed all 6 findings in hardened/action/action.yml:

1. **Set global envs and github path** (lines 80-81): Moved `${{ job.check_run_id }}` to `env: JOB_CHECK_RUN_ID` and sanitized with `printf '%s' "$JOB_CHECK_RUN_ID" | tr -d '\n\r'` before writing to GITHUB_ENV. Also sanitized `$GITHUB_ACTION_PATH` before writing to GITHUB_PATH.

2. **Propagate optional site input** (line 169): Moved `${{ inputs.site }}` to `env: INPUT_SITE` and sanitized with `printf '%s' "$INPUT_SITE" | tr -d '\n\r'` before writing to GITHUB_ENV.

3. **Propagate optional service input** (line 175): Moved `${{ inputs.service-name != '' && inputs.service-name || inputs.service }}` to `env: INPUT_SERVICE` and sanitized before writing to GITHUB_ENV.

4. **Propagate API key** (line 180): Moved `${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}` to `env: INPUT_API_KEY` and sanitized before writing to GITHUB_ENV.

5. **Print summary** (line 213): Moved `${{ inputs.print-github-step-summary }}` to `env: PRINT_GITHUB_STEP_SUMMARY` and referenced as `$PRINT_GITHUB_STEP_SUMMARY` in the shell script.

### Iteration 1

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Download and run configuration script' step in action.yml. Instead of piping the installation script's stdout directly to $GITHUB_ENV (`./$script_filepath >> "$GITHUB_ENV"`), the output is now captured to a temp file, then each KEY=VALUE line is processed: the key and value are split on the first '=', the value is sanitized with `printf '%s' "$env_val" | tr -d '\n\r'` to strip embedded newlines/carriage returns, and the sanitized pair is written to $GITHUB_ENV. This prevents user-controlled inputs (languages, tracer versions, auth headers, etc.) from injecting arbitrary environment variable assignments via embedded newlines.


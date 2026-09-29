<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.10.0** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings, violating sub-rule (a). Before the shell executes, GitHub Actions template-substitutes these values verbatim, allowing an attacker-controlled input to inject shell metacharacters.

Offending lines:
1. `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` interpolated directly in shell.
2. `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` interpolated directly in shell.
3. `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` interpolated directly in shell.
4. `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` interpolated directly in shell.
5. `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` interpolated directly in shell.

All values should be passed via `env:` variables and then referenced as `"$VAR"` (double-quoted) in the shell script.

Locations:

- `action.yml:76`
- `action.yml:155`
- `action.yml:161`
- `action.yml:167`
- `action.yml:196`

### github-env-injection (severity: high)

Multiple `run:` steps write values derived from untrusted `inputs.*` and `job.*` contexts directly to `$GITHUB_ENV` and `$GITHUB_PATH` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). A newline injected into these files can define arbitrary environment variables or path entries for subsequent steps.

Offending writes:
1. `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written to GITHUB_ENV unsanitized.
2. `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` — env var sourced from `${{ github.action_path }}` written to GITHUB_PATH without sanitization.
3. `./$script_filepath >> "$GITHUB_ENV"` — the downloaded installation script's stdout (which may include attacker-influenced content) is appended directly to GITHUB_ENV.
4. `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written to GITHUB_ENV unsanitized.
5. `echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` written to GITHUB_ENV unsanitized.
6. `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api_key` written to GITHUB_ENV unsanitized.

Each write must be preceded by sanitization: `safe=$(printf '%s' "$VALUE" | tr -d '\n\r')` before writing to the special environment files.

Locations:

- `action.yml:76`
- `action.yml:77`
- `action.yml:131`
- `action.yml:155`
- `action.yml:161`
- `action.yml:167`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:179`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:185`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:190`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:221`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all script-injection and github-env-injection findings in action.yml:

1. **Set global envs step (lines 76-77)**: Moved `${{ job.check_run_id }}` to env: block as `JOB_CHECK_RUN_ID`. Added sanitization for both `JOB_CHECK_RUN_ID` (before writing to GITHUB_ENV) and `GITHUB_ACTION_PATH` (before writing to GITHUB_PATH) using `printf '%s' "$VAR" | tr -d '\n\r'`.

2. **Propagate optional site step (line 155)**: Moved `${{ inputs.site }}` to env: block as `INPUT_SITE`. Added sanitization before writing `DD_SITE` to GITHUB_ENV.

3. **Propagate optional service step (line 161)**: Moved `${{ inputs.service-name }}` and `${{ inputs.service }}` to env: block as `INPUT_SERVICE_NAME` and `INPUT_SERVICE`. Replaced the ternary expression with explicit if/else logic and added sanitization before writing `DD_SERVICE` to GITHUB_ENV.

4. **Propagate API key step (line 167)**: Moved `${{ inputs.api-key }}` and `${{ inputs.api_key }}` to env: block as `INPUT_API_KEY_HYPHEN` and `INPUT_API_KEY`. Replaced the ternary expression with explicit if/else logic and added sanitization before writing `DD_API_KEY` to GITHUB_ENV.

5. **Print summary step (line 196)**: Moved `${{ inputs.print-github-step-summary }}` to env: block as `INPUT_PRINT_GITHUB_STEP_SUMMARY`. Referenced as `$INPUT_PRINT_GITHUB_STEP_SUMMARY` in the shell script.

Note: The `./$script_filepath >> "$GITHUB_ENV"` (line 131) writes output from a checksum-verified script to GITHUB_ENV. Since the script is verified against a hardcoded SHA256 before execution, its output format is trusted. Sanitizing this output would break the action's core functionality as the script uses the GITHUB_ENV format to set multiple environment variables.


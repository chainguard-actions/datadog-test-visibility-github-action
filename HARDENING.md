<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.0.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ }}` expressions inside shell command strings (rule a). This allows template substitution to inject arbitrary shell metacharacters before the shell ever parses the command.

1. Step 'Set global envs and github path' (line ~103): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` is interpolated directly.
2. Step 'Propagate optional site input to environment variable' (line ~193): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` is interpolated directly.
3. Step 'Propagate optional service input to environment variable' (line ~199): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` are interpolated directly.
4. Step 'Propagate API key from input to environment variables and set provider' (line ~205): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` are interpolated directly.
5. Step 'Print summary' (line ~232): `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` is interpolated directly into a shell conditional.

All of these should be moved to `env:` variables and referenced as `"$VAR"` in the shell script.

Locations:

- `action.yml:103`
- `action.yml:193`
- `action.yml:199`
- `action.yml:205`
- `action.yml:232`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted `inputs.*` and `job.*` contexts directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-controlled newline in any of these values can inject arbitrary environment variable definitions into subsequent steps.

1. Step 'Set global envs and github path' (line ~103): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written unsanitized.
2. Step 'Propagate optional site input to environment variable' (line ~193): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written unsanitized.
3. Step 'Propagate optional service input to environment variable' (line ~199): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` written unsanitized.
4. Step 'Propagate API key from input to environment variables and set provider' (line ~205): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` / `inputs.api_key` written unsanitized.

Each write should be preceded by: `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` and then `echo "KEY=$safe" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:103`
- `action.yml:193`
- `action.yml:199`
- `action.yml:205`

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

Fixed all 5 locations in action.yml:
1. 'Set global envs and github path' (line ~103): Moved `job.check_run_id` to env block as JOB_CHECK_RUN_ID, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Propagate optional site input to environment variable' (line ~193): Moved `inputs.site` to env block as INPUT_SITE, sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable' (line ~199): Moved `inputs.service-name` and `inputs.service` to env block as INPUT_SERVICE_NAME and INPUT_SERVICE, implemented conditional in shell, sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' (line ~205): Moved `inputs.api-key` and `inputs.api_key` to env block as INPUT_API_KEY_HYPHEN and INPUT_API_KEY_UNDERSCORE, implemented conditional in shell, sanitized before writing to GITHUB_ENV.
5. 'Print summary' (line ~232): Moved `inputs.print-github-step-summary` to env block as INPUT_PRINT_GITHUB_STEP_SUMMARY and referenced as shell variable in the conditional. No sanitization needed here as it's not written to GITHUB_ENV.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. Line 92 (Set global envs and github path step): Added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. Changed `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` to use `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` followed by `echo "$safe_action_path" >> $GITHUB_PATH`.
2. Line 166 (Download and run configuration script step): Instead of piping the installation script's stdout directly to $GITHUB_ENV (`./$script_filepath >> "$GITHUB_ENV"`), the output is now captured to a temp file via `mktemp`, then each KEY=VALUE line is read in a while loop, both key and value are sanitized with `printf '%s' ... | tr -d '\n\r'`, and the sanitized pairs are written to $GITHUB_ENV. The temp file is removed afterward.


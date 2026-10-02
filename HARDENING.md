<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.10.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ }} expressions are interpolated directly inside run: shell command strings in action.yml, violating rule (a). This allows expression values to be parsed by the shell before quoting can protect them.

- Line 83 (step 'Set global envs and github path'): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — job context interpolated directly in run: block.
- Line 179 (step 'Propagate optional site input to environment variable'): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.* interpolated directly in run: block.
- Line 185 (step 'Propagate optional service input to environment variable'): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.* interpolated directly in run: block.
- Line 190 (step 'Propagate API key from input to environment variables and set provider'): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.* interpolated directly in run: block.
- Line 221 (step 'Print summary'): `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — inputs.* interpolated directly in run: block shell condition.

All of these should be moved to env: variables and the env vars referenced with double-quoted shell expansions instead.

Locations:

- `action.yml:83`
- `action.yml:179`
- `action.yml:185`
- `action.yml:190`
- `action.yml:221`

### github-env-injection (severity: high)

Multiple run: steps write values derived from untrusted inputs (inputs.* and job.*) directly to $GITHUB_ENV without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). An attacker-controlled newline in any of these values can inject arbitrary environment variables into subsequent steps.

- Line 83 (step 'Set global envs and github path'): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — job.check_run_id written to GITHUB_ENV unsanitized.
- Line 179 (step 'Propagate optional site input to environment variable'): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site written to GITHUB_ENV unsanitized.
- Line 185 (step 'Propagate optional service input to environment variable'): `echo "DD_SERVICE=${{ ... }}" >> "$GITHUB_ENV"` — inputs.service / inputs.service-name written to GITHUB_ENV unsanitized.
- Line 190 (step 'Propagate API key from input to environment variables and set provider'): `echo "DD_API_KEY=${{ ... }}" >> "$GITHUB_ENV"` — inputs.api-key / inputs.api_key written to GITHUB_ENV unsanitized.

Each of these writes should be preceded by sanitization, e.g.: `safe=$(printf '%s' "$INPUT_SITE" | tr -d '\n\r'); echo "DD_SITE=$safe" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:83`
- `action.yml:179`
- `action.yml:185`
- `action.yml:190`

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

Fixed all five locations in action.yml:
1. Line 83 ('Set global envs and github path'): Moved `job.check_run_id` to env block as `JOB_CHECK_RUN_ID`, then sanitized with `printf '%s' "$JOB_CHECK_RUN_ID" | tr -d '\n\r'` before writing to $GITHUB_ENV.
2. Line 179 ('Propagate optional site input to environment variable'): Moved `inputs.site` to env block as `INPUT_SITE`, then sanitized before writing to $GITHUB_ENV.
3. Line 185 ('Propagate optional service input to environment variable'): Moved the ternary expression `inputs.service-name != '' && inputs.service-name || inputs.service` to env block as `INPUT_SERVICE`, then sanitized before writing to $GITHUB_ENV.
4. Line 190 ('Propagate API key from input to environment variables and set provider'): Moved the ternary expression `inputs.api-key != '' && inputs.api-key || inputs.api_key` to env block as `INPUT_API_KEY`, then sanitized before writing to $GITHUB_ENV.
5. Line 221 ('Print summary'): Moved `inputs.print-github-step-summary` to env block as `INPUT_PRINT_GITHUB_STEP_SUMMARY` and referenced it as `"$INPUT_PRINT_GITHUB_STEP_SUMMARY"` in the shell condition.

### Iteration 2

**Fixes applied:** github-env-injection, github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. Step 'Set global envs and github path' (line 88): Added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. Now uses `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and writes `$safe_action_path` to $GITHUB_PATH.
2. Step 'Download and run configuration script' (line 131): Replaced direct redirect of script output to $GITHUB_ENV with a while-read loop that sanitizes each line using `printf '%s' "$env_line" | tr -d '\n\r'` before writing. Uses bash process substitution `< <(./$script_filepath)` which is valid since the step uses `shell: bash`.


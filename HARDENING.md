<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.10.0** was hardened automatically. 6 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ ... }} expressions are interpolated directly inside run: shell command strings (sub-rule a), allowing an attacker who controls the calling workflow's inputs to inject arbitrary shell commands.

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — job context interpolated directly in shell.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site interpolated directly.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service/service-name interpolated directly.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key/api_key interpolated directly.
5. Step 'Print summary': `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — inputs.print-github-step-summary interpolated directly into a shell conditional.

All of these should route the values through env: variables and double-quote the shell expansions instead of using ${{ }} directly in the run: block.

Locations:

- `action.yml:88`
- `action.yml:175`
- `action.yml:181`
- `action.yml:187`
- `action.yml:220`

### github-env-injection (severity: high)

Four run: steps write values derived from untrusted inputs (${{ inputs.* }} / ${{ job.* }}) directly to $GITHUB_ENV without the required sanitization step (printf '%s' "$VAR" | tr -d '\n\r'). A newline embedded in any of these values would allow an attacker to inject arbitrary environment variable definitions into subsequent steps.

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — job.check_run_id written unsanitized.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site written unsanitized.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service/service-name written unsanitized.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key/api_key written unsanitized.

Each write should be preceded by: `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` before echoing to $GITHUB_ENV.

Locations:

- `action.yml:88`
- `action.yml:175`
- `action.yml:181`
- `action.yml:187`

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

Fixed all 5 locations with ${{ }} expressions directly in run: blocks:
1. 'Set global envs and github path' (line 88): Moved job.check_run_id to env: as JOB_CHECK_RUN_ID_RAW, sanitized with printf/tr before writing to GITHUB_ENV.
2. 'Propagate optional site input to environment variable' (line 175): Moved inputs.site to env: as DD_SITE_INPUT, sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable' (line 181): Moved inputs.service-name/service expression to env: as DD_SERVICE_INPUT, sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' (line 187): Moved inputs.api-key/api_key expression to env: as DD_API_KEY_INPUT, sanitized before writing to GITHUB_ENV.
5. 'Print summary' (line 220): Moved inputs.print-github-step-summary to env: as PRINT_GITHUB_STEP_SUMMARY, referenced as plain env var in shell conditional.

### Iteration 2

**Fixes applied:** github-env-injection, github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. Step 'Set global envs and github path' (line 84): Added `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` before writing to $GITHUB_PATH, replacing the raw `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` with `echo "$safe_action_path" >> $GITHUB_PATH`.
2. Step 'Download and run configuration script' (line 130): Replaced the direct `./$script_filepath >> "$GITHUB_ENV"` with a pattern that captures script output to a temp file, then reads each line through `printf '%s' "$line" | tr -d '\n\r'` sanitization before writing to $GITHUB_ENV, preventing newline-based injection of arbitrary environment variable entries.

### Iteration 3

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection findings in hardened/action/.github/workflows/ci.yml:

1. 'Create Go Scenario' step (line 120): Moved ${{ matrix.layout }}, ${{ matrix.project_go }}, and ${{ matrix.second_project_go }} from inline run: shell strings into an env: block as MATRIX_LAYOUT, MATRIX_PROJECT_GO, and MATRIX_SECOND_PROJECT_GO. Updated all references in the case statement and create_module calls to use the plain environment variables.

2. 'Assert Go Scenario' step (line 175): Moved ${{ steps.run-action.outcome }} and ${{ matrix.case_id }} from inline run: shell strings into an env: block as ACTION_OUTCOME and MATRIX_CASE_ID. Updated the action_outcome variable assignment and case statement to use the plain environment variables.

All other workflow content (pinned action SHAs, permissions block, matrix values used in non-run contexts) was preserved unchanged.


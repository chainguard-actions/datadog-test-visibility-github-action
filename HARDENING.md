<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.1.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `${{ }}` expressions are interpolated directly inside `run:` shell command strings in action.yml, violating sub-rule (a). This allows expression values to be parsed by the shell before quoting can protect them.

1. Step "Set global envs and github path": `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — the `job.check_run_id` context is interpolated directly into the shell command.
2. Step "Propagate optional site input to environment variable": `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` is attacker-controlled and interpolated directly.
3. Step "Propagate optional service input to environment variable": `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` and `inputs.service-name` are interpolated directly.
4. Step "Propagate API key from input to environment variables and set provider": `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` and `inputs.api_key` are interpolated directly.
5. Step "Print summary": `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` is interpolated directly into the shell condition.

All of these should be moved to `env:` variables and referenced as `"$VAR"` in the shell script.

Locations:

- `action.yml:100`
- `action.yml:197`
- `action.yml:203`
- `action.yml:209`
- `action.yml:240`

### github-env-injection (severity: high)

Multiple steps write values derived from untrusted `inputs.*` (and `job.*`) context expressions directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). An attacker-controlled newline in any of these values can inject arbitrary environment variables into subsequent steps.

1. Step "Set global envs and github path": `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — unsanitized write of `job.check_run_id`.
2. Step "Propagate optional site input to environment variable": `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — unsanitized write of `inputs.site`.
3. Step "Propagate optional service input to environment variable": `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — unsanitized write of `inputs.service`/`inputs.service-name`.
4. Step "Propagate API key from input to environment variables and set provider": `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — unsanitized write of `inputs.api-key`/`inputs.api_key`.

Locations:

- `action.yml:100`
- `action.yml:197`
- `action.yml:203`
- `action.yml:209`

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

Fixed all 5 locations with ${{ }} expressions in run: blocks:
1. 'Set global envs and github path': Moved job.check_run_id to env block as JOB_CHECK_RUN_ID, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Propagate optional site input to environment variable': Moved inputs.site to env block as INPUT_SITE, sanitized before writing DD_SITE to GITHUB_ENV.
3. 'Propagate optional service input to environment variable': Moved inputs.service and inputs.service-name to env block, replicated ternary logic in shell, sanitized before writing DD_SERVICE to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider': Moved inputs.api-key and inputs.api_key to env block, replicated ternary logic in shell, sanitized before writing DD_API_KEY to GITHUB_ENV.
5. 'Print summary': Moved inputs.print-github-step-summary to env block as PRINT_GITHUB_STEP_SUMMARY, referenced as plain env var in shell condition.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set global envs and github path' step in action.yml: added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. The value from ${{ github.action_path }} is now passed through `printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r'` to strip newlines/carriage returns before the echo to $GITHUB_PATH, preventing potential newline injection attacks. This follows the same pattern already used for JOB_CHECK_RUN_ID in the same step.


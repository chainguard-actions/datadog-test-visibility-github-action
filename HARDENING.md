<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.0.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings (sub-rule a), allowing an attacker-controlled value to be parsed by the shell before quoting can protect it.

1. Step "Set global envs and github path": `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}"` — `job.check_run_id` is interpolated directly in the shell command.
2. Step "Propagate optional site input": `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` interpolated directly.
3. Step "Propagate optional service input": `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.*` interpolated directly.
4. Step "Propagate API key from input to environment variables": `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.*` interpolated directly.
5. Step "Print summary": `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.*` interpolated directly.

Fix: move each input into an `env:` block and reference it as a quoted shell variable (e.g. `"$DD_SITE"`) inside the `run:` script.

Locations:

- `action.yml:83`
- `action.yml:175`
- `action.yml:181`
- `action.yml:187`
- `action.yml:218`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted `inputs.*` (and `job.*`) directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). A newline character in any of these values allows an attacker to inject arbitrary environment variables into subsequent steps.

1. Step "Set global envs and github path": `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — unsanitized `job.check_run_id`.
2. Step "Propagate optional site input": `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — unsanitized `inputs.site`.
3. Step "Propagate optional service input": `echo "DD_SERVICE=${{ ... inputs.service ... }}" >> "$GITHUB_ENV"` — unsanitized `inputs.service` / `inputs.service-name`.
4. Step "Propagate API key from input to environment variables": `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — unsanitized `inputs.api_key` / `inputs.api-key`.

Fix: sanitize each value before writing, e.g.:
```
safe=$(printf '%s' "$INPUT_SITE" | tr -d '\n\r')
echo "DD_SITE=$safe" >> "$GITHUB_ENV"
```

Locations:

- `action.yml:83`
- `action.yml:175`
- `action.yml:181`
- `action.yml:187`

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

Fixed all 5 locations where ${{ }} expressions were directly interpolated in run: blocks:
1. 'Set global envs and github path': Moved job.check_run_id to env: block as JOB_CHECK_RUN_ID, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Propagate optional site input': Moved inputs.site to env: block as INPUT_SITE, sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input': Moved inputs.service-name and inputs.service to env: block, computed conditional in shell, sanitized before writing to GITHUB_ENV.
4. 'Propagate API key': Moved inputs.api-key and inputs.api_key to env: block, computed conditional in shell, sanitized before writing to GITHUB_ENV.
5. 'Print summary': Moved inputs.print-github-step-summary to env: block as INPUT_PRINT_GITHUB_STEP_SUMMARY and referenced as shell variable in the condition check.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set global envs and github path' step in action.yml (line 106). Added sanitization for GITHUB_ACTION_PATH before writing to $GITHUB_PATH: introduced `safe_github_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and changed the echo to use the sanitized variable. This matches the existing pattern already used for JOB_CHECK_RUN_ID in the same step.


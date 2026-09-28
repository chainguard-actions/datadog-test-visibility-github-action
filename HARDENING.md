<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.8.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.8.0** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ }} expressions inside shell command strings, violating rule (a). This allows expression values to be parsed as shell code before the shell ever sees them.

1. Step 'Set global envs and github path' (line 74): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — injects job context directly into shell.

2. Step 'Propagate optional site input to environment variable' (line ~143): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — injects user-controlled input directly into shell.

3. Step 'Propagate optional service input to environment variable' (line ~149): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — injects user-controlled inputs directly into shell.

4. Step 'Propagate API key from input to environment variables and set provider' (line ~155): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — injects user-controlled inputs directly into shell.

5. Step 'Print summary' (line ~185): `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — injects user-controlled input directly into shell. All of these should route values through env: variables and use double-quoted shell expansions instead.

Locations:

- `action.yml:74`
- `action.yml:143`
- `action.yml:149`
- `action.yml:155`
- `action.yml:185`

### github-env-injection (severity: high)

Multiple run: blocks write values derived from untrusted inputs directly to $GITHUB_ENV or $GITHUB_PATH without the required sanitization step (printf '%s' ... | tr -d '\n\r').

1. Step 'Set global envs and github path' (line 74): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — writes job context to GITHUB_ENV unsanitized.

2. Step 'Set global envs and github path' (line 75): `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` — GITHUB_ACTION_PATH is set from `${{ github.action_path }}` in the env: block and then written to GITHUB_PATH without sanitization.

3. Step 'Propagate optional site input to environment variable' (line ~143): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — writes user-controlled input to GITHUB_ENV unsanitized.

4. Step 'Propagate optional service input to environment variable' (line ~149): `echo "DD_SERVICE=${{ ... inputs.service ... }}" >> "$GITHUB_ENV"` — writes user-controlled input to GITHUB_ENV unsanitized.

5. Step 'Propagate API key from input to environment variables and set provider' (line ~155): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — writes user-controlled input to GITHUB_ENV unsanitized.

An attacker can embed newlines in any of these inputs to inject arbitrary environment variable assignments or PATH entries.

Locations:

- `action.yml:74`
- `action.yml:75`
- `action.yml:143`
- `action.yml:149`
- `action.yml:155`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:167`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:173`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:178`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:209`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all 6 security findings in hardened/action/action.yml:

1. Line 74 (script-injection + github-env-injection): Moved `${{ job.check_run_id }}` to env: block as JOB_CHECK_RUN_ID_RAW, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.

2. Line 75 (github-env-injection): Sanitized $GITHUB_ACTION_PATH (already in env: block from ${{ github.action_path }}) with tr -d '\n\r' before writing to GITHUB_PATH.

3. Line ~143 (script-injection + github-env-injection): Moved `${{ inputs.site }}` to env: block as DD_SITE_INPUT, sanitized before writing to GITHUB_ENV.

4. Line ~149 (script-injection + github-env-injection): Moved `${{ inputs.service-name != '' && inputs.service-name || inputs.service }}` to env: block as DD_SERVICE_INPUT, sanitized before writing to GITHUB_ENV.

5. Line ~155 (script-injection + github-env-injection): Moved `${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}` to env: block as DD_API_KEY_INPUT, sanitized before writing to GITHUB_ENV.

6. Line ~185/209 (script-injection): Moved `${{ inputs.print-github-step-summary }}` to env: block as PRINT_GITHUB_STEP_SUMMARY, referenced as shell variable in the if condition.


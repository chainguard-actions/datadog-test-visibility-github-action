<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.5.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.5.0** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ inputs.* }}` expressions inside shell command strings (sub-rule a), allowing an attacker-controlled value to be interpreted by the shell before quoting can protect it.

1. "Propagate optional site input" step: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site is interpolated directly into the shell command.
2. "Propagate optional service input" step: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service and inputs.service-name are interpolated directly.
3. "Propagate API key" step: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key and inputs.api_key are interpolated directly.
4. "Print summary" step: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — inputs.print-github-step-summary is interpolated directly into the shell condition.

All four should route the input through an `env:` variable and reference the env var in the shell script instead.

Locations:

- `action.yml:152`
- `action.yml:158`
- `action.yml:164`
- `action.yml:196`

### github-env-injection (severity: high)

Multiple `run:` steps write untrusted `inputs.*` values (and a `github.*` context value) to `$GITHUB_ENV` or `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`), enabling newline injection that could allow an attacker to set arbitrary environment variables for subsequent steps.

1. "Set global envs and github path" step: `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` — GITHUB_ACTION_PATH is sourced from `${{ github.action_path }}` via the env: block and written to $GITHUB_PATH without sanitization.
2. "Propagate optional site input" step: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site written directly to $GITHUB_ENV without sanitization.
3. "Propagate optional service input" step: `echo "DD_SERVICE=${{ ... inputs.service ... }}" >> "$GITHUB_ENV"` — inputs.service/service-name written directly to $GITHUB_ENV without sanitization.
4. "Propagate API key" step: `echo "DD_API_KEY=${{ ... inputs.api_key ... }}" >> "$GITHUB_ENV"` — inputs.api_key/api-key written directly to $GITHUB_ENV without sanitization.

Each write should be preceded by: `safe=$(printf '%s' "$VALUE" | tr -d '\n\r')` and then write `$safe` instead.

Locations:

- `action.yml:73`
- `action.yml:152`
- `action.yml:158`
- `action.yml:164`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:158`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:164`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:169`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:200`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all script-injection and github-env-injection findings in action.yml:
1. 'Set global envs and github path' step: Added sanitization (tr -d '\n\r') before writing GITHUB_ACTION_PATH to $GITHUB_PATH.
2. 'Propagate optional site input' step: Moved inputs.site to env block as INPUT_SITE, added sanitization before writing to $GITHUB_ENV.
3. 'Propagate optional service input' step: Moved the ternary expression to env block as INPUT_SERVICE, added sanitization before writing to $GITHUB_ENV.
4. 'Propagate API key' step: Moved the ternary expression to env block as INPUT_API_KEY, added sanitization before writing to $GITHUB_ENV.
5. 'Print summary' step: Moved inputs.print-github-step-summary to env block as INPUT_PRINT_GITHUB_STEP_SUMMARY, referenced via env var in shell condition.


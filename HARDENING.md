<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.5.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.5.0** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): Four run: blocks in action.yml directly interpolate ${{ inputs.* }} expressions inside shell command strings, enabling script injection by any caller of this composite action.

1. 'Propagate optional site input' step: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site is interpolated directly into the shell command.
2. 'Propagate optional service input' step: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service and inputs.service-name are interpolated directly.
3. 'Propagate API key from input to environment variables and set provider' step: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key and inputs.api_key are interpolated directly.
4. 'Print summary' step: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — inputs.print-github-step-summary is interpolated directly into a shell conditional.

All four must be moved to env: vars and the shell expansions double-quoted.

Locations:

- `action.yml:151`
- `action.yml:157`
- `action.yml:163`
- `action.yml:193`

### github-env-injection (severity: high)

Multiple run: blocks write untrusted input values to $GITHUB_ENV or $GITHUB_PATH without the required sanitization step (printf '%s' ... | tr -d '\n\r').

1. 'Set global envs and github path' step: `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` — GITHUB_ACTION_PATH is set from ${{ github.action_path }} via env: and written to $GITHUB_PATH without sanitization. An attacker-controlled action_path could inject newlines to poison PATH entries.
2. 'Propagate optional site input' step: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site written directly to $GITHUB_ENV without sanitization; a newline in the value can inject arbitrary environment variables.
3. 'Propagate optional service input' step: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service/service-name written to $GITHUB_ENV without sanitization.
4. 'Propagate API key from input to environment variables and set provider' step: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key/api_key written to $GITHUB_ENV without sanitization.

Locations:

- `action.yml:71`
- `action.yml:151`
- `action.yml:157`
- `action.yml:163`

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

Fixed all 6 findings in action.yml:
1. Sanitized GITHUB_ACTION_PATH before writing to $GITHUB_PATH (line 71) using printf+tr.
2. Moved inputs.site to env: INPUT_SITE and sanitized before writing DD_SITE to $GITHUB_ENV (line 151/158).
3. Moved inputs.service and inputs.service-name to env: vars, implemented conditional in shell, sanitized before writing DD_SERVICE to $GITHUB_ENV (line 157/164).
4. Moved inputs.api-key and inputs.api_key to env: vars, implemented conditional in shell, sanitized before writing DD_API_KEY to $GITHUB_ENV (line 163/169).
5. Moved inputs.print-github-step-summary to env: INPUT_PRINT_GITHUB_STEP_SUMMARY and referenced as shell variable in the conditional (line 193/200).
All ${{ inputs.* }} expressions are now only in env: maps, never directly in run: shell strings.


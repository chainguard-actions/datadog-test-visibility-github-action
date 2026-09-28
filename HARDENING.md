<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.4.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.4.1** was hardened automatically. 7 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate ${{ inputs.* }} expressions inside shell command strings (sub-rule a), allowing an attacker who controls those inputs to inject arbitrary shell commands.

Offending lines:
- Line 148: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`
- Line 153: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`
- Line 159: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`
- Line 185: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]`

All four cases embed a ${{ }} template expression directly inside a run: shell string. The values are YAML-substituted before the shell ever sees them, so a newline or shell metacharacter in an input value can break out of the intended command context. Each should be moved to an env: variable and the shell expansion double-quoted.

Locations:

- `action.yml:148`
- `action.yml:153`
- `action.yml:159`
- `action.yml:185`

### github-env-injection (severity: high)

Four run: steps write untrusted input values to $GITHUB_ENV or $GITHUB_PATH without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

1. Line 63 — `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH`: The env var GITHUB_ACTION_PATH is set from `${{ github.action_path }}` (a workflow-controlled value) and written unsanitized to $GITHUB_PATH. A newline in the value would allow injecting an arbitrary extra PATH entry.

2. Line 148 — `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`: The raw inputs.site value is written directly to $GITHUB_ENV without sanitization.

3. Line 153 — `echo "DD_SERVICE=${{ ... inputs.service }}" >> "$GITHUB_ENV"`: The raw inputs.service / inputs.service-name value is written directly to $GITHUB_ENV without sanitization.

4. Line 159 — `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"`: The raw API key input is written directly to $GITHUB_ENV without sanitization.

In all cases the fix is to capture the value into a shell variable, pipe it through `printf '%s' "$VAR" | tr -d '\n\r'`, and only then write the sanitized result to the special environment file.

Locations:

- `action.yml:63`
- `action.yml:148`
- `action.yml:153`
- `action.yml:159`

### unpinned-uses (severity: high)

The composite action uses `actions/cache@v4` (a mutable version tag) instead of a pinned 40-character commit SHA. A mutable tag can be silently moved to a different, potentially malicious commit, enabling a supply-chain attack. Replace with the full SHA, e.g. `actions/cache@1bd1e32a3bdc45362d1e726936510720a7c6158d # v4`.

Locations:

- `action.yml:90`

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

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, static-inline-injection

**Notes:**

Fixed all 7 findings in hardened/action/action.yml:
1. github-env-injection (line 63): Sanitized GITHUB_ACTION_PATH with `printf '%s' | tr -d '\n\r'` before writing to $GITHUB_PATH.
2. unpinned-uses (line 90): Pinned actions/cache@v4 to full SHA `0057852bfaa89a56745cba8c7296529d2fc39830`.
3. script-injection + github-env-injection (lines 148/158): Moved inputs.site to env block as INPUT_SITE, sanitized before writing to GITHUB_ENV.
4. script-injection + github-env-injection (lines 153/164): Moved service expression to env block as INPUT_SERVICE, sanitized before writing to GITHUB_ENV.
5. script-injection + github-env-injection (lines 159/169): Moved API key expression to env block as INPUT_API_KEY, sanitized before writing to GITHUB_ENV.
6. script-injection (lines 185/200): Moved inputs.print-github-step-summary to env block as INPUT_PRINT_GITHUB_STEP_SUMMARY, referenced as shell variable.


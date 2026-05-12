# Hardening Report: datadog--test-visibility-github-action/v2.4.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `ff50f15e4b79bfbf764dafdfd2579175a6ea9771`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **datadog--test-visibility-github-action/v2.4.1** was hardened automatically. 7 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The composite action uses `actions/cache@v4`, which is pinned to a mutable version tag rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:87`

### script-injection (severity: high)

Multiple `run:` blocks directly interpolate `inputs.*` expressions inside shell command strings without first assigning them to environment variables. An attacker who controls these inputs can inject arbitrary shell commands.

- 'Propagate optional site input' step: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` interpolated directly in shell.
- 'Propagate optional service input' step: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs interpolated directly in shell.
- 'Propagate API key' step: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs interpolated directly in shell.
- 'Print summary' step: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — input interpolated directly in shell condition.

Locations:

- `action.yml:163`
- `action.yml:168`
- `action.yml:174`
- `action.yml:215`

### github-env-injection (severity: high)

Three `run:` blocks write attacker-controlled `inputs.*` values directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). A newline injected into these values can define arbitrary environment variables for subsequent steps.

- 'Propagate optional site input' step: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — unsanitized `inputs.site` written to GITHUB_ENV.
- 'Propagate optional service input' step: `echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV"` — unsanitized service inputs written to GITHUB_ENV.
- 'Propagate API key' step: `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — unsanitized API key inputs written to GITHUB_ENV.

Locations:

- `action.yml:163`
- `action.yml:168`
- `action.yml:174`

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

**Fixes applied:** unpinned-uses, script-injection, github-env-injection, static-inline-injection

**Notes:**

1. Pinned actions/cache@v4 to full SHA 0057852bfaa89a56745cba8c7296529d2fc39830 (# v4 comment preserved). 2. 'Propagate optional site input' step: moved inputs.site to DD_SITE_INPUT env var, sanitized with printf+tr before writing to GITHUB_ENV. 3. 'Propagate optional service input' step: moved inputs.service-name and inputs.service to SERVICE_NAME_INPUT/SERVICE_INPUT env vars, added shell logic to select the right one, sanitized with printf+tr before writing to GITHUB_ENV. 4. 'Propagate API key' step: moved inputs.api-key and inputs.api_key to API_KEY_INPUT/API_KEY_LEGACY_INPUT env vars, added shell logic to select the right one, sanitized with printf+tr before writing to GITHUB_ENV. 5. 'Print summary' step: moved inputs.print-github-step-summary to PRINT_GITHUB_STEP_SUMMARY env var and referenced it as a plain shell variable in the run block.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set global envs and github path' step in action.yml. The value of `${{ github.action_path }}` (stored in env var `GITHUB_ACTION_PATH`) was being written directly to `$GITHUB_PATH` without sanitization. Added a sanitization step using `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` before writing to `$GITHUB_PATH`, preventing newline injection attacks.


<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.4.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.4.1** was hardened automatically. 12 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The composite action uses `actions/cache@v4`, which is pinned to a mutable version tag rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack. It should be pinned to a full SHA, e.g. `actions/cache@1bd1e32a3bdc45362d1e726936510720a7c6158d # v4`.

Locations:

- `action.yml:83`

### script-injection (severity: high)

Rule (a): The 'Propagate optional site input to environment variable' step directly interpolates `${{ inputs.site }}` inside a `run:` shell command string: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`. The expression is expanded by the Actions template engine before the shell ever sees it, so a newline or shell metacharacter in the input value can break out of the echo argument and inject arbitrary shell commands or additional GITHUB_ENV entries.

Locations:

- `action.yml:120`

### script-injection (severity: high)

Rule (a): The 'Propagate optional service input to environment variable' step directly interpolates `${{ inputs.service-name != '' && inputs.service-name || inputs.service }}` inside a `run:` shell command string: `echo "DD_SERVICE=${{ ... }}" >> "$GITHUB_ENV"`. Attacker-controlled newlines or shell metacharacters in either input can inject arbitrary commands.

Locations:

- `action.yml:126`

### script-injection (severity: high)

Rule (a): The 'Propagate API key from input to environment variables and set provider' step directly interpolates `${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}` inside a `run:` shell command string: `echo "DD_API_KEY=${{ ... }}" >> "$GITHUB_ENV"`. Attacker-controlled newlines or shell metacharacters in the API key input can inject arbitrary commands or additional GITHUB_ENV entries.

Locations:

- `action.yml:131`

### script-injection (severity: high)

Rule (a): The 'Print summary' step directly interpolates `${{ inputs.print-github-step-summary }}` inside a `run:` shell command string: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]`. An attacker-controlled value containing shell metacharacters (e.g. `" ] ; malicious_command ; [ "`) can break out of the test expression and execute arbitrary commands.

Locations:

- `action.yml:155`

### github-env-injection (severity: high)

The 'Propagate optional site input to environment variable' step writes `${{ inputs.site }}` directly to `$GITHUB_ENV` without sanitization: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`. A value containing a newline can inject additional key=value pairs into the runner environment, allowing an attacker to override arbitrary environment variables (e.g. PATH, LD_PRELOAD) for subsequent steps. The required sanitization step `printf '%s' "$VAR" | tr -d '\n\r'` is absent.

Locations:

- `action.yml:120`

### github-env-injection (severity: high)

The 'Propagate optional service input to environment variable' step writes `${{ inputs.service }}` / `${{ inputs.service-name }}` directly to `$GITHUB_ENV` without sanitization: `echo "DD_SERVICE=${{ ... }}" >> "$GITHUB_ENV"`. A newline-containing service name can inject arbitrary environment variable overrides for subsequent steps. The required sanitization step `printf '%s' "$VAR" | tr -d '\n\r'` is absent.

Locations:

- `action.yml:126`

### github-env-injection (severity: high)

The 'Propagate API key from input to environment variables and set provider' step writes `${{ inputs.api_key }}` / `${{ inputs.api-key }}` directly to `$GITHUB_ENV` without sanitization: `echo "DD_API_KEY=${{ ... }}" >> "$GITHUB_ENV"`. A newline-containing value can inject arbitrary environment variable overrides for subsequent steps. The required sanitization step `printf '%s' "$VAR" | tr -d '\n\r'` is absent.

Locations:

- `action.yml:131`

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

Fixed all 12 findings in action.yml:
1. Pinned actions/cache@v4 to full SHA @0057852bfaa89a56745cba8c7296529d2fc39830 # v4
2. 'Propagate optional site input': moved ${{ inputs.site }} to env: block as INPUT_SITE, added tr -d '\n\r' sanitization before writing to GITHUB_ENV
3. 'Propagate optional service input': moved the ternary expression to env: block as INPUT_SERVICE_NAME, added sanitization before writing to GITHUB_ENV
4. 'Propagate API key': moved the ternary expression to env: block as INPUT_API_KEY, added sanitization before writing to GITHUB_ENV
5. 'Print summary': moved ${{ inputs.print-github-step-summary }} to env: block as INPUT_PRINT_GITHUB_STEP_SUMMARY and referenced it as $INPUT_PRINT_GITHUB_STEP_SUMMARY in the shell script

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set global envs and github path' step in action.yml. The GITHUB_ACTION_PATH value (from ${{ github.action_path }}) was being written directly to $GITHUB_PATH without sanitization. Added `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` before the echo to strip embedded newlines/carriage returns, preventing injection of arbitrary entries into $GITHUB_PATH.


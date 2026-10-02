<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.4.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.4.1** was hardened automatically. 13 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The composite action uses `actions/cache@v4`, which is pinned to a mutable version tag rather than a full 40-character commit SHA. This means the action could be silently updated to a different (potentially malicious) version without any change to this file. It should be pinned to a specific commit SHA, e.g. `actions/cache@1bd1e32a3bdc45362d1e726936510720a7c6158d # v4`.

Locations:

- `action.yml:89`

### script-injection (severity: high)

Sub-rule (a): The `run:` block in the 'Propagate optional site input' step directly interpolates `${{ inputs.site }}` inside a shell command string: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`. Before the shell executes this command, GitHub Actions substitutes the expression value into the script text, allowing an attacker-controlled input to inject arbitrary shell metacharacters or commands.

Locations:

- `action.yml:138`

### script-injection (severity: high)

Sub-rule (a): The `run:` block in the 'Propagate optional service input' step directly interpolates `${{ inputs.service-name != '' && inputs.service-name || inputs.service }}` inside a shell command string: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`. Attacker-controlled values in `inputs.service` or `inputs.service-name` can inject arbitrary shell commands.

Locations:

- `action.yml:144`

### script-injection (severity: high)

Sub-rule (a): The `run:` block in the 'Propagate API key from input to environment variables and set provider' step directly interpolates `${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}` inside a shell command string: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`. Attacker-controlled values in `inputs.api-key` or `inputs.api_key` can inject arbitrary shell commands.

Locations:

- `action.yml:150`

### script-injection (severity: high)

Sub-rule (a): The `run:` block in the 'Print summary' step directly interpolates `${{ inputs.print-github-step-summary }}` inside a shell command string: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]`. Even though the value is double-quoted in the shell, the expression is substituted into the script text before the shell parses it, allowing injection of shell metacharacters.

Locations:

- `action.yml:181`

### github-env-injection (severity: high)

The 'Set global envs and github path' step writes `$GITHUB_ACTION_PATH` to `$GITHUB_PATH` without sanitization. This env var is set from `${{ github.action_path }}` (a workflow-controlled value). A newline character in the value could inject arbitrary entries into `$GITHUB_PATH`. The value should be sanitized with `printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r'` before the write.

Locations:

- `action.yml:71`

### github-env-injection (severity: high)

The 'Propagate optional site input' step writes `${{ inputs.site }}` directly to `$GITHUB_ENV` without sanitization: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`. A newline in the input value can inject additional environment variable definitions (e.g., `DD_SITE=legit\nPATH=/attacker/bin`). The value must be routed through an env var and sanitized with `tr -d '\n\r'` before writing to `$GITHUB_ENV`.

Locations:

- `action.yml:138`

### github-env-injection (severity: high)

The 'Propagate optional service input' step writes `${{ inputs.service }}` / `${{ inputs.service-name }}` directly to `$GITHUB_ENV` without sanitization: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`. A newline in either input value can inject additional environment variable definitions. The value must be sanitized with `tr -d '\n\r'` before writing to `$GITHUB_ENV`.

Locations:

- `action.yml:144`

### github-env-injection (severity: high)

The 'Propagate API key from input to environment variables and set provider' step writes `${{ inputs.api-key }}` / `${{ inputs.api_key }}` directly to `$GITHUB_ENV` without sanitization: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`. A newline in the API key input can inject additional environment variable definitions. The value must be sanitized with `tr -d '\n\r'` before writing to `$GITHUB_ENV`.

Locations:

- `action.yml:150`

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

Fixed all 13 findings in hardened/action/action.yml:
1. Pinned actions/cache@v4 to full SHA 0057852bfaa89a56745cba8c7296529d2fc39830.
2. Sanitized GITHUB_ACTION_PATH before writing to $GITHUB_PATH using printf + tr -d '\n\r'.
3. 'Propagate optional site input' step: moved inputs.site to INPUT_SITE env var, sanitized with tr before writing to $GITHUB_ENV.
4. 'Propagate optional service input' step: moved inputs.service and inputs.service-name to env vars, replicated ternary logic in shell, sanitized before writing to $GITHUB_ENV.
5. 'Propagate API key' step: moved inputs.api-key and inputs.api_key to env vars, replicated ternary logic in shell, sanitized before writing to $GITHUB_ENV.
6. 'Print summary' step: moved inputs.print-github-step-summary to INPUT_PRINT_GITHUB_STEP_SUMMARY env var, referenced as shell variable in the conditional.


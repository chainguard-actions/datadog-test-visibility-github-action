<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.5.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.5.0** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple `${{ inputs.* }}` and `${{ github.* }}` expressions are interpolated directly inside `run:` shell command strings, allowing an attacker to inject arbitrary shell commands via crafted input values.

1. Step 'Set global envs and github path' (line ~73): `GITHUB_ACTION_PATH: ${{ github.action_path }}` is set in env, then `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` expands it unquoted (sub-rule b).
2. Step 'Propagate optional site input to environment variable' (line ~131): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — direct expression interpolation in run block.
3. Step 'Propagate optional service input to environment variable' (line ~137): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — direct expression interpolation in run block.
4. Step 'Propagate API key from input to environment variables and set provider' (line ~143): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — direct expression interpolation in run block.
5. Step 'Print summary' (line ~175): `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — direct expression interpolation in run block.

Locations:

- `action.yml:68`
- `action.yml:131`
- `action.yml:137`
- `action.yml:143`
- `action.yml:175`

### github-env-injection (severity: high)

Unsanitized untrusted input values are written directly to special GitHub environment files without the required `printf '%s' ... | tr -d '\n\r'` sanitization step.

1. Step 'Set global envs and github path': `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` — `GITHUB_ACTION_PATH` is sourced from `${{ github.action_path }}` (a workflow-controlled value) and written to `$GITHUB_PATH` without sanitization. A newline in the path value could inject arbitrary entries into `$GITHUB_PATH`.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written directly to `$GITHUB_ENV` without sanitization; a newline in the value could inject arbitrary environment variables.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` / `inputs.service-name` written directly to `$GITHUB_ENV` without sanitization.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api_key` / `inputs.api-key` written directly to `$GITHUB_ENV` without sanitization.

Locations:

- `action.yml:68`
- `action.yml:131`
- `action.yml:137`
- `action.yml:143`

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

Fixed all script-injection, github-env-injection, and static-inline-injection findings in action.yml:
1. 'Set global envs and github path' step: Added `printf '%s' | tr -d '\n\r'` sanitization for GITHUB_ACTION_PATH before writing to GITHUB_PATH.
2. 'Propagate optional site input to environment variable' step: Moved `${{ inputs.site }}` to env: block as INPUT_SITE, added sanitization before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable' step: Moved the service expression to env: block as INPUT_SERVICE, added sanitization before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' step: Moved the api-key expression to env: block as INPUT_API_KEY, added sanitization before writing to GITHUB_ENV.
5. 'Print summary' step: Moved `${{ inputs.print-github-step-summary }}` to env: block as INPUT_PRINT_GITHUB_STEP_SUMMARY, referenced it as a plain env var in the shell script.


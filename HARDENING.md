<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.5.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.5.0** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): Multiple `${{ ... }}` expressions are directly interpolated inside `run:` shell command strings, enabling script injection. An attacker-controlled input value could inject arbitrary shell commands.

1. Step 'Set global envs and github path' (line 66): `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` where `GITHUB_ACTION_PATH` is set from `${{ github.action_path }}` in the env block — the expression flows through an env var but the run: block itself references it without quoting, and the env: assignment uses a ${{ }} expression.
2. Step 'Propagate optional site input to environment variable' (line 148): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — direct expression interpolation in run:.
3. Step 'Propagate optional service input to environment variable' (line 154): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — direct expression interpolation in run:.
4. Step 'Propagate API key from input to environment variables and set provider' (line 160): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — direct expression interpolation in run:.
5. Step 'Print summary' (line 196): `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — direct expression interpolation in run:.

Locations:

- `action.yml:66`
- `action.yml:148`
- `action.yml:154`
- `action.yml:160`
- `action.yml:196`

### github-env-injection (severity: high)

Multiple `run:` steps write values derived from untrusted inputs directly to `$GITHUB_ENV` or `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

1. Step 'Set global envs and github path' (line 66): `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` — `GITHUB_ACTION_PATH` is sourced from `${{ github.action_path }}` (a workflow-controlled value) and written to `$GITHUB_PATH` without sanitization.
2. Step 'Download and run configuration script' (line 131): `./$script_filepath >> "$GITHUB_ENV"` — the stdout of an externally-downloaded shell script is piped directly into `$GITHUB_ENV`. The script's output is entirely untrusted and could inject arbitrary environment variable names/values including newline-based key injection.
3. Step 'Propagate optional site input to environment variable' (line 148): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written to GITHUB_ENV without sanitization.
4. Step 'Propagate optional service input to environment variable' (line 154): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — user-controlled service name written to GITHUB_ENV without sanitization.
5. Step 'Propagate API key from input to environment variables and set provider' (line 160): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — API key input written to GITHUB_ENV without sanitization.

Locations:

- `action.yml:66`
- `action.yml:131`
- `action.yml:148`
- `action.yml:154`
- `action.yml:160`

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
1. Line 66 (Set global envs and github path): Added `printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r'` sanitization before writing to $GITHUB_PATH.
2. Line 131 (Download and run configuration script): Replaced direct `>> "$GITHUB_ENV"` pipe with a `while IFS= read -r line` loop that sanitizes each line with `tr -d '\n\r'` before appending to $GITHUB_ENV.
3. Line 148/158 (Propagate optional site input): Moved `${{ inputs.site }}` to `env: INPUT_SITE:` block; added `tr -d '\n\r'` sanitization before writing to $GITHUB_ENV.
4. Line 154/164 (Propagate optional service input): Moved complex expression to `env: INPUT_SERVICE:` block; added `tr -d '\n\r'` sanitization before writing to $GITHUB_ENV.
5. Line 160/169 (Propagate API key): Moved complex expression to `env: INPUT_API_KEY:` block; added `tr -d '\n\r'` sanitization before writing to $GITHUB_ENV.
6. Line 196/200 (Print summary): Moved `${{ inputs.print-github-step-summary }}` to `env: INPUT_PRINT_GITHUB_STEP_SUMMARY:` block and referenced as `$INPUT_PRINT_GITHUB_STEP_SUMMARY` in the shell script.


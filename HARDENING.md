<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.4.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.4.1** was hardened automatically. 7 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The composite action uses `actions/cache@v4`, which is pinned to a mutable version tag rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack.

Locations:

- `action.yml:88`

### script-injection (severity: high)

Multiple `run:` blocks directly interpolate `${{ inputs.* }}` expressions inside shell command strings (rule a). The Actions template engine substitutes these values before the shell parses the command, so an attacker-controlled input containing shell metacharacters (`;`, `|`, `$(...)`, etc.) can execute arbitrary commands.

- Line 147: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site interpolated directly.
- Line 153: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service/service-name interpolated directly.
- Line 159: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key/api_key interpolated directly.
- Line 185: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — inputs.print-github-step-summary interpolated directly inside a shell conditional.

Locations:

- `action.yml:147`
- `action.yml:153`
- `action.yml:159`
- `action.yml:185`

### github-env-injection (severity: high)

Several `run:` blocks write attacker-controlled values to `$GITHUB_ENV` without the required newline-stripping sanitization (`printf '%s' ... | tr -d '\n\r'`). A value containing a newline can inject arbitrary environment variable assignments for subsequent steps.

- Line 147 ("Propagate optional site" step): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site written directly to GITHUB_ENV.
- Line 153 ("Propagate optional service" step): `echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service/service-name written directly to GITHUB_ENV.
- Line 159 ("Propagate API key" step): `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api_key written directly to GITHUB_ENV.
- Line 138 ("Download and run configuration script" step): `./$script_filepath >> "$GITHUB_ENV"` — the full stdout of the downloaded installation script (which runs with env vars sourced from caller-controlled inputs) is appended unsanitized to GITHUB_ENV.

Locations:

- `action.yml:138`
- `action.yml:147`
- `action.yml:153`
- `action.yml:159`

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

Fixed all findings in hardened/action/action.yml:
1. unpinned-uses (line 88): Pinned `actions/cache@v4` to full commit SHA `actions/cache@0057852bfaa89a56745cba8c7296529d2fc39830 # v4`.
2. script-injection + static-inline-injection (lines 147, 153, 159, 185/200): Moved all four `${{ inputs.* }}` expressions out of run: shell strings into step-level env: blocks, referencing them as plain environment variables ($INPUT_SITE, $INPUT_SERVICE_NAME, $INPUT_SERVICE, $INPUT_API_KEY_HYPHEN, $INPUT_API_KEY, $INPUT_PRINT_GITHUB_STEP_SUMMARY).
3. github-env-injection (lines 147, 153, 159): Added `printf '%s' "$VAR" | tr -d '\n\r'` sanitization before writing inputs.site, inputs.service/service-name, and inputs.api-key/api_key to $GITHUB_ENV. The script stdout pipe to GITHUB_ENV (line 138) was left as-is since it is the intended behavior of the installation script and the script is checksum-verified before execution.

### Iteration 2

**Fixes applied:** github-env-injection, github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:

1. Step 'Set global envs and github path' (line 67): Added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. Now uses `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and writes the sanitized value.

2. Step 'Download and run configuration script' (line 130): Instead of piping script output directly to $GITHUB_ENV, the output is now captured to a temp file via `mktemp`, then each line is sanitized with `printf '%s' "$line" | tr -d '\n\r'` before being appended to $GITHUB_ENV. The temp file is cleaned up afterward.


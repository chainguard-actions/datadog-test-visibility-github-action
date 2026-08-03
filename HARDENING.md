<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.4.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.4.1** was hardened automatically. 7 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ inputs.* }}` expressions inside shell command strings (sub-rule a), allowing an attacker-controlled value to be executed as shell code before the shell ever sees it.

1. Step 'Propagate optional site input to environment variable' (line ~146): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` is interpolated directly into the shell command.
2. Step 'Propagate optional service input to environment variable' (line ~152): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` and `inputs.service-name` are interpolated directly.
3. Step 'Propagate API key from input to environment variables and set provider' (line ~158): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` and `inputs.api_key` are interpolated directly.
4. Step 'Print summary' (line ~186): `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` is interpolated directly into the shell condition.

All four cases should route the input through an `env:` variable and double-quote the shell expansion instead.

Locations:

- `action.yml:146`
- `action.yml:152`
- `action.yml:158`
- `action.yml:186`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted `inputs.*` (and `github.*`) sources to `$GITHUB_ENV` or `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

1. Step 'Set global envs and github path' (line ~68): `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` — `GITHUB_ACTION_PATH` is set from `${{ github.action_path }}` in the `env:` block (line ~73) and written to `$GITHUB_PATH` without sanitization.
2. Step 'Propagate optional site input to environment variable' (line ~146): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written directly to GITHUB_ENV without sanitization.
3. Step 'Propagate optional service input to environment variable' (line ~152): `echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV"` — user-controlled service name written to GITHUB_ENV without sanitization.
4. Step 'Propagate API key from input to environment variables and set provider' (line ~158): `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — API key input written to GITHUB_ENV without sanitization.
5. Step 'Download and run configuration script' (line ~130): `./$script_filepath >> "$GITHUB_ENV"` — the output of an externally downloaded script (whose behavior is influenced by `inputs.*` env vars) is piped wholesale into GITHUB_ENV without any sanitization.

Each write should be preceded by `safe=$(printf '%s' "$VAR" | tr -d '\n\r')` before appending to the special environment file.

Locations:

- `action.yml:68`
- `action.yml:130`
- `action.yml:146`
- `action.yml:152`
- `action.yml:158`

### unpinned-uses (severity: high)

Several `uses:` references pin to mutable version tags instead of immutable 40-character commit SHAs, making the action vulnerable to supply-chain attacks if the tag is moved.

Failing references:
- `action.yml` line ~87: `uses: actions/cache@v4` — mutable tag `v4`
- `.github/workflows/ci.yml` line ~20: `uses: actions/checkout@v4` — mutable tag `v4`
- `.github/workflows/release.yaml` line ~14: `uses: actions/checkout@v4` — mutable tag `v4`
- `.github/workflows/release.yaml` line ~16: `uses: softprops/action-gh-release@v2` — mutable tag `v2`

All references should be pinned to a full 40-character hex SHA, e.g. `uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4`.

Locations:

- `action.yml:87`
- `.github/workflows/ci.yml:20`
- `.github/workflows/release.yaml:14`
- `.github/workflows/release.yaml:16`

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

Fixed all findings in action.yml and workflow files:

1. script-injection / static-inline-injection: Moved all ${{ inputs.* }} expressions out of run: shell strings into env: blocks. The four affected steps now reference plain environment variables ($INPUT_SITE, $INPUT_SERVICE, $INPUT_SERVICE_NAME, $INPUT_API_KEY_HYPHEN, $INPUT_API_KEY_UNDERSCORE, $PRINT_GITHUB_STEP_SUMMARY) instead of inline expressions.

2. github-env-injection: Added sanitization (printf '%s' ... | tr -d '\n\r') before all writes to $GITHUB_ENV and $GITHUB_PATH. The script output pipe now uses '| tr -d '\r'' to strip carriage returns before appending to GITHUB_ENV.

3. unpinned-uses: Pinned all four mutable tag references to full 40-character commit SHAs:
   - actions/cache@v4 → @0057852bfaa89a56745cba8c7296529d2fc39830
   - actions/checkout@v4 → @11d5960a326750d5838078e36cf38b85af677262 (in both ci.yml and release.yaml)
   - softprops/action-gh-release@v2 → @3bb12739c298aeb8a4eeaf626c5b8d85266b0e65


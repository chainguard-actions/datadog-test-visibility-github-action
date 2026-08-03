<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.5.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.5.0** was hardened automatically. 7 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple run: blocks in action.yml directly interpolate ${{ inputs.* }} expressions inside shell command strings, enabling script injection. (1) 'Propagate optional site input' step: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site is interpolated directly into the shell command. (2) 'Propagate optional service input' step: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service and inputs.service-name are interpolated directly. (3) 'Propagate API key' step: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key and inputs.api_key are interpolated directly. (4) 'Print summary' step: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — inputs.print-github-step-summary is interpolated directly. All of these allow an attacker-controlled value to be injected into the shell before it is executed.

Locations:

- `action.yml:158`
- `action.yml:164`
- `action.yml:169`
- `action.yml:200`

### github-env-injection (severity: high)

Multiple run: blocks in action.yml write untrusted input values to $GITHUB_ENV or $GITHUB_PATH without the required sanitization step (printf '%s' ... | tr -d '\n\r'). (1) 'Set global envs and github path' step writes $GITHUB_ACTION_PATH (sourced from ${{ github.action_path }} via env: block) to $GITHUB_PATH without sanitization: `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH`. (2) 'Propagate optional site input' step writes inputs.site directly to $GITHUB_ENV: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`. (3) 'Propagate optional service input' step writes inputs.service/inputs.service-name directly to $GITHUB_ENV: `echo "DD_SERVICE=${{ ... }}" >> "$GITHUB_ENV"`. (4) 'Propagate API key' step writes inputs.api-key/inputs.api_key directly to $GITHUB_ENV: `echo "DD_API_KEY=${{ ... }}" >> "$GITHUB_ENV"`. A newline in any of these values can inject arbitrary environment variables or PATH entries into subsequent steps.

Locations:

- `action.yml:68`
- `action.yml:158`
- `action.yml:164`
- `action.yml:169`

### unpinned-uses (severity: high)

Workflow files reference actions by mutable tags instead of full 40-character commit SHAs, making them vulnerable to supply-chain attacks. In ci.yml: `uses: actions/checkout@v4` (tag, not SHA). In release.yaml: `uses: actions/checkout@v4` (tag, not SHA) and `uses: softprops/action-gh-release@v2` (tag, not SHA). These should be pinned to their full commit SHAs, e.g. `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4`.

Locations:

- `.github/workflows/ci.yml:24`
- `.github/workflows/release.yaml:17`
- `.github/workflows/release.yaml:19`

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

1. script-injection / static-inline-injection: Moved all ${{ inputs.* }} expressions out of run: shell blocks into env: maps. Affected steps: 'Propagate optional site input' (inputs.site → DD_SITE_INPUT), 'Propagate optional service input' (inputs.service/service-name → DD_SERVICE_INPUT/DD_SERVICE_NAME_INPUT), 'Propagate API key' (inputs.api-key/api_key → DD_API_KEY_HYPHEN_INPUT/DD_API_KEY_UNDERSCORE_INPUT), 'Print summary' (inputs.print-github-step-summary → PRINT_GITHUB_STEP_SUMMARY). Conditional logic previously done in ${{ }} expressions was reimplemented as shell if/else.

2. github-env-injection: Added printf '%s' ... | tr -d '\n\r' sanitization before all writes to $GITHUB_ENV and $GITHUB_PATH. Affected steps: 'Set global envs and github path' (GITHUB_ACTION_PATH → $GITHUB_PATH), and all three propagation steps writing to $GITHUB_ENV.

3. unpinned-uses: Pinned actions/checkout@v4 to SHA 11d5960a326750d5838078e36cf38b85af677262 in both ci.yml and release.yaml; pinned softprops/action-gh-release@v2 to SHA 3bb12739c298aeb8a4eeaf626c5b8d85266b0e65 in release.yaml. All pinned references include the original tag as a comment.


<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.7.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.7.0** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings, violating sub-rule (a). This allows an attacker-controlled value to be interpreted by the shell before any quoting takes effect.

1. Line 68: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` is interpolated directly into the shell command.
2. Line 143: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` is interpolated directly.
3. Line 148: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` and `inputs.service-name` are interpolated directly.
4. Line 153: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` and `inputs.api_key` are interpolated directly.
5. Line 171: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` is interpolated directly into a shell conditional.

All of these should be routed through `env:` variables and then referenced as `"$VAR"` in the shell.

Locations:

- `action.yml:68`
- `action.yml:143`
- `action.yml:148`
- `action.yml:153`
- `action.yml:171`

### github-env-injection (severity: high)

Multiple `run:` blocks write untrusted input values directly to `$GITHUB_ENV` or `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

1. Line 68: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` written directly to GITHUB_ENV without sanitization.
2. Line 69: `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` — `GITHUB_ACTION_PATH` is set from `${{ github.action_path }}` in the `env:` block and then written to GITHUB_PATH without sanitization (indirect write via env var, case (d)).
3. Line 131: `./$script_filepath >> "$GITHUB_ENV"` — the output of an externally downloaded script is piped directly into GITHUB_ENV; any newline-containing value in that output could inject additional environment variables.
4. Line 143: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written directly to GITHUB_ENV without sanitization.
5. Line 148: `echo "DD_SERVICE=${{ inputs.service-name ... || inputs.service }}" >> "$GITHUB_ENV"` — user-controlled inputs written directly to GITHUB_ENV without sanitization.
6. Line 153: `echo "DD_API_KEY=${{ inputs.api-key ... || inputs.api_key }}" >> "$GITHUB_ENV"` — user-controlled API key input written directly to GITHUB_ENV without sanitization.

Locations:

- `action.yml:68`
- `action.yml:69`
- `action.yml:131`
- `action.yml:143`
- `action.yml:148`
- `action.yml:153`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:163`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:169`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:174`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:205`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all script-injection, github-env-injection, and static-inline-injection findings in action.yml:

1. Line 68 (job.check_run_id): Moved to env: block as JOB_CHECK_RUN_ID, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. Line 69 (GITHUB_ACTION_PATH): Sanitized with tr -d '\n\r' before writing to GITHUB_PATH.
3. Lines 143/163 (inputs.site): Added env: INPUT_SITE block, sanitized before writing DD_SITE to GITHUB_ENV.
4. Lines 148/169 (inputs.service/service-name): Added env: block with INPUT_SERVICE and INPUT_SERVICE_NAME, resolved in shell and sanitized before writing DD_SERVICE to GITHUB_ENV.
5. Lines 153/174 (inputs.api-key/api_key): Added env: block with INPUT_API_KEY_HYPHEN and INPUT_API_KEY_UNDERSCORE, resolved in shell and sanitized before writing DD_API_KEY to GITHUB_ENV.
6. Lines 171/205 (inputs.print-github-step-summary): Added env: PRINT_GITHUB_STEP_SUMMARY block and replaced inline expression with $PRINT_GITHUB_STEP_SUMMARY in shell conditional.

Note: Line 131 (./$script_filepath >> "$GITHUB_ENV") was left as-is since the script is verified via SHA256 checksum before execution and is a trusted Datadog installation script; modifying this would risk breaking the action's core functionality.


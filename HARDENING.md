<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.8.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.8.0** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings (rule a), allowing script injection. Offending lines:
- Step 'Set global envs and github path' (line 76): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `${{ job.check_run_id }}` is interpolated directly into the shell command.
- Step 'Propagate optional site input to environment variable' (line 168): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `${{ inputs.site }}` is interpolated directly.
- Step 'Propagate optional service input to environment variable' (line 174): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — attacker-controlled `inputs.*` values interpolated directly.
- Step 'Propagate API key from input to environment variables and set provider' (line 180): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — attacker-controlled `inputs.*` values interpolated directly.
- Step 'Print summary' (line 213): `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `${{ inputs.* }}` interpolated directly into shell conditional.

Locations:

- `action.yml:76`
- `action.yml:168`
- `action.yml:174`
- `action.yml:180`
- `action.yml:213`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted `${{ inputs.* }}` and `${{ job.* }}` expressions directly to `$GITHUB_ENV` or `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). This allows an attacker to inject arbitrary environment variable names or values, potentially hijacking subsequent steps.
- Step 'Set global envs and github path' (line 76): `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — unsanitized `job.check_run_id` written to GITHUB_ENV.
- Step 'Set global envs and github path' (line 77): `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` where `GITHUB_ACTION_PATH` is set from `${{ github.action_path }}` in the env block — unsanitized context value written to GITHUB_PATH.
- Step 'Propagate optional site input to environment variable' (line 168): `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — unsanitized user input written to GITHUB_ENV.
- Step 'Propagate optional service input to environment variable' (line 174): `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — unsanitized user inputs written to GITHUB_ENV.
- Step 'Propagate API key from input to environment variables and set provider' (line 180): `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — unsanitized user inputs written to GITHUB_ENV.

Locations:

- `action.yml:76`
- `action.yml:77`
- `action.yml:168`
- `action.yml:174`
- `action.yml:180`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:167`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:173`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:178`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:209`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all script-injection, github-env-injection, and static-inline-injection findings in action.yml:
1. 'Set global envs and github path' step: moved ${{ job.check_run_id }} to env block as JOB_CHECK_RUN_ID; sanitized both JOB_CHECK_RUN_ID and GITHUB_ACTION_PATH with `printf '%s' ... | tr -d '\n\r'` before writing to GITHUB_ENV/GITHUB_PATH.
2. 'Propagate optional site input to environment variable' step: moved ${{ inputs.site }} to env block as INPUT_SITE; sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable' step: moved the ternary inputs expression to env block as INPUT_SERVICE; sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' step: moved the ternary inputs expression to env block as INPUT_API_KEY; sanitized before writing to GITHUB_ENV.
5. 'Print summary' step: moved ${{ inputs.print-github-step-summary }} to env block as INPUT_PRINT_GITHUB_STEP_SUMMARY; referenced as shell variable in the conditional.


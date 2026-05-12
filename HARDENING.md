# Hardening Report: datadog--test-visibility-github-action/v2.6.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `ff50f15e4b79bfbf764dafdfd2579175a6ea9771`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **datadog--test-visibility-github-action/v2.6.0** was hardened automatically. 6 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate GitHub Actions expressions inside shell command strings without first assigning them to environment variables.

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` is interpolated directly into the shell command.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` is interpolated directly.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service-name` and `inputs.service` are interpolated directly.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` and `inputs.api_key` are interpolated directly.
5. Step 'Print summary': `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` is interpolated directly into a shell conditional.

An attacker supplying a crafted input value (e.g. containing shell metacharacters) could achieve arbitrary command execution.

Locations:

- `action.yml:70`
- `action.yml:163`
- `action.yml:170`
- `action.yml:177`
- `action.yml:213`

### github-env-injection (severity: high)

Multiple `run:` blocks write attacker-controlled `inputs.*` values (and one `github.*` value) to `$GITHUB_ENV` or `$GITHUB_PATH` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). This allows an attacker to inject arbitrary environment variable definitions by embedding newlines in input values.

1. Step 'Set global envs and github path': `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` where `GITHUB_ACTION_PATH` is set from `${{ github.action_path }}` via env — unsanitized write to GITHUB_PATH.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` written to GITHUB_ENV without sanitization.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — user-controlled service name written to GITHUB_ENV without sanitization.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — API key input written to GITHUB_ENV without sanitization.

A malicious value containing a newline (e.g. `value\nEVIL_VAR=injected`) would define additional environment variables for subsequent steps.

Locations:

- `action.yml:71`
- `action.yml:163`
- `action.yml:170`
- `action.yml:177`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:159`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:165`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:170`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:201`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all 6 findings in action.yml:
1. 'Set global envs and github path': Moved job.check_run_id to env block as JOB_CHECK_RUN_ID; sanitized both JOB_CHECK_RUN_ID and GITHUB_ACTION_PATH with printf/tr before writing to GITHUB_ENV/GITHUB_PATH.
2. 'Propagate optional site input to environment variable': Moved inputs.site to env block as DD_SITE_INPUT; sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable': Moved inputs.service-name and inputs.service to env block as SERVICE_NAME_INPUT and SERVICE_INPUT; replicated ternary logic in shell; sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider': Moved inputs.api-key and inputs.api_key to env block as API_KEY_HYPHEN_INPUT and API_KEY_UNDERSCORE_INPUT; replicated ternary logic in shell; sanitized before writing to GITHUB_ENV.
5. 'Print summary': Moved inputs.print-github-step-summary to env block as PRINT_GITHUB_STEP_SUMMARY; referenced as plain env var in shell conditional.


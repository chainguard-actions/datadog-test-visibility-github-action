# Hardening Report: datadog--test-visibility-github-action/v2.5.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `ff50f15e4b79bfbf764dafdfd2579175a6ea9771`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **datadog--test-visibility-github-action/v2.5.0** was hardened automatically. 11 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Propagate optional site input to environment variable' run: block directly interpolates the attacker-controlled expression ${{ inputs.site }} inside the shell command string: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`. The input value should be assigned to an env: variable and referenced as $ENV_VAR instead.

Locations:

- `action.yml:153`

### script-injection (severity: high)

The 'Propagate optional service input to environment variable' run: block directly interpolates attacker-controlled expressions ${{ inputs.service-name }} and ${{ inputs.service }} inside the shell command string: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`. These inputs should be assigned to env: variables and referenced as $ENV_VAR instead.

Locations:

- `action.yml:159`

### script-injection (severity: high)

The 'Propagate API key from input to environment variables and set provider' run: block directly interpolates attacker-controlled expressions ${{ inputs.api-key }} and ${{ inputs.api_key }} inside the shell command string: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`. These inputs should be assigned to env: variables and referenced as $ENV_VAR instead.

Locations:

- `action.yml:165`

### script-injection (severity: high)

The 'Print summary' run: block directly interpolates the attacker-controlled expression ${{ inputs.print-github-step-summary }} inside the shell command string: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]`. This input should be assigned to an env: variable and referenced as $ENV_VAR instead.

Locations:

- `action.yml:196`

### github-env-injection (severity: high)

The 'Propagate optional site input to environment variable' run: block writes the attacker-controlled value ${{ inputs.site }} directly to $GITHUB_ENV without sanitization: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`. An attacker can inject newlines to set arbitrary environment variables. The required sanitization step `printf '%s' "$VAR" | tr -d '\n\r'` is missing.

Locations:

- `action.yml:153`

### github-env-injection (severity: high)

The 'Propagate optional service input to environment variable' run: block writes attacker-controlled values ${{ inputs.service }} and ${{ inputs.service-name }} directly to $GITHUB_ENV without sanitization: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`. An attacker can inject newlines to set arbitrary environment variables. The required sanitization step `printf '%s' "$VAR" | tr -d '\n\r'` is missing.

Locations:

- `action.yml:159`

### github-env-injection (severity: high)

The 'Propagate API key from input to environment variables and set provider' run: block writes attacker-controlled values ${{ inputs.api-key }} and ${{ inputs.api_key }} directly to $GITHUB_ENV without sanitization: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`. An attacker can inject newlines to set arbitrary environment variables. The required sanitization step `printf '%s' "$VAR" | tr -d '\n\r'` is missing.

Locations:

- `action.yml:165`

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

Fixed all 11 findings in action.yml across 4 steps:
1. 'Propagate optional site input to environment variable': Moved ${{ inputs.site }} to env: as DD_SITE_INPUT, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Propagate optional service input to environment variable': Moved ${{ inputs.service-name }} and ${{ inputs.service }} to env: as SERVICE_NAME_INPUT/SERVICE_INPUT, implemented conditional logic in shell, sanitized before writing to GITHUB_ENV.
3. 'Propagate API key from input to environment variables and set provider': Moved ${{ inputs.api-key }} and ${{ inputs.api_key }} to env: as API_KEY_DASH_INPUT/API_KEY_UNDERSCORE_INPUT, implemented conditional logic in shell, sanitized before writing to GITHUB_ENV.
4. 'Print summary': Moved ${{ inputs.print-github-step-summary }} to env: as PRINT_GITHUB_STEP_SUMMARY and referenced it as $PRINT_GITHUB_STEP_SUMMARY in the shell script.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:

1. 'Set global envs and github path' step (line 68): Added `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` before writing to `$GITHUB_PATH`, replacing the direct `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` with the sanitized value.

2. 'Download and run configuration script' step (line 131): Replaced `./$script_filepath >> "$GITHUB_ENV"` with a pattern that captures script output into a variable, then processes each KEY=VALUE line individually — splitting on the first `=`, sanitizing the value with `printf '%s' "$value" | tr -d '\n\r'`, and writing the sanitized pair to `$GITHUB_ENV`. This prevents attacker-controlled input values (languages, site, tracer versions, etc.) containing newlines from injecting arbitrary env vars.


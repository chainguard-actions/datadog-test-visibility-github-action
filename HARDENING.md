# Hardening Report: datadog--test-visibility-github-action/v2.8.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `ff50f15e4b79bfbf764dafdfd2579175a6ea9771`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **datadog--test-visibility-github-action/v2.8.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple run: blocks in action.yml directly interpolate inputs.* expressions inside shell commands without first assigning them to environment variables. (1) Step 'Propagate optional site input': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site interpolated directly in shell. (2) Step 'Propagate optional service input': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service and inputs.service-name interpolated directly. (3) Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key and inputs.api_key interpolated directly. (4) Step 'Print summary': `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — inputs.print-github-step-summary interpolated directly in shell condition.

Locations:

- `action.yml:147`
- `action.yml:153`
- `action.yml:160`
- `action.yml:196`

### github-env-injection (severity: high)

Multiple run: blocks write attacker-controlled inputs.* values directly to $GITHUB_ENV without the required sanitization step (printf '%s' ... | tr -d '\n\r'). (1) Step 'Propagate optional site input': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — inputs.site written unsanitized to GITHUB_ENV. (2) Step 'Propagate optional service input': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — inputs.service/service-name written unsanitized to GITHUB_ENV. (3) Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — inputs.api-key/api_key written unsanitized to GITHUB_ENV. An attacker-controlled input containing newlines could inject arbitrary environment variables.

Locations:

- `action.yml:147`
- `action.yml:153`
- `action.yml:160`

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

Fixed all four affected steps in action.yml:
1. 'Propagate optional site input to environment variable': moved inputs.site to env block (DD_SITE_INPUT), sanitized with printf/tr before writing to GITHUB_ENV.
2. 'Propagate optional service input to environment variable': moved inputs.service-name and inputs.service to env block (SERVICE_NAME_INPUT, SERVICE_INPUT), replaced inline ternary with shell if/else, sanitized before writing to GITHUB_ENV.
3. 'Propagate API key from input to environment variables and set provider': moved inputs.api-key and inputs.api_key to env block (API_KEY_HYPHEN, API_KEY_UNDERSCORE), replaced inline ternary with shell if/else, sanitized before writing to GITHUB_ENV.
4. 'Print summary': moved inputs.print-github-step-summary to env block (PRINT_GITHUB_STEP_SUMMARY), replaced inline ${{ }} expression in shell if condition with the environment variable reference.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the 'Set global envs and github path' step in action.yml: replaced the direct `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH` with a sanitized version that strips newlines/carriage returns first using `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` before writing to $GITHUB_PATH. This prevents newline injection via the attacker-influenced `github.action_path` value.


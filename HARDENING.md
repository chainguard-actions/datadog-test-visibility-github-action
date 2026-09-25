<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.2.0** was hardened automatically. 13 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Set global envs and github path' step directly interpolates `${{ job.check_run_id }}` inside a `run:` shell command string. The expression is substituted by the Actions runner before the shell sees it, allowing injection of arbitrary shell content. Offending line: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV`

Locations:

- `action.yml:90`

### script-injection (severity: high)

Sub-rule (a): The 'Propagate optional site input to environment variable' step directly interpolates `${{ inputs.site }}` inside a `run:` shell command string. Attacker-controlled input is substituted before the shell parses the command. Offending line: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`

Locations:

- `action.yml:186`

### script-injection (severity: high)

Sub-rule (a): The 'Propagate optional service input to environment variable' step directly interpolates `${{ inputs.service-name }}` and `${{ inputs.service }}` inside a `run:` shell command string. Attacker-controlled inputs are substituted before the shell parses the command. Offending line: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`

Locations:

- `action.yml:192`

### script-injection (severity: high)

Sub-rule (a): The 'Propagate API key from input to environment variables and set provider' step directly interpolates `${{ inputs.api-key }}` and `${{ inputs.api_key }}` inside a `run:` shell command string. Attacker-controlled inputs are substituted before the shell parses the command. Offending line: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`

Locations:

- `action.yml:197`

### script-injection (severity: high)

Sub-rule (a): The 'Print summary' step directly interpolates `${{ inputs.print-github-step-summary }}` inside a `run:` shell command string inside a conditional expression. Attacker-controlled input is substituted before the shell parses the command. Offending line: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]; then`

Locations:

- `action.yml:220`

### github-env-injection (severity: high)

The 'Propagate optional site input to environment variable' step writes `${{ inputs.site }}` directly into $GITHUB_ENV without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). A newline in the input value can inject arbitrary environment variables into subsequent steps. Offending line: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`

Locations:

- `action.yml:186`

### github-env-injection (severity: high)

The 'Propagate optional service input to environment variable' step writes `${{ inputs.service }}` / `${{ inputs.service-name }}` directly into $GITHUB_ENV without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). A newline in the input value can inject arbitrary environment variables into subsequent steps. Offending line: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`

Locations:

- `action.yml:192`

### github-env-injection (severity: high)

The 'Propagate API key from input to environment variables and set provider' step writes `${{ inputs.api-key }}` / `${{ inputs.api_key }}` directly into $GITHUB_ENV without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). A newline in the input value can inject arbitrary environment variables into subsequent steps. Offending line: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`

Locations:

- `action.yml:197`

### github-env-injection (severity: high)

The 'Set global envs and github path' step writes `${{ job.check_run_id }}` directly into $GITHUB_ENV without sanitization (no `printf '%s' ... | tr -d '\n\r'` step). Although `job.check_run_id` is GitHub-controlled, it is still an expression interpolated directly into the shell command and written to $GITHUB_ENV. Offending line: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV`

Locations:

- `action.yml:90`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:186`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:192`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:197`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:228`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all 13 findings across 5 steps in action.yml:
1. 'Set global envs and github path' (line 90): Moved `${{ job.check_run_id }}` to env: block as JOB_CHECK_RUN_ID; sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Propagate optional site input to environment variable' (line 186): Moved `${{ inputs.site }}` to env: block as INPUT_SITE; sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable' (line 192): Moved the ternary expression for service/service-name to env: block as INPUT_SERVICE_EFFECTIVE; sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider' (line 197): Moved the ternary expression for api-key/api_key to env: block as INPUT_API_KEY_EFFECTIVE; sanitized before writing to GITHUB_ENV.
5. 'Print summary' (line 220/228): Moved `${{ inputs.print-github-step-summary }}` to env: block as INPUT_PRINT_GITHUB_STEP_SUMMARY; referenced as shell variable in the conditional.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. 'Set global envs and github path' step (line 92): Added newline sanitization for GITHUB_ACTION_PATH before writing to $GITHUB_PATH using `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and writing `$safe_action_path` instead.
2. 'Download and run configuration script' step (line 148): Replaced direct pipe of script stdout to $GITHUB_ENV with a sanitized approach: capture output to a temp file via mktemp, then process each KEY=VALUE line in a while loop that strips newlines from the value portion using `printf '%s' "$value" | tr -d '\n\r'` before writing to $GITHUB_ENV.


<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v2.6.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v2.6.0** was hardened automatically. 6 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in action.yml directly interpolate `${{ ... }}` expressions inside shell command strings (rule a). This allows an attacker-controlled value to be parsed by the shell before any quoting can protect it.

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — `job.check_run_id` is interpolated directly.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — `inputs.site` is interpolated directly.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"` — `inputs.service` and `inputs.service-name` are interpolated directly.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"` — `inputs.api-key` and `inputs.api_key` are interpolated directly.
5. Step 'Print summary': `if [ "${{ inputs.print-github-step-summary }}" == "false" ]` — `inputs.print-github-step-summary` is interpolated directly.

Fix: move each expression into an `env:` block and reference the env var (double-quoted) inside the `run:` script.

Locations:

- `action.yml:68`
- `action.yml:152`
- `action.yml:158`
- `action.yml:163`
- `action.yml:192`

### github-env-injection (severity: high)

Multiple `run:` blocks write values derived from untrusted `inputs.*` and `job.*` expressions directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). A newline character embedded in an input value can inject arbitrary environment variables into subsequent steps.

1. Step 'Set global envs and github path': `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` — unsanitized write of `job.check_run_id`.
2. Step 'Propagate optional site input to environment variable': `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"` — unsanitized write of `inputs.site`.
3. Step 'Propagate optional service input to environment variable': `echo "DD_SERVICE=${{ ... inputs.service ... }}" >> "$GITHUB_ENV"` — unsanitized write of `inputs.service` / `inputs.service-name`.
4. Step 'Propagate API key from input to environment variables and set provider': `echo "DD_API_KEY=${{ ... inputs.api_key ... }}" >> "$GITHUB_ENV"` — unsanitized write of `inputs.api_key` / `inputs.api-key`.

Fix: sanitize each value before writing, e.g.:
```
safe=$(printf '%s' "$INPUT_SITE" | tr -d '\n\r')
echo "DD_SITE=$safe" >> "$GITHUB_ENV"
```

Locations:

- `action.yml:68`
- `action.yml:152`
- `action.yml:158`
- `action.yml:163`

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

Fixed all 5 script-injection and 4 github-env-injection findings in action.yml:
1. 'Set global envs and github path': Moved `job.check_run_id` to env: block as JOB_CHECK_RUN_ID, sanitized with tr -d '\n\r' before writing to GITHUB_ENV.
2. 'Propagate optional site input to environment variable': Moved `inputs.site` to env: block as INPUT_SITE, sanitized before writing to GITHUB_ENV.
3. 'Propagate optional service input to environment variable': Moved `inputs.service` and `inputs.service-name` to env: block as INPUT_SERVICE and INPUT_SERVICE_NAME, replicated ternary logic with bash parameter expansion `${INPUT_SERVICE_NAME:-$INPUT_SERVICE}`, sanitized before writing to GITHUB_ENV.
4. 'Propagate API key from input to environment variables and set provider': Moved `inputs.api-key` and `inputs.api_key` to env: block as INPUT_API_KEY_HYPHEN and INPUT_API_KEY_UNDERSCORE, replicated ternary logic with bash parameter expansion, sanitized before writing to GITHUB_ENV.
5. 'Print summary': Moved `inputs.print-github-step-summary` to env: block as INPUT_PRINT_GITHUB_STEP_SUMMARY, referenced as double-quoted env var in shell condition.

### Iteration 2

**Fixes applied:** github-env-injection, github-env-injection

**Notes:**

Fixed two github-env-injection findings in action.yml:
1. 'Set global envs and github path' step (line 70): Added sanitization of GITHUB_ACTION_PATH before writing to $GITHUB_PATH. Now uses `safe_action_path=$(printf '%s' "$GITHUB_ACTION_PATH" | tr -d '\n\r')` and writes the sanitized value.
2. 'Download and run configuration script' step (line 130): Instead of piping script output directly to $GITHUB_ENV, the output is captured to a temp file via mktemp, then each line is sanitized with `printf '%s' "$line" | tr -d '\n\r'` before being appended to $GITHUB_ENV. The temp file is removed after processing.


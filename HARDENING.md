<!-- markdownlint-disable -->

# Hardening Report: DataDog--test-visibility-github-action/v3.4.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **DataDog--test-visibility-github-action/v3.4.0** was hardened automatically. 14 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): step 'Set global envs and github path' puts a `${{ }}` expression straight into the run script: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV`. Move it into an env: variable and expand it with double quotes.

Locations:

- `action.yml:91`

### github-env-injection (severity: high)

Step 'Set global envs and github path' writes workflow-controlled values to special env files without first running `printf '%s' ... | tr -d '\n\r'`. These lines are affected: `echo "JOB_CHECK_RUN_ID=${{ job.check_run_id }}" >> $GITHUB_ENV` and `echo "$GITHUB_ACTION_PATH" >> $GITHUB_PATH`, where GITHUB_ACTION_PATH comes from `${{ github.action_path }}`. The $GITHUB_ENV and $GITHUB_PATH targets are also unquoted.

Locations:

- `action.yml:91`
- `action.yml:92`

### script-injection (severity: high)

Rule (b): step 'Download and run configuration script' expands the inherited process env var GITHUB_WORKSPACE without quotes: `mkdir -p $GITHUB_WORKSPACE/.datadog`, `ln -s $GITHUB_WORKSPACE/.datadog /github/workspace/.datadog` and `export DD_TRACER_FOLDER=$GITHUB_WORKSPACE/.datadog`. Wrap each expansion in double quotes.

Locations:

- `action.yml:123`
- `action.yml:130`
- `action.yml:134`

### script-injection (severity: high)

Rule (a): step 'Propagate optional site input to environment variable' puts an input straight into the run script: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:213`

### github-env-injection (severity: high)

Step 'Propagate optional site input to environment variable' writes `inputs.site` to $GITHUB_ENV without stripping newlines first: `echo "DD_SITE=${{ inputs.site }}" >> "$GITHUB_ENV"`. An input containing a newline could inject extra environment variables.

Locations:

- `action.yml:213`

### script-injection (severity: high)

Rule (a): step 'Propagate optional service input to environment variable' puts inputs straight into the run script: `echo "DD_SERVICE=${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:219`

### github-env-injection (severity: high)

Step 'Propagate optional service input to environment variable' writes `inputs.service` or `inputs.service-name` to $GITHUB_ENV without the `printf '%s' ... | tr -d '\n\r'` step.

Locations:

- `action.yml:219`

### script-injection (severity: high)

Rule (a): step 'Propagate API key from input to environment variables and set provider' puts inputs straight into the run script: `echo "DD_API_KEY=${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:224`

### github-env-injection (severity: high)

Step 'Propagate API key from input to environment variables and set provider' writes `inputs.api-key` or `inputs.api_key` to $GITHUB_ENV without the `printf '%s' ... | tr -d '\n\r'` step.

Locations:

- `action.yml:224`

### script-injection (severity: high)

Rule (a): step 'Print summary' puts an input straight into the run script: `if [ "${{ inputs.print-github-step-summary }}" == "false" ]; then`. Pass it through an env: variable and quote the expansion.

Locations:

- `action.yml:255`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.site }}" appears directly in run: block of step "Propagate optional site input to environment variable"; move to env: map

Locations:

- `action.yml:214`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.service-name != '' && inputs.service-name || inputs.service }}" appears directly in run: block of step "Propagate optional service input to environment variable"; move to env: map

Locations:

- `action.yml:220`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.api-key != '' && inputs.api-key || inputs.api_key }}" appears directly in run: block of step "Propagate API key from input to environment variables and set provider"; move to env: map

Locations:

- `action.yml:225`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.print-github-step-summary }}" appears directly in run: block of step "Print summary"; move to env: map

Locations:

- `action.yml:256`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

action.yml changes:
- Moved job.check_run_id, inputs.site, the service/service-name expression, the api-key/api_key expression and inputs.print-github-step-summary out of run: scripts into step env: variables.
- Values written to GITHUB_ENV and GITHUB_PATH (JOB_CHECK_RUN_ID, the action path, DD_SITE, DD_SERVICE, DD_API_KEY) now go through printf '%s' | tr -d '\n\r' first.
- Put double quotes around the GITHUB_ENV, GITHUB_PATH, GITHUB_OUTPUT and GITHUB_STEP_SUMMARY targets and the GITHUB_WORKSPACE paths in mkdir, ln -s and the DD_TRACER_FOLDER export.
No behaviour changes otherwise. These are text edits only; nothing was run or tested.


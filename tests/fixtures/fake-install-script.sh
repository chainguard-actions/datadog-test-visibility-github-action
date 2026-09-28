#!/bin/sh
# Fake Datadog test visibility installation script
# Mimics the real script by setting environment variables for the configured languages

set -e

# Output env vars based on configured languages
LANGS="${DD_CIVISIBILITY_INSTRUMENTATION_LANGUAGES:-}"

echo "# Datadog Test Visibility configuration"

if echo "$LANGS" | grep -qi "js" || [ "$LANGS" = "all" ]; then
  echo "DD_TRACER_VERSION_JS=5.0.0"
  echo "NODE_OPTIONS=--require /github/workspace/.datadog/dd-trace/init.js"
fi

if echo "$LANGS" | grep -qi "python" || [ "$LANGS" = "all" ]; then
  echo "DD_TRACER_VERSION_PYTHON=2.0.0"
  echo "PYTHONPATH=/github/workspace/.datadog/ddtrace"
fi

if echo "$LANGS" | grep -qi "java" || [ "$LANGS" = "all" ]; then
  echo "DD_TRACER_VERSION_JAVA=1.0.0"
  echo "JAVA_TOOL_OPTIONS=-javaagent:/github/workspace/.datadog/dd-java-agent.jar"
fi

if echo "$LANGS" | grep -qi "dotnet" || [ "$LANGS" = "all" ]; then
  echo "DD_TRACER_VERSION_DOTNET=2.0.0"
fi

if echo "$LANGS" | grep -qi "ruby" || [ "$LANGS" = "all" ]; then
  echo "DD_TRACER_VERSION_RUBY=1.0.0"
fi

if echo "$LANGS" | grep -qi "go" || [ "$LANGS" = "all" ]; then
  echo "DD_TRACER_VERSION_GO=0.1.0"
fi

echo "DD_CIVISIBILITY_ENABLED=true"

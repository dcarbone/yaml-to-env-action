#!/usr/bin/env bash

GITHUB_ENV="$(pwd)/test.env"
YAMLTOENV_DEBUG='true'
YAMLTOENV_YAML_FILE="$(pwd)/test-values.yaml"

printf '' > $GITHUB_ENV

export GITHUB_ENV
export YAMLTOENV_DEBUG
export YAMLTOENV_YAML_FILE

exec "$(pwd)/scripts/yaml-to-env.sh"

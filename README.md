# YAML to ENV GitHub Action

[GitHub Action](https://docs.github.com/en/actions) that reads values from a YAML file, setting them into the `$GITHUB_ENV` of a job.

# Index

1. [Example Workflow](#example-workflow)
2. [Conversion Rules](#conversion-rules) 
3. [Inputs](#action-inputs)
4. [Outputs](#action-outputs)

## Example Workflow

```yaml
name: YAML to Env Example Workflow

on:
  workflow_dispatch:
    inputs:
      yaml-file:
        type: string
        required: false
        description: "Path to YAML file to parse"
        default: "test-values.yaml"
      yq-version:
        type: string
        required: false
        description: "Version of yq to install, if not already"
        default: "4.27.5"
      debug:
        type: boolean
        required: false
        description: "Enable debug logging"
        default: false

jobs:
  yaml-to-env:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set ENV values from YAML
        uses: dcarbone/yaml-to-env-action@v1.0.0
        with:
          debug: '${{ inputs.debug }}'
          yaml-file: '${{ inputs.yaml-file }}'
          yq-version: '${{ inputs.yq-version }}'

      - name: Print environment variables
        run: |
          printenv

```

## Conversion Rules

#### Simple

Source YAML:
```yaml
key: value
```

Output env:
```text
KEY=value
```

#### Nested Object

Source YAML:
```yaml
object:
  key1: value1
  key2: value 2
  key3:
    - nested value 1
    - nested value 2
```

Output env:
```text
OBJECT_KEY1=value1
OBJECT_KEY2=value 2
OBJECT_KEY3_0=nested value 1
OBJECT_KEY3_1=nested value 2
```

#### Multiline value

Source YAML:
```yaml
multiline: |
  value with
  more than 1 line
```

Output env:
```text
MULTILINE<<EOF
value with
more than 1 line
EOF
```

## Action Inputs

#### yaml-file
```yaml
  yaml-file:
    required: true
    description: "Filepath to YAML to parse"
```

#### yq-version
```yaml
  yq-version:
    required: false
    default: "4.27.5"
    description: "Version of yq to install, if not already in path.  Tested with >= 4.25."
```

#### debug
```yaml
  debug:
    required: false
    default: "false"
    description: "Enable debug logging.  This WILL print un-masked secrets to stdout, so use with caution."
```

## Action Outputs

#### yq-installed
```yaml
  yq-installed:
    description: "'true' if yq was installed by this action"
```

# YAML to ENV GitHub Action

[GitHub Action](https://docs.github.com/en/actions) that reads values from a YAML file, setting them into the `$GITHUB_ENV` of a job.

<!-- TOC -->
* [YAML to ENV GitHub Action](#yaml-to-env-github-action)
  * [Example Workflow](#example-workflow)
  * [Conversion Rules](#conversion-rules)
    * [Names](#names)
      * [Simple](#simple)
      * [Nested Object](#nested-object)
      * [Multiline value](#multiline-value)
  * [Action Inputs](#action-inputs)
      * [yaml-file](#yaml-file)
      * [yq-version](#yq-version)
      * [mask-values](#mask-values)
  * [Action Outputs](#action-outputs)
      * [yq-installed](#yq-installed)
      * [var-count](#var-count)
      * [yaml-keys](#yaml-keys)
      * [env-names](#env-names)
<!-- TOC -->

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
      mask-values:
        type: string
        required: false
        default: 'false'
        description: 'If "true", masks all extracted values.'

jobs:
  yaml-to-env:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set ENV values from YAML
        uses: dcarbone/yaml-to-env-action@v2
        with:
          yaml-file: '${{ inputs.yaml-file }}'
          yq-version: '${{ inputs.yq-version }}'

      - name: Print environment variables
        run: |
          printenv

```

## Conversion Rules

### Names

Key to env name happens using the following script:

```shell
tr '[:lower:]' '[:upper:]' | sed -E 's/[^a-zA-Z0-9_]/_/g';
```

You can see the exact logic [here](./scripts/yaml-to-env.sh)

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

#### mask-values
```yaml
  mask-values:
    required: false
    default: "false"
    description: "Add value masking to all exported environment variable values (https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#example-masking-an-environment-variable)"
```

## Action Outputs

#### yq-installed
```yaml
  yq-installed:
    description: "'true' if yq was installed by this action"
```

#### var-count
```yaml
  var-count:
    description: "Number of environment variables defined from source YAML file."
```

#### yaml-keys
```yaml
  yaml-keys:
    description: "Comma-separated string of keys extracted from source YAML file."
```

#### env-names
```yaml
  env-names:
    description: "Comma-separated string of exported environment variable names"
```

---
name: maven-generate-dependency-tree
description: Generate a timestamped maven dependency tree report in markdown format.
argument-hint: "timestamp=<yyyymmdd-hhmmss>, outputPath=<directory-path>"
authors: ["paul58914080@gmail.com"]
---

# Generate Dependency Tree Report

Run a maven command to generate a dependency tree report in markdown format. The report will be timestamped and saved to the specified output directory.

## Purpose

The purpose of this skill is to generate a comprehensive dependency tree for a Maven project, which helps in understanding the project's dependencies and their relationships.

Use this skill when you need a detailed view of the dependencies in a Maven project, with an output file path derived from:

- `timestamp`: A string in the format `yyyymmdd-hhmmss` representing the time when the report is generated.
- `outputPath`: A string representing the directory path where the generated report will be saved.

Trigger examples: 

- `Run generate-dependency-tree with defaults`
- `Run generate dependency tree`
- `Run generate maven dependency tree`
- `Run the maven dependency tree report with timestamp=20240101-120000`
- `Run dependency tree report with timestamp=20240101-120000 and outputPath=/reports/dependency-tree`

## Inputs

Optional inputs include:

- `timestamp`: A string in the format `yyyymmdd-hhmmss` representing the time when the report is generated. If not provided, the current timestamp will be used.
- `outputPath`: A string representing the directory path where the generated report will be saved. If not provided, the report will be saved in `maven-dependency-tree` directory.

## Execution order

1. Resolve the timestamp and outputPath inputs, using defaults if necessary.
2. Create the target directory: cortexaidevkit/<timestamp>/<outputPath> if it does not exist.
3. Run this command in the root directory of the Maven project after resolving the inputs: 
    ```
    sh ./.github/skills/maven-generate-dependency-tree/scripts/maven-generate-dependency-tree.sh -t <timestamp> -o <outputPath>
    ```

## Decision points

- If timestamp is invalid, stop and request a valid timestamp in the format `yyyymmdd-hhmmss`.
- If outputPath is invalid, stop and request a valid directory path.
- If maven i.e. `mvn` is unavailable, stop and report that Maven is required to run this skill.
- If no `pom.xml` is found in the current directory, stop and report that the skill must run from the Maven project root.
- If the command fails, stop and report the error code, message, and any relevant details to help diagnose the issue.

## Quality checks

- Verify that the generated report file exists in the specified path i.e. cortexaidevkit/<timestamp>/<outputPath>/dependency.dot

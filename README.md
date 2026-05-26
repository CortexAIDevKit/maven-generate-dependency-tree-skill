# maven-generate-dependency-tree

GitHub Copilot Skill to generate a timestamped Maven dependency tree report for single and multi-module maven projects.

## What this skill does ?

This repository contains a **GitHub Copilot Skill**. Copilot agents in VS Code
discover it via `.github/skills/maven-generate-dependency-tree/SKILL.md` and
execute its script on demand.

The skill runs Maven dependency analysis and writes a Graphviz DOT report to:

`cortexaidevkit/<timestamp>/<outputPath>/dependency.dot`

It supports:

- `timestamp` in `yyyymmdd-hhmmss` format (defaults to current time)
- `outputPath` as a relative directory (defaults to `maven-dependency-tree`)

For multi-module projects, it generates module-level `.dot` files at `cortexaidevkit/<timestamp>/<outputPath>/module-dot` and
aggregates them into a single `cortexaidevkit/<timestamp>/<outputPath>/dependency.dot` output.

## Structure

```
maven-generate-dependency-tree/
└── .github/
    └── skills/
        └── maven-generate-dependency-tree/
            ├── SKILL.md
            └── scripts/
                └── maven-generate-dependency-tree.sh
```

- `SKILL.md`: skill metadata and execution instructions for Copilot.
- `scripts/maven-generate-dependency-tree.sh`: entry point that validates
  inputs and runs `mvn dependency:tree`.

## Requirements

- Maven available on `PATH` (`mvn`)
- A `pom.xml` in the current working directory

## Invoking from Copilot

Open Copilot Chat in VS Code and reference the skill name
`maven-generate-dependency-tree`, for example:

- "Run generate maven dependency tree"
- "Run the maven dependency tree report with timestamp=20260526-153000"
- "Run dependency tree report with timestamp=20260526-153000 and outputPath=reports"


## Running scripts locally

From the Maven project root:

```bash
sh ./.github/skills/maven-generate-dependency-tree/scripts/maven-generate-dependency-tree.sh
```

With explicit inputs:

```bash
sh ./.github/skills/maven-generate-dependency-tree/scripts/maven-generate-dependency-tree.sh \
  -t 20260526-153000 \
  -o maven-dependency-tree
```


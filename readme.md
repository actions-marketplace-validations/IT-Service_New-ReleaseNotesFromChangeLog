# GitHub Action "New-ReleaseNotesFromChangeLog"

[![GitHub release](https://img.shields.io/github/v/release/IT-Service/New-ReleaseNotesFromChangeLog.svg?sort=semver&logo=github)](https://github.com/IT-Service/New-ReleaseNotesFromChangeLog/releases)

[![Semantic Versioning](https://img.shields.io/static/v1?label=Semantic%20Versioning&message=v2.0.0&color=green&logo=semver)](https://semver.org/lang/ru/spec/v2.0.0.html)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-v1.0.0-yellow.svg?logo=git)](https://conventionalcommits.org)

This action create ReleaseNotes.md file from ChangeLog.md content for specified
project version (or for latest (top) version in ChangeLog.md).

## Usage

See [action.yml](action.yml)

Basic:

```yaml
steps:
- uses: actions/checkout@v3
- uses: actions/New-ReleaseNotesFromChangeLog@v1
  with:
    release-notes-path: "RELEASENOTES.md" # path for generated file
    version: "v1.2.0" # project version for ReleaseNotes.md
    verbose: true # generate verbose action output
```

Automatic version project detection with `GitVersion`:

```yaml
steps:
- uses: actions/checkout@v3
- uses: actions/New-ReleaseNotesFromChangeLog@v1
  with:
    use-gitversion: true
    gitversion-use-config-file: true
    release-notes-path: "RELEASENOTES.md"
    verbose: true
```

Use project version from tag name:

```yaml
steps:
- uses: actions/checkout@v3
- uses: actions/New-ReleaseNotesFromChangeLog@v1
  with:
    use-tag-as-version: true
    release-notes-path: "RELEASENOTES.md"
    verbose: true
```

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE).

## Contributions

Contributions are welcome! See [Contributor's Guide](.github/CONTRIBUTING.md).

# -*- Mode: Makefile; tab-width: 4; indent-tabs-mode: t -*- vim:noet:sw=4:ts=4:syntax=just
#
# Revision History:
#
PROJECT_NAME := `basename "$PWD"`
PROJECT_VERSION := `yq -r .version vars/version.yml`
BUMP_VERSION := `grep ^current_version .bumpversion.cfg | awk '{print $NF}'`

vars:
    @echo "PROJECT_NAME: {{PROJECT_NAME}}"
    @echo "PROJECT_VERSION: {{PROJECT_VERSION}}"
    @echo "BUMP_VERSION: {{BUMP_VERSION}}"

version-sanity:
  #!/usr/bin/env bash
  set -euo pipefail
  error() { echo "$@" >&2 ; exit 1; }
  if [[ "{{PROJECT_VERSION}}" != "{{BUMP_VERSION}}" ]]; then
    error "Version mismatch {{PROJECT_VERSION}} != {{BUMP_VERSION}}"
  else
    echo "Versions are equal {{PROJECT_VERSION}}, {{BUMP_VERSION}}"
  fi

changelog-check:
  #!/usr/bin/env bash
  set -euo pipefail
  error() { echo "$@" >&2 ; exit 1; }
  if echo "{{PROJECT_VERSION}}" | grep -q "dev"; then
    error "Cannot pull request when dev version"
  elif ! grep -q "^## \[{{PROJECT_VERSION}}\] - 20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]$" CHANGELOG.md; then
    error "No changelog entry for {{PROJECT_VERSION}}"
  elif grep -q "Unreleased" CHANGELOG.md; then
    error "Unreleased section in CHANGELOG.md"
  else
    echo "Changelog entry found for {{PROJECT_VERSION}}"
  fi

lint:
    ansible-lint

test: version-sanity lint

citest: changelog-check test

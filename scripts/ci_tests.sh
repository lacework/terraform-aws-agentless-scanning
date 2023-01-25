#!/bin/bash
#
# Name::        ci_tests.sh
# Description:: Use this script to run ci tests of this repository
# Author::      Salim Afiune Maya (<afiune@lacework.net>)
#
set -eou pipefail

readonly project_name=terraform-aws-agentless-scanning

TEST_CASES=(
  exmaples/multi-account-multi-region-auto-snapshot
  examples/multi-account-multi-region
  examples/single-account-existing-vpc
  examples/single-account-multi-region
  examples/single-account-single-region
  examples/use-existing-iam-roles-single-region
  examples/use-existing-iam-roles-multi-region
)

log() {
  echo "--> ${project_name}: $1"
}

warn() {
  echo "xxx ${project_name}: $1" >&2
}

integration_tests() {
  for tcase in ${TEST_CASES[*]}; do
    log "Running tests at $tcase"
    ( cd $tcase || exit 1
      terraform init
      terraform validate
      terraform plan
    ) || exit 1
  done
}

lint_tests() {
  log "terraform fmt check"
  terraform fmt -check
}

main() {
  lint_tests
  integration_tests
}

main || exit 99

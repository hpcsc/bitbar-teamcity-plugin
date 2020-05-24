#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

teardown() {
  unset -f date
}

@test "return INACTIVE if current time is before from field" {
  date() {
    echo "05:25"
  }
  export -f date

  BASE_DIR=$(dirname ${BATS_TEST_DIRNAME})
  run ${BASE_DIR}/src/teamcity-build-status.2m.sh
  assert_success
  assert_output --partial 'INACTIVE'
}

@test "return INACTIVE if current time is after until field" {
  date() {
    echo "17:01"
  }
  export -f date

  BASE_DIR=$(dirname ${BATS_TEST_DIRNAME})
  run ${BASE_DIR}/src/teamcity-build-status.2m.sh
  assert_success
  assert_output --partial 'INACTIVE'
}

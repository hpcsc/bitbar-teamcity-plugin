#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

teardown() {
  unset -f date
  unset -f security
  unset -f curl
}

@test "return INACTIVE if current time is before from field" {
  date() { echo "05:25"; }
  export -f date

CONFIG=$(cat <<'EOF'
{
    "username": "admin",
    "server": "http://localhost:8111",
    "projectId": "SomeProjectId",
    "keychainAccountId": "local-teamcity",
    "from": "09:00"
}
EOF
)

  BASE_DIR=$(dirname ${BATS_TEST_DIRNAME})
  run ${BASE_DIR}/src/teamcity-build-status.2m.sh <(echo ${CONFIG})

  assert_success
  assert_output --partial 'INACTIVE'
}

@test "return INACTIVE if current time is after until field" {
  date() { echo "17:01"; }
  export -f date

CONFIG=$(cat <<'EOF'
{
    "username": "admin",
    "server": "http://localhost:8111",
    "projectId": "SomeProjectId",
    "keychainAccountId": "local-teamcity",
    "until": "17:00"
}
EOF
)

  BASE_DIR=$(dirname ${BATS_TEST_DIRNAME})
  run ${BASE_DIR}/src/teamcity-build-status.2m.sh <(echo ${CONFIG})

  assert_success
  assert_output --partial 'INACTIVE'
}

@test "return INACTIVE if current date is not within configured daysOfWeek" {
  date() {
    if [ "$1" = "+%H:%M" ]; then
      echo "17:01";
    else
      echo "2";
    fi;
  }
  export -f date

CONFIG=$(cat <<'EOF'
{
    "username": "admin",
    "server": "http://localhost:8111",
    "projectId": "SomeProjectId",
    "keychainAccountId": "local-teamcity",
    "daysOfWeek": "1,3,4,5"
}
EOF
)

  BASE_DIR=$(dirname ${BATS_TEST_DIRNAME})
  run ${BASE_DIR}/src/teamcity-build-status.2m.sh <(echo ${CONFIG})

  assert_success
  assert_output --partial 'INACTIVE'
}

@test "return SUCCESS if all builds returned have success status" {
  security() { echo "password: blah"; }
  export -f security
  curl() {
    source 'tests/fake-teamcity-response-generator.sh'
    generate_fake_teamcity_response 3
  }
  export -f curl

CONFIG=$(cat <<'EOF'
{
    "username": "admin",
    "server": "http://localhost:8111",
    "projectId": "SomeProjectId",
    "keychainAccountId": "local-teamcity"
}
EOF
)

  BASE_DIR=$(dirname ${BATS_TEST_DIRNAME})
  run ${BASE_DIR}/src/teamcity-build-status.2m.sh <(echo ${CONFIG})

  assert_success
  assert_output --partial 'SUCCESS'
}

@test "return FAILURE if at least one build has failure status" {
  security() { echo "password: blah"; }
  export -f security
  curl() {
    source 'tests/fake-teamcity-response-generator.sh'
    generate_fake_teamcity_response 2 1
  }
  export -f curl

CONFIG=$(cat <<'EOF'
{
    "username": "admin",
    "server": "http://localhost:8111",
    "projectId": "SomeProjectId",
    "keychainAccountId": "local-teamcity"
}
EOF
)

  BASE_DIR=$(dirname ${BATS_TEST_DIRNAME})
  run ${BASE_DIR}/src/teamcity-build-status.2m.sh <(echo ${CONFIG})

  assert_success
  assert_output --partial 'FAILURE'
}

@test "return links to failure builds if at least one build has failure status" {
  security() { echo "password: blah"; }
  export -f security
  curl() {
    source 'tests/fake-teamcity-response-generator.sh'
    generate_fake_teamcity_response 2 1
  }
  export -f curl

CONFIG=$(cat <<'EOF'
{
    "username": "admin",
    "server": "http://localhost:8111",
    "projectId": "SomeProjectId",
    "keychainAccountId": "local-teamcity"
}
EOF
)

  BASE_DIR=$(dirname ${BATS_TEST_DIRNAME})
  run ${BASE_DIR}/src/teamcity-build-status.2m.sh <(echo ${CONFIG})

  assert_success
  assert_output --partial 'http://localhost:8111/viewLog.html?buildId=260&buildTypeId=failure-project-1'
}

@test "return UNREACHABLE if not able to reach TeamCity after timeout period" {
  security() { echo "password: blah"; }
  export -f security

CONFIG=$(cat <<'EOF'
{
    "username": "admin",
    "server": "http://not-existing-server:8111",
    "projectId": "SomeProjectId",
    "keychainAccountId": "local-teamcity"
}
EOF
)

  BASE_DIR=$(dirname ${BATS_TEST_DIRNAME})
  run ${BASE_DIR}/src/teamcity-build-status.2m.sh <(echo ${CONFIG})

  assert_success
  assert_output --partial 'UNREACHABLE'
}

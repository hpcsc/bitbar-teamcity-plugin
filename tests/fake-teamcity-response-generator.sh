#!/usr/bin/env bash

BUILD_TEMPLATE=$(cat <<EOF
{
    "id": "{project-id}",
    "name": "{build-id}",
    "project": {
        "id": "{project-id}",
        "name": "{project-id}",
        "parentProjectId": "{project-id}-Parent",
        "href": "/app/rest/projects/id:{project-id}",
        "webUrl": "http://localhost:8111/project.html?projectId={project-id}"
    },
    "builds": {
        "build": [
            {
                "number": "46",
                "status": "{status}",
                "webUrl": "http://localhost:8111/viewLog.html?buildId=260&buildTypeId={project-id}",
                "statusText": "{status}"
            }
        ]
    }
}
EOF
)

_generate_builds_response() {
    local no_of_builds=$1
    local status=$2

    local response=''
    for i in $(seq 1 ${no_of_builds}); do
        local delimiter=','
        if [ "${i}" = "1" ]; then
            delimiter=''
        fi;

        response="${response}${delimiter}$(echo ${BUILD_TEMPLATE} | \
                        sed 's/{project-id}/'${status}'-project-'${i}'/g' | \
                        sed 's/{status}/'$(echo ${status} | tr '[:lower:]' '[:upper:]')'/g' | \
                        sed 's/{build-id}/'${status}'-build-'${i}'/g')"
    done
    echo "${response}"
}

generate_fake_teamcity_response() {
    local no_of_success=${1:-1}
    local no_of_failure=${2:-0}

    local success_builds=$(_generate_builds_response ${no_of_success} success)
    local builds="${success_builds}"

    if [ "${no_of_failure}" != "0" ]; then
        local failure_builds=$(_generate_builds_response ${no_of_failure} failure)
        builds="${builds},${failure_builds}"
    fi;

    echo '{ "buildType": ['${builds}'] }'
}

#!/usr/bin/env bash

# <bitbar.title>TeamCity Build Status</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>David Nguyen</bitbar.author>
# <bitbar.author.github>hpcsc</bitbar.author.github>
# <bitbar.desc>Displays TeamCity build status</bitbar.desc>
# <bitbar.dependencies>jq,curl</bitbar.dependencies>
# <bitbar.image>https://i.imgur.com/BJ9SNIh.png</bitbar.image>
# <bitbar.abouturl>https://github.com/hpcsc/bitbar-teamcity-plugin</bitbar.abouturl>
#
# Displays status of a TeamCity project
# If any build configuration in that TeamCity project fails, the link to TeamCity page for that build configuration is displayed in the dropdown
#
# CONFIGURATION
# - This plugin requires your TeamCity password to be stored in MacOs Keychain:
#     - Open MacOs Keychain Access
#     - Choose `login` in `Keychains` panel and `Passwords` in `Category` panel
#     - Click `+` button at the top, fill in:
#     Keychain Item Name: anything
#     Account Name: e.g. teamcity-admin
#     Password: your TeamCity password
#     - Click `Add`
#
# - Fill in configuration in .bitbar-teamcity-plugin.json in Bitbar plugins folder

export PATH=/usr/local/bin:${PATH}

if ([[ "$(type -t jq)" != "function" ]] && [[ ! -x "$(command -v jq)" ]]) ||
    ([[ "$(type -t curl)" != "function" ]] && [[ ! -x "$(command -v curl)" ]]); then
    echo "=== jq and curl are required for this plugin"
    echo "They are either not installed or not available at PATH=${PATH}"
    exit 1
fi;

SCRIPT_DIR=$(cd $(dirname $0); pwd)
CONFIG_FILE=${1:-${SCRIPT_DIR}/.bitbar-teamcity-plugin.json}

CONFIG=$(cat ${CONFIG_FILE})
USERNAME=$(echo ${CONFIG} | jq -r '.username')
SERVER=$(echo ${CONFIG} | jq -r '.server')
PROJECT_ID=$(echo ${CONFIG} | jq -r '.projectId')
KEYCHAIN_ACCOUNT_ID=$(echo ${CONFIG} | jq -r '.keychainAccountId')
FROM=$(echo ${CONFIG} | jq -r '.from | select (. != null)')
UNTIL=$(echo ${CONFIG} | jq -r '.until | select (. != null)')
DAYS_OF_WEEK=$(echo ${CONFIG} | jq -r '.daysOfWeek | select (. != null)')

PROJECT_URL="Open TeamCity | href=${SERVER}/project/${PROJECT_ID}"

print_inactive_output() {
    echo "INACTIVE | color=gray"
    echo "---"
    echo "${PROJECT_URL}"
}

if ([[ -n "${UNTIL}" ]] && [[ "$(date '+%H:%M')" > "${UNTIL}" ]]) ||
   ([[ -n "${FROM}" ]] && [[ "$(date '+%H:%M')" < "${FROM}" ]]); then
    print_inactive_output
    exit 0
fi;

if [[ -n "${DAYS_OF_WEEK}" ]] && [[ "${DAYS_OF_WEEK}," != *"$(date '+%u'),"* ]]; then
    print_inactive_output
    exit 0
fi;

KEYCHAIN_RECORD=$(security 2>&1 >/dev/null find-generic-password -ga ${KEYCHAIN_ACCOUNT_ID})
PASSWORD=$(echo ${KEYCHAIN_RECORD} | sed 's/password:[[:space:]]"\(.*\)"/\1/')

BUILDS=$(curl -H 'Accept: application/json' \
              -u "${USERNAME}:${PASSWORD}" \
              -s \
              --max-time 3 \
              ${SERVER}/app/rest/buildTypes?locator=affectedProject:\(id:${PROJECT_ID}\)\&fields=buildType\(id,name,project,builds\(\$locator\(running:any,canceled:false,count:1\),build\(number,status,statusText,webUrl\)\)\)
        )

if [[ $? -ne 0 ]]; then
    echo "UNREACHABLE | color=red"
    echo "---"
    echo "${PROJECT_URL}"
    exit 0
fi;

LINKS=$(echo ${BUILDS} | \
    jq -r '.buildType[] | select(.builds.build[0].status == "FAILURE") | (.project.name) + " - " + (.name) + " #" + (.builds.build[0].number) + "| color=red href=" + (.builds.build[0].webUrl) + "\n--" + .builds.build[0].statusText +" | color=red href=" + (.builds.build[0].webUrl)')
IFS=$'\n'

NO_OF_FAILED_BUILDS=$(echo ${LINKS} | tr -d '\n' | tr -d ' ')
if [ "${NO_OF_FAILED_BUILDS}" = "" ]; then
    echo "SUCCESS | color=green"
else
    echo "FAILURE | color=red"
    echo "---"
    for link in ${LINKS}; do
        echo $link
    done
fi

echo "---"
echo "${PROJECT_URL}"

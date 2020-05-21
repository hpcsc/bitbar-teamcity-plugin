#!/bin/bash

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

if [[ ! -x "$(command -v jq)" ]] || [[ ! -x "$(command -v curl)" ]]; then
    echo "=== jq and curl are required for this plugin"
    echo "They are either not installed or not available at PATH=${PATH}"
    exit 1
fi;

SCRIPT_DIR=$(cd $(dirname $0); pwd)

CONFIG=$(cat ${SCRIPT_DIR}/.bitbar-teamcity-plugin.json)
USERNAME=$(echo ${CONFIG} | jq -r '.username')
SERVER=$(echo ${CONFIG} | jq -r '.server')
PROJECT_ID=$(echo ${CONFIG} | jq -r '.projectId')
KEYCHAIN_ACCOUNT_ID=$(echo ${CONFIG} | jq -r '.keychainAccountId')
FROM=$(echo ${CONFIG} | jq -r '.from | select (. != null)')
UNTIL=$(echo ${CONFIG} | jq -r '.until | select (. != null)')

PROJECT_URL="Open TeamCity | href=${SERVER}/project/${PROJECT_ID}"

if ([[ -n "${UNTIL}" ]] && [[ "$(date '+%H:%M')" > "${UNTIL}" ]]) ||
   ([[ -n "${FROM}" ]] && [[ "$(date '+%H:%M')" < "${FROM}" ]]); then
    echo "INACTIVE | color=gray"
    echo "---"
    echo "${PROJECT_URL}"
    exit 0
fi;

KEYCHAIN_RECORD=$(security 2>&1 >/dev/null find-generic-password -ga ${KEYCHAIN_ACCOUNT_ID})
PASSWORD=$(echo ${KEYCHAIN_RECORD} | sed 's/password:[[:space:]]"\(.*\)"/\1/')

BUILDS=$(curl -H 'Accept: application/json' \
              -u "${USERNAME}:${PASSWORD}" \
              -s \
              ${SERVER}/app/rest/buildTypes?locator=affectedProject:\(id:${PROJECT_ID}\)\&fields=buildType\(id,name,project,builds\(\$locator\(running:any,canceled:false,count:1\),build\(number,status,statusText,webUrl\)\)\)
        )

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

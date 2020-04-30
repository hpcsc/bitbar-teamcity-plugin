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
# - Fill in below configuration variables

USERNAME="your-teamcity-username"
SERVER="https://your-teamcity-url"
PROJECT_ID="id-of-the-teamcity-project-that-you-want-to-monitor"
KEYCHAIN_ACCOUNT_ID="your-keychain-account-id"

# END CONFIGURATION

KEYCHAIN_RECORD=$(security 2>&1 >/dev/null find-generic-password -ga ${KEYCHAIN_ACCOUNT_ID})
PASSWORD=$(echo ${KEYCHAIN_RECORD} | sed 's/password:[[:space:]]"\(.*\)"/\1/')

BUILDS=$(curl -H 'Accept: application/json' \
              -u "${USERNAME}:${PASSWORD}" \
              -s \
              ${SERVER}/app/rest/buildTypes?locator=affectedProject:\(id:${PROJECT_ID}\)\&fields=buildType\(id,name,project,builds\(\$locator\(running:any,canceled:false,count:1\),build\(number,status,statusText,webUrl\)\)\)
        )

export PATH=/usr/local/bin:${PATH}

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
echo "Open TeamCity | href=${SERVER}/project/${PROJECT_ID}"

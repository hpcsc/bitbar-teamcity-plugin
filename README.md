# BitBar TeamCity Build Status

A plugin for [BitBar](https://github.com/matryer/bitbar) to display build status of a TeamCity project

![Screenshot](https://i.imgur.com/BJ9SNIh.png)

## Setup

- Follow instruction in BitBar to install BitBar and setup plugins directory
- Store your TeamCity password in MacOs Keychain:
    - Open your MacOs Keychain Access
    - Choose `login` in `Keychains` panel and `Passwords` in `Category` panel
    - Click `+` button at the top, fill in:
    ```
    Keychain Item Name: anything
    Account Name: e.g. teamcity-admin
    Password: your TeamCity password
    ```
    - Click `Add`

- Update the configuration for this plugin in the shell script file:

```
USERNAME="your-teamcity-username"
SERVER="https://your-teamcity-url"
PROJECT_ID="id-of-the-teamcity-project-that-you-want-to-monitor"    # this id is displayed in the url when you navigate to your TeamCity project using browser
KEYCHAIN_ACCOUNT_ID=teamcity-admin  # this matches the account name in previous step
```

- Drop the script into your BitBar plugin folder
- When the plugin runs for the 1st time, it will ask for permission to access your Keychain to get TeamCity password.

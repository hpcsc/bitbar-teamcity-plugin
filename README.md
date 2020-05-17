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

- Clone this repository and symlink the script in this repo to your BitBar plugins folder:

    ```
    ln -s $PWD/teamcity-build-status.2m.sh path-to-your-bitbar-plugin-folder/teamcity-build-status.2m.sh
    ```

- Copy `sample.config.json` to your BitBar plugins folder and rename it:

    ```
    cp ./sample-config.json path-to-your-bitbar-plugin-folder/.bitbar-teamcity-plugin.json
    ```

    Notice the dot in front of json file name? This is to prevent BitBar from executing this file

- Update configuration in your `bitbar-teamcity-plugin.json`

Note: When the plugin runs for the 1st time, it will ask for permission to access your Keychain to get TeamCity password.

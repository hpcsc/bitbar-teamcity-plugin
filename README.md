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
    ln -s $PWD/src/teamcity-build-status.2m.sh path-to-your-bitbar-plugin-folder/teamcity-build-status.2m.sh
    ```

- Copy `sample.config.json` to your BitBar plugins folder and rename it to `.bitbar-teamcity-plugin.json`:

    ```
    cp ./sample-config.json path-to-your-bitbar-plugin-folder/.bitbar-teamcity-plugin.json
    ```

    Notice the dot in front of json file name? This is to prevent BitBar from executing this file

- Update configuration in your `bitbar-teamcity-plugin.json`

    - `from`/`until` fields:

        The plugin will not make the call to TeamCity server if the current time is not within `from` and `until` timespan. Both `from` and `until` are optional. When they are present, they must follow the format of `HH:mm` where `HH` is in 24h format (if the hour component is less than 10, prefix it with 0 like `06`). The plugin only uses string comparison to compare the time for simplicity and therefore will not be able to handle complicated/invalid time pattern.

Note: When the plugin runs for the 1st time, it will ask for permission to access your Keychain to get TeamCity password.


## Run Tests

This project uses [bats](https://github.com/bats-core/bats-core) and several of its additional libraries like [bats-assert](https://github.com/bats-core/bats-assert) and [bats-support](https://github.com/bats-core/bats-support) for testing

To run the test locally:

```
git submodule update --init --remote    # pull bats dependency libraries
./batect test                           # run tests using batect. Tests are run in bats container
```

# koha-plugin-rest-biblios

This is a REST API plugin for Koha. It provides API support for
modifying biblio records.

Some of the functionality is based on Koha code (see
https://github.com/Koha-Community/Koha/) and koha-plugin-rest-di (see
https://github.com/NatLibFi/koha-plugin-rest-di).

## Downloading

You can download the relevant *.kpz file from the [release page](https://github.com/NatLibFi/koha-plugin-rest-biblios/releases).

## Installing

The plugin is installed by uploading the KPZ (Koha Plugin Zip) package of a released version on the Manage Plugins page of the Koha staff interface.

To set up the Koha plugin system you must first make some changes to your install:

1. Change `<enable_plugins>0<enable_plugins>` to ` <enable_plugins>1</enable_plugins>` in your koha-conf.xml file.
2. Confirm that the path to `<pluginsdir>` exists, is correct, and is writable by the web server.
3. Restart your webserver.

Once the setup is complete you will need to enable plugins by setting UseKohaPlugins system preference to 'Enable'.

You can upload and configure the plugin on the Administration -> Plugins -> Manage Plugins page.

### Required User Permissions

To use all the functionality the plugin provides, the following permissions are needed for the user account used to authenticate for the API:

 - catalogue
 - editcatalogue
   - edit_catalogue

## Building a Release

Travis will build the release provided the commit includes a suitable version tag:

1. `git tag -a vX.Y.Z -m "Release X.Y.Z"` (Feel free to provide a longer message too, it's displayed on the Releases page)
2. `git push --tags origin master`

To manually build a release locally, run `./build.sh`.


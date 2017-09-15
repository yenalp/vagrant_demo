#!/usr/bin/env bash
deploy_release.help.init() {
    deploy_release.help.print() {
        cat << EOF
This command deploys a release of the app to a the server.

This script is mainly intended for pushing releases to UAT and QAT servers.
Each release version is given a unique URL, database and nginx configuration.
This allows multiple UAT and QAT releases to live side by side on a single server.

{{#textprint.b}}{{#textprint.u}}{{#textprint.info}}Description{{/textprint.info}}{{/textprint.u}}{{/textprint.b}}

This script performs the following actions:
{{#textprint.list}}
    {{#textprint.listItem}}Checks out the specified branch from the deployment repo{{/textprint.listItem}}
    {{#textprint.listItem}}Performs a composer install for the API{{/textprint.listItem}}
    {{#textprint.listItem}}Creates a database with the name of the release{{/textprint.listItem}}
    {{#textprint.listItem}}Creates a .env file and updates:{{#textprint.list}}
        {{#textprint.listItem}}DB_DATABASE{{/textprint.listItem}}
        {{#textprint.listItem}}DB_USERNAME{{/textprint.listItem}}
        {{#textprint.listItem}}DB_PASSWORD{{/textprint.listItem}}
        {{#textprint.listItem}}VERSION_API{{/textprint.listItem}}
        {{#textprint.listItem}}APP_KEY{{/textprint.listItem}}{{/textprint.list}}
    {{/textprint.listItem}}
    {{#textprint.listItem}}Runs db migrations{{/textprint.listItem}}
    {{#textprint.listItem}}Runs db seeds if it is the first deployment of this release{{/textprint.listItem}}
    {{#textprint.listItem}}Creates an nginx site for the API with a subdomain of the release{{/textprint.listItem}}
    {{#textprint.listItem}}Creates an nginx site for the UI with a subdomain of the release{{/textprint.listItem}}
    {{#textprint.listItem}}Unlinks the previous deployed version of the same release{{/textprint.listItem}}
    {{#textprint.listItem}}Links the new deployed version to current{{/textprint.listItem}}
{{/textprint.list}}

{{#textprint.b}}{{#textprint.u}}{{#textprint.info}}Setup{{/textprint.info}}{{#/textprint.u}}{{/textprint.b}}

{{#textprint.warning}}{{#textprint.b}}The script assumes the following:{{/textprint.b}}{{/textprint.warning}}
{{#textprint.list}}
    {{#textprint.listItem}}That the deploy repo has been populated manually or by using this project's 'build_release' command{{/textprint.listItem}}
    {{#textprint.listItem}}The script assumes that the deploy repo contains a 'ui' and 'api' directory in the root{{/textprint.listItem}}
    {{#textprint.listItem}}The 'ui' directory should contain an already built(webpacked) copy of the frontend{{/textprint.listItem}}
    {{#textprint.listItem}}The 'api' directory should contain a Lumen(or Laravel) app{{/textprint.listItem}}
    {{#textprint.listItem}}If the branch is specified it should exist in the deploy repo{{/textprint.listItem}}
    {{#textprint.listItem}}If the release is specified(without a branch) the deploy repo will contain a branch named release/<release>{{/textprint.listItem}}
    {{#textprint.listItem}}The server should already be provisioned using the API 'setup_app --env qat' command{{/textprint.listItem}}
    {{#textprint.listItem}}It will run locally on the server the release is to be deployed on{{/textprint.listItem}}
    {{#textprint.listItem}}Your DNS uses a wildcard for the first subdomain segment which points to your server{{/textprint.listItem}}
        {{#textprint.listItem}}eg. in cloudflare an entry like '*.harp2-api-qat'{{/textprint.listItem}}
{{/textprint.list}}

{{#textprint.b}}{{#textprint.u}}{{#textprint.info}}Examples{{/textprint.info}}{{#/textprint.u}}{{/textprint.b}}

    {{#textprint.info}}Example 1: deploy release version 0.0.2-rc1{{/textprint.info}}
        {{#textprint.d}}deploy_release -b release/0.0.2-rc1 -v{{/textprint.d}}

    {{#textprint.info}}Example 2: pushes changes to this script to the server{{/textprint.info}}
        The easiest way to deploy this script(or updates) is the following:

        Build a dist version of this script into a single file
        {{#textprint.d}}build_dist -n deploy_release{{/textprint.d}}
        Copy the new build to your server
        {{#textprint.d}}scp  -i <path to your key file>.pem <path to your bf2 env>/commands/deploy_release/dist/deploy_release <server username>@<server address>:/home/<server username>{{/textprint.d}}

        You can now ssh in to the server and execute 'deploy_release' file in the home directory.
EOF
    }
}

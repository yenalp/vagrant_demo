#!/usr/bin/env bash
build_release.help.init() {
    build_release.help.print() {
        cat << EOF
This command builds a release and pushes it to the deployment repo.

This script is mainly intended for building releases to UAT and QAT servers.
Given a branch name in the UI(web) repo and a branch name in the API repo,
it will build a dpeloyable version of the app and check it in to the deployment
repo with the specified branch name.

All static assets, including packaged JS files, images fonts etc. will be checked in to
the deploy repo for the front end.  {{#textprint.u}}Only built assets{{/textprint.u}} for the frontend
will be checked in to the deploy repo and no riginal source code will be included.

All vendor files for the API will not be committed and a composer install will be run
on the target server to ensure all C bindings are compiled for the target server
architecture correctly.

This script performs the following actions:
{{#textprint.list}}
    {{#textprint.listItem}}Checks out the deploy repo{{/textprint.listItem}}
    {{#textprint.listItem}}Checks out the UI repo{{/textprint.listItem}}
    {{#textprint.listItem}}NPM installs the UI dependencies{{/textprint.listItem}}
    {{#textprint.listItem}}Webpacks the frontend{{/textprint.listItem}}
    {{#textprint.listItem}}Checkouts out the API repo{{/textprint.listItem}}
    {{#textprint.listItem}}Copies the built frontent assets to the deploy repo{{/textprint.listItem}}
    {{#textprint.listItem}}Copies the API project to the deploy repo{{/textprint.listItem}}
    {{#textprint.listItem}}Generates changelogs for the api and ui repos{{/textprint.listItem}}
    {{#textprint.listItem}}Creates the release branch in the deploy repo{{/textprint.listItem}}
    {{#textprint.listItem}}Pushes to the release branch of the repo{{/textprint.listItem}}
{{/textprint.list}}

{{#textprint.b}}{{#textprint.info}}Example:{{/textprint.info}}{{/textprint.b}}
 Building the front-end from 'updates/npm-upgrades' branch,
 the api from the 'releases/0.0.3' branch and pushing to the
 deploy repo branch 'release/0.0.3'

    {{#textprint.d}}build_release -f -u updates/npm-upgrades -a release/0.0.3 -b release/0.0.3{{/textprint.d}}

EOF
    }
}

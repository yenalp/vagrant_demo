#!/usr/bin/env bash
# This line is required and is used to locate and load the project bootstrap which
# is needed for setting up functionality which is common to all commands.
source $(bash_bootstrap $(dirname $(readlink -f ${BASH_SOURCE}) ) ) || exit 1

import.require 'script'
import.require 'provision.webpack'
import.require 'provision.nodejs'
import.require 'provision.jq'
vendor.wrap 'mo/mo' 'vendor.include.mo'

import.extension 'build_release.changelogs'
import.extension 'build_release.functions'
import.extension 'build_release.help'

build_release.init() {

    # Turn off output capture for this command to stop a big pause
    # in output while running webpack.
    export BF2_CAP=0

    build_release.__init() {
        import.useModule 'script'
        import.useModule 'provision.webpack'
        import.useModule 'provision.nodejs'
        import.useModule 'provision.jq'
        vendor.include.mo

        import.useExtension 'build_release.changelogs'
        import.useExtension 'build_release.functions'
        import.useExtension 'build_release.help'

        build_release.args
        logger.forceVerbose
    }
    build_release.args() {
        args.add --key 'build_release_force' \
            --name 'Force' \
            --alias '-f' \
            --alias '--force' \
            --desc 'Forces build even when not running on SemaphoreCI.' \
            --required '0' \
            --has-value 'n' \
            --type 'switch'

        args.add --key 'build_release_dry' \
            --name 'Dry Run' \
            --alias '-d' \
            --alias '--dry-run' \
            --desc 'If set the release will not be committed and pushed to the deploy repo.' \
            --required '0' \
            --has-value 'n' \
            --type 'switch'

        args.add --key 'build_release_branch' \
            --name 'Release Branch' \
            --alias '-b' \
            --alias '--branch' \
            --desc 'If set this branch will be used to build the release.' \
            --required '0' \
            --has-value 'y' \
            --default "$BRANCH_NAME"

        args.add --key 'build_release_ui_branch' \
            --name 'UI Branch' \
            --alias '-u' \
            --alias '--ui-branch' \
            --desc 'This is the branch in the UI repo that will be used to build this release.' \
            --required '1' \
            --has-value 'y'

        args.add --key 'build_release_api_branch' \
            --name 'API Branch' \
            --alias '-a' \
            --alias '--api-branch' \
            --desc 'This is the branch in the API repo that will be used to build this release.' \
            --required '1' \
            --has-value 'y'
    }
    build_release.main() {

        local __branch_name

        local __build_path="/home/${USER}/builds"

        # local __ui_repo_path="/home/${USER}/app"
        # local __api_repo_path="/home/${USER}/api"
        local __ui_repo_path="${__build_path}/app"
        local __api_repo_path="${__build_path}/api"
        local __deploy_repo_path="/home/${USER}/hicmr-harp2-deploy"
        local __release_path="/home/${USER}/release/"

        local __api_repo_url='bitbucket.org/hicmr/hicmr-harp2-api.git'
        local __ui_repo_url='bitbucket.org/hicmr/hicmr-harp2-web.git'
        local __ui_repo_branch=''
        local __api_repo_branch=''
        local __release_num=''

        __api_repo_url='bitbucket.org:hicmr/hicmr-harp2-api.git'
        __ui_repo_url='bitbucket.org:hicmr/hicmr-harp2-web.git'

        local __deploy_repo='bitbucket.org/hicmr/hicmr-harp2-deploy.git'
        local __deploy_git_username="iopdeploy"
        local __deploy_git_email="iopdeploy@inoutput.io"
        local __deploy_git_pwd="d3pl0y10p19"

        provision.require 'jq' || {
            script.exitWithError "Failed to install jq"
        }

        build_release.functions.handleArgs


        logger.info --message ""

        logger.info --message \
            "This will build a deployment for you app:"

        logger.info --message \
            "{{#textprint.warning}}{{#textprint.u}}=============================================================================={{/textprint.u}}{{/textprint.warning}}"

        logger.info --message \
            "{{#textprint.b}}This will build a release from:{{/textprint.b}}"

        logger.info --message \
            "API branch: \"${__api_repo_branch}\" in \"${__api_repo_url}\""
        logger.info --message \
            "UI branch: \"${__ui_repo_branch}\" in \"${__ui_repo_url}\""

        logger.info --message \
            "And push the release to:"
        logger.info --message \
            "Release branch \"${__branch_name}\" in ${__deploy_repo}"


        logger.info --message \
            "{{#textprint.warning}}{{#textprint.u}}=============================================================================={{/textprint.u}}{{/textprint.warning}}"


        build_release.functions.installRequirements

        build_release.functions.getDeployRepo

        build_release.functions.checkoutUiRepo

        build_release.functions.buildUI

        build_release.functions.checkoutApiRepo

        build_release.functions.setupBranch

        build_release.functions.copyReleaseFiles

        build_release.changelogs.generate

        build_release.functions.pushToDeployRepo

        script.exitSuccess "build_release exited successfully!"
    }
}

# If sourced, load all functions.
# If executed, perform the actions as expected.
if [[ "$0" == "$BASH_SOURCE" ]] || ! [[ -n "$BASH_SOURCE" ]]; then
    import.useModule 'bootstrap'
    bootstrap.run 'build_release' "$@"
fi

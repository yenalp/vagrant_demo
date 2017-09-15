#!/usr/bin/env bash
# This line is required and is used to locate and load the project bootstrap which
# is needed for setting up functionality which is common to all commands.
source $(bash_bootstrap $(dirname $(readlink -f ${BASH_SOURCE}) ) ) || exit 1

import.require 'script'
import.require 'provision.nginx'
import.require 'provision.postgres'
import.require 'provision.apg'

import.extension 'deploy_release.functions'
import.extension 'deploy_release.help'

deploy_release.init() {
    deploy_release.__init() {
        import.useModule 'script'
        import.useModule 'provision.nginx'
        import.useModule 'provision.postgres'
        import.useModule 'provision.apg'
        import.useExtension 'deploy_release.functions'
        import.useExtension 'deploy_release.help'

        deploy_release.args
    }
    deploy_release.args() {
        args.add --key 'deploy_release_branch' \
            --name 'Branch Name' \
            --alias '-b' \
            --alias '--branch' \
            --desc 'The branch name in the deployment repository to deploy' \
            --required-unless 'deploy_release_num' \
            --has-value 'y'

        args.add --key 'deploy_release_num' \
            --name 'Release Version Number' \
            --alias '-r' \
            --alias '--release' \
            --desc 'The semantic version number of this release' \
            --required-unless 'deploy_release_branch' \
            --has-value 'y'

        args.add --key 'deploy_release_api_ver' \
            --name 'API Version' \
            --alias '--api-version' \
            --desc 'This value will be appended to release version number in the API env file but will not be included in the subdomain' \
            --required '0' \
            --has-value 'y'
    }
    deploy_release.main() {
        local __branch_name
        local __release_num
        # The version number with . and space characters replaced with - chars
        local __release_clean
        # The path of the deployed release
        local __deploy_dir
        local __app_dir
        local __current_sym
        local __app_name
        local __app_clean
        local __release_ts

        local __deploy_repo
        local __deploy_username
        local __deploy_pwd
        local __deploy_repo_url

        local __api_path
        local __ui_path

        local __base_url
        local __rel_subdomain
        local __api_domain
        local __ui_domain

        local __db_name
        local __db_user
        local __db_pwd
        local __new_db

        local __server_env_name
        local __api_ver_num

        deploy_release.handleArgs

        logger.info --message \
            "Release version number is \"${__release_num}\""

        logger.info --message \
            "Release branch is \"${__branch_name}\""

        logger.info --message \
            "Release cleaned value is \"${__release_clean}\""

        logger.info --message \
            "Deployment directory is \"${__deploy_dir}\""

        logger.info --message \
            "API domain is \"${__api_domain}\""

        logger.info --message \
            "UI domain is \"${__ui_domain}\""

        logger.info --message \
            "API version will be \"${__api_ver_num}\""

        deploy_release.getReleaseCode

        deploy_release.composerInstall

        deploy_release.configureApiSite

        deploy_release.configureDatabase

        deploy_release.configureEnvFile

        deploy_release.runMigrations

        deploy_release.configureUiSite

        logger.success --message \
            "All deploy steps have completed succesfully, linking release to current..."

        deploy_release.linkRelease

        provision.nginx.restart || {
            script.exitWithError "Failed to restart nginx service"
        }

        script.exitSuccess "Your script has exited successfully!"
    }
}

# If sourced, load all functions.
# If executed, perform the actions as expected.
if [[ "$0" == "$BASH_SOURCE" ]] || ! [[ -n "$BASH_SOURCE" ]]; then
    import.useModule 'bootstrap'
    bootstrap.run 'deploy_release' "$@"
fi

#!/usr/bin/env bash

build_release.functions.init() {
    build_release.functions.handleArgs() {
        if [ "${__args_VALS[build_release_branch>>specified]}" == '1' ]; then
            # export __branch_name="${__args_VALS[build_release_branch]}"
            __branch_name="${__args_VALS[build_release_branch]}"

        fi
        logger.info --message \
            "Using branch \"${__branch_name}\""

        if [ "${__args_VALS[build_release_force]}" != '1' ]; then
            if [ "$SEMAPHORE" != "true" ]; then
                logger.warning --message \
                    'This script should be run on semaphore, exiting build...'
                script.exitSuccess "Could not build the app"
            fi

            echo "$__branch_name" | grep -q "^release/" || {
                logger.warning --message \
                    'This script is only designed to build branches starting with "release/", exiting build...'
                script.exitSuccess "Could not build the app"
            }
        fi

        if [ "$SEMAPHORE" == "true" ]; then
            # Change expected repo paths if running on Semaphore CI
            __ui_repo_path="${__build_path}/hicmr-harp2-web"
            __api_repo_path="${__build_path}/hicmr-harp2-api"
        fi

        __ui_repo_branch="${__args_VALS[build_release_ui_branch]}"
        __api_repo_branch="${__args_VALS[build_release_api_branch]}"

        __release_num="${__ui_repo_branch##*/}"
    }

    build_release.functions.installRequirements() {
        logger.info --message 'installing NodeJS...'
        provision.require 'nodejs' || {
            script.exitWithError "Nodejs requirement not met"
        }

        logger.info --message 'installing webpack...'
        provision.require 'webpack' || {
            script.exitWithError "Webpack requirement not met"
        }
    }

    build_release.functions.getDeployRepo() {

        # Clean up existing release directory and deploy repos if they exist
        if [ -d "${__deploy_repo_path}" ]; then
            logger.info --message \
                'Removing existing deploy repo...'
            rm -rf "${__deploy_repo_path}"
        fi

        if [ -d "${__release_path}" ]; then
            rm -rf "${__release_path}"
            logger.info --message \
                'Removing existing release dir...'
        fi

        cd "/home/${USER}/"
        # Clone the deploy repo
        git clone "https://${__deploy_git_username}:${__deploy_git_pwd}@bitbucket.org/hicmr/hicmr-harp2-deploy.git" || {
            script.exitWithError \
                "Failed to clone the deploy repository"
        }

        # Create a temporary release directory
        mkdir "${__release_path}"
        cd "${__release_path}"
        # Copy deploy repo to release preventing merge conflicts
        cp -r "${__deploy_repo_path}/.git" "${__release_path}/"
    }

    build_release.functions.setupBranch() {
        cd "${__release_path}"
        # Create and or checkout release branch
        local __is_branch
        # Checks to see id the branch exists in the deploy repo
        __is_branch=$(git for-each-ref refs --format "%(refname:short)" \
            | sed "s|^origin/||" \
            | grep -w "^$__branch_name\$" \
            | wc -l)

        if [ "$__is_branch" == '1' ]; then
            logger.info --message \
                "Branch \"$__branch_name\" already exists in the deploy repo"
            git checkout "$__branch_name" > /dev/null || {
                script.exitWithError \
                    "Failed to checkout deploy repo branch \"${__branch_name}\""
            }
        else
            logger.info --message \
                "Branch \"$__branch_name\" does not exist in the deploy repo, creating..."
            git checkout -b "$__branch_name"
        fi
    }

    build_release.functions.buildUI() {
        logger.info --message \
            "Installing required npm packages for building the frontend..."
        cd "${__ui_repo_path}/sourcecode"

        npm install
        
        local __version_file="${__ui_repo_path}/sourcecode/version.json"
        if [ -f "${__version_file}" ]; then
            local __commit_str=''
            __commit_str="$(git rev-parse --short HEAD)"

            echo -e "$(eval "jq -M '.version |= \"${__release_num}\"' ${__version_file}")" > "${__version_file}"
            echo -e "$(eval "jq -M '.commit |= \"${__commit_str}\"' ${__version_file}")" > "${__version_file}"

            logger.info --message \
                "Set commit to '${__commit_str}' and version to '${__release_num}'"
        else
            logger.warning --message \
                "UI version file not found at '${__version_file}'"
        fi


        logger.info --message \
            "Running webpack to build frontend assets..."
        export NODE_ENV='production'
        webpack --bail --no-color || {
            script.exitWithError \
                "Failed to run webpack..."
        }
    }

    build_release.functions.copyReleaseFiles() {
        if [ -d "${__release_path}/api" ]; then
            rm -rf "${__release_path}/api" > /dev/null
        fi
        if [ -d "${__release_path}/ui" ]; then
            rm -rf "${__release_path}/ui" > /dev/null
        fi
        # Copy application distribution files
        cp -r "${__api_repo_path}/sourcecode" "${__release_path}/api" || {
            script.exitWithError \
                "Failed to copy API to release directory"
        }
        cp -r "${__ui_repo_path}/sourcecode/dist_build" "${__release_path}/ui" || {
            script.exitWithError \
                "Failed to copy API to release directory"
        }
        # Remove .gitignore from dist_build
        if [ -f "${__release_path}ui/.gitignore" ]; then
            rm "${__release_path}ui/.gitignore"
        fi

        # Remove the tests directory
        if [ -d "${__release_path}api/tests" ]; then
            rm -rf "${__release_path}api/tests"
        fi

    }

    build_release.functions.pushToDeployRepo() {
        cd "${__release_path}"
        git config user.email "${__deploy_git_email}"
        git config user.name "${__deploy_git_username}"
        if [  "${__args_VALS[build_release_dry]}" != '1' ]; then
            # Add, commit and push the changes to the deploy repo
            git add -A
            git commit -m "release: pushed release ${__branch_name} to deploy"
            git push \
                "https://${__deploy_git_username}:${__deploy_git_pwd}@bitbucket.org/hicmr/hicmr-harp2-deploy.git" \
                "$__branch_name" \
                --quiet
        else
            logger.info --message \
                'Skipping push to deploy repo because dry run flag was specified...'
        fi
    }

    build_release.functions.checkoutApiRepo() {
        logger.info --message \
            "Checking out the API repo"

        if [ -d "${__api_repo_path}" ]; then
            logger.info --message \
                "Removing the existing API deployment repo from \"${__api_repo_path}\""
            rm -rf "${__api_repo_path}"
        fi

        mkdir -p "${__api_repo_path}"

        git clone \
            "${__api_repo_url}" \
            "${__api_repo_path}" || {
                script.exitWithError "Failed to clone API repo"
            }

        cd "${__api_repo_path}"


        # Create and or checkout release branch
        local __is_branch
        # Checks to see id the branch exists in the deploy repo
        __is_branch=$(git for-each-ref refs --format "%(refname:short)" \
            | sed "s|^origin/||" \
            | grep -w "^$__api_repo_branch\$" \
            | wc -l)


        if [ "$__is_branch" == '1' ]; then
            logger.info --message \
                "Branch \"${__api_repo_branch}\" already exists in the API repo"
            git checkout "$__api_repo_branch" > /dev/null || {
                script.exitWithError \
                    "Failed to checkout API repo branch \"${__api_repo_branch}\""
            }
        else
            script.exitWithError \
                "Branch \"$__api_repo_branch\" does not exist in the API repo"
        fi
    }

    build_release.functions.checkoutUiRepo() {
        logger.info --message \
            "Checking out the UI repo"

        if [ -d "${__ui_repo_path}" ]; then
            logger.info --message \
                "Removing the existing UI deployment repo from \"${__ui_repo_path}\""
            rm -rf "${__ui_repo_path}"
        fi

        mkdir -p "${__ui_repo_path}"

        git clone \
            "${__ui_repo_url}" \
            "${__ui_repo_path}" || {
                script.exitWithError "Failed to clone UI repo"
            }

        cd "${__ui_repo_path}"


        # Create and or checkout release branch
        local __is_branch
        # Checks to see id the branch exists in the deploy repo
        __is_branch=$(git for-each-ref refs --format "%(refname:short)" \
            | sed "s|^origin/||" \
            | grep -w "^$__ui_repo_branch\$" \
            | wc -l)


        if [ "$__is_branch" == '1' ]; then
            logger.info --message \
                "Branch \"${__ui_repo_branch}\" already exists in the UI repo"
            git checkout "$__ui_repo_branch" > /dev/null || {
                script.exitWithError \
                    "Failed to checkout UI repo branch \"${__ui_repo_branch}\""
            }
        else
            script.exitWithError \
                "Branch \"$__ui_repo_branch\" does not exist in the UI repo"
        fi
    }

}

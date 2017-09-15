#!/usr/bin/env bash

deploy_release.functions.init() {
    deploy_release.handleArgs() {
        __release_ts="$(date '+%Y-%m-%d_%H-%M-%S')"

        __app_name="HARP 2"

        __deploy_repo="bitbucket.org/hicmr/hicmr-harp2-deploy.git"
        __deploy_username="iopdeploy"
        __deploy_pwd="d3pl0y10p19"
        __deploy_repo_url="https://${__deploy_username}:${__deploy_pwd}@${__deploy_repo}"
        __server_env_name='qat'

        __base_url='inoutput.io'

        if [ "${__args_VALS['deploy_release_branch>>specified']}" == '1' ]; then
            __branch_name="${__args_VALS['deploy_release_branch']}"
        else
            __branch_name="release/${__args_VALS['deploy_release_num']}"
        fi

        if [ "${__args_VALS['deploy_release_num>>specified']}" == '1' ]; then
            __release_num="${__args_VALS['deploy_release_num']}"
        else
            __release_num="${__branch_name##*/}"
        fi

        __api_ver_num="${__release_num}"

        if [ "${__args_VALS['deploy_release_api_ver>>specified']}" == '1' ]; then
            __api_ver_num="${__release_num}${__args_VALS['deploy_release_api_ver']}"
        fi



        __release_clean="${__release_num// /-}"
        __release_clean="${__release_clean//\//-}"
        __release_clean="${__release_clean//./-}"

        __app_clean="${__app_name// /-}"
        __app_clean="${__app_clean//\//-}"
        __app_clean="${__app_clean//./-}"
        __app_clean="${__app_clean,,}"

        __rel_subdomain="${__release_clean}.${__app_clean}"
        __api_domain="${__rel_subdomain}-api-${__server_env_name}.${__base_url}"
        __ui_domain="${__rel_subdomain}-ui-${__server_env_name}.${__base_url}"

        __app_dir="/home/${USER}/deployments/${__app_clean}"
        __deploy_dir="${__app_dir}/releases/${__release_clean}/${__release_ts}"
        __current_sym="${__app_dir}/releases/${__release_clean}/current"

        __api_path="${__deploy_dir}/api"
        __ui_path="${__deploy_dir}/ui"

        __db_name="${__rel_subdomain}"
        __db_user="${USER}"
        __db_pwd="secret"
        __new_db=false
    }

    deploy_release.getReleaseCode() {
        mkdir -p "${__deploy_dir}"
        git clone "${__deploy_repo_url}" "${__deploy_dir}" || {
            script.exitWithError "Failed to clone from the deploy repo"
        }

        cd "${__deploy_dir}"
        local __is_branch
        # Checks to see id the branch exists in the deploy repo
        __is_branch=$(git for-each-ref refs --format "%(refname:short)" \
            | sed "s|^origin/||" \
            | grep -w "^$__branch_name\$" \
            | wc -l)

        if [ "$__is_branch" != '1' ]; then
            script.exitWithError \
                "Branch \"$__branch_name\" does not exist in the deploy repo"
        fi

        cd "${__deploy_dir}"
        git checkout "${__branch_name}" > /dev/null || {
            script.exitWithError \
                "Failed to checkout deploy repo branch \"${__branch_name}\""
        }
    }

    deploy_release.composerInstall() {
        logger.info --message \
            "Running composer install..."
        # Fails if tests dir is missing so just create an empty one
        mkdir -p "${__api_path}/tests"
        cd "${__api_path}"
        composer install --no-interaction --optimize-autoloader || {
            script.exitWithError \
                "Composer install failed"
        }
    }

    deploy_release.linkRelease() {
        logger.info --message \
            "Linking to current release..."
        if [ -L "${__current_sym}" ]; then
            rm "${__current_sym}"
        fi

        ln -s "${__deploy_dir}" "${__current_sym}"

        if [ ! -L "${__current_sym}" ]; then
            script.exitWithError \
                "Faild to link \"${__deploy_dir}\" to \"${__current_sym}\""
        fi

        logger.info --message \
            'Set the permissions issue on the storage directory after QAT release deployment'

        sudo chmod -R a+rw "${__api_path}/storage"
    }

    deploy_release.configureApiSite() {
        logger.info --message \
            "Configuring API site in nginx..."

        provision.nginx.createLaravelSite \
            --port '80' \
            --ssl-port '443' \
            --path "${__current_sym}/api/public" \
            --site-name "${__api_domain}" \
        || {
                script.exitWithError "Failed to create nginx site config"
        }
    }

    deploy_release.configureUiSite() {
        logger.info --message \
            "Configuring UI site in nginx..."

        provision.nginx.createNonDefaultSiteConfig \
            --port '80' \
            --path "${__current_sym}/ui" \
            --site-name "${__ui_domain}" \
        || {
                script.exitWithError "Failed to create nginx site config"
        }
    }

    deploy_release.configureDatabase() {

        provision.postgres.dbExists \
            --db-name "${__db_name}" \
            --owner "${__db_user}" || {
                __new_db=true
            }

        provision.postgres.addUser \
            --username "${__db_user}" \
            --pwd "${__db_pwd}" \
            || {
                script.exitWithError "Failed to create postgres user"
            }

        provision.postgres.requireDb \
            --db-name "${__db_name}" \
            --owner "${__db_user}"
    }

    deploy_release.configureEnvFile() {

        logger.info --message \
            "Adding db info to .env file"

        local __env_file
        __env_file="${__api_path}/.env"

        if [ ! -f "${__env_file}" ]; then
            cp "${__env_file}.example" "${__env_file}"
        fi

        sed -i s/^DB_DATABASE=.*/DB_DATABASE=\"${__db_name}\"/ "${__env_file}" || {
            script.exitWithError "Failed to set DB_DATABASE key"
        }
        sed -i s/^DB_USERNAME=.*/DB_USERNAME=\"${__db_user}\"/ "${__env_file}" || {
            script.exitWithError "Failed to set DB_USERNAME key"
        }
        sed -i s/^DB_PASSWORD=.*/DB_PASSWORD=\"${__db_pwd}\"/ "${__env_file}" || {
            script.exitWithError "Failed to set DB_PASSWORD key"
        }

        logger.info --message \
            "Adding release version info to .env file"

        sed -i s/^VERSION_API=.*/VERSION_API=\"${__api_ver_num}\"/ "${__env_file}" || {
            script.exitWithError "Failed to set API_VERSION number"
        }

        # Generate app key
        # When using Lumen we can't use the normal "php artisan key:generate"
        provision.require 'apg' || {
            script.exitWithError "Failed to install apg"
        }

        # Use apg to generate a random 45 character string
        local __app_key=''
        __app_key="$(apg -n 1 -m 45 -x 45)"
        logger.info --message \
            "Adding new app key \"${__app_key}\" to .env file"

        sed -i s/^APP_KEY=.*/APP_KEY=\"base64:${__app_key}\"/ "${__env_file}" || {
            script.exitWithError "Failed to set app key"
        }

    }

    deploy_release.runMigrations() {
        cd "${__api_path}"

        if ${__new_db}; then
            logger.info --message \
                "Running seed data with migrations because this is a fresh database..."
            php artisan migrate --seed || {
                script.exitWithError "Failed to run migrations..."
            }
        else
            logger.info --message \
                "Running migrations without seed data because this is an existing database..."
            php artisan migrate || {
                script.exitWithError "Failed to run migrations..."
            }
        fi
    }
}

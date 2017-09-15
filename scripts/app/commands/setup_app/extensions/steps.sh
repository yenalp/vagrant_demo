#!/usr/bin/env bash

setup_app.steps.init() {
    setup_app.steps.setup() {

        declare -A -g __app_CONF

        declare -g __steps_ARR=( \
            'checkForUpdates' \
            'installNginx' \
            'installNodeJs' \
            'installWebpack'
            'installNpmPackages'
            'installComposer' \
            'installPhp7PPA' \
            'installPhp' \
            'stopApache' \
            'configureTesting' \
            'configureSite' \
            'disableSendFile' \
            'configureLoginMessage' \
            'composerInstall' \
            'restartSite' \
            'installSelenium' \
            'installFirefox' \
            'installPhantomJs' \
            'installCapistrano' \
            'installMailcatcher' \
            'configureMailCatcher' \
        )

        declare -A -g __steps_CONF

        __steps_CONF['checkForUpdates']=true
        __steps_CONF['installNginx']=true
        __steps_CONF['installNodeJs']=true
        __steps_CONF['installWebpack']=true
        __steps_CONF['installNpmPackages']=true
        __steps_CONF['installComposer']=false
        __steps_CONF['installPhp7PPA']=false
        __steps_CONF['installPhp']=true
        __steps_CONF['stopApache']=false
        __steps_CONF['configureTesting']=true
        __steps_CONF['configureSite']=true
        __steps_CONF['disableSendFile']=true
        __steps_CONF['configureLoginMessage']=true
        __steps_CONF['composerInstall']=true
        __steps_CONF['restartSite']=true
        __steps_CONF['installSelenium']=false
        __steps_CONF['installFirefox']=false
        __steps_CONF['installPhantomJs']=false
        __steps_CONF['installCapistrano']=false
        __steps_CONF['installMailcatcher']=false
        __steps_CONF['configureMailCatcher']=false
    }

    setup_app.steps.run() {
        local __total_steps="${#__steps_ARR[@]}"
        local __current_step=0
        for i in ${__steps_ARR[@]}; do
            let __current_step=__current_step+1
            local __run_step=true
            if [[ "${__steps_CONF[${i}]+exists}" ]]; then
                __run_step="${__steps_CONF[${i}]}"
            fi

            if $__run_step; then
                logger.step --number "$__current_step" \
                    --total "${__total_steps}" \
                    --message "Running ${i}..."
                setup_app.steps.$i
            else
                logger.step --number "$__current_step" \
                    --total "${__total_steps}" \
                    --message "Skipping ${i}..."
            fi
        done
    }


    setup_app.steps.checkForUpdates() {
        logger.info --message 'Checking for updates...'
        # update the apt-get cache before we try and install anything
        script.tryCommand --command 'os.updates.check' --retries 4 || {
			script.exitWithError "Updating apt-cache failed"
        }

    }

    setup_app.steps.installNodeJs() {
        logger.info --message 'Checking for updates...'
        # Install the nodejs requirements
        provision.require 'nodejs' || {
			script.exitWithError "Nodejs requirement not met"
        }

    }

    setup_app.steps.installWebpack() {
        logger.info --message 'installing webpack...'
        provision.require 'webpack' || {
			script.exitWithError "Webpack requirement not met"
        }
    }

    setup_app.steps.installNpmPackages() {
        logger.info --message 'Installing NPM packages...'
        cd "${__source_dir}"
        if [ -f "package.json" ]; then
            npm install --no-progress || {
    		    script.exitWithError "Npm requirement not met"
    		}
        fi
    }

    setup_app.steps.installComposer() {
        logger.info --message 'Installing composer...'
        # Install the composer requirments
        provision.require 'composer' || {
			script.exitWithError "Composer requirement not met"
        }
    }

    setup_app.steps.installPhp7PPA() {
        provision.php.installPhp7PPA || {
            script.exitWithError "Failed to install PHP7 PPA"
        }
    }

    setup_app.steps.installPhp() {
        provision.php.requireWithExtensions || {
            script.exitWithError "Failed to install PHP"
        }
        provision.php.enableFpmReload || {
            script.exitWithError "Failed to enable php-fpm reload."
        }
    }

    setup_app.steps.stopApache() {
        # This is for semaphore because we use nginx and
        # apache2 is running by default on port 80 already
        sudo service apache2 stop
    }

    setup_app.steps.installNginx() {
        provision.require 'nginx' || {
            script.exitWithError "Failed to install nginx."
        }
    }

    setup_app.steps.configureTesting() {
        logger.info --message 'Installing PhantomJs...'
    }

    setup_app.steps.configureSite() {
        provision.nginx.clearAllSites || {
            script.exitWithError "Failed to clear enabled nginx sites."
        }

        provision.nginx.createSite \
            --port '8080' \
            --path "${__source_dir}/dist_build" \
            --site-name "app" \
        || {
                script.exitWithError "Failed to create nginx site config"
        }
    }

    setup_app.steps.disableSendFile() {
        provision.nginx.disableSendFile || {
            script.exitWithError "Failed to disable sendfile"
        }
    }

    setup_app.steps.configureLoginMessage() {
        cd "${__source_dir}"

        login_message -i -p -n "${__target_env}" || {
            script.exitWithError "Failed to update motd"
        }
    }

    setup_app.steps.composerInstall() {
        if [ -f "${__app_root_path}/tests/composer.json" ]; then
            # Install Composer packages
            cd "${__app_root_path}/tests"
            composer install --prefer-dist --no-interaction --quiet || {
    			script.exitWithError "Composer install failed"
            }
        fi
    }

    setup_app.steps.restartSite() {
        provision.nginx.restart || {
            script.exitWithError "Failed to restart nginx"
        }

        provision.php.fpmReload || {
            script.exitWithError "Failed to reload fpm"
        }
    }

    setup_app.steps.installPhantomJs() {
        provision.require 'phantomjs' || {
            script.exitWithError "Failed to install phantomjs."
        }
    }

    setup_app.steps.installSelenium() {
        provision.require 'selenium' || {
            script.exitWithError "Failed to install selenium."
        }
    }

    setup_app.steps.installFirefox() {
        provision.require 'firefox' || {
            script.exitWithError "Failed to install firefox."
        }
    }

    setup_app.steps.installCapistrano() {
        cd "$__app_root_path"

        # Install ruby
        provision.require 'ruby' || {
            script.exitWithError "Ruby install failed"
        }

        # Install bundler
        provision.require 'bundler' || {
            script.exitWithError "Bundler requirement not met"
        }

        # Install ruby gems for capistrano
        bundle install || {
            script.exitWithError "Bundle install failed"
        }
    }

    setup_app.steps.installMailcatcher() {
        provision.require 'mailcatcher' || {
            script.exitWithError "Failed to install mailcatcher."
        }
    }

    setup_app.steps.configureMailCatcher() {
        provision.mailcatcher.startOnBoot || {
            script.exitWithError "Failed to setup start mailcatcher on boot."
        }

        provision.mailcatcher.makePhpUseMailCatcher || {
            script.exitWithError "Failed to make php use mailcatcher."
        }

        provision.mailcatcher.startMailCatcher || {
            script.exitWithError "Failed to start mailcatcher."
        }
    }
}

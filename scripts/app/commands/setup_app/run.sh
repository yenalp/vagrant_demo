#!/usr/bin/env bash
# This line is required and is used to locate and load the project bootstrap which
# is needed for setting up functionality which is common to all commands.
source $(bash_bootstrap $(dirname $(readlink -f ${BASH_SOURCE}) ) ) || exit 1

import.require 'script'
import.require 'config'
import.require 'pathing'
import.require 'os.updates'
import.require 'provision.php'
import.require 'provision.ruby'
import.require 'provision.nginx'
import.require 'provision.nodejs'
import.require 'provision.bundler'
import.require 'provision.webpack'
import.require 'provision.composer'
import.require 'provision.supervisor'
import.require 'provision.hiptest_publisher'
import.require 'provision.phantomjs'
import.require 'provision.selenium'
import.require 'provision.firefox'
import.require 'provision.mailcatcher'

import.extension 'setup_app.vagrant'
import.extension 'setup_app.semaphore'
import.extension 'setup_app.steps'

setup_app.init() {
    setup_app.__init() {
        import.useModule 'bootstrap'
        import.useModule 'script'
        import.useModule 'config'
        import.useModule 'pathing'
        import.useModule 'os.updates'
        import.useModule 'provision.composer'
        import.useModule 'provision.hiptest_publisher'
		import.useModule 'provision.php'
        import.useModule 'provision.ruby'
        import.useModule 'provision.bundler'
        import.useModule 'provision.nginx'
        import.useModule 'provision.nodejs'
        import.useModule 'provision.webpack'
        import.useModule 'provision.supervisor'
        import.useModule 'provision.hiptest_publisher'
        import.useModule 'provision.phantomjs'
        import.useModule 'provision.selenium'
        import.useModule 'provision.firefox'
        import.useModule 'provision.mailcatcher'

        import.useExtension 'setup_app.steps'
        import.useExtension 'setup_app.vagrant'
        import.useExtension 'setup_app.semaphore'
        # Force verbose output for the provision script
        logger.forceVerbose
        setup_app.args
    }
    setup_app.args() {
        args.add --key 'setup_env_type' \
            --name 'Environment' \
            --alias '-e' \
            --alias '--env' \
            --desc 'The type of environment to provision' \
            --required '0' \
            --has-value 'y' \
            --type 'enum' \
            --enum-value 'vagrant' \
            --enum-value 'semaphore' \
            --default 'vagrant'
    }
    setup_app.main() {
		# Find the root of the project
		local __app_root_path
		pathing.closestParentFile --filename '.project_root' \
			--return __app_root_path || {
				script.exitWithError "Could not find .project_root"
			}

        local __target_env="${__args_VALS['setup_env_type']}"

        local __source_dir="${__app_root_path}/sourcecode"

        setup_app.steps.setup

        case "${__target_env}" in
            vagrant)
                import.useExtension 'setup_app.vagrant'
                setup_app.vagrant.setup
                ;;
            semaphore)
                import.useExtension 'setup_app.semaphore'
                setup_app.semaphore.setup
                ;;

            *)
                script.exitWithError "The environment \"${__target_env}\" is not implemented."
        esac

        setup_app.steps.run
    }
}

# If sourced, load all functions.
# If executed, perform the actions as expected.
if [[ "$0" == "$BASH_SOURCE" ]] || ! [[ -n "$BASH_SOURCE" ]]; then
    import.useModule 'bootstrap'
    bootstrap.run 'setup_app' "$@"
fi

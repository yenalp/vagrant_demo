#!/usr/bin/env bash
# This line is required and is used to locate and load the project bootstrap which
# is needed for setting up functionality which is common to all commands.
source $(bash_bootstrap $(dirname $(readlink -f ${BASH_SOURCE}) ) ) || exit 1

import.require 'script'
import.require 'pathing'
import.extension 'create_test_symlinks.owner'
import.extension 'create_test_symlinks.facility'
import.extension 'create_test_symlinks.user'
import.extension 'create_test_symlinks.all'
import.extension 'create_test_symlinks.symlinks'

create_test_symlinks.init() {
    create_test_symlinks.__init() {
        import.useModule 'script'
        import.useModule 'pathing'
        import.useExtension 'create_test_symlinks.owner'
        import.useExtension 'create_test_symlinks.facility'
        import.useExtension 'create_test_symlinks.user'
        import.useExtension 'create_test_symlinks.all'
        import.useExtension 'create_test_symlinks.symlinks'
        logger.forceVerbose
        create_test_symlinks.args
    }
    create_test_symlinks.args() {
        args.add --key 'create_test_symlinks_components' \
            --name 'Name of the compent to create a symlink' \
            --alias '-c' \
            --alias '--component' \
            --desc 'An example of a required parameter' \
            --required '1' \
            --has-value 'm' \
            --type 'enum' \
            --enum-value 'tool' \
            --enum-value 'owner' \
            --enum-value 'user' \
            --enum-value 'facility' \
            --enum-value 'all' \
            --default 'all'
    }
    create_test_symlinks.main() {

        local __api_root_path
        pathing.closestParentFile --filename '.project_root' \
            --return __api_root_path \
            --from "$(pwd)" || {
                script.exitWithError "Could not find .project_root"
            }
        local __comp_name="${__args_VALS['create_test_symlinks_components']}"
        local -A __features
        local __destination_base="${__api_root_path}/sourcecode/tests"

        case "${__comp_name}" in
            owner )
                create_test_symlinks.owner.setup
                create_test_symlinks.symlinks.create "${__destination_base}" "${__comp_name}"
                ;;
            facility )
                create_test_symlinks.facility.setup
                create_test_symlinks.symlinks.create "${__destination_base}" "${__comp_name}"
                ;;
            user )
                create_test_symlinks.user.setup
                create_test_symlinks.symlinks.create "${__destination_base}" "${__comp_name}"
                ;;
            * )
                create_test_symlinks.all.setup  "${__destination_base}"
                # Do something
        esac
        script.exitSuccess "Your script has exited successfully!"
    }
}

# If sourced, load all functions.
# If executed, perform the actions as expected.
if [[ "$0" == "$BASH_SOURCE" ]] || ! [[ -n "$BASH_SOURCE" ]]; then
    import.useModule 'bootstrap'
    bootstrap.run 'create_test_symlinks' "$@"
fi

#!/usr/bin/env bash
bootstrapping.init() {
    bootstrapping.installAllCommands() {
        # if "dist" is passed dist builds will be installed preferentially
        local __build_type=${1:-dev}
        local __app_paths
        local IFS=':'
        read -r -a __app_paths <<< "${BF2_PATH}"
        local __app_path
        for __app_path in "${__app_paths[@]}"
		do
            if [ "$__app_path" != '' ]; then
                bootstrapping.installCommands "$__app_path" "${__build_type}"
            fi
        done
    }
    bootstrapping.installCommands() {

        # local __path=$(dirname $(readlink -f ${BASH_SOURCE}))
        local __path="$1"
        local __cmd_type="$2"
        local __commands_path=$(readlink -f ${__path}/commands)
        local __hooks_path=$(readlink -f ${__path}/install_hooks)

        # Install this command
        local __current_file=$(readlink -f ${BASH_SOURCE})
        rm -f "${__hooks_path}/install_commands"
        ln -s "${__current_file}" "${__hooks_path}/install_commands"

        # local __commands_path=$(readlink -f ${__path}/../commands)
        # local __hooks_path=$(readlink -f ${__path}/../install_hooks)
        echo "Looking for commands in \"${__path}\""
        if [ ! -d "${__commands_path}" ]; then
            echo "No commands dir found at \"${__commands_path}\""
            return
        fi

        local -a __cmd_paths_tmp
        local IFS=':'
        read -r -a __cmd_paths_tmp <<< "$(find "${__commands_path}" -name 'run.sh' | tr '\n' ':')"

        local __cmd_path
        for __cmd_path in "${__cmd_paths_tmp[@]}"
		do
            echo "-"
			echo "Found command at \"${__cmd_path}\""
            local __cmd_dir_path=$(dirname "${__cmd_path}")
            local __cmd_dir_name=$(basename "${__cmd_dir_path}")
            local __dist_path="${__cmd_dir_path}/dist/${__cmd_dir_name}"
            if [ "${__cmd_type}" == 'dist' ] \
                && [ -f "$__dist_path" ]
            then
                __cmd_path="${__dist_path}"
                echo "Found dist build of command at \"${__dist_path}\""
            fi
            echo "Installing command \"${__cmd_dir_name}\" to \"${__hooks_path}/${__cmd_dir_name}\""
            rm -f "${__hooks_path}/${__cmd_dir_name}"
            ln -s "${__cmd_path}" "${__hooks_path}/${__cmd_dir_name}"
		done
        bootstrapping.addToBashRc "$__hooks_path" "$(readlink -f ${__path})"
        echo "-----"
    }
    bootstrapping.addToBashRc() {
        local __rc_hooks_path="$1"
        local __rc_app_path="$2"
        if [ $(grep "export BF2_PATH" "/home/${USER}/.bashrc" | wc -l) == '0' ]; then
            echo "export BF2_PATH=\"\${BF2_PATH}:${__rc_app_path}\"" >> "/home/${USER}/.bashrc"
			echo "export PATH=\"\${PATH}:${__rc_hooks_path}\"" >> "/home/${USER}/.bashrc"
        fi
        if [ $(grep "export BF2_FW_PATH" "/home/${USER}/.bashrc" | wc -l) == '0' ]; then
            echo "export BF2_FW_PATH=\"${__rc_app_path}\"" >> "/home/${USER}/.bashrc"
        fi
    }
}

bootstrapping.init
# bootstrapping.installCommands

bootstrapping.installAllCommands "$@"

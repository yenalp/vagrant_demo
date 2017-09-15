#!/usr/bin/env bash
# Public: Initialise the import module.
#
# Loads and initilaises the functions exposed by the import module.  Unlike
# most modules this also automatically calls its own __init() function in
# order to bootstrap the functions required for importing other modules.
# Because it is used to import other modules it needs to be "sourced" to
# make it available.  After this all other modules should be included using
# this module.  NOTE: this module should have no dependencies on other modules,
# therefore convenience functions from other modules cannot be used.
#
# Examples
#
#   source 'modules/import.sh'
#   import.init
#
# Returns the exit code of the last command which would most likely always be 0
# as it is simply loading the module functions in to the global scope
import.init() {
	import.__init() {
		declare -A -g __import_LOADED
		declare -A -g __import_INITED
		declare -A -g __import_RUN
		local -a __import_tmp_paths
		declare -a -g __import_PATHS

		import.loadAppPaths
		# import.require 'vendor'
		# import.useModule 'vendor'
	}
	import.require() {
		local __im_req_mod_name="$1"
		local __require_file=${2:-module}

        if [[ ${__import_LOADED["${__im_req_mod_name}"]+exists} ]]; then
            return
        fi

		local __mod_file
		import.getModulePath __mod_file "$__im_req_mod_name" "$__require_file"

        local __timing='0'
        if [ "${__timing}" == '1' ] && [ "$(basename ${__mod_file})" == 'module.sh' ]; then

            local __reqs="$(grep 'import.require' ${__mod_file})"
            local __test=$( (bash -c 'source '"${__mod_file}"' 2>&1 && declare -f') \
                | grep -v 'import.require' \
                | grep -v 'vendor.require' \
                | sed 's/^    { $//g' \
                | sed '/^    function *.*() / s/$/{\n        local __start_ms=\$(date +%s%3N)/' \
                | sed 's/^    }/\nlocal __res=\"\$?\"\n        echo \"\$(caller 0 | awk \x27{ print \$2 }\x27) - \$(( \$(date +%s%3N) - \$__start_ms ))\"\nreturn \"\$__res\"\n    }/')

            echo -e "${__reqs}\n\n${__test}" | sed -E 's/(^    function *.*\(\) \{)/&\necho -n "calling => & from =>"\n/' > "/tmp/$(basename ${__mod_file})"
            source "/tmp/$(basename ${__mod_file})"
        else

			echo -e "${__mod_file} ......... "
            source "${__mod_file}"
        fi


		__import_LOADED["${__im_req_mod_name}"]='1'
	}
	import.getModulePath() {
		local __returnvar=$1
		local __im_req_mod_name="$2"
		local __require_file="${3:-module}"

		if [[ "$__im_req_mod_name" == *"."* ]]; then
		  __im_req_mod_name="${__im_req_mod_name/.//}"
		fi

		if [[ "$__im_req_mod_name" == *">"* ]]; then
		  local __im_req_sub=${__im_req_mod_name##*>}
		  __im_req_mod_name=${__im_req_mod_name%%>*}
		  __require_file="${__require_file}.${__im_req_sub}"
		fi

		local __path=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

		local __mod_file_path="${__path}/${__im_req_mod_name//.//}/${__require_file}.sh"

        # Check if there is an environment override for this module.
        local __env_path="${BF2_ENV}/modules/${__im_req_mod_name//.//}/${__require_file}.sh"
        if [ -f "${__env_path}" ]; then
            __mod_file_path="${__env_path}"
        fi

		if [[ "$__returnvar" ]]; then
	        eval $__returnvar="$(echo -e '$__mod_file_path')"
	    else
	        echo "$__mod_file_path"
	    fi
	}
	import.initModule() {
		local __import_modName="$1"
		local __config_type="$2"
		local __config_name="$3"

		"${__import_modName}.init"
		if import.functionExists "${__import_modName}.__init"; then
			"${__import_modName}.__init" "${__config_type}" "${__config_name}"
		fi
		__import_INITED["${__import_modName}"]='1'
	}

	import.run() {
		local __import_modName="$1"
		__import_RUN["${__import_modName}"]='1'
	}

	import.useModule() {
		local __import_modName="$1"
		local __config_type="$2"
		local __config_name="$3"

		if [[ ! ${__import_INITED["${__import_modName}"]+exists} ]]; then
			echo -e "${__import_modName} ......... "
			import.initModule "$__import_modName" "${__config_type}" "${__config_name}"
		else
			"${__import_modName}.init" "${__config_type}" "${__config_name}"
		fi
	}
	import.functionExists() {
	    declare -f -F $1 > /dev/null
	    return $?
	}
	import.loadAppPaths() {
		local -a __import_tmp_paths
		local __ifs_tmp="$IFS"
		IFS=':' read -r -a __import_tmp_paths <<< "$BF2_PATH"
		IFS="$__ifs_tmp"
		local __import_script_path="$(dirname $(readlink -f "${BASH_SOURCE}"))"
		__import_script_path="$(readlink -f "${__import_script_path}/..")"
		local __import_path_var
		local -a __import_tmp_paths_clean
		local __import_include_current_path=1
		for __import_path_var in "${__import_tmp_paths[@]}"
		do
			if [ "$__import_path_var" != '' ]; then
				__import_tmp_paths_clean+=("$__import_path_var")
			fi
			if [ "$__import_path_var" == "$__import_script_path" ]; then
				__import_include_current_path=0
			fi
		done

		if [ $__import_include_current_path -eq 1 ]; then
			__import_tmp_paths_clean+=("$__import_script_path")
		fi

		local __import_path_count=${#__import_tmp_paths_clean[@]}
		let __import_path_count=__import_path_count-1

		for __import_path_var in "${__import_tmp_paths_clean[@]}"
		do
			__import_PATHS["${__import_path_count}"]="$__import_path_var"
			let __import_path_count=__import_path_count-1
		done
	}

	# This is here because the init module is only loaded once
	# normally modules should not do this
	import.__init
	return $?
}

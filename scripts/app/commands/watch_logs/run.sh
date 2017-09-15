#!/usr/bin/env bash
# This line is required and is used to locate and load the project bootstrap which
# is needed for setting up functionality which is common to all commands.
source $(bash_bootstrap $(dirname $(readlink -f ${BASH_SOURCE}) ) ) || exit 1

import.require 'script'

watch_logs.init() {
    # Turn off output capture for this command to stop a big pause
    # in output while running webpack.
    export BF2_CAP=0

    watch_logs.__init() {
        import.useModule 'script'
        # watch_logs.args
    }
    watch_logs.args() {
        args.add --key 'watch_logs_param1' \
            --name 'Example Parameter' \
            --alias '-p' \
            --alias '--param' \
            --desc 'An example of a required parameter' \
            --required '1' \
            --has-value 'y'
    }
    watch_logs.main() {
        sudo tail -f /var/lib/postgresql/9.5/main/pg_log/postgresql.log | watch_logs.parsePostgres
        script.exitSuccess "Your script has exited successfully!"
    }
    watch_logs.parsePostgres() {
        local __line_type
        while read __line; do
            __line_type=$(echo "$__line" | awk -F" " '{ print $7 }')
            # Strip trailing colon
            __line_type="${__line_type%%:}"
            local -A __data

            case "$__line_type" in
                statement)
                    watch_logs.output
                    local -A __data
                    watch_logs.parsePostgresStatement
                    ;;

                execute)
                    watch_logs.parsePostgresExeceute
                    ;;

                parameters)
                    watch_logs.parsePostgresParameters
                    ;;

                *)
                    watch_logs.parsePostgresUnknown
                    watch_logs.output
                    local -A __data
            esac


        done
    }
    watch_logs.parsePostgresUnknown() {
        watch_logs.parseCommon
    }
    watch_logs.parsePostgresStatement() {
        local __started
        __started=$(echo "$__line" | awk '{ print $1 " " $2 " " $3 }')
        __data['started']="${__started}"
    }
    watch_logs.parsePostgresExeceute() {
        watch_logs.parseCommon
        local __sql="${__line#*LOG:}"
        __sql="${__sql#*: }"
        __data['sql']="${__sql}"
    }
    watch_logs.parsePostgresParameters() {
        local __params="${__line#*DETAIL:}"
        __params="${__params#*parameters: }"
        __data['parameters']="${__params}"

        local __ended
        __ended=$(echo "$__line" | awk '{ print $1 " " $2 " " $3 }')
        __data['ended']="${__ended}"
    }
    watch_logs.parseCommon() {
        local __json_line=$(watch_logs.jsonEscape "${__line}")
        __data['type']="${__line_type}"
        __data['line']="${__line}"
    }
    watch_logs.jsonEscape() {
        local __res
        __res=$(echo "${1}" | jq -R .)
        echo "${__res}"
    }
    watch_logs.output() {
        local __json='{'
        local __prefix=''
        for i in "${!__data[@]}"; do
            local __json_line=$(watch_logs.jsonEscape "${__data[$i]}")
            __json="${__json}${__prefix}\"${i}\": ${__json_line}"
            __prefix=','
        done
        __json="${__json}}"

        echo "${__json}"
    }
}

# If sourced, load all functions.
# If executed, perform the actions as expected.
if [[ "$0" == "$BASH_SOURCE" ]] || ! [[ -n "$BASH_SOURCE" ]]; then
    import.useModule 'bootstrap'
    bootstrap.run 'watch_logs' "$@"
fi

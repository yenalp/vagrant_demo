#!/usr/bin/env bash

import.require 'provision.scripts>base'

provision.scripts.init() {
    provision.scripts.__init() {
        local __config_type="$1"
        local __config_name="$2"

        import.useModule "provision.scripts_base"
        if [ "${__config_name}" = "cake" ]; then
            provision.scripts_base.wkhtmltopdfInstall "$@"
            provision.scripts_base.createWebLink "$@"
        fi
    }
}

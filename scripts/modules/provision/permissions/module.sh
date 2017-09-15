#!/usr/bin/env bash

import.require 'provision.permissions>base'

provision.permissions.init() {
    provision.permissions.__init() {
        local __config_type="$1"
        local __config_name="$2"

        import.useModule "provision.permissions_base"

        if [ "${__config_name}" = "laravel" ]; then
            provision.permissions_base.updatePermisions "transformer" "laravel"
            provision.permissions_base.updatePermisions "db" "laravel"
            provision.permissions_base.updatePermisions "gateway" "laravel"
        fi

        if [ "${__config_name}" = "cake" ]; then
            provision.permissions_base.updatePermisions "smoke" "cake"
            provision.permissions_base.updatePermisions "gas" "cake"
            provision.permissions_base.updatePermisions "sales" "cake"
            provision.permissions_base.wkhtmltopdfPermissions
        fi

    }
}

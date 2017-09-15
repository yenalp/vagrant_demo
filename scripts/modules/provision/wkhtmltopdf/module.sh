#!/usr/bin/env bash

import.require 'provision.wkhtmltopdf>base'

provision.wkhtmltopdf.init() {
    provision.wkhtmltopdf.__init() {
        local __config_type="$1"
        local __config_name="$2"

        import.useModule "provision.wkhtmltopdf_base"
        if [ "${__config_name}" = "cake" ]; then
            provision.wkhtmltopdf_base.remove "$@"
            provision.wkhtmltopdf_base.require "$@"
        fi
    }
}

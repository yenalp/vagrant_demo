#!/usr/bin/env bash

import.require 'provision.apache>base'

provision.apache.init() {
    provision.apache.__init() {
        local __config_type="$1"
        local __config_name="$2"

        import.useModule "provision.apache_base"
        provision.apache_base.modSSL "$@"
        # provision.apache_base.start "$@"
        # provision.apache_base.clearAllEnabledSites "$@"
        # provision.apache_base.clearAllAvailableSites "$@"

        echo -e "====================================================="
        echo -e "${__config_name}"
        echo -e "====================================================="
        if [ "${__config_name}" = "laravel" ]; then
            provision.apache_base.configureSSL "api"
            provision.apache_base.configureSSL "transformer"
            provision.apache_base.configureSSL "db"

            provision.apache_base.createSite "gateway/public" "api" "8080:4780" "4430:5430" "laravel"
            provision.apache_base.createSite "transformer/public" "transformer" "8081:4781" "4431:5431" "laravel"
            provision.apache_base.createSite "db/public" "db" "8082:4782" "4432:5432" "laravel"
        fi

        if [ "${__config_name}" = "cake" ]; then
            provision.apache_base.configureSSL "smoke"
            provision.apache_base.configureSSL "gas"
            provision.apache_base.configureSSL "sales"
    	    provision.apache_base.configureSSL "corporate"

            provision.apache_base.createSite "smoke/app/webroot/" "smoke" "8090:4790" "4440:5440" "cake"
            provision.apache_base.createSite "gas/app/webroot/" "gas" "8091:4791" "4441:5441" "cake"
            provision.apache_base.createSite "sales/app/webroot/" "sales" "8092:4792" "4442:5442" "cake"
            provision.apache_base.createSite "corporate/app/webroot/" "corporate" "8093:4793" "4443:5443" "cake"
        fi

        provision.apache_base.restart "$@"
    }
}

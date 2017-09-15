#!/usr/bin/env bash

import.require 'provision.nginx>base'

provision.nginx.init() {
    provision.nginx.__init() {
        local __config_type="$1"
        local __config_name="$2"

        import.useModule "provision.nginx_base"
        provision.nginx_base.require "$@"
        provision.nginx_base.start "$@"
        provision.nginx_base.clearAllEnabledSites "$@"
        provision.nginx_base.clearAllAvailableSites "$@"

        provision.nginx_base.configureSSL "transformer"
        provision.nginx_base.configureSSL "smoke"
        provision.nginx_base.configureSSL "gas"
        provision.nginx_base.configureSSL "sales"
	    provision.nginx_base.configureSSL "corporate"
        provision.nginx_base.configureSSL "db"
        provision.nginx_base.configureSSL "api"

        provision.nginx_base.createSite "/home/vagrant/app/sourcecode/transformer/public" "transformer" "80:4775" "443:5429" "lumen"
        provision.nginx_base.createSite "/home/vagrant/app/sourcecode/smoke/app/webroot/" "smoke" "8080:5776" "4430:5430" "cake"
        provision.nginx_base.createSite "/home/vagrant/app/sourcecode/gas/app/webroot/" "gas" "8081:4777" "4431:5431" "cake"
        provision.nginx_base.createSite "/home/vagrant/app/sourcecode/sales/app/webroot/" "sales" "8082:4778" "4432:5432" "cake"
        provision.nginx_base.createSite "/home/vagrant/app/sourcecode/db/public" "db" "8083:4779" "4433:5433" "lumen"
        provision.nginx_base.createSite "/home/vagrant/app/sourcecode/corporate/app/webroot/" "corporate" "8084:4780" "4434:5434" "cake"
        provision.nginx_base.createSite "/home/vagrant/app/sourcecode/gateway/public" "api" "8085:4781" "4435:5435" "lumen"

        provision.nginx_base.restart "$@"
    }
}

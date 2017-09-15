#!/usr/bin/env bash

import.require 'provision.mysql>base'

provision.mysql.init() {
    provision.mysql.__init() {
        local __config_type="$1"
        local __config_name="$2"

        import.useModule "provision.mysql_base"

        if [ "${__config_type}" = "mysql" ]; then

            provision.mysql_base.require "$@"
            provision.mysql_base.start "$@"

            provision.mysql_base.createDb "demo_detectorinspector"
            provision.mysql_base.createUser "demo_detectorinspector" "vagrant" "password"

            provision.mysql_base.createDb "demo_global_clean"
            provision.mysql_base.createUser "demo_global_clean" "vagrant" "password"

            provision.mysql_base.createDb "globalVIC"
            provision.mysql_base.createUser "globalVIC" "vagrant" "password"

            provision.mysql_base.createDb "demo_detectorinspector_backup"
            provision.mysql_base.createUser "demo_detectorinspector_backup" "vagrant" "password"

            provision.mysql_base.createDb "demo_global_backup"
            provision.mysql_base.createUser "demo_global_backup" "vagrant" "password"

            provision.mysql_base.createDb "detectorinspectorSA"
            provision.mysql_base.createUser "detectorinspectorSA" "vagrant" "password"

            provision.mysql_base.createDb "demo_detectorinspector_clean"
            provision.mysql_base.createUser "demo_detectorinspector_clean" "vagrant" "password"

            provision.mysql_base.createDb "globalTAS"
            provision.mysql_base.createUser "globalTAS" "vagrant" "password"

            provision.mysql_base.createDb "demo_global"
            provision.mysql_base.createUser "demo_global" "vagrant" "password"

            provision.mysql_base.createDb "demo_gas"
            provision.mysql_base.createUser "demo_gas" "vagrant" "password"

            provision.mysql_base.createDb "gasVIC"
            provision.mysql_base.createUser "gasVIC" "vagrant" "password"

            provision.mysql_base.createDb "demo_gas_backup"
            provision.mysql_base.createUser "demo_gas_backup" "vagrant" "password"

            provision.mysql_base.createDb "demo_users_backup"
            provision.mysql_base.createUser "demo_users_backup" "vagrant" "password"

            provision.mysql_base.createDb "detectorinspectorNSW"
            provision.mysql_base.createUser "detectorinspectorNSW" "vagrant" "password"

            provision.mysql_base.createDb "detectorinspectorNT"
            provision.mysql_base.createUser "detectorinspectorNT" "vagrant" "password"

            provision.mysql_base.createDb "demo_users"
            provision.mysql_base.createUser "demo_users" "vagrant" "password"

            provision.mysql_base.createDb "users"
            provision.mysql_base.createUser "users" "vagrant" "password"

            provision.mysql_base.createDb "detectorinspectorTAS"
            provision.mysql_base.createUser "detectorinspectorTAS" "vagrant" "password"

            provision.mysql_base.createDb "salesNT"
            provision.mysql_base.createUser "salesNT" "vagrant" "password"

            provision.mysql_base.createDb "globalSA"
            provision.mysql_base.createUser "globalSA" "vagrant" "password"

            provision.mysql_base.createDb "detectorinspectorVIC"
            provision.mysql_base.createUser "detectorinspectorVIC" "vagrant" "password"

            provision.mysql_base.createDb "globalVIC"
            provision.mysql_base.createUser "globalVIC" "vagrant" "password"

            provision.mysql_base.createDb "demo_users_clean"
            provision.mysql_base.createUser "demo_users_clean" "vagrant" "password"

            provision.mysql_base.createDb "salesVIC"
            provision.mysql_base.createUser "salesVIC" "vagrant" "password"

            provision.mysql_base.createDb "globalNSW"
            provision.mysql_base.createUser "globalNSW" "vagrant" "password"

            provision.mysql_base.createDb "globalNT"
            provision.mysql_base.createUser "globalNT" "vagrant" "password"

            provision.mysql_base.createDb "salesSA"
            provision.mysql_base.createUser "salesSA" "vagrant" "password"

            provision.mysql_base.createDb "salesSA"
            provision.mysql_base.createUser "salesSA" "vagrant" "password"

            provision.mysql_base.createDb "salesNSW"
            provision.mysql_base.createUser "salesNSW" "vagrant" "password"

            provision.mysql_base.createDb "salesTAS"
            provision.mysql_base.createUser "salesTAS" "vagrant" "password"

            provision.mysql_base.createDb "di_gateway"
            provision.mysql_base.createUser "di_gateway" "vagrant" "password"

            provision.mysql_base.createDb "di_gateway_test"
            provision.mysql_base.createUser "di_gateway_test" "vagrant" "password"

            provision.mysql_base.updateMyCnf
            provision.mysql_base.restart
        else
            provision.mysql_base.requireClient "$@"
        fi
    }
}

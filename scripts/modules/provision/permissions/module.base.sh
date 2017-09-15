#!/usr/bin/env bash

import.require 'provision>base'

provision.permissions_base.init() {
    provision.permissions_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m PERMISSIONS ... "
        import.useModule 'provision_base'
    }

    provision.permissions_base.updatePermisions() {
        local __conf_path='/var/www/html/app/sourcecode'
        local __site_name="${1}"
        local __site_type="${2}"

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Updating permisions for ${__site_type} ... "

        if [ "${__site_type}" = "laravel" ]; then
            provision.permissions_base.lumenPermissions "${__conf_path}/${__site_name}" || {
                echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Updating Lumen permisions FAILED ... "
                return 1
            }
        fi

        if [ "${__site_type}" = "cake" ]; then
            provision.permissions_base.cakePermissions "${__conf_path}/${__site_name}" || {
                echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Updating Cake permisions FAILED ... "
                return 1
            }
        fi
        return 0

    }

    provision.permissions_base.lumenPermissions() {
        local __site_path="${1}"

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Updating permisions ${__site_path}/storage ... "
        sudo chmod -R 777 "${__site_path}/storage" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Updating permisions ${__site_path}/storage FAILED ... "
            return 1
        }
    }

    provision.permissions_base.cakePermissions() {
        local __site_path="${1}"

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Updating permisions ${__site_path}/app/tmp ... "
        sudo chmod -R 777 "${__site_path}/app/tmp" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Updating permisions ${__site_path}/app/tmp FAILED ... "
            return 1
        }

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Updating permisions ${__site_path}/app/webroot/files ... "
        sudo chmod -R 777 "${__site_path}/app/webroot/files" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Updating permisions ${__site_path}/app/webroot/files FAILED ... "
            return 1
        }
    }

    provision.permissions_base.wkhtmltopdfPermissions() {
        local __wkhtmltopdf="/usr/local/bin/wkhtmltopdf"

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Updating permissions for ${__wkhtmltopdf} to 700"
        sudo chmod 755 "${__wkhtmltopdf}" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Updating permissions for ${__wkhtmltopdf} to 700 FAILED ... "
            return 1
        }
    }
}

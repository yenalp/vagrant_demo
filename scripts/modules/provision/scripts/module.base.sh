#!/usr/bin/env bash

import.require 'provision>base'

provision.scripts_base.init() {
    provision.scripts_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m SCRIPTS ... "
        import.useModule 'provision_base'
    }

    provision.scripts_base.wkhtmltopdfScript() {
        local __xvfb_run="/usr/bin/xvfb-run"
        local __wkhtmltopdf="/usr/local/bin/wkhtmltopdf-amd64"
        local __block="#!/usr/bin/env bash

# Public: to run wkhtmltopdf.
#
# Will run wkhtmltopdf when headless environment is not present
#

${__xvfb_run} ${__wkhtmltopdf} \"\$@\"
        "
        echo "${__block}"
    }

    provision.scripts_base.wkhtmltopdfInstall() {
        local __wkhtmltopdf="/usr/local/bin/wkhtmltopdf"

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Creating wkhtmltopdf script at  \"${__wkhtmltopdf}\" ... "
        provision.scripts_base.wkhtmltopdfScript | sudo tee "${__wkhtmltopdf}" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Failed to create wkhtmltopdf file at \"${__wkhtmltopdf}\" ... "
            return 1
        }
    }


    provision.scripts_base.createWebLink() {
        local __web_root_global="/var/www/html/app/sourcecode"

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Creating link to web root ... "
        sudo rm "/home/${USER}/app"
        sudo ln -s "${__web_root_global}"  "/home/${USER}/app"|| {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Failed creating link to web root ... "
            return 1
        }
    }
}

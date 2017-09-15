#!/usr/bin/env bash

import.require 'provision>base'

provision.wkhtmltopdf_base.init() {
    provision.wkhtmltopdf_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m WKHTMTOPDF ... "
        import.useModule 'provision_base'
    }
    provision.wkhtmltopdf_base.require() {
        if [ ! -f "/usr/local/bin/wkhtmltopdf-amd64" ]; then

            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing wkhtmltopdf ... "
            sudo wget -nv -O /usr/local/bin/wkhtmltopdf-0.11.0_rc1-static-amd64.tar.bz2 https://s3-ap-southeast-2.amazonaws.com/miscellaneous-detector/wkhtmltopdf-0.11.0_rc1-static-amd64.tar.bz2 2>&1
            cd /usr/local/bin
            sudo tar -xvf wkhtmltopdf-0.11.0_rc1-static-amd64.tar.bz2
            sudo rm -f wkhtmltopdf-0.11.0_rc1-static-amd64.tar.bz2 || {
              return 1
            }
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package wkhtmltopdf installed ... "
        fi
        return 0
    }

    provision.wkhtmltopdf_base.remove() {
        sudo rm -f wkhtmltopdf
        sudo rm -f wkhtmltopdf-0.11.0_rc1-static-amd64  || {
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Removing wkhtmltopdf ... "
            return 1
        }

        return 0
    }
}

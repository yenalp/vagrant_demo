#!/usr/bin/env bash

import.require 'provision>base'

provision.libfontconfig_base.init() {
    provision.libfontconfig_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m FREETYPE and FONTCONFIG  ... "
        import.useModule 'provision_base'
    }
    provision.libfontconfig_base.fontconfig() {
        if [ $(rpm -qa|grep -c fontconfig) -gt 0 ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package fontconfig installed ... "
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing fontconfig ... "
            sudo yum install -y fontconfig || {
              return 1
            }
        fi
        return 0
    }

    provision.libfontconfig_base.freetype() {
        if [ $(rpm -qa|grep -c freetype) -gt 0 ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package freetype installed ... "
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing freetype ... "
            sudo yum install -y freetype || {
              return 1
            }
        fi
        return 0
    }
}

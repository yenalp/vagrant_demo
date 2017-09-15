#!/usr/bin/env bash

import.require 'provision>base'

provision.xvfb_base.init() {
    provision.xvfb_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m XVFB ... "
        import.useModule 'provision_base'
    }
    provision.xvfb_base.require() {
        if [ $(rpm -qa|grep -c xorg-x11-server-Xvfb.x86_64) -gt 0 ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package xvfb installed ... "
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing xvfb ... "
            sudo yum install -y xorg-x11-server-Xvfb.x86_64 || {
              return 1
            }
        fi
        return 0
    }
}

#!/usr/bin/env bash

provision_base.init() {
    provision_base.isInstalled() {
        if [ $(which "$1" | wc -l) == '0' ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m  Command \"${1}\" is not installed"
            return 1
        fi
        return 0
    }
    provision_base.require() {
        local __item_name="$1"
        shift;
        "provision.${__item_name}.require" "$@"
    }
    provision_base.isPackageInstalled() {
        if [ $(apt-cache policy "$1" | grep 'Installed: (none)' | wc -l) != '0' ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m  Package \"${1}\" is not installed"
            return 1
        fi
        logger.info --message \
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m  Package \"${1}\" is already installed"
        return 0
    }
}

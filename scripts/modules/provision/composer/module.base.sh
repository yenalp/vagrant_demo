#!/usr/bin/env bash

import.require 'provision>base'

provision.composer_base.init() {
    provision.composer_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m COMPOSER ... "
        import.useModule 'provision_base'
    }
    provision.composer_base.require() {

        if [ ! -f "/usr/local/bin/composer" ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing composer ... "
            cd /home/${USER}/
            sudo curl -sS https://getcomposer.org/installer | php
            sudo mv composer.phar /usr/local/bin/composer || {
              return 1
            }
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package composer installed ... "
        fi
        return 0
    }
}

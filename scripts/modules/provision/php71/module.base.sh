#!/usr/bin/env bash

import.require 'provision>base'

provision.php71_base.init() {
    provision.php71_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m PHP7.1 ... "
        import.useModule 'provision_base'
    }
    provision.php71_base.require() {
        if [ $(rpm -qa|grep -c php71) -gt 0 ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package php7.1 installed ... "
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing php7.1 ... "
            sudo yum-config-manager --enable remi-php71
            sudo yum update
            sudo yum install -y php71 || {
              return 1
            }
        fi
        return 0
    }

    provision.php71_base.installPhp7PPA() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing php7 PPA ... "
        sudo apt-get install -y \
            software-properties-common \
            python-software-properties

        sudo add-apt-repository ppa:ondrej/php -y || {
        echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Installing php7 PPA FAILED ... "
            return 1
        }
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Updating apt-get ... "
        sudo apt-get update
    }

    provision.php71_base.requireWithExtensions() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing php7.1 extensions ... "
        sudo apt-get install -y \
            php71-cli \
            php71-dev \
            php-pear \
            php71-mysql \
            php71-mbstring \
            php-apcu \
            php71-json \
            php71-curl \
            php71-gd \
            php71-gmp\
            php71-imap \
            php71-mcrypt \
            php-memcached \
            php71-fpm \
	        php71-zip \
        || {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing php7.1 extensions FAILED... "
            return 1
        }
        return 0
    }

    provision.php71_base.fpmReload() {
        echo -e "\e[34m\xE2\x84\xB9  INFO : \e[97m Restarting php7 fpm ... "
        sudo systemctl restart php71-fpm || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Restarting php7 fpm FAILED ... "
            return 1
        }
        return 0
    }

    provision.php71_base.modifyPhpini() {
        echo -e "\e[34m\xE2\x84\xB9  INFO : \e[97m Updating php.ini ... "

        sudo cp /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.org
        sudo cp /etc/php/7.0/fpm/php.ini "/home/${USER}/php.ini"

        sudo sed -i "/\;cgi\.fix_pathinfo*/acgi\.fix_pathinfo=0" "/home/${USER}/php.ini"

        # sudo sed -i -e "/^extension\=php_mysqli\.dll/s/^;*//" "/home/${USER}/php.ini"/
        sudo sed -i "/\;extension=php_mysqli\.dll/aextension=php_mysqli\.dll"    "/home/${USER}/php.ini" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Updating php.ini FAILED ... "
            return 1
        }

        sudo rm /etc/php/7.0/fpm/php.ini
        sudo mv "/home/${USER}/php.ini" /etc/php/7.0/fpm/php.ini
        return 0
    }
}

#!/usr/bin/env bash

import.require 'provision>base'

provision.php56_base.init() {
    provision.php56_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m php56 ... "
        import.useModule 'provision_base'
    }
    provision.php56_base.require() {
        if [ $(rpm -qa|grep -c php56) -gt 0 ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package php5.6 installed ... "
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing php5.6 ... "
            sudo yum install -y php56 || {
                return 1
            }
        fi
        return 0
    }

    provision.php56_base.requireWithExtensions() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing php5.6 extensions ... "
            sudo yum install -y php56-mysqlnd.x86_64
            sudo yum install -y php56-devel.x86_64
            sudo yum install -y php56-mbstring.x86_64
            sudo yum install -y php56-pecl-apcu.x86_64
            sudo yum install -y php56-gd.x86_64
            sudo yum install -y php56-gmp.x86_64
            sudo yum install -y php56-imap.x86_64
            sudo yum install -y php56-mcrypt.x86_64
            sudo yum install -y php56-pecl-memcached.x86_64
            sudo yum install -y php56-fpm.x86_64
            sudo yum install -y php56-zip.x86_64
            sudo yum install -y php56-pdo.x86_64
        # || {
        # echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing php5.6 extensions FAILED... "
        #     return 1
        # }
        return 0
    }

    provision.php56_base.fpmReload() {
        echo -e "\e[34m\xE2\x84\xB9  INFO : \e[97m Restarting php56 fpm ... "
        sudo service php-fpm start || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Restarting php56 fpm FAILED ... "
            return 1
        }
        return 0
    }

    provision.php56_base.modifyPhpini() {
        echo -e "\e[34m\xE2\x84\xB9  INFO : \e[97m Updating php.ini ... "

        sudo cp /etc/php.ini /etc/php.ini.org
        sudo cp /etc/php.ini "/home/${USER}/php.ini"

        sudo sed -i "/\;cgi\.fix_pathinfo*/acgi\.fix_pathinfo=0" "/home/${USER}/php.ini"

        # sudo sed -i -e "/^extension\=php_mysqli\.dll/s/^;*//" "/home/${USER}/php.ini"/
        sudo sed -i "/\;extension=php_mysqli\.dll/aextension=php_mysqli\.dll"    "/home/${USER}/php.ini" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Updating php.ini FAILED ... "
            return 1
        }

        sudo rm /etc/php.ini
        sudo mv "/home/${USER}/php.ini" /etc/php.ini
        return 0
    }
}

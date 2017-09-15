#!/usr/bin/env bash

import.require 'provision>base'

provision.php70_base.init() {
    provision.php70_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m php70 ... "
        import.useModule 'provision_base'
    }
    provision.php70_base.require() {
        if [ $(rpm -qa|grep -c php70) -gt 0 ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package php70 installed ... "
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing php70 ... "
            sudo yum install -y php70 || {
              return 1
            }
        fi
        return 0
    }

    provision.php70_base.requireWithExtensions() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing php7.0 extensions ... "
        sudo yum install -y php70-mysqlnd.x86_64
        sudo yum install -y php70-devel.x86_64
        sudo yum install -y php70-mbstring.x86_64
        sudo yum install -y php70-pecl-apcu.x86_64
        sudo yum install -y php70-gd.x86_64
        sudo yum install -y php70-gmp.x86_64
        sudo yum install -y php70-imap.x86_64
        sudo yum install -y php70-mcrypt.x86_64
        sudo yum install -y php70-pecl-memcached.x86_64
        sudo yum install -y php70-fpm.x86_64
        sudo yum install -y php70-zip.x86_64
        sudo yum install -y php70-pdo.x86_64
        # || {
        # echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing php7.0 extensions FAILED... "
        #     return 1
        # }
        return 0
    }

    provision.php70_base.fpmReload() {
        echo -e "\e[34m\xE2\x84\xB9  INFO : \e[97m Restarting php70 fpm ... "
        sudo service php-fpm start || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Restarting php70 fpm FAILED ... "
            return 1
        }
        return 0
    }

    provision.php70_base.modifyPhpini() {
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

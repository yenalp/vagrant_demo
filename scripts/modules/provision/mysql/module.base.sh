#!/usr/bin/env bash

import.require 'provision>base'

provision.mysql_base.init() {
    provision.mysql_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m MYSQL ... "
        import.useModule 'provision_base'
    }
    provision.mysql_base.require() {

        if [ $(which "$1" | wc -l) == '0' ]; then

            sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
            sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'

            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Updating apt-get ... "
            sudo apt-get update

            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing mysql ... "
            sudo apt-get -y install mysql-server || {
              return 1
            }
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package mysql installed ... "
        fi
        return 0
    }

    provision.mysql_base.requireClient() {
        if [ $(rpm -qa|grep -c mysql) -gt 0 ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package mysql client installed ... "
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing mysql client ... "
            sudo yum install -y mysql || {
              return 1
            }
        fi
        return 0
    }

    provision.mysql_base.start() {
        echo -e "\e[34m\xE2\x84\xB9  INFO : \e[97m Starting mysql server ... "
        sudo systemctl start mysql || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Starting mysql server  FAILED ... "
            return 1
        }
        return 0
    }

    provision.mysql_base.restart() {
        echo -e "\e[34m\xE2\x84\xB9  INFO : \e[97m Restarting mysql server ... "
        sudo systemctl restart mysql || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Restarting mysql server  FAILED ... "
            return 1
        }
        return 0
    }

    provision.mysql_base.flush() {
        local __root_password="password"
        sudo export DEBIAN_FRONTEND=noninteractive

        echo -e "\e[34m\xE2\x84\xB9  INFO : \e[97m Flushing mysql privileges ... "
        sudo mysql -uroot -p${__root_password} mysql <<< "GRANT ALL ON *.* TO 'root'@'%'; FLUSH PRIVILEGES;" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Flushing mysql privileges  FAILED ... "
            return 1
        }
        return 0
    }

    provision.mysql_base.updateMyCnf() {

        local __config_cnf="
[mysqld]
bind-address = 0.0.0.0
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/
        "
        echo -e "\e[34m\xE2\x84\xB9  INFO : \e[97m Updating mysql my.cnf ... "

        sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.org
        sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf "/home/${USER}/mysqld.cnf"
        sudo sed -i -e "/^bind-address/s/^#*/#/" "/home/${USER}/mysqld.cnf"

            echo -e  "sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION" | sudo tee -a "/home/${USER}/mysqld.cnf"

        sudo sed -i "/bind-address*/abind-address = 0.0.0.0" "/home/${USER}/mysqld.cnf" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Updating mysql my.cnf FAILED ... "
            return 1
        }

        sudo rm /etc/mysql/mysql.conf.d/mysqld.cnf
        sudo mv "/home/${USER}/mysqld.cnf" /etc/mysql/mysql.conf.d/mysqld.cnf

        # echo -e "${__config_cnf}" | sudo tee -a "/home/${USER}/my.cnf" || {
        #     echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Updating mysql my.cnf FAILED ... "
        #     return 1
        # }
        #
        # sudo cp "/home/${USER}/my.cnf" /etc/mysql/my.cnf
        return 0
    }

    provision.mysql_base.createDb() {
        local __db_name="${1}"
        local __root_password="password"
        local __db_exist=`sudo mysql -uroot -p${__root_password} ${__db_name} -e ''; echo $?`

        echo -e "\e[34m\xE2\x84\xB9  INFO : \e[97m Create mysql database \"${__db_name}\" ... "
        if [ "${__db_exist}" -eq "1" ]; then

            sudo mysql -uroot -p${__root_password} -e "CREATE DATABASE ${__db_name}" || {
                echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Creating mysql database \"${__db_name}\" FAILED ... "
                return 1
            }
        else
            echo -e "\e[33m\xE2\x95\x9A\xE2\x95\x90  \xE2\x9A\xA0  WARNING: \e[97m Creating mysql database \"${__db_name}\" EXISTS ALREADY ... "
        fi
        return 0
    }

    provision.mysql_base.createUser() {
        local __db_name="${1}"
        local __db_user="${2}"
        local __db_pass="${3}"
        local __root_password="password"
        local __db_exist=`sudo mysql -uroot -p${__root_password} ${__db_name} -e ''; echo $?`


        # sudo export DEBIAN_FRONTEND=noninteractive
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Create mysql user \"${__db_user}\" for database \"${__db_name}\" ... "

        # if [ "${__db_exist}" -eq "1" ]; then
        sudo mysql -uroot -p${__root_password} -e "grant all privileges on ${__db_name}.* to '${__db_user}'@'%' identified by '${__db_pass}'"|| {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Creating mysql user \"${__db_user}\" for database \"${__db_name}\" FAILED ... "
            return 1
        }
        # else
        #     echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Creating mysql user \"${__db_user}\" for database \"${__db_name}\" EXISTS ALREADY ... "
        # fi
        return 0
    }
}

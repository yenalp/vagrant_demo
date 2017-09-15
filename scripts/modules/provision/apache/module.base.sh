#!/usr/bin/env bash

import.require 'provision>base'

provision.apache_base.init() {
    provision.apache_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m APACHE2 ... "
        import.useModule 'provision_base'
    }

    provision.apache_base.modSSL() {
        if [ $(rpm -qa|grep -c mod24_ssl) -gt 0 ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package mod_ssl installed ... "
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing mod_ssl ... "
            sudo yum install -y mod24_ssl || {
              return 1
            }
        fi
    }

    provision.apache_base.start() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Starting apache server ... "
        sudo service httpd start
        return 1
    }

    provision.apache_base.restart() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Restarting apache server ... "
        sudo service httpd stop
        sudo service httpd start
        return 1
    }

    provision.apache_base.clearAllEnabledSites() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Clearing all existing enabled sites ... "
        local __conf_en_sites='/etc/apache2/sites-enabled'

        if [ ! -d "${__conf_en_sites}" ]; then
            echo -e "\e[31m\xF0\x9F\x92\x80 ERROR: \e[97m Could not find ngnix config dir at \"${__conf_en_sites}\" ... "
        else
            sudo find "${__conf_en_sites}" -maxdepth 1 -type l -exec rm -f {} \;
        fi
        return "$?"
    }

    provision.apache_base.clearAllAvailableSites() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Clearing all existing available sites ... "
        local __conf_av_sites='/etc/apache2/sites-available'

        if [ ! -d "${__conf_av_sites}" ]; then
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Could not find ngnix config dir at \"${__conf_av_sites}\" ... "
        else
            sudo find "${__conf_av_sites}" -mindepth 1 -exec rm -f {} \;
        fi
        return "$?"
    }

    provision.apache_base.createSite() {
        local __path="/var/www/html/app/sourcecode/${1}"
        local __site_name="${2}"
        local __port="${3}"
        local __ssl_port="${4}"
        local __ngix_config="${5}"
        local __conf_av_sites='/etc/httpd/conf.d'
        local __conf_sites="/etc/httpd/conf.d/sites"
        local __conf_httpd="/etc/httpd/conf"
        local __config_file="${__conf_sites}/${__site_name}.conf"
        local __config_av_file="${__conf_av_sites}/${__site_name}.conf"
        local __config_httpd_file="${__conf_httpd}/httpd.conf"


        if [ ! -d "${__conf_av_sites}" ]; then
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Could not find httpd config dir at \"${__conf_av_sites}\" ... "
        fi

        if [ ! -d "${__conf_sites}" ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Creating sites config dir at \"${__conf_sites}\" ... "
            sudo mkdir -p ${__conf_sites} || {
                echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Fasiled creating sites config dir at \"${__conf_sites}\" ... "
            }
        fi

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Creating default http config at \"${__config_httpd_file}\" ... "
        if [ ! -f "${__config_httpd_file}.org" ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Creating backup http config at \"${__config_httpd_file}.org\" ... "
            sudo cp "${__config_httpd_file}" "${__config_httpd_file}.org"
        fi

        provision.apache_base.createHttpConf | sudo tee "${__config_httpd_file}" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Failed creating default http config at \"${__config_httpd_file}\" ... "
        }

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Creating site config at \"${__config_file}\" ... "
        provision.apache_base.createSiteConfig "${__path}" "${__site_name}" | sudo tee "${__config_file}" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Failed creating site config  at \"${__config_httpd_file}\" ... "
        }

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Creating default laravel vhost config at ${__config_av_file} ... "
        provision.apache_base.createVhostConfig "${__site_name}" "${__port}" "${__ssl_port}" "${__config_file}" | sudo tee "${__config_av_file}" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Failed creating vhost config  at \"${__config_httpd_file}\" ... "
        }

        # echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Enabling vhost config at \"${__config_av_file}\" ... "
        # sudo a2ensite "${__site_name}.conf" || {
        #     echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Failed enabling vhost config  at \"${__config_httpd_file}\" ... "
        # }

        return 0
    }

    provision.apache_base.createHttpConf() {
        local __block="
ServerName \"All\"
ServerRoot \"/etc/httpd\"
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
<IfModule dir_module>
    DirectoryIndex index.php index.html
</IfModule>
<Directory />
    AllowOverride none
    Require all denied
</Directory>
<Directory \"/var/www\">
    AllowOverride None
    # Allow open access:
    Require all granted
</Directory>
<Directory \"/var/www/html\">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<Files \".ht*\">
    Require all denied
</Files>
ErrorLog \"logs/error_log\"
LogLevel warn

<IfModule log_config_module>
    LogFormat \"%h %l %u %t \\\"%r\\\" %>s %b\" common

    <IfModule logio_module>
      LogFormat \"%h %l %u %t \\\"%r\\\" %>s %b \\\"%{Referer}i\\\" \\\"%{User-Agent}i\\\" %I %O\" combinedio
    </IfModule>
    CustomLog \"logs/access_log\" combined
</IfModule>

<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8

<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
IncludeOptional conf.d/*.conf
        "

        echo "${__block}"

    }

    provision.apache_base.createSiteConfig() {
        local __site_path="${1}"
        local __site_name="${2}"

        local __block="
ServerName ${__site_name}
ServerAdmin admin@${__site_name}
DocumentRoot ${__site_path}

<Directory "${__site_path}">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

ErrorLog /var/log/httpd/${__site_name}-error.log
CustomLog /var/log/httpd/${__site_name}-access.log combined

<FilesMatch \.php$>
    SetHandler \"proxy:fcgi://127.0.0.1:9000\"
</FilesMatch>
        "
        echo "${__block}"
    }


    provision.apache_base.createVhostConfig() {
        local -A __params
        __params['site-name']="${1}"
        __params['port']="${2}"
        __params['ssl-port']="${3}"
        __params['config-include']="${4}"

        local __site_port1=`echo "${__params['port']}" | cut -d ":" -f 1`
        local __site_ssl_port1=`echo "${__params['ssl-port']}" | cut -d ":" -f 1`
        local __site_port2=`echo "${__params['port']}" | cut -d ":" -f 2`
        local __site_ssl_port2=`echo "${__params['ssl-port']}" | cut -d ":" -f 2`
        local __site_name="${__params['site-name']}"
        local __config_include="${__params['config-include']}"

        local __block="
Listen ${__site_port1}
Listen ${__site_port2}
Listen ${__site_ssl_port1}
Listen ${__site_ssl_port2}

<VirtualHost *:${__site_port1} *:${__site_port2}>
    Include ${__config_include}
</VirtualHost>

<VirtualHost *:${__site_ssl_port1} *:${__site_ssl_port2}>
    Include ${__config_include}

    SSLEngine on
    SSLCertificateFile      /etc/certs/ssl/${__site_name}.crt
    SSLCertificateKeyFile   /etc/certs/ssl/${__site_name}.key
</VirtualHost>
        "
        echo "${__block}"
    }

    provision.apache_base.configureSSL() {

        local -A __params
        __params['site-name']="${1}"
        __params['ssl-certs-dir']='/etc/certs/ssl'

        local __key_name="${__params['site-name']}"
        # sudo mkdir -p "${__key_name}"
        local __ssl_path="${__params['ssl-certs-dir']}"
        sudo mkdir -p "${__ssl_path}"

        local __path_key="${__ssl_path}/${__key_name}.key"
        local __path_csr="${__ssl_path}/${__key_name}.csr"
        local __path_crt="${__ssl_path}/${__key_name}.crt"

        if [ ! -f "${__path_key}" ] || [ ! -f "${__path_csr}" ] || [ ! -f "${__path_crt}" ]
        then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Creating SSL certificate files for \"${__key_name}\" ... "

            sudo openssl genrsa -out "${__path_key}" 2048 2> /dev/null || {
                echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Failed to create SSL keyfile at \"${__path_key}\" ... "
                return 1
            }
            sudo openssl req -nodes -new -key "${__path_key}" \
                -out "${__path_csr}" -subj "/CN=${__key_name}/O=Vagrant/C=UK" 2> /dev/null \
            || {
                echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Failed to create SSL csr file at \"${__path_csr}\" ... "
                return 1
            }
            sudo openssl x509 -req -days 365 -in "${__path_csr}" \
                -signkey "${__path_key}" -out "${__path_crt}"  2> /dev/null \
            || {
                echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m  Failed to create SSL crt file at \"${__path_crt}\" ... "
                return 1
            }
        else
            echo -e "\e[33m\xE2\x95\x9A\xE2\x95\x90  \xE2\x9A\xA0  WARNING: \e[97m  SSL certificate files for \"${__key_name}\" already exist ... "
        fi
        return 0
    }
}

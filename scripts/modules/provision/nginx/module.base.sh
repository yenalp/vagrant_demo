#!/usr/bin/env bash

import.require 'provision>base'

provision.nginx_base.init() {
    provision.nginx_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m NGINX ... "
        import.useModule 'provision_base'
    }

    provision.nginx_base.require() {
        if [ $(which "$1" | wc -l) == '0' ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing nginx ... "
            sudo apt-get -y install nginx || {
                return 1
            }
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Package nginx installed ... "
            return 0
        fi;
    }

    provision.nginx_base.start() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Starting nginx server ... "
        sudo service nginx start

        return 1
    }

    provision.nginx_base.restart() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Restarting nginx server ... "
        sudo systemctl reload nginx

        return 1
    }

    provision.nginx_base.clearAllEnabledSites() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Clearing all existing enabled sites ... "
        local __conf_en_sites='/etc/nginx/sites-enabled'

        if [ ! -d "${__conf_en_sites}" ]; then
            echo -e "\e[31m\xF0\x9F\x92\x80 ERROR: \e[97m Could not find ngnix config dir at \"${__conf_en_sites}\" ... "
        else
            sudo find "${__conf_en_sites}" -maxdepth 1 -type l -exec rm -f {} \;
        fi
        return "$?"
    }

    provision.nginx_base.clearAllAvailableSites() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Clearing all existing available sites ... "
        local __conf_av_sites='/etc/nginx/sites-available'

        if [ ! -d "${__conf_av_sites}" ]; then
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Could not find ngnix config dir at \"${__conf_av_sites}\" ... "
        else
            sudo find "${__conf_av_sites}" -mindepth 1 -exec rm -f {} \;
        fi
        return "$?"
    }

    provision.nginx_base.createLumenSiteConfig() {
        local -A __params
        __params['port']="${3}"
        __params['ssl-port']="${4}"
        __params['path']="${1}"
        __params['site-name']="${2}"

        local __site_path="${__params['path']}"
        local __site_port1=`echo "${__params['port']}" | cut -d ":" -f 1`
        local __site_ssl_port1=`echo "${__params['ssl-port']}" | cut -d ":" -f 1`
        local __site_port2=`echo "${__params['port']}" | cut -d ":" -f 2`
        local __site_ssl_port2=`echo "${__params['ssl-port']}" | cut -d ":" -f 2`
        local __site_name="${__params['site-name']}"

        local __block="server {
            listen ${__site_port1};
            listen ${__site_ssl_port1} ssl;
            listen ${__site_port2};
            listen ${__site_ssl_port2} ssl;
            server_name ${__site_name}.local;
            root \"${__site_path}\";

            index index.php index.html index.htm index.nginx-debian.html;

            charset utf-8;

            location / {
                try_files \$uri \$uri/ /index.php?\$query_string;
            }

            location = /favicon.ico { access_log off; log_not_found off; }
            location = /robots.txt  { access_log off; log_not_found off; }

            access_log off;
            error_log  /var/log/nginx/${__site_name}-error.log error;

            sendfile off;

            client_max_body_size 100m;

            location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php7.0-fpm.sock;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;

                fastcgi_intercept_errors off;
                fastcgi_buffer_size 16k;
                fastcgi_buffers 4 16k;
                fastcgi_connect_timeout 300;
                fastcgi_send_timeout 300;
            }

            location ~ /\.ht {
                deny all;
            }


            ssl_certificate     /etc/nginx/ssl/${__site_name}.crt;
            ssl_certificate_key /etc/nginx/ssl/${__site_name}.key;
        }
        "
        echo "${__block}"
    }

    provision.nginx_base.createCakePhpSiteConfig() {
        local -A __params
        __params['port']="${3}"
        __params['ssl-port']="${4}"
        __params['path']="${1}"
        __params['site-name']="${2}"

        local __site_path="${__params['path']}"
        local __site_port1=`echo "${__params['port']}" | cut -d ":" -f 1`
        local __site_ssl_port1=`echo "${__params['ssl-port']}" | cut -d ":" -f 1`
        local __site_port2=`echo "${__params['port']}" | cut -d ":" -f 2`
        local __site_ssl_port2=`echo "${__params['ssl-port']}" | cut -d ":" -f 2`
        local __site_name="${__params['site-name']}"

        local __block="server {
            listen ${__site_port1};
            listen ${__site_ssl_port1} ssl;
            listen ${__site_port2};
            listen ${__site_ssl_port2} ssl;
            server_name ${__site_name}.local;
            root ${__site_path};

            index index.php index.html index.htm index.nginx-debian.html;

            charset utf-8;
            log_not_found off;
            access_log off;
            error_log  /var/log/nginx/${__site_name}-error.log error;

            sendfile off;

            client_max_body_size 100m;

            location / {

              index index.php index.html index.htm;

              if (-f \$request_filename) {
                break;
              }
              if (-d \$request_filename) {
                break;
              }

              rewrite ^(.+)$ /index.php?q=\$1 last;

            }

            # Static files.
            # Set expire headers, Turn off access log
            location ~* \favicon.ico$ {
              access_log off;
              expires 1d;
              add_header Cache-Control public;
            }

            location ~ ^/(img|cjs|ccss)/ {
              access_log off;
              expires 7d;
              add_header Cache-Control public;
            }

            # Deny access to .htaccess files,
            # git & svn repositories, etc
            location ~ /(\.ht|\.git|\.svn) {
              deny  all;
            }

            location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php7.0-fpm.sock;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;

                fastcgi_intercept_errors off;
                fastcgi_buffer_size 16k;
                fastcgi_buffers 4 16k;
                fastcgi_connect_timeout 300;
                fastcgi_send_timeout 300;
            }

            ssl_certificate     /etc/nginx/ssl/${__site_name}.crt;
            ssl_certificate_key /etc/nginx/ssl/${__site_name}.key;

        }
        "
        echo "${__block}"
    }

    provision.nginx_base.createSite() {
        local __path="${1}"
        local __site_name="${2}"
        local __port="${3}"
        local __ssl_port="${4}"
        local __ngix_config="${5}"

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Creating default site config ... "
        local __conf_en_sites='/etc/nginx/sites-enabled'
        local __conf_av_sites='/etc/nginx/sites-available'

        if [ ! -d "${__conf_av_sites}" ]; then
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Could not find ngnix config dir at \"${__conf_av_sites}\" ... "
        fi

        local __config_file="${__conf_av_sites}/${__site_name}"
        if [ "${__ngix_config}" = "lumen" ]; then
            provision.nginx_base.createLumenSiteConfig "${__path}" "${__site_name}" "${__port}" "${__ssl_port}" | sudo tee "${__config_file}"
        elif [ "${__ngix_config}" = "cake" ]; then
            provision.nginx_base.createCakePhpSiteConfig "${__path}" "${__site_name}" "${__port}" "${__ssl_port}" | sudo tee "${__config_file}"
        else
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Could not find ngnix config file ... "
            return 0
        fi

        local __enabled_config_file="${__conf_en_sites}/${__site_name}"
        sudo ln -s "${__config_file}" "${__enabled_config_file}"

        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Checking for web root ... "

        return 0
    }

    provision.nginx_base.configureSSL() {

        local -A __params
        __params['site-name']="${1}"
        __params['ssl-certs-dir']='/etc/nginx/ssl'


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
            sudo openssl req -new -key "${__path_key}" \
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

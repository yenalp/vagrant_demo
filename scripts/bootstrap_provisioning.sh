#!/usr/bin/env bash
# echo -e "$(dirname $(readlink -f ${BASH_SOURCE}) )/modules/import.sh"
# echo -e "${BASH_SOURCE[*]}"
# source "$(dirname $(readlink -f ${BASH_SOURCE}) )/modules/import.sh"
source "/var/www/html/app/scripts/modules/import.sh"
import.init

cd "/home/${USER}"

# This finds the project directory in the vagrant home dir regardless
# of the name of the project directory.
__app_name_dir="/var/www/html/app"
__setup_path="${__app_name_dir}/scripts"

echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Updating yum ... "
sudo yum -y update

# apache
import.require 'provision.apache'
import.useModule 'provision.apache' $1 $2

# xvfb
import.require 'provision.xvfb'
import.useModule 'provision.xvfb' $1 $2

# libfontconfig
import.require 'provision.libfontconfig'
import.useModule 'provision.libfontconfig' $1 $2

# wkhtmltopdf
import.require 'provision.wkhtmltopdf'
import.useModule 'provision.wkhtmltopdf' $1 $2

# mysql
import.require 'provision.mysql'
import.useModule 'provision.mysql' $1 $2

# composer
import.require 'provision.composer'
import.useModule 'provision.composer' $1 $2

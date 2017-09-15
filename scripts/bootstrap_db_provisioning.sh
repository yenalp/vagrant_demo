#!/usr/bin/env bash
# echo -e "$(dirname $(readlink -f ${BASH_SOURCE}) )/modules/import.sh"
# echo -e "${BASH_SOURCE[*]}"
# source "$(dirname $(readlink -f ${BASH_SOURCE}) )/modules/import.sh"
source "/home/vagrant/app/scripts/modules/import.sh"
import.init

cd "/home/${USER}"

# This finds the project directory in the vagrant home dir regardless
# of the name of the project directory.
__app_name_dir="/home/${USER}/app"
__setup_path="${__app_name_dir}/scripts"

# mysql
import.require 'provision.mysql'
import.useModule 'provision.mysql' $1 $2

# Motd
import.require 'provision.motd'
import.useModule 'provision.motd'

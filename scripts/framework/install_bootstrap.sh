#!/usr/bin/env bash
# This is required for the bash framework to run
if [ $(which bash_bootstrap | wc -l) -eq 0 ]; then
    echo "Installing bash_bootstrap..."
    CURRENT_BF2_PATH="$(dirname $(readlink -f "${BASH_SOURCE}"))"
    sudo ln -s "${CURRENT_BF2_PATH}/bash_bootstrap.sh" "/usr/local/bin/bash_bootstrap"
    if [ ! "$?" == "0" ]; then
        echo "Failed to install"
        exit 1
    fi
fi

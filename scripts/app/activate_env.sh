#!/usr/bin/env bash
source "$(dirname $(readlink -f ${BASH_SOURCE}) )/../bf2/activate_env.sh"
unset BF2_ENV
export BF2_ENV="$(dirname $(readlink -f "${BASH_SOURCE}"))"

if [ $(echo "$PATH" | grep "$(dirname $(readlink -f "${BASH_SOURCE}"))/install_hooks" | wc -l) == '0' ]; then
	export PATH="$(dirname $(readlink -f "${BASH_SOURCE}"))/install_hooks:${PATH}"
fi

if [ $(echo "$BF2_PATH" | grep $(dirname $(readlink -f "${BASH_SOURCE}")) | wc -l) == '0' ]; then
	export BF2_PATH="${BF2_PATH}:$(dirname $(readlink -f "${BASH_SOURCE}"))"
fi

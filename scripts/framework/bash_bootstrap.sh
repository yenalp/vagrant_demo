#!/usr/bin/env bash
C_DIR=$(readlink -f "$1")
C_USAGE_EXAMPLE="source \$(bash_bootstrap \$(dirname \$(readlink -f \${BASH_SOURCE}) ) ) || exit 1"
if [ ! -d "$C_DIR" ]; then
	>&2 echo "ERROR: Unable to locate the specifed directory \"$1\""
	>&2 echo "You should include the following snippet at the top of your script to use bash_bootstrap"
	>&2 echo "$C_USAGE_EXAMPLE"
	exit 1
fi
BOOTSTRAP_FILE_NAME="$2"
if [ "$BOOTSTRAP_FILE_NAME" == "" ]; then
	BOOTSTRAP_FILE_NAME="bootstrap.sh"
fi
while [[ "$C_DIR" != / ]] ; do
    # find "$C_DIR"/ -maxdepth 1 "$@"
    SEARCH_RES=$(find "$C_DIR"/ -maxdepth 1 -name "$BOOTSTRAP_FILE_NAME")
    if [ ! "$SEARCH_RES" == "" ]; then
    	echo "$SEARCH_RES" | head -n 1
    	exit 0
    fi
    C_DIR=$(readlink -f "${C_DIR}/..")
done
>&2 echo "ERROR: Could not locate bootstrap file \"$BOOTSTRAP_FILE_NAME\" in a parent of \"$1\""
>&2 echo "You should include the following snippet at the top of your script to use bash_bootstrap"
>&2 echo "$C_USAGE_EXAMPLE"
exit 1

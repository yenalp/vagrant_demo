#!/usr/bin/env bash

import.require 'provision.php71>base'

provision.php71.init() {
    provision.php71.__init() {
        import.useModule "provision.php71_base"
        # provision.php7_base.installPhp7PPA "$@"
        provision.php71_base.require "$@"
        provision.php7_base.requireWithExtensions "$@"
        # provision.php7_base.modifyPhpini "$@"
        # provision.php7_base.fpmReload "$@"
    }
}

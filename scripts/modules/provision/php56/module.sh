#!/usr/bin/env bash

import.require 'provision.php56>base'

provision.php56.init() {
    provision.php56.__init() {
        import.useModule "provision.php56_base"
        provision.php56_base.require "$@"
        provision.php56_base.requireWithExtensions "$@"
        provision.php56_base.modifyPhpini "$@"
        provision.php56_base.fpmReload "$@"
    }
}

#!/usr/bin/env bash

import.require 'provision.php70>base'

provision.php70.init() {
    provision.php70.__init() {
        import.useModule "provision.php70_base"
        provision.php70_base.require "$@"
        provision.php70_base.requireWithExtensions "$@"
        provision.php70_base.modifyPhpini "$@"
        provision.php70_base.fpmReload "$@"
    }
}

#!/usr/bin/env bash

import.require 'provision.libfontconfig>base'

provision.libfontconfig.init() {
    provision.libfontconfig.__init() {
        import.useModule "provision.libfontconfig_base"
        provision.libfontconfig_base.freetype "$@"
        provision.libfontconfig_base.fontconfig "$@"
    }
}

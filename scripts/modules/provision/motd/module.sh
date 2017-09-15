#!/usr/bin/env bash

import.require 'provision.motd>base'

provision.motd.init() {
    provision.motd.__init() {
        import.useModule "provision.motd_base"
        # provision.motd_base.require "$@"
        provision.motd_base.add "$@"
    }
}

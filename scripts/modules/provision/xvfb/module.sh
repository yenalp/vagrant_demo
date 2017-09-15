#!/usr/bin/env bash

import.require 'provision.xvfb>base'

provision.xvfb.init() {
    provision.xvfb.__init() {
        import.useModule "provision.xvfb_base"
        provision.xvfb_base.require "$@"
    }
}

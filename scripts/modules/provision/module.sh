#!/usr/bin/env bash

import.require 'provision>base'

provision.nginx.init() {
    provision.nginx.__init() {
        import.useModule "provision.nginx_base"
    }
}

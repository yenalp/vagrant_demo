#!/usr/bin/env bash

setup_app.vagrant.init() {
    setup_app.vagrant.setup() {
        __steps_CONF['installComposer']=true
        __steps_CONF['installSelenium']=true
        __steps_CONF['installFirefox']=true
        __steps_CONF['installPhantomJs']=true
        __steps_CONF['installCapistrano']=true
        __steps_CONF['installMailcatcher']=true
        __steps_CONF['configureMailCatcher']=true
    }
}

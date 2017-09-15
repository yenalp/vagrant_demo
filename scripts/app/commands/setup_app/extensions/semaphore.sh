#!/usr/bin/env bash

setup_app.semaphore.init() {
    setup_app.semaphore.setup() {
        # __steps_CONF['installComposer']=true
        # __steps_CONF['installSelenium']=true
        # __steps_CONF['installFirefox']=true
        __steps_CONF['installPhantomJs']=true
        __steps_CONF['restartSite']=false
        __steps_CONF['installPhp']=false
        __steps_CONF['composerInstall']=false
        __steps_CONF['installCapistrano']=true
    }
}

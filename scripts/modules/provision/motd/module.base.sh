#!/usr/bin/env bash

provision.motd_base.init() {
    provision.motd_base.__init() {
        echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m MOTD ... "
    }

    provision.motd_base.require() {
        if [ $(which "$1" | wc -l) == '0' ]; then
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing update-motd ... "
            sudo apt-get -y install update-motd || {
                return 1
            }
        else
            echo -e "\e[34m\xE2\x84\xB9  INFO: \e[97m Installing update-motd installed ... "
            return 0
        fi;
    }

    provision.motd_base.createMotd() {
        local __block="\e[33m
 ____       _            _               ___                           _
|  _ \  ___| |_ ___  ___| |_ ___  _ __  |_ _|_ __  ___ _ __   ___  ___| |_ ___  _ __
| | | |/ _ \ __/ _ \/ __| __/ _ \| '__|  | || '_ \/ __| '_ \ / _ \/ __| __/ _ \| '__|
| |_| |  __/ ||  __/ (__| || (_) | |     | || | | \__ \ |_) |  __/ (__| || (_) | |
|____/ \___|\__\___|\___|\__\___/|_|    |___|_| |_|___/ .__/ \___|\___|\__\___/|_|
                                                      |_|
\e[32m
\e[1mEnvironment: \e[0m \e[97mvagrant

\e[4m\e[94mProject URLS\e[0m
\e[97m
    \xE2\x97\x8F \e[94m Database Server\e[0m \e[97m
        \xE2\x9A\xAC IP: 10.0.0.10
        \xE2\x9A\xAC PORT: 3360
    \xE2\x97\x8F \e[94m Laravel Servers\e[0m \e[97m
        \xE2\x9A\xAC HTTP
            \xE2\x9A\xAC URL: http://api.local.detectorinspector.com.au:4780
            \xE2\x9A\xAC URL: http://transformer.local.detectorinspector.com.au:4781
            \xE2\x9A\xAC URL: http://db.local.detectorinspector.com.au:4782
        \xE2\x9A\xAC HTTPS
            \xE2\x9A\xAC URL: https://api.local.detectorinspector.com.au:5430
            \xE2\x9A\xAC URL: https://transformer.local.detectorinspector.com.au:5431
            \xE2\x9A\xAC URL: https://db.local.detectorinspector.com.au:5432
        \xE2\x9A\xAC IP: 10.0.0.11
    \xE2\x97\x8F \e[94m Cake Servers\e[0m \e[97m
        \xE2\x9A\xAC HTTP
            \xE2\x9A\xAC URL: http://smoke.local.detectorinspector.com.au:4790
            \xE2\x9A\xAC URL: http://gas.local.detectorinspector.com.au:4791
            \xE2\x9A\xAC URL: http://sales.local.detectorinspector.com.au:4792
            \xE2\x9A\xAC URL: http://corporate.local.detectorinspector.com.au:4793
        \xE2\x9A\xAC HTTPS
            \xE2\x9A\xAC URL: https://smoke.local.detectorinspector.com.au:5440
            \xE2\x9A\xAC URL: https://gas.local.detectorinspector.com.au:5441
            \xE2\x9A\xAC URL: https://sales.local.detectorinspector.com.au:5442
            \xE2\x9A\xAC URL: https://corporate.local.detectorinspector.com.au:5443
        \xE2\x9A\xAC IP: 10.0.0.12
        "
        echo -e "${__block}"
    }

    provision.motd_base.add() {
        echo -e "\e[34m\xE2\x84\xB9  INFO : \e[97m Adding Motd ... "

        sudo cat /dev/null > "/home/${USER}/motd"
        sudo cp /etc/motd /etc/motd.orig

        provision.motd_base.createMotd | sudo tee -a "/home/${USER}/motd" || {
            echo -e "\e[31m\xF0\x9F\x92\x80  ERROR: \e[97m Adding Motd FAILED ... "
            return 1
        }

        # sudo mv "/home/${USER}/00-header" /etc/update-motd.d/00-header
        sudo mv "/home/${USER}/motd" /etc/motd
        return 0

    }



}

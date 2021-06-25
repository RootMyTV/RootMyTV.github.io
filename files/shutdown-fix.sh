#!/bin/bash

# This script is executed at bootup to fix up shutdown hook script that will
# remove developer mode flag on certain shutdown events if start-devmode.sh
# script is missing. (which is the case on post-2021/06 firmware versions, where
# start-devmode.sh is signed)

# TODO: do we want to force-create com.lgerp directory here as well?

# Running pre-webOS 5.x (upstart)
if [[ -f /etc/init/shutdown.conf ]]; then
    if ! findmnt /etc/init/shutdown.conf >/dev/null ; then
        echo "upstart: fixing shutdown.conf..."
        cp /etc/init/shutdown.conf /tmp/.shutdown.conf
        sed -i 's;/media/cryptofs/apps/usr/palm/services/com.palmdts.devmode.service/start-devmode.sh;/var/lib/webosbrew/startup.sh;g' /tmp/.shutdown.conf
        mount --bind /tmp/.shutdown.conf /etc/init/shutdown.conf
        initctl reload-configuration
    else
        echo "upstart: fixed already"
    fi
fi

# Running webOS 5.x+ (systemd)
if [[ -f /etc/systemd/system/scripts/shutdown.sh ]]; then
    if ! findmnt /etc/systemd/system/scripts/shutdown.sh >/dev/null ; then
        echo "systemd: fixing shutdown.sh"
        cp /etc/systemd/system/scripts/shutdown.sh /tmp/.shutdown.sh
        sed -i 's;/media/cryptofs/apps/usr/palm/services/com.palmdts.devmode.service/start-devmode.sh;/var/lib/webosbrew/startup.sh;g' /tmp/.shutdown.sh
        mount --bind /tmp/.shutdown.sh /etc/systemd/system/scripts/shutdown.sh
    else
        echo "systemd: fixed already"
    fi
fi

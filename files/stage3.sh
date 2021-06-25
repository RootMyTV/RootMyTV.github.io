#!/bin/sh

# Hey! Yes, you! Do you happen to be an LG Engineer? RootMyTV/webosbrew/OpenLGTV
# teams wanted to say hello!
#
# While we understand this is beyond engineering decisions, we would greatly
# appreciate if webOS TV was made more open - not necessarily to remote
# exploitation, but to people willing to hack on their devices.

# Remove this script - in case a reboot happens, we should end up with a clean
# system...
rm $0
sync

# Start root telnet server
telnetd -l /bin/sh

# give the system time to wake up
sleep 3

mount --bind /bin/false /usr/sbin/update
pkill -9 -f /usr/sbin/update

# This will prevent shutdown.sh removing our devmode_enabled flag...
rm -rf /var/luna/preferences/devmode_enabled
mkdir -p /var/luna/preferences/devmode_enabled

# Cleanup after rootmytv v1
if [[ -f /media/cryptofs/apps/usr/palm/services/com.palmdts.devmode.service/start-devmode.sh ]] && [[ ! -f /media/cryptofs/apps/usr/palm/services/com.palmdts.devmode.service/start-devmode.sig ]] && ! grep '/var/lib/webosbrew/startup.sh' /media/cryptofs/apps/usr/palm/services/com.palmdts.devmode.service/start-devmode.sh ; then
    luna-send -a webosbrew -f -n 1 luna://com.webos.notification/createToast '{"sourceId":"webosbrew","message": "Cleaning up RootMyTV v1..."}'
    rm -rf /media/cryptofs/apps/usr/palm/services/com.palmdts.devmode.service/start-devmode.sh
fi

luna-send -a webosbrew -f -n 1 luna://com.webos.notification/createToast '{"sourceId":"webosbrew","message": "Installing homebrew channel..."}'

mkfifo /tmp/luna-install
luna-send -i 'luna://com.webos.appInstallService/dev/install' '{"id":"com.ares.defaultName","ipkUrl":"/media/internal/downloads/hbchannel.ipk","subscribe":true}' >/tmp/luna-install &
LUNA_PID=$!
echo "pid: $LUNA_PID"
egrep -i -m 1 'installed|failed' /tmp/luna-install
echo "finished"
kill -term $LUNA_PID
rm /tmp/luna-install

rm /media/internal/downloads/hbchannel.ipk

luna-send -a webosbrew -f -n 1 luna://com.webos.notification/createToast '{"sourceId":"webosbrew","message": "Installing final startup.sh..."}'
cp /media/developer/apps/usr/palm/services/org.webosbrew.hbchannel.service/startup.sh /var/lib/webosbrew/startup.sh

# Disable telnet by default now, since we already have persistence figured out
# fairly well.
touch /var/luna/preferences/webosbrew_telnet_disabled

# Block system updates since now we know LG is finally willing to patch up our
# exploits sooner or later.
touch /var/luna/preferences/webosbrew_block_updates

# This is a load-bearing tee. Don't ask.
luna-send -a webosbrew -f -n 1 luna://com.webos.notification/createToast '{"sourceId":"webosbrew","message": "Elevating homebrew channel..."}'
/media/developer/apps/usr/palm/services/org.webosbrew.hbchannel.service/elevate-service 2>&1 | tee /tmp/elevate.log

luna-send -a webosbrew -f -n 1 luna://com.webos.notification/createToast '{"sourceId":"webosbrew","message": "Finished!"}'

luna-send -a com.webos.service.secondscreen.gateway -f -n 1 luna://com.webos.notification/createAlert '{"sourceId":"webosbrew","message":"webOS Homebrew Channel installed. Would you like to reboot now?","buttons":[{"label":"Reboot now","onclick":"luna://com.webos.service.sleep/shutdown/machineReboot","params":{"reason":"remoteKey"}},{"label":"Reboot later"}]}'

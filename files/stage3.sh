#!/bin/sh

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

luna-send -a webosbrew -f -n 1 luna://com.webos.notification/createToast '{"sourceId":"webosbrew","message": "Installing homebrew channel..."}'

mkfifo /tmp/luna-install
luna-send -i 'luna://com.webos.appInstallService/dev/install' '{"id":"com.ares.defaultName","ipkUrl":"/media/internal/downloads/hbchannel.ipk","subscribe":true}' >/tmp/luna-install &
LUNA_PID=$!
echo "pid: $LUNA_PID"
egrep -i -m 1 'installed|failed' /tmp/luna-install
echo "finished"
kill -term $LUNA_PID
rm /tmp/luna-install

luna-send -a webosbrew -f -n 1 luna://com.webos.notification/createToast '{"sourceId":"webosbrew","message": "Elevating homebrew channel..."}'
/media/developer/apps/usr/palm/services/org.webosbrew.hbchannel.service/elevate-service

luna-send -a webosbrew -f -n 1 luna://com.webos.notification/createToast '{"sourceId":"webosbrew","message": "Installing final start-devmode.sh..."}'
cp /media/developer/apps/usr/palm/services/org.webosbrew.hbchannel.service/startup.sh /media/cryptofs/apps/usr/palm/services/com.palmdts.devmode.service/start-devmode.sh

luna-send -a webosbrew -f -n 1 luna://com.webos.notification/createToast '{"sourceId":"webosbrew","message": "Finished!"}'

luna-send -a com.webos.service.secondscreen.gateway -f -n 1 luna://com.webos.notification/createAlert '{"sourceId":"webosbrew","message":"webOS Homebrew Channel installed. Would you like to reboot now?","buttons":[{"label":"Reboot now","onclick":"luna://com.webos.service.sleep/shutdown/machineReboot","params":{"reason":"SwDownload"}},{"label":"Reboot later"}]}'

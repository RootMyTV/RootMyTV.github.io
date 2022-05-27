# Troubleshooting

After an initial reboot an unauthenticated telnet service (port 23) is exposed.
In case of any issues it can be used for debugging. Additionally, if an error
occurs during Homebrew Channel install, the bootstrap shell script is removed,
and the TV should return to original state after a reboot. Then, rooting may be
reattempted.

## Exploit fails on stage 1 (system browser)
- Check if LG Connect Apps is enabled (webOS 3.x devices)
- Verify if http://localhost:3000 works in webOS system browser

## Exploit fails on stage 2 (full screen app)
- If the message says "Service does not exist:
  com.webos.service.downloadmanager" - your TV is running webOS TV version older
  than 3.4, and thus the service we use a vulnerability in is not present.
  RootMyTV will not work on your TV, and there's no way of upgrading to a
  vulnerable version. You may try using some older exploits like
  [GetMeIn](https://forum.xda-developers.com/t/getmein-one-time-rooting-jailbreaking-tool-for-webos-lg-tvs.3887904/).
- If the message says "Denied method call", there's a chance LG already patched
  your TV firmware. In certain cases (when only a system app update has been
  released, not a full firmware update) you *may try*:
    * unplugging the TV from the network
    * doing a "Reset to initial settings", going through the first time wizard
    * running https://rootmy.tv immediately after reconnecting the network
- If the message says "This likely means your TV is not vulnerable to LunaDownloadMgr
  exploit." **and your TV is running webOS TV version between 3.0.0 and 3.4.0** you
  may try checking if there's a system update available. A vulnerability
  in LunaDownloadMgr we use has been introduced in webOS 3.4.0 which got
  released on some TV models.

  **NOTE:** "webOS TV Version" (core system version, formatted
  `1.2.3-123456 (some-codename)`) is a different thing to
  "Software Version" (per-model firmware version, formatted `01.23.45`).

## TV reboots but Homebrew Channel is missing
Your TV is already patched. Wait for another root exploit release.

## Homebrew Channel shows up/telnet works but everything disappears after a reboot
This may be caused by some leftover files from RootMyTV v1. You can either:
- Connect over telnet and run: `rm /media/cryptofs/apps/usr/palm/services/com.palmdts.devmode.service/start-devmode.sh`
- or just run "Reset to Initial Settings" option in webOS settings

Afterwards you will need to run https://rootmy.tv again.

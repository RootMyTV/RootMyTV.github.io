# RootMyTV

RootMyTV is a "remote" root exploit chain, and Jailbreak, for LG WebOS smart TVs.

All you need is an internet-connected smart TV, and a TV remote (or alternatively, an Arduino and an IR LED!).

# How it works

In summary, we use a chain of exploits to get persistent root code execution.
As root, we install the [WebOS Homebrew Channel](https://github.com/DavidBuchanan314/webos-homebrew-channel) app, and disable various
security/sandboxing/jailing anti-features.

## Rooting

"LG ThinQ Login" is a privileged app, which is used to sign in to various "smart" services.
If we use the option to sign in with an Amazon account, we can click web links, and
ultimately end up on google.com. From there, we can search and navigate to [RootMy.TV](https://rootmy.tv),
which hosts the next stage of the exploit. Any javascript that we run has privileged access
to various "private" Luna IPC APIs, including DownloadManager, which has a [publicly documented](https://blog.recurity-labs.com/2021-02-03/webOS_Pt1.html)
arbitrary-root-file-write vulnerability.

Using DownloadManager, we download the Homebrew Channel app, force-enable the developer mode setting, and then
download a shell script to `/media/cryptofs/apps/usr/palm/services/com.palmdts.devmode.service/start-devmode.sh`.

Then, we use another Luna API call to reboot the TV. When the TV boots back up, and on
every subsequent boot, our code in `start-devmode.sh` script gets run as root.

## Jailbreaking

Normally, the only way to run your own code on WebOS is to [enable Developer Mode](https://webostv.developer.lge.com/develop/app-test),
which is an officially supported feature. There are four big problems with LG's
Developer Mode:

1. It requires creating an online account with LG, which in turn requires accepting oppressive ToS agreements.

2. When developer mode times out, all developer-installed apps are removed.

3. Apps run inside a restricted chroot jail, under the unprivileged user account "prisoner".

4. Apps can only access "public" Luna APIs, which significantly restricts their potential functionality.

The `start-devmode.sh` startup script contains code to overcome these limitations, as follows:

 - It starts a telnet server, allowing full remote root access to the TV, for debugging, research etc.

 - It patches `sam` (System and Application Manager) at runtime, to allow installing and launching (non-devmode) apps from unofficial sources. Apps installed in this way can access "private" Luna APIs.

 - It remounts the app data paritions without the `nosuid` flag, enabling native apps with the `setuid` filesystem permission bit to run as root. Apps with root privileges can trivially escape from the chroot jail.

 - System telemetry is disabled by setting the "immutable" filesystem permission bit, on various telemetry log directories.

# Homebrew Channel

To take full advantage of these new features, I created the "[WebOS Homebrew Channel](https://github.com/DavidBuchanan314/webos-homebrew-channel)" app.
This app allows users and developers to easily "sideload" their own apps.

It also
provides some Luna IPC services which may be useful for jailbroken app development, including
the ability to run shell commans as root.

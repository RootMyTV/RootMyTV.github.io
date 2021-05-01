# RootMyTV

RootMyTV is a "remote" root exploit chain, and Jailbreak, for LG webOS smart TVs.

All you need is an internet-connected smart TV, and a TV remote (or alternatively, an Arduino and an IR LED!).

# How it works

In summary, we use a chain of exploits to get persistent root code execution.
As root, we install the [webOS Homebrew Channel](https://github.com/webosbrew/webos-homebrew-channel) app, and disable various
security/sandboxing/jailing anti-features.

## Rooting

### Background

webOS, as the name suggests, is a Smart TV operating system mostly based on web
technologies. Applications, both system and external are either run in a
stripped down web browser ("WebAppMgr") or in Qt QML runtime. Almost all system
and external applications run in chroot-based jails as an additional security
layer.

"Web apps", outside of standard web technologies, also get access to an API for
communicating with "Luna Service Bus". This is a bus, similar to D-Bus, used to
exchange messages and provide various services across different security
domains. Bus clients can expose some RPC methods to other applications
(identified by URIs `luna://service-name/prefix-maybe/method-name`) which accept
JSON object message as their call parameters, and then can return one or many
messages. (depending on the call being "subscribable" or not)

While Luna bus seems to have extensive ACL handling, considering the history of
webOS IP transfers, seems like not many engineers fully understand its
capabilities. Part of the bus is marked as "private", which is only accessible
by certain system applications, while most of the other calls are "public" and
can be accessed by all apps.

Unexpectedly, one of the "public" services exposed on a bus is "LunaDownloadMgr"
which provides a convenient API for file download, progress tracking, etc...
Said service has been researched in the past and an identity confusion bug
leading to an arbitrary unjailed root file write vulnerability has been
[publicly documented](https://blog.recurity-labs.com/2021-02-03/webOS_Pt1.html).

This in of itself was not very helpful in production hardware, thus we needed to
find a way of calling an arbitrary Luna service from an application with
`com.webos.` / `com.palm.` / `com.lge.` application ID.

### Step #0 - Getting in (stage1.html)

In order to gain initial programmatic control of the TV user interface an
interface of "LG Connect Apps" can be used. Its protocol called "SSAP" is a
simple websocket-based RPC mechanism that can be used to indirectly interact
with Luna Service bus and has been extensively documented in various
home-automation related contexts.  We use that to launch a vulnerable system
application which is not easily accessible with plain user interaction.

#### Step #0.1 - Escaping the origins

SSAP API is meant to be used from an external mobile app. For the sake of
simplicity, though, we wanted to serve our exploit as a web page. This lead us
to notice, that, understandably, SSAP server explicitly rejects any connections
from HTTP origins. However, there was an additional exception from that rule,
and seemingly authors wanted to allow file:// origins, which present themselves
to the server as `null`. Turns out there's one other origin that can be used
that is also reprted as `null` and that is `data:` URIs.

In order to exploit this, we've created a minimal WebSocket API proxy
implementation that opens a hidden iframe with a javascript payload (which is
now running in a `data:`/`null` origin) and exchanges the messages with the main
browser frame. This has been released as [a separate
library](https://github.com/Informatic/webos-ssap-web).

#### Step #0.2 - General Data Protocol Redirection

There's a minor problem with establishing the connection with SSAP websocket
server. While we all believe in utter chaos, we don't feel very comfortable with
serving our exploit over plain HTTP, which would be the only way of avoiding
Mixed Content prevention policies. (by default https origins are not allowed to
communicate with plain http endpoints)

While [some newer Chromium versions](https://chromium.googlesource.com/chromium/src.git/+/130ee686fa00b617bfc001ceb3bb49782da2cb4e)
do allow Mixed Content communication with `localhost`, that was not the case
when Chromium 38 was released (used in webOS 3.x). Thankfully, it seems like the
system browser on webOS 3.x is also vulnerable to something that has been
considered a security issue in most browsers for a while now - navigation to
`data:` URIs. Thus, when applicable, our exploits attempts to open itself as a
`data:` base64-encoded URI. This makes our browser no longer consider the origin
being secure, and we can again access the plain-http WebSocket server.

### Step #1 - Social login escape (stage1.html)

Having some initial programmatic control of the TV via SSAP we can execute any
application present on the TV. All cross-application launches can contain an
extra JSON object called `launchParams`. This is used to eg. open a system
browser with specific link open, or launch a predetermined YouTube video. Turns
out this functionality is also used to select which social website to use in
`com.webos.app.facebooklogin`, which is the older sibling of
`com.webos.app.iot-thirdparty-login` used in initial exploit, present on all
webOS versions up until (at least) 3.x.

When launching social login via LG Account Management this application accepts
an argument called `server`. This turns out to be a part of URL that "web app"
browser is navigated to. Thus, using properly prepared `launchParams` we are
able to open an arbitrary web page (with the only requirement being it served
over `https`) running as a system app that is considered by `LunaDownloadMgr`
a "system" app.

### Step #2 - Download All The Things

Since we are already running as a system application, we can download files
(securely over https!) into arbitrary unjailed filesystem locations as root.

We use that to download following files:

* `stage3.sh` →
  `/media/cryptofs/apps/usr/palm/services/com.palmdts.devmode.service/start-devmode.sh` -
  this is the script executed at startup by `/etc/init/devmode.conf` as root,
  in order to run developer mode jailed SSH daemon.
* `hbchannel.ipk` → `/media/internal/downloads/hbchannel.ipk` - since our end
  goal is intalling the Homebrew Channel app, we can also just download it
  during the earlier stages of an exploit and confirm it's actually downloaded.
* `devmode_enabled` → `/var/luna/preferences/devmode_enabled` - this is the flag
  checked before running `start-devmode.sh` script, and is just a dummy file.

### Step #3 - Homebrew Channel Deployment

`stage3.sh` script is a minimal tool that, after opening an emergency telnet
shell and removing itself (in case something goes wrong and the user needs to
reboot a TV - script keeps running but will no longer be executed on next
startup), installs the homebrew channel app via standard devmode service calls
and elevates its service to run unjailed as root as well.


# Legacy

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

Normally, the only way to run your own code on webOS is to [enable Developer Mode](https://webostv.developer.lge.com/develop/app-test),
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

To take full advantage of these new features, we created the "[webOS Homebrew Channel](https://github.com/DavidBuchanan314/webos-homebrew-channel)" app.
This app allows users and developers to easily "sideload" their own apps.

It also provides some Luna IPC services which may be useful for jailbroken app development, including
the ability to run shell commands as root. We also provide a user-friendly
interface to manage various configuration options, like locking software update
nagging, early boot user scripts with some fallback in case of system crashes
or exposing root SSH daemon.

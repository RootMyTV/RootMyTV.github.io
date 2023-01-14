![RootMyTV header image](./img/header_logo.png)

RootMyTV is a user-friendly exploit for rooting/jailbreaking LG webOS smart TVs.

It bootstraps the installation of the [webOS Homebrew Channel](https://github.com/webosbrew/webos-homebrew-channel),
and allows it to run with elevated privileges. The Homebrew Channel is a
community-developed open source app, that makes it easier to develop and install
3rd party software. [Find out more about it here](https://github.com/webosbrew/webos-homebrew-channel).

If you want the full details of how the exploit works, [skip ahead to our writeup](#research-summary-and-timeline).

# Is my TV vulnerable?

---

*Update (2022-12-24)*: **The vulnerabilities used by RootMyTV (both v1 and v2) have been patched by LG.
RootMyTV is unlikely to work on firmware released since mid-2022.**
If you get a `"Denied method call "download" for category "/""` error, your TV is patched.
If your TV reboots but Homebrew Channel is not installed, it is likely patched.
Firmware downgrades are no longer possible without already having root access.

---

At the time of writing the original exploit (RootMyTV v1 - 2021-05-15), all
webOS versions between 3.4 and 6.0 we tested (TVs released between mid-2017 and
early-2021) are supported by this exploit chain. Around June-July 2021 LG
started rolling out updates which added some minor mitigations that broke our
original exploit chain.

**At the time of writing (RootMyTV v2 - 2022-01-05)**, all webOS versions
between 4.x and 6.2+ we tested (TVs released between early-2018 and late-2021)
are supported by the new exploit chain.

Some versions between 3.4 and 3.9 may be supported by RootMyTV v2, but your
mileage may vary.

Note: this versioning refers to the "webOS TV Version" field in the settings menu, *not* the "Software Version" field.

*If you want to protect your TV against remote exploitation, please see the
[relevant section](#mitigation-note) of our writeup and/or await an update from LG.*

# Usage Instructions

**Step Zero (disclaimer):** Be aware of the risks. Rooting your TV is (unfortunately) not supported by
LG, and although we've done our best to minimise the risk of damage,
we cannot make any guarantees. This may void your warranty.

1. (Pre-webOS 4.0) Make sure "Settings → Network → LG Connect Apps" feature is enabled.
2. Developer Mode app **must be uninstalled before rooting**. Having this
   application installed will interfere with RootMyTV v2 exploit, and its full
   functionality is replaced by Homebrew Channel built-in SSH server.
3. Open the TV's web browser app and navigate to [https://rootmy.tv](https://rootmy.tv)
4. "Slide to root" using a Magic Remote or press button "5" on your remote.
5. Accept the security prompt.
6. The exploit will proceed automatically. The TV will reboot itself once
   during this process, and optionally a second time to finalize the installation
   of the Homebrew Channel. On-screen notifications will indicate the exploit's
   progress. On webOS 6.x **Home Screen needs to be opened** for
   notifications/prompts to show up.

Your TV should now have Homebrew Channel app installed.

By default system updates and remote root access are disabled on install. If
you want to change these settings go to Homebrew Channel → Settings. Options
there are applied after a reboot.

For exploiting broken TVs, check out the information [here](./docs/HEADLESS.md).

## Why rooting

* Unlimited "Developer Mode" access

   * While LG allows willing Homebrew developers/users to install unofficial
     applications onto their TVs, official method requires manual renewal of
     "developer mode session", which expires after 50 hours of inactivity.
   * Some of the [amazing homebrew](https://repo.webosbrew.org) that has been
     built/ported onto webOS would likely never be accepted onto LG's official
     Content Store.

* Lower level user/application access

   * This allows willing developers to research webOS system internals, which
     will result in creation of amazing projects, like
     [PicCap](https://github.com/TBSniller/piccap) (high performance video
     capture used for DIY immersive ambient lighting setups), or access to some
     interesting features like customization of system UI, remote adjustment of
     certain TV configuration options, and others.

## FAQ

### Is it safe?

While we cannot take any responsibility for Your actions, we have not
encountered any bricks due to rooting. If you only use trusted software from
[official Homebrew Channel repository](https://repo.webosbrew.org), then you
should be safe.

### Will this void my warranty?

**This is not a legal advice.** At least in the EU, [rooting and other software
modifications are generally deemed to be legal](https://piana.eu/root/) and
should not be a basis for voiding your warranty.

### How do I get rid of this?

[Factory
reset](https://www.lg.com/us/support/video-tutorials/lg-tv-how-to-reset-my-lg-smart-tv-CT10000020-1441914092672)
should remove all root-related configuration files.

We don't have a convenient tool for root removal *without factory reset*, though
a knowledgable person may be able to [remove our customizations manually](https://github.com/webosbrew/webos-homebrew-channel/issues/11).

### Are system updates possible?

While updates are technically possible, if LG patches the exploit, you might end
up "locked out" and unable to re-root your TV if you somehow lose access. We
also can't predict how future updates will affect our techniques used to elevate
and operate the Homebrew Channel app.

### Will this break Netflix/YouTube/AmazonVideo?

No. This does not break or limit access to subscription services or other DRMed
content.

However, staying on very old firmware version (which may be required for keeping
root access persistent) may limit Your access to LG Content Store application
installs, updates, or (rarely) launches. Workarounds for this [are in the
works](https://github.com/webosbrew/webos-homebrew-channel/issues/75).

### How do I update from RootMyTV v1? (released 2021/05)

If you are not going to update your TV Software Version to the one that is
already patched (most 4.x+ released after 2021/06) there is no need to update.
New chain does not bring any new features - the most sensible thing you can do
is to update your Homebrew Channel app.

If you are already rooted on downgraded/pre-2021-06 firmware version and want to
upgrade further, doing an official software update will remove existing root
files and homebrew applications. Running RootMyTV v2 then will reenable root
access again. You will need to reinstall removed applications yourself.

**If you know what you are doing** and want to persist installed applications,
you need to remove
`/media/cryptofs/apps/usr/palm/services/com.palmdts.devmode.service/start-devmode.sh`
file right before an update (without rebooting inbetween), and then run
RootMyTV v2 right on first boot after software update.

### I quickly turned my TV on and off and it's really angry about Failsafe Mode

**If "Failsafe Mode" got tripped on your TV and it's showing angry notifications,
go to Homebrew Channel → Settings, switch "Failsafe Mode" off and press
"Reboot".**

"Failsafe Mode" is a mode where none of our system customizations are enabled
and only an emergency remote access server gets started up.

This mode gets enabled automatically when the TV crashes, gets its power removed
or is shut down during early system startup. In order to reduce chances of that
happening we recommend enabling "Quick Start+" setting in webOS System Settings
General tab. This will make the TV only go to "sleep mode" (which doesn't take
much more power) instead of doing a full shutdown, and will not need to restart
our services on every suspend. This will also make TV startup much faster.

### I want to run some commands as root during boot!

Our [startup
script](https://github.com/webosbrew/webos-homebrew-channel/blob/main/services/startup.sh#L77-L80)
runs all executable files in `/var/lib/webosbrew/init.d` on boot (via
`run-parts` - filenames may only contain `a-zA-Z0-9-_` letters!) - create your
own scripts there.

Create any customizations there and **do not** modify existing RootMyTV/Homebrew
Channel scripts, since these may be overwritten on future updates.

If you are a homebrew developer - create a symlink to a script in your own app
path there, and **do not** copy over anything there.

### I want to support you financially!

If you want, you can support this project via GitHub Sponsors - see "Sponsor"
button in upper right corner.

## Post-Installation Advice (IMPORTANT!)

1. Don't update your TV. While updates are technically possible, if LG patches the
   exploit, you might end up "locked out" and unable to re-root your TV if you
   somehow lose access. We also can't predict how future updates will affect
   our techniques used to elevate and operate the Homebrew Channel app. **"Block
   system updates" option in Homebrew Channel will disable firmware update
   checks.** Make sure "Automatic system updates" option in webOS System
   Settings is disabled as well.

2. It is **required** to remove "Developer Mode" app before rooting. Otherwise it will interfere with the startup script used to
   bootstrap the jailbreak. SSH service exposed by Homebrew Channel is compatible with
   webOS SDK tooling.

3. If you need remote root shell access and know how to use SSH, you can enable
   it in Homebrew Channel settings. Default password is `alpine`, but we recommend
   setting up SSH Public Key authentication by copying your SSH Public Key over
   to `/home/root/.ssh/authorized_keys` on the TV. This will disable password
   authentication after a reboot.

   GitHub user registered keys can be installed using the following snippet:
   ```sh
   mkdir -p ~/.ssh && curl https://github.com/USERNAME.keys > ~/.ssh/authorized_keys
   ```

   Alternative option is Telnet (can be enabled in Homebrew Channel → Settings
   → Telnet) though it is **highly discouraged**, since this gives
   unauthenticated root shell to anyone on a local network.

4. It is recommended to have "Quick Start+" functionality **enabled**. This will
   make shutdown button on a remote not do a full system shutdown. If you
   quickly turn the TV on and off without Quick Start+, our "Failsafe Mode" may
   get triggered (which is there to prevent startup scripts bricking the TV)
   which will go away after switching relevant switch in Homebrew Channel
   Settings.

## Troubleshooting

In case of any problems [join the OpenLGTV Discord server](https://discord.gg/xWqRVEm)
and ask for help on `#rootmytv` channel, ask on [our `#openlgtv:netserve.live`
Matrix channel](https://matrix.to/#/#openlgtv:netserve.live), or file a GitHub issue.

Before asking for support, please consult our [Troubleshooting guide](./docs/TROUBLESHOOTING.md).

# Research Summary and Timeline

RootMyTV is a chain of exploits. The discovery and development of these
exploits has been a collaborative effort, with direct and indirect contributions
from multiple researchers.

On October 05, 2020, Andreas Lindh reported a root file overwrite vulnerability
to LG. On February 03, 2021, Andreas [published his findings](https://blog.recurity-labs.com/2021-02-03/webOS_Pt1.html),
demonstrating a local root exploit against the webOS Emulator (a part
of LG's development SDK). LG had boldly claimed that this issue did not affect their devices,
and that they were going to patch their emulator.

On February 15th, 2021, David Buchanan reported a vulnerability in LG's
"ThinQ login" app, which allowed the app to be hijacked via a specific sequence
of user inputs, allowing an attacker to call privileged APIs.
On March 23rd 2021, David [published a proof-of-concept exploit](https://forum.xda-developers.com/t/rootmy-tv-coming-soon-developer-pre-release-available-now.4232223/),
which enabled users to gain root privileges on their LG smart TVs. This was made
possible by combining it with the local root vulnerability previously
reported by Andreas (Yes, the same one that LG said did not affect their devices!).

Around March 28th 2021, Piotr Dobrowolski discovered a similar vulnerability in the
"Social login" app, which is present across a wider range of webOS versions.
More importantly, this exploit could be easily triggered over the local network,
using SSAP (details below), making it much more reliable and user-friendly.

At time of writing, the code in this repo is the combined work of David
Buchanan (Web design, initial PoC exploit) and Piotr Dobrowolski (Improved "v1" exploit
implementation, writeup, and "v2" research and implementation).

We would like to thank:

 - Andreas Lindh for publishing his webOS research.

 - The wider webOS community, particularly the [XDA forums](https://forum.xda-developers.com/f/webos-software-and-hacking-general.1079/) and the [OpenLGTV discord](https://discord.gg/xWqRVEm).

 - All the contributors (present and future) to the Homebrew Channel, and development of other homebrew apps and software.

 - LG, for patching symptoms of bugs rather than underlying causes...

# The Technical Details

### Background

webOS, as the name suggests, is a Smart TV operating system mostly based on web
technologies. Applications, both system and external are either run in a
stripped down Chromium-based web browser ("WebAppMgr") or in Qt QML runtime. Almost all system
and external applications run in chroot-based jails as an additional security
layer.

"Web apps", outside of standard web technologies, also get access to an API for
communicating with "Luna Service Bus". This is a bus, similar to D-Bus, used to
exchange messages and provide various services across different security
domains. Bus clients can expose some RPC methods to other applications
(identified by URIs `luna://service-name/prefix-maybe/method-name`) which accept
JSON object message as their call parameters, and then can return one or many
messages. (depending on the call being "subscribable" or not)

While Luna bus seems to have extensive ACL handling, considering the [history of webOS IP transfers](https://en.wikipedia.org/wiki/WebOS#History), seems like not many engineers fully understand its
capabilities. Part of the bus is marked as "private", which is only accessible
by certain system applications, while most of the other calls are "public" and
can be accessed by all apps.

Unexpectedly, one of the internal services exposed on a bus is "LunaDownloadMgr"
which provides a convenient API for file download, progress tracking, etc...
Said service has been researched in the past and an identity confusion bug
leading to an arbitrary unjailed root file write vulnerability has been
[publicly documented](https://blog.recurity-labs.com/2021-02-03/webOS_Pt1.html).

This in and of itself was not very helpful in production hardware, thus we needed to
find a way of calling an arbitrary Luna service from an application with a
`com.webos.` / `com.palm.` / `com.lge.` application ID.

### Step #0 - Getting in (index.html)

In order to gain initial programmatic control of the TV GUI, an
interface called "LG Connect Apps" can be used. Its protocol, called "SSAP" (Simple Service Access Protocol), is a
simple websocket-based RPC mechanism that can be used to indirectly interact
with Luna Service bus, and has been extensively documented in various
home-automation related contexts. We use that to launch a vulnerable system
application which is not easily accessible with normal user interaction.

#### Step #0.1 - Escaping the origins

SSAP API is meant to be used from an external mobile app. For the sake of
simplicity, though, we wanted to serve our exploit as a web page. This lead us
to notice that, understandably, the SSAP server explicitly rejects any connections
from (plaintext) HTTP origins. However, there was an additional exception to that rule,
and seemingly the authors wanted to allow `file://` origins, which present themselves
to the server as `null`. Turns out there's one other origin that can be used
that is also reprted as `null`, and that is `data:` URIs.

In order to exploit this, we've created a minimal WebSocket API proxy
implementation that opens a hidden iframe with a javascript payload (which is
now running in a `data:`/`null` origin) and exchanges the messages with the main
browser frame. This has been released as [a separate
library](https://github.com/Informatic/webos-ssap-web).

#### Step #0.2 - General Data Protocol Redirection

There's a minor problem with establishing the connection with the SSAP websocket
server. While we all believe in utter chaos, we don't feel very comfortable with
serving our exploit over plaintext HTTP, which would be the only way of avoiding
Mixed Content prevention policies. (by default, https origins are not allowed to
communicate with plaintext http endpoints)

While [some newer Chromium versions](https://chromium.googlesource.com/chromium/src.git/+/130ee686fa00b617bfc001ceb3bb49782da2cb4e)
do allow Mixed Content communication with `localhost`, that was not the case
when Chromium 38 was released (used in webOS 3.x). Thankfully, it seems like the
system browser on webOS 3.x is also vulnerable to something that has been
considered a security issue in most browsers for a while now - navigation to
`data:` URIs. Thus, when applicable, our exploits attempts to open itself as a
`data:` base64-encoded URI. This makes our browser no longer consider the origin
being secure, and we can again access the plain-http WebSocket server.

#### Mitigation note

An observant reader may have noticed that the service we use is meant to be used
remotely. While the connection itself needs a confirmation using a remote **we
highly recommend to disable LG Connect Apps functionality** in order to prevent
remote exploitation. However, this option seems to only be present on webOS
versions older than webOS 4.x - in such cases the only solutions are to either
**keep the TV on a separate network**, or disable SSAP service manually
using the following command after rooting:
```sh
luna-send -n 1 'palm://com.webos.settingsservice/setSystemSettings' '{"category":"network","settings":{"allowMobileDeviceAccess":false}}'
```

### Step #1 - Social login escape (stage1.html)

Having some initial programmatic control of the TV via SSAP, we can execute any
application present on the TV. All cross-application launches can contain an
extra JSON object called `launchParams`. This is used to eg. open a system
browser with specific site open, or launch a predetermined YouTube video. Turns
out this functionality is also used to select which social website to use in
`com.webos.app.facebooklogin`, which is the older sibling of
`com.webos.app.iot-thirdparty-login` used in initial exploit, present on all
webOS versions up until (at least) 3.x.

When launching social login via LG Account Management, this application accepts
an argument called `server`. This turns out to be a part of URL that "web app"
browser is navigated to. Thus, using a properly prepared `launchParams` we are
able to open an arbitrary web page (with the only requirement being that it's served
over `https`) running as a system app that is considered by `LunaDownloadMgr`
a "system" app.

### Step #2 - Download All The Things (stage2.html)

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

### Step #3 - Homebrew Channel Deployment (stage3.sh)

`stage3.sh` script is a minimal tool that, after opening an emergency telnet
shell and removing itself (in case something goes wrong and the user needs to
reboot a TV - script keeps running but will no longer be executed on next
startup), installs the homebrew channel app via standard devmode service calls
and elevates its service to run unjailed as root as well.

### 2021/06: The Old-New Chain (RootMyTV v2)
Around 2021/06 LG started rolling out a patched version which involved some
fixes for the tricks we used in this chain:

* Certain applications we used for private bus access have their permissions limited to `public`
* LunaDownloadMgr now checks target paths against a list of regular expressions
  in `/etc/palm/luna-downloadmgr/download.json`
* `start-devmode.sh` script is now shipped with a signature and is now verified using `openssl` on each boot
    * This one had an interesting side effect - it took approximately a month
      for LG to roll out a new Developer Mode application with signed
      `start-devmode.sh`, during which time updated TVs were unable to use
      developer mode at all.

Most of these mitigations are too trivial to work around, thus we still consider
this chain unfixed.

* There are still applications on the system that are vulnerable to XSS attacks
  with private bus permissions
* Regular expressions used to verify target paths are too broad, and thus still
  allow us to write to relevant paths
* There are multiple paths that are executed during bootup, so we don't even
  need to use `start-devmode.sh`

Our initial estimate for fixing these issues in our chain were "a couple of
hours" - patches theorized on our side on 2021/05/27 turned out to be correct,
but due to some strategic choices and lack of personal time, we decided to
postpone testing and release for a couple of months. Sorry. :)

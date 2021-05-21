## Blind Deployment

A TV with a broken screen can be rooted quite easily, turning it into a useful platform
for further research.

[The exploit](https://rootmy.tv) can be saved to a local disk on (Ctrl-S...) a
"normal" browser running on a local network. After opening the resulting
`index.html` file a prompt will be shown asking for an IP address of a TV to
perform rooting on. This can help when rooting a TV without a working display.

0. Check if the TV responds on HTTP port 3000 (http://your-tv:3000) - if it does,
   you can skip step 1 as it already has LG Connect Apps enabled.
1. Enable LG Connect Apps (Key sequence likely depends on webOS version, this
   is documented for webOS 3.8)
    - Long press "Quick Settings" on Magic Remote (or press "Quick Settings"
      once, ↑, OK)
    - Wait a couple of seconds...
    - 3x ↓
    - 1x →
    - 4x ↓ (or as many as possible, LG Connect Apps is the last item in the
      menu)
    - OK (open submenu)
    - OK (enable)
    - Exit (or press back multiple times)
2. Run an exploit in an external browser providing an IP address of a TV
3. When asked for a connection prompt after a couple of seconds, press → and OK
4. TV should reboot after a while and should start responding to unauthenticated
   telnet connections on its IP address.

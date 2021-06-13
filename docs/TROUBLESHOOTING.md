# Troubleshooting

**TODO: We don't have a proper troubleshooting guide yet, its best just to ask on the discord, and hopefully we'll update this as time goes on.**

- Check if LG Connect Apps is enabled
- Verify if http://localhost:3000 works in webOS system browser
- After an initial reboot an unauthenticated telnet service (port 23) is exposed.
  In case of any issues it can be used for debugging. Additionally, if an error
  occurs during Homebrew Channel install, the bootstrap shell script is removed,
  and the TV should return to original state after a reboot. Then, rooting may be
  reattempted.

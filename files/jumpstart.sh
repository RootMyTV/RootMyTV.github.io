# *** W A R N I N G ***
#
# Do **not** touch this file, nor /var/lib/webosbrew/startup.sh - this is a
# crucial part of RootMyTV exploit chain.
#
# If you want your own startup script customization, create an executable script
# in /var/lib/webosbrew/init.d/ directory - this will be ran during early
# bootup.
#
# *** W A R N I N G ***

LD_PRELOAD="" nohup sh /var/lib/webosbrew/startup.sh & >/dev/null

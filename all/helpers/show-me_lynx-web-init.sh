#!/bin/bash
export SHOW_ME_APP=${1,,}
[[ -n $(command 2>/dev/null lynx) ]] || || { printf "Missing application \"lynx\".  Attempting to install\n";apt update && apt install -fqy lynx; }
[[ -n $(command 2>/dev/null lynx) ]] || || { printf "Missing application \"lynx\".  Attempted installation failed.  Exiting\n";exit 1; }
[[ -f /opt/show-me/all/helpers/${SHOW_ME_APP}.lynx ]] || { printf "No lynx script found for Show Me app \"${SHOW_ME_APP}\"";exit 0; }
lynx -cmd_script=/opt/show-me/all/helpers/${SHOW_ME_APP}.lynx "https://${SHOW_ME_APP}.ubuntu-show.me"
exit $?


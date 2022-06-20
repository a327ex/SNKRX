#!/bin/sh
# NB. Requires libsteam_api.so on the LD_LIBRARY_PATH
#     or within ./engine/love/linux/

set -e

GAME_PATH="$(dirname "$0" | xargs realpath)"
EXEC_PATH="$GAME_PATH/engine/love"

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$EXEC_PATH/linux"
export LUA_CPATH="$EXEC_PATH/linux/?.so"

# NB. We have to be in EXEC_PATH, so Steam finds the steam_appid.txt
cd "$EXEC_PATH"
./linux/love "$GAME_PATH"

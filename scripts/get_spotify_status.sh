#!/bin/bash

PARENT_BAR="now-playing"
PARENT_BAR_PID=$(pgrep -a "polybar" | grep "$PARENT_BAR" | cut -d" " -f1)


PLAYER="spotify"

FORMAT="{{ title }} - {{ artist }}"

update_hooks() {
    while IFS= read -r id
    do
        polybar-msg -p "$id" hook spotify-play-pause $2 1>/dev/null 2>&1
    done < <(echo "$1")
}

PLAYERCTL_STATUS=$(playerctl --player=$PLAYER status 2>/dev/null)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    STATUS=$PLAYERCTL_STATUS
else
    STATUS="No player is running"
fi

if [ "$1" == "--status" ]; then
    echo "$STATUS"
else
    if [ "$STATUS" = "Stopped" ]; then
        echo "No music is playing"
    elif [ "$STATUS" = "Paused"  ]; then
        update_hooks "$PARENT_BAR_PID" 2
        playerctl --player=$PLAYER metadata --format "$FORMAT"
    elif [ "$STATUS" = "No player is running"  ]; then
        echo "$STATUS"
    else
        update_hooks "$PARENT_BAR_PID" 1
        playerctl --player=$PLAYER metadata --format "$FORMAT"
    fi
fi
metadata=$(playerctl --player=spotify metadata title)
if echo "$metadata" | grep -q "^Advertisement"; then
  pactl set-sink-mute @DEFAULT_SINK@ true
else
  pactl set-sink-mute @DEFAULT_SINK@ false
fi

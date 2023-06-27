
## Spotify Module Installation for Polybar

This guide provides instructions on how to install and configure a Spotify module for Polybar. The module allows you to display the current Spotify status, control playback, and show the currently playing track.

<p align="center" width="100%">
    <img src="https://github.com/Willianjesusdasilva/Polybar-component-spotify/blob/32c4b56a89f1f7cdefe9e90a2e4731b002a00022/src/example.gif"> 
</p>
<p align="center" width="100%">
    <img src="https://github.com/Willianjesusdasilva/Polybar-component-spotify/blob/a1c98fdc669a52cf380f252be563311549d787e6/src/example_zoom.gif"> 
</p>

### Prerequisites

Before proceeding, make sure you have the following dependencies installed:

-   Polybar: A highly customizable status bar for Linux.
-   Playerctl: A command-line utility for controlling media players.
-   Spotify: The Spotify client for Linux.
-   Zscroll: A utility for scrolling text in the terminal.

## Installing Playerctl, Spotify, and Zscroll

This section provides instructions on how to install Playerctl, Spotify, and Zscroll on both Ubuntu and Arch Linux. These instructions will guide you through the installation process for each distribution.

### Ubuntu

To install Playerctl, Spotify, and Zscroll on Ubuntu, follow these steps:

1.  Open a terminal.
    
2.  Update the package list by running the following command:

    `sudo apt update` 
    
3.  Install Playerctl by running the following command:
    
    `sudo apt install playerctl` 
    
4.  Install Spotify by following the official instructions provided by Spotify for Ubuntu. You can visit the Spotify website ([https://www.spotify.com](https://www.spotify.com/)) or use the following commands to install the Spotify snap package:
    
    `sudo snap install spotify` 
    
5.  Install Zscroll by running the following command:

    `sudo apt install zscroll` 
    
Now you have successfully installed Playerctl, Spotify, and Zscroll on Ubuntu.

### Arch Linux

To install Playerctl, Spotify, and Zscroll on Arch Linux, follow these steps:

1.  Open a terminal.
    
2.  Update the package list by running the following command:

    `sudo pacman -Syu` 
    
3.  Install Playerctl by running the following command:

    `sudo pacman -S playerctl` 
    
4.  Install Spotify by following the official instructions provided by Spotify for Arch Linux. You can visit the Spotify website ([https://www.spotify.com](https://www.spotify.com/)) or use an AUR helper like yay to install the Spotify package:

    `yay -S spotify` 
    
    Note: If you don't have yay installed, you can install it by following the instructions on the yay GitHub repository ([https://github.com/Jguer/yay](https://github.com/Jguer/yay)).
    
5.  Install Zscroll by running the following command:

    `sudo pacman -S zscroll` 

Now you have successfully installed Playerctl, Spotify, and Zscroll on Arch Linux.

You can now proceed with configuring Polybar and setting up the Spotify module using the previously provided instructions.

### Step 1: Configure Polybar

To configure Polybar for the Spotify module, follow these steps:

1.  Open the Polybar configuration file. The file location may vary depending on your installation, but it's usually located at `~/.config/polybar/config`.
2.  Locate the `[bar]` section where you want to add the Spotify module.
3.  Modify the `modules-center` line to include the Spotify module and separators. For example

```sh
modules-center = spotify sep spotify-prev sep spotify-play-pause sep spotify-next
```

4.  Add the following section at the end of the configuration file:

```sh
[module/spotify]
type = custom/script
tail = true
interval = 1
format-prefix = " "
format = <label>
exec = ~/.config/polybar/scripts/scroll_spotify_status.sh

[module/spotify-prev]
type = custom/script
exec = echo "玲"
format = <label>
click-left = playerctl previous -p spotify

[module/spotify-play-pause]
type = custom/ipc
hook-0 = echo ""
hook-1 = echo ""
initial = 1
click-left = playerctl play-pause -p spotify

[module/spotify-next]
type = custom/script
exec = echo "怜"
format = <label>
click-left = playerctl next -p spotify` 
```

3.  Save the changes and close the file.

### Step 2: Create the supporting scripts

Now, you need to create two supporting scripts: `get_spotify_status.sh` and `scroll_spotify_status.sh`. Follow the instructions below to create these scripts:

1.  Open a text editor.
2.  Copy the content of the `get_spotify_status.sh` script:

```sh
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
fi` 
```

3.  Save the file as `get_spotify_status.sh`. Make sure to set the correct permissions to make it executable.

4.  Create another file in the same directory called `scroll_spotify_status.sh`. Copy the following content into the file:

```sh
#!/bin/bash

zscroll -l 30 \
        --delay 0.1 \
        --scroll-padding "  " \
        --match-command "`dirname $0`/get_spotify_status.sh --status" \
        --match-text "Playing" "--scroll 1" \
        --match-text "Paused" "--scroll 1" \
        --update-check true "`dirname $0`/get_spotify_status.sh" &

wait
```

5.  Save the file as `scroll_spotify_status.sh` in the same directory. Set the correct permissions to make it executable.

### Step 3: Restart Polybar

After creating the scripts, restart Polybar to apply the changes. The Spotify module should now be displayed in your Polybar, allowing you to control playback and view the current track information.

Please note that you may need to adjust the paths in the Polybar configuration file (`~/.config/polybar/config`) to match the actual locations of the scripts on your system.

That's it! You have successfully installed and configured the Spotify module for Polybar. Enjoy your music!

#!/bin/sh

# This script's function is to pull in all of the programs used in my i3 config.
# It should be run before initially starting i3 to ensure that everything will work properly.	

# Audio and brightness controls
yay -S --noconfirm pulseaudio-ctl
yay -S --noconfirm brightnessctl

# Compositing
yay -S --noconfirm compton-tryone-git

# Screenshots
sudo pacman -S --noconfirm maim xclip

# Screen locker
yay -S --noconfirm i3lock-fancy-git

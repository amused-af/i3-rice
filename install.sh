#!/bin/bash

### Automatic rice deployment script:
### This script will automatically deploy my rice on any Arch Linux based distribution you run it on.
### (more info to be added)


# Check if the script is being run as root
if ! [[ $(id -u) = 0 ]]; then
	echo "This script needs to be run as root. Please try running it again using sudo."
	exit 1
fi

# Welcome and platform check
clear
echo "Welcome to my automatic rice deployment script."
echo "Are you running this script on a laptop? Input Y or N."
while ! [[ "$input" = true ]]; do
	read laptop
	if [[ "$laptop" = Y ]] || [[ "$laptop" = y ]]; then
		lappy=true
		input=true
	fi
	if [[ "$laptop" = N ]] || [[ "$laptop" = n ]]; then
		lappy=false
		input=true
	fi
	if ! [[ "$input" = true ]]; then
		echo "Invalid input."
	fi
done
input=false
echo "Which user do you want to setup these dotfiles for?"
read dotusr

# Functions
init () {
	# Initial install prep
	echo "Copying pacman configuration..."
	cp ./pacman/pacman.conf /etc/pacman.conf
	echo "Initializing pacman keyring..."
	pacman-key --init >/dev/null
	pacman-key --populate archlinux >./pacman-key.log
	echo "Creating standard user directories..."
	pacman -S --noconfirm xdg-user-dirs >/dev/null
	xdg-user-dirs-update >/dev/null
	echo "Implementing Gnome Virtual File System (may take a while)..."
	pacman -S --noconfirm gvfs >/dev/null
}

drivers () {
	echo "Which drivers would you like to install?"
	echo "Input A for AMD, I for intel integrated graphics, or N for nvidia"
	while ! [[ "$input" = true ]]; do
		read gpu
		if [[ "$gpu" = A ]] || [[ "$gpu" = a ]]; then
			echo "Now installing AMD open source drivers..."
			pacman -S --noconfirm xf86-video-amdgpu mesa >/dev/null
			input=true
		fi
		if [[ "$gpu" = I ]] || [[ "$gpu" = i ]]; then
			echo "Now installing mesa..."
			echo "Intel graphics will work best with Xorg's built-in modesetting driver, so there's no need to install an independent driver."
			pacman -S --noconfirm mesa
			input=true
		fi
		if [[ "$gpu" = N ]] || [[ "$gpu" = n ]]; then
			echo "Now installing Nvidia drivers and utilities..."
			pacman -S --noconfirm nvidia nvidia-utils
			input=true
		fi
		if ! [[ "$input" = true ]]; then
			echo "Invalid input."
		fi
	done
	input=false
}

mgmnt () {
	echo "Now installing programs for package and file management:"
	echo "Installing archiver..."
	pacman -S --noconfirm file-roller unrar p7zip >/dev/null
	echo "Installing yay, an AUR manager..."
	git clone https://aur.archlinux.org/yay.git >/dev/null
	cd ./yay
	runuser -u "$dotusr" -c 'makepkg -sri' >/dev/null
	cd ..
	clear
}

fonts () {
	echo "Installing fonts:"
	# Fallback font for applications
	echo "Installing DejaVu Sans Mono..."
	pacman -S --noconfirm ttf-dejavu >/dev/null
	# Terminal font
	echo "Installing Adobe Source Code Pro..."
	pacman -S --noconfirm adobe-source-code-pro-fonts >/dev/null
	# Polybar font
	echo "Installing Bitstream Vera Sans Mono..."
	pacman -S --noconfirm ttf-bitstream-vera >/dev/null
	# Font for non-latin unicode characters
	echo "Installing Adobe Source Han Serif fonts..."
	pacman -S --noconfirm adobe-source-han-serif-otc-fonts >/dev/null
	# Google fonts for websites to render correctly
	echo "Installing Google Noto fonts..."
	pacman -S --noconfirm noto-fonts >/dev/null
	# Icon font
	echo "Installing Font Awesome..."
	pacman -S --noconfirm ttf-font-awesome >/dev/null
}

i3deps () {
	echo "Installing i3-gaps and dependencies used in my config:" 
	echo "Installing i3-gaps..."
	pacman -S --noconfirm i3-gaps >/dev/null
	echo "Adding i3-gaps to xinit..."
	pacman -S --noconfirm xorg-xinit >/dev/null
	runuser -u "$dotusr" -c 'echo "exec i3" >> ~/.xinitrc'
	echo "Installing rofi..."
	pacman -S --noconfirm rofi >/dev/null
	# Audio and brightness controls
	if [[ "$lappy" = true ]]; then
		runuser -u "$dotusr" -c 'yay -S --noconfirm pulseaudio-ctl >/dev/null'
		runuser -u "$dotusr" -c 'yay -S --noconfirm brightnessctl >/dev/null'
	fi
	echo "Installing compton compositor..."
	pacman -S --noconfirm compton >/dev/null
	echo "Installing programs for taking and saving screenshots..."
	pacman -S --noconfirm maim xclip >/dev/null
	echo "Installing programs for locking the screen..."
	runuser -u "$dotusr" -c 'yay -S --noconfirm i3lock-fancy-git >/dev/null'
}

deploy () {
	echo "Now deploying config files and other data:"
	echo "Copying i3 config..."
	runuser -u "$dotusr" -c 'mkdir ~/.config/i3 >/dev/null 2>&1'
	runuser -u "$dotusr" -c 'cp ./i3/config ~/.config/i3/config'
	echo "Copying termite config..."
	runuser -u "$dotusr" -c 'mkdir ~/.config/termite >/dev/null 2>&1'
	runuser -u "$dotusr" -c 'cp ./termite/config ~/.config/termite/config'
	echo "Copying compton config..."
	runuser -u "$dotusr" -c 'cp ./compton/compton.conf ~/.config/compton.conf'
	echo "Copying zshrc..."
	runuser -u "$dotusr" -c 'cp ./.zshrc ~/.zshrc'
	echo "Copying pacman hooks..."
	mkdir /etc/pacman.d/hooks >/dev/null 2>&1
	cp ./pacman/hooks/* /etc/pacman.d/hooks
	echo "Copying PATH scripts..."
	runuser -u "$dotusr" -c 'mkdir ~/.bin >dev/null 2>&1'
	runuser -u "$dotusr" -c 'cp ./.bin/* ~/.bin'
	echo "Copying wallpapers..."
	runuser -u "$dotusr" -c 'mkdir ~/Pictures/.wallpapers >/dev/null 2>&1'
	runuser -u "$dotusr" -c 'cp ./wallpapers/* ~/Pictures/.wallpapers'
}

pbdeploy () {
	echo "Compiling and installing polybar."
	echo "This might take a couple minutes."
	sleep 1
	runuser -u "$dotusr" -c 'yay -S polybar'
	pacman -S --noconfirm jsoncpp >/dev/null
}


# Main script
echo "Would you like to deploy the entire rice, or (a) certain part(s) of it?"
echo "Input Y to deploy the entire rice, or N to see a list of specific parts to deploy."
while ! [[ "$input" = true ]]; do
	read fulldeploy
	if [[ "$fulldeploy" = Y ]] || [[ "$fulldeploy" = y ]]; then
		init
		drivers
		mgmnt
		usercreate
		fonts
		i3deps
		deploy
		pbdeploy
		exit 0
	fi
	if [[ "$fulldeploy" = N ]] || [[ "$fulldeploy" = n ]]; then
		input=true
	fi
	if ! [[ "$input" = true ]]; then
		echo "Invalid input."
	fi
done
input=false

# Manual deployment selection
clear
echo "Select which parts of the rice you want to be deployed."
echo "You can choose multiple parts like so: '1,3,4,5'"
echo "1. Initial preparation (pacman config, gvfs implementation)"
echo "2. Driver installation"
echo "3. User account creation"
echo "4. Fonts installation"
echo "5. i3 and dependencies used in my config installation"
echo "6. Config deployment"
echo "7. Polybar compiling and deployment"

while ! [[ "$input" = true ]]; do
	read selection
	if [[ "$selection" = *"1"* ]]; then
		init
		input=true
	fi
	if [[ "$selection" = *"2"* ]]; then
		drivers
		input=true
	fi
	if [[ "$selection" = *"3"* ]]; then
		usercreate
		input=true
	fi
	if [[ "$selection" = *"4"* ]]; then
		fonts
		input=true
	fi
	if [[ "$selection" = *"5"* ]]; then
		i3deps
		input=true
	fi
	if [[ "$selection" = *"6"* ]]; then
		deploy
		input=true
	fi
	if [[ "$selection" = *"7"* ]]; then
		pbdeploy
		input=true
	fi
	if ! [[ "$input" = true ]]; then
		echo "Invalid input"
	fi
done

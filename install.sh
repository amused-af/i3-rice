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
while ! [[ "$input" = true ]]; do
	echo "Are you running this script on a laptop? Input Y or N."
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
	pacman-key --init &>/dev/null
	pacman-key --populate archlinux &>/dev/null
	echo "Creating standard user directories..."
	pacman -S --noconfirm xdg-user-dirs &>/dev/null
	su -c 'xdg-user-dirs-update' "$dotusr" &>/dev/null
	echo "Implementing Gnome Virtual File System (may take a while)..."
	pacman -S --noconfirm gvfs &>/dev/null
}

drivers () {
	while ! [[ "$input" = true ]]; do
		echo "Which drivers would you like to install?"
		echo "Input A for AMD, I for intel integrated graphics, or N for nvidia"
		read gpu
		if [[ "$gpu" = A ]] || [[ "$gpu" = a ]]; then
			echo "Installing AMD open source drivers..."
			pacman -S --noconfirm xf86-video-amdgpu mesa &>/dev/null
			pacman -S --noconfirm xorg-server &>/dev/null
			pacman -S --noconfirm xorg-xrandr &>/dev/null
			pacman -S --noconfirm arandr &>/dev/null
			input=true
		fi
		if [[ "$gpu" = I ]] || [[ "$gpu" = i ]]; then
			echo "Intel graphics will work best with Xorg's built-in modesetting driver, so there's no need to install an independent driver."
			echo "Installing mesa..."
			pacman -S --noconfirm mesa &>/dev/null
			pacman -S --noconfirm xorg-server &>/dev/null
			pacman -S --noconfirm xorg-xrandr &>/dev/null
			pacman -S --noconfirm arandr &>/dev/null
			input=true
		fi
		if [[ "$gpu" = N ]] || [[ "$gpu" = n ]]; then
			echo "Installing Nvidia drivers and utilities..."
			pacman -S --noconfirm nvidia nvidia-utils &>/dev/null
			pacman -S --noconfirm xorg-server &>/dev/null
			pacman -S --noconfirm xorg-xrandr &>/dev/null
			pacman -S --noconfirm arandr &>/dev/null
			input=true
		fi
		if ! [[ "$input" = true ]]; then
			echo "Invalid input."
		fi
	done
	input=false
	echo "Installing pulseaudio..."
	pacman -S --noconfirm pulseaudio pulseaudio-alsa pavucontrol &>/dev/null 
}

mgmnt () {
	echo "Installing programs for file management:"
	echo "Installing archiver..."
	pacman -S --noconfirm file-roller unrar p7zip &>/dev/null
	echo "Installing file manager and plugins..."
	pacman -S --noconfirm thunar &>/dev/null
	pacman -S --noconfirm tumbler &>/dev/null
}

fonts () {
	echo "Installing fonts:"
	# Fallback font for applications
	echo "Installing DejaVu Sans Mono..."
	pacman -S --noconfirm ttf-dejavu &>/dev/null
	# Terminal font
	echo "Installing Adobe Source Code Pro..."
	pacman -S --noconfirm adobe-source-code-pro-fonts &>/dev/null
	# Polybar fontthought
	echo "Installing Apple San Francisco"
	su -c 'yay -S --noconfirm otf-san-francisco' "$dotusr" &>/dev/null
	# Font for non-latin unicode characters
	echo "Installing Adobe Source Han Serif fonts..."
	pacman -S --noconfirm adobe-source-han-serif-otc-fonts &>/dev/null
	# Google fonts for websites to render correctly
	echo "Installing Google Noto fonts..."
	pacman -S --noconfirm noto-fonts &>/dev/null
	# Icon font
	echo "Installing Font Awesome..."
	pacman -S --noconfirm ttf-font-awesome &>/dev/null
}

i3deps () {
	echo "Installing i3-gaps and dependencies used in my config:" 
	echo "Installing i3-gaps..."
	pacman -S --noconfirm i3-gaps &>/dev/null
	echo "Installing termite..."
	pacman -S --noconfirm termite &>/dev/null
	echo "Installing pywal..."
	pacman -S --noconfirm python-pywal &>/dev/null
	echo "Adding i3-gaps and pywal to xinit..."
	pacman -S --noconfirm xorg-xinit &>/dev/null
	echo "wal -R" >> /home/"$dotusr"/.xinitrc
	echo "exec i3" >> /home/"$dotusr"/.xinitrc
	echo "Installing rofi..."
	pacman -S --noconfirm rofi &>/dev/null
	echo "Installing zsh..."
	pacman -S --noconfirm zsh &>/dev/null
	su -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"' "$dotusr" &>/dev/null
	rm /home/"$dotusr"/.zshrc.pre-oh-my-zsh
	# Audio and brightness controls
	if [[ "$lappy" = true ]]; then
		su -c 'yay -S --noconfirm pulseaudio-ctl' "$dotusr" &>/dev/null
		su -c 'yay -S --noconfirm brightnessctl' "$dotusr" &>/dev/null
	fi
	echo "Installing compton compositor..."
	pacman -S --noconfirm compton &>/dev/null
	echo "Installing programs for taking and saving screenshots..."
	pacman -S --noconfirm maim xclip &>/dev/null
	echo "Installing program for locking the screen..."
	su -c 'yay -S --noconfirm i3lock-fancy-git' "$dotusr" &>/dev/null
}

deploy () {
	echo "Deploying config files and other data:"
	echo "Copying config files..."
	cp -r ./.config /home/"$dotusr"/.config
	cp -r ./.vim /home/"$dotusr"/.vim
	cp ./.zshrc /home/"$dotusr"/.zshrc
	cp ./.vimrc /home/"$dotusr"/.vimrc
	echo "Copying pacman hooks..."
	mkdir /etc/pacman.d/hooks
	cp ./pacman/hooks/* /etc/pacman.d/hooks
	echo "Copying PATH scripts..."
	mkdir /home/"$dotusr"/.bin
	cp ./.bin/* /home/"$dotusr"/.bin
	echo "Copying wallpapers..."
	mkdir /home/"$dotusr"/Pictures/.wallpapers
	cp ./wallpapers/* /home/"$dotusr"/Pictures/.wallpapers
	echo "Setting default wallpaper"
	pacman -S --noconfirm feh &>/dev/null
	wal -i /home/"$dotusr"/Pictures/.wallpapers/abstract_wallpenis.jpg &>/dev/null
}

pbdeploy () {
	echo "Compiling and installing polybar."
	echo "This might take a couple minutes."
	sleep 1
	su -c 'yay -S polybar' "$dotusr"
	pacman -S --noconfirm jsoncpp >/dev/null
	chmod +x /home/"$dotusr"/.config/polybar/launch.sh
}


# Main script
clear
while ! [[ "$input" = true ]]; do
	echo "Would you like to deploy the entire rice, or (a) certain part(s) of it?"
	echo "Input Y to deploy the entire rice, or N to see a list of specific parts to deploy."
	read fulldeploy
	if [[ "$fulldeploy" = Y ]] || [[ "$fulldeploy" = y ]]; then
		clear
		init
		clear
		drivers
		clear
		mgmnt
		clear
		fonts
		clear
		i3deps
		clear
		deploy
		clear
		pbdeploy
		clear
		echo "Rice deployment complete."
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
echo "3. File management tools installation"
echo "4. Fonts installation"
echo "5. i3 and dependencies used in my config installation"
echo "6. Config deployment"
echo "7. Polybar compiling and deployment"

while ! [[ "$input" = true ]]; do
	read selection
	clear
	if [[ "$selection" = *"1"* ]]; then
		init
		input=true
	fi
	if [[ "$selection" = *"2"* ]]; then
		drivers
		input=true
	fi
	if [[ "$selection" = *"3"* ]]; then
		mgmnt
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

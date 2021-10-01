#!/usr/bin/env bash

if [[ $EUID != 0 ]];
then
	echo "This Script must be run as root!"
	exit 1
fi


Wrong_usage() {
	echo "Usage: $1 [OPTION]..."
	echo "Try '$1 help' for more information."
}

Help() {
	# Display Help
	echo "TP-Link TL_WN722N v2/v3 [Realtek RTL8188EUS] Enable Monitor Mode"
	echo
	echo "Syntax: $1 [interface id] [up|down|enable]"
	echo "Example: $1 wlan0 up"
	echo
	echo "options:"
	echo "enable	Install and enable new driver which support Monitor mode"
	echo "up		Set Interface in Monitor Mode"
	echo "down		Set Interface in Managed Mode"
	echo "help		Help Menu"
	echo
	echo "Report bugs to: https://github.com/anilbeesetti/tplinkmon"
}

Enable() {
	apt update
	apt install bc build-essential libelf-dev linux-headers-`uname -r` dkms
	rmmod r8188eu.ko
	cd /tmp
	git clone "https://github.com/aircrack-ng/rtl8188eus"
	cd rtl8188eus
	echo "blacklist r8188eu" > "/etc/modprobe.d/realtek.conf"
	make
	make install
	modprobe 8188eu
	echo "Reboot the system in order to blacklist the old driver and load the new driver/module."
}


if [[ $1 == "help" ]]
then
    Help $0
    exit 0
elif (( $# < 2 || $# > 2 ))
then
	Wrong_usage $0
	exit 1
elif [[ $2 == "enable" ]]
then
	Enable
	exit 0
elif [[ $2 == "up" ]]
then
	ifconfig $1 down
	airmon-ng check kill > /dev/null
	iwconfig $1 mode monitor
	ifconfig $1 up
	echo "====================Monitor Mode Enabled========================="
	iwconfig $1
elif [[ $2 == "down" ]]
then
	ifconfig $1 down
	airmon-ng check kill > /dev/null
	iwconfig $1 mode managed
	ifconfig $1 up
	NetworkManager
	echo "====================Monitor Mode Disabled========================="
	iwconfig $1
else
	Wrong_usage $0
	exit 1
fi

#!/bin/bash

###
# Script variables
###
ALERT_EMAIL="jmcparland@tcmlabs.com"
SNAPS=1
#WIRELESS_DEVICE=wlp4s0
VPN="openvpn@overwatch"

###
# Take SNAPS pictures in rapid succession
###
ts=`date +%s`
ffmpeg -f v4l2 -s vga -i /dev/video0 -vframes $SNAPS /tmp/pwfail-$ts.%01d.jpg

###
# Open the VPN connection to home if it's not already and allow all input
# Ensure openvpn connection restarts on reboot
# Give time for tunnel to open before reporting network stats (nmcli)
###
systemctl start $VPN
systemctl enable $VPN
systemctl start ssh
systemctl enable ssh
iptables -P INPUT ACCEPT
sleep 3

###
# Email the last one to the ALERT_EMAIL address
###
{
	echo "Hostname: $HOSTNAME"
	echo "DTG: $(date)"
	echo "Public IP: $(wget -qO- ipinfo.io/ip)"
	echo "nmcli output:"
	nmcli
} | mail -s "$HOSTNAME Failed Access $(date)" -A /tmp/pwfail-$ts.$SNAPS.jpg $ALERT_EMAIL

###
# Always return 0
###
exit 0

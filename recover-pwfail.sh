#!/bin/bash

VPN="openvpn@myvpnid"

iptables -P INPUT DROP
systemctl disable $VPN
systemctl stop openvpn
systemctl disable ssh
systemctl stop ssh

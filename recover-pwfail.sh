#!/bin/bash

VPN="openvpn@overwatch"

iptables -P INPUT DROP
systemctl disable $VPN
systemctl stop openvpn
systemctl disable sshd
systemctl stop sshd

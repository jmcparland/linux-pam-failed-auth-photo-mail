# linux-pam-failed-auth-photo-mail
General instructions for using PAM and a script to take action when authentication fails (e.g., wrong password). Inspiration, not a hardened package.

# PAM Fundamentals
The Pluggable Authentication Module (PAM) system is generally consulted when a user attempts to authenticate to a system. This includes logging in, unlocking a lock screen, performing su or sudo, etc. `/etc/pam.d` is the location of PAM configuration data. The file `/etc/pam.d/common-auth` provides the core of what most services include when performing authentication; in general, there may be several lines of what constitutes successful authentication falling through to lines indicating how to handle failure. [The success lines generally indicate a "jump" command indicating a number of non-comment lines to jump over on successful authentication. This jumps over the "what to do on failure" section.]  We have inserted a line 

`auth	[default=ignore]		pam_exec.so seteuid /usr/local/bin/handle-pwfail.sh`

instructing PAM to execute the script /usr/local/bin/handle-pwfail.sh as root on authentication failure.

# On Failure
Our `/usr/local/bin/handle-pwfail.sh` file is a simple bash script that performs the following actions:
* Take a photo snapshot using the laptop's built-in web camera. [Requires the ffmpeg package.]
* "Calls home" as an openvpn client back to a waiting openvpn server. [Requires openvpn & configuration of client & server.]
* "Enables" the openvpn service so that the link will be persistent / re-establish on reboot.
* Starts and enables the sshd service for remote login.
* Opens the laptop firewall to accept inbound connections -- for instance, ssh connections through vpn to the laptop.
* Sends an email report of the event, including:
  * The hostname of the laptop
  * The date & time of the event
  * The public IP address in front of the laptop (output of `wget -qO- ipinfo.io/ip`)
  * Some basic network environmental information (devices, ip addresses, dns, domain, etc., from the `nmcli` command)
  * The photo taken, as an attachment

# To Recover
We constructed `/usr/local/bin/recover-pw-fail.sh` to restore some of the above back to our default settings. Owership is root:root and permissions are set to 750 requiring root access (su/sudo).

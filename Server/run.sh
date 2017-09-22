#!/bin/sh -eu

# generate SSH host key (not done by default on Alpine), and actually if we'd do it when
# building the Docker image, that'd be a huge security implication (leak the host private key)
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -b 4096 -t rsa
	export WD=$PWD
	cd /etc/ssh/
	ssh-keygen -A
	cd $WD
fi

# display version number in motd
adduser -s /bin/sh -D $USER
mkdir /home/$USER/.ssh
PASWD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)"
chown $USER /home/$USER/
echo $USER:$PASWD | chpasswd
echo $USER:$PASWD
exec /usr/sbin/sshd -D

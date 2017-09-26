#!/bin/sh -eu

# generate SSH host key (not done by default on Alpine), and actually if we'd do it when
# building the Docker image, that'd be a huge security implication (leak the host private key)
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -b 4096 -t rsa
	#export WD=$PWD
	#cd /etc/ssh/
	#ssh-keygen -A
	#cd $WD
fi

# display version number in motd
adduser -s /bin/sh -D $USER
mkdir /home/$USER/.ssh
chown $USER /home/$USER/
chown $USER /home/$USER/.ssh

PASWD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)"
echo $USER:$PASWD | chpasswd
echo $USER:$PASWD

echo "$USER_CA_PUBKEY" > /etc/ssh/user_ca.pub
echo "$SSH_PRIVKEY" > /etc/ssh/ssh_host_rsa_key
echo "$SSH_PUBKEY" > /etc/ssh/ssh_host_rsa_key.pub
echo "$SSH_CERTIFICATE" > /etc/ssh/ssh_host_rsa_key-cert.pub

/usr/sbin/sshd -D

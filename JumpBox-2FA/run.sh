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
echo "$SSH_PUBKEY" > /home/$USER/.ssh/authorized_keys
chown $USER /home/$USER/
chown $USER /home/$USER/.ssh/*
chmod 644 /home/$USER/.ssh/authorized_keys
chmod 755 /home/$USER/.ssh/
echo $USER:$PASWD | chpasswd

cd /home/$USER
su - $USER -c "google-authenticator -t -d -u -f -w 3"
cd $WD

echo -e "auth required pam_google_authenticator.so" >> /etc/pam.d/base-auth

exec /usr/sbin/sshd -D

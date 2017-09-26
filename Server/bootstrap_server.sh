#!/bin/sh -eu

HOSTNAME=test.server.example.com
CNAME=bs-server

echo "Creating keypair for server"
ssh-keygen -f ./ssh_host_rsa_key -N '' -b 4096 -t rsa

#IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CNAME)
echo "Creating a Host certificate for container with hostname $HOSTNAME"
ssh-keygen -s ../host_ca -I $CNAME -h -n $HOSTNAME -V +1w ./ssh_host_rsa_key.pub

#echo "Pushing host certificate to container so container can identify itself to users connecting"
#docker cp ssh_host_rsa_key-cert.pub $CNAME:/etc/ssh/

echo "Starting Server Container"
docker run -d -p 2222:22 \
-e USER=op9 \
-e USER_CA_PUBKEY="$(cat ../user_ca.pub)" \
-e SSH_PRIVKEY="$(cat ssh_host_rsa_key)" \
-e SSH_PUBKEY="$(cat ssh_host_rsa_key.pub)" \
-e SSH_CERTIFICATE="$(cat ssh_host_rsa_key-cert.pub)" \
-e HOSTNAME=$HOSTNAME \
--name $CNAME \
server

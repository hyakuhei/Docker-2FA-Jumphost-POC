#!/bin/sh -eu

SERVER_HOSTNAME=test.server.example.com
SERVER_NAME=bs-server
USER=op9

IP="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $SERVER_NAME)"

echo "Creating keypair for forward jump to server"
ssh-keygen -f ./fwd/id_rsa -N '' -b 4096 -t rsa

#Keys in the ./fwd folder are used for connections From Jumpbox -> Server

echo "Creating a User certificate for user to use in forward connection"
ssh-keygen -s ../user_ca -I $USER -n $USER -V +1d ./fwd/id_rsa.pub

echo "Starting JumpAuth Container"
docker run -d -p 1122:22 \
-e USER=op9 \
-e HOST_CA_PUBKEY="$(cat ../host_ca.pub)" \
-e SSH_PUBKEY="$(cat ../id_rsa.pub)" \
-e SSH_FWD_PUBKEY="$(cat fwd/id_rsa.pub)" \
-e SSH_FWD_PRIVKEY="$(cat fwd/id_rsa)" \
-e SSH_FWD_CERTIFICATE="$(cat fwd/id_rsa-cert.pub)" \
-e UPDATE_HOSTS="$IP $SERVER_HOSTNAME " \
jumpauth

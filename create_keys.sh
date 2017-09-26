#!/bin/sh -eu

echo "Creating CA keys"

ssh-keygen -f user_ca
ssh-keygen -f host_ca
ssh-keygen -f id_rsa -N '' -b 4096 -t rsa

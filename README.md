# Dynamic 2FA Jump Container POC
As I was playing around with some things in the IBM bluemix environment I started wondering about using ephemeral container jump-hosts to pivot into cloud environments. As a proof of concept toy, I wanted to experiment with how one might use Docker to spawn jump-hosts that could be used to log into other hosts.

Note: If you're trying to solve a gated access issue you're better off looking at technologies like [ssh keybox](https://github.com/skavanagh/KeyBox),   [teleport](https://gravitational.com/teleport/) or [tycotic](https://thycotic.com/)

For my imaginary scenario, I have a jump box positioned between my client and the servers that I want to modify.

```
----------      -----------      ----------
| client | ---> | jumpbox | ---> | server |
----------      -----------      ----------
      pubkey + 2fa        ssh certificate
```
The client authenticates with the JumpBox using their SSH public key and Google Authenticator. The jumpbox is pre-configured with a SSH certificate that provides access onwards to the server for that specific user.

This repository contains two folders, each has dockerfiles for building containers, scripts to run on container invocation etc.

## JumpAuth
The eventual idea here is that you might want to have jumpboxes that spawn sessions for users to connect via, which is why this jumpbox creates a lot of things when it starts up.

What I think is interesting is the way it also dynamically provisions 2FA services for Google Authenticator.

## Server
This one's pretty simple, a small Alpine container that's just intended as an SSH endpoint in order for the jumpbox to have something to forward connections onto.

## Getting started
Create (or provide) the keys that our 'client' will use along with

- The container will start, it will run a local copy of the ```run.sh``` script which creates a user in this case called 'op9', imports a pubkey for that user and configures google authenticator
- Get the logs from the container and use them to access the OTP code for the container

## Quickstart
```
git clone git@github.com:hyakuhei/Docker-2FA-Jumphost-POC.git
cd Docker-2FA-Jumphost-POC
sh create_keys.sh
cd Server
sh bootstrap_server.sh
cd ../JumpAuth
sh bootstrap_jumpauth.sh
cd ..

#Two containers are now running, a "server" we want to reach and a "Jumpbox" that is configured to allow forward access to that server.

#To connect to the server, via the jumpbox run:
ssh -A -t -p 1122 -i ./id_rsa -l op9 127.0.0.1 ssh -A test.server.example.com
```

## Example video
[![Video of operation](https://img.youtube.com/vi/m3JFaFzrevM/0.jpg)](https://www.youtube.com/watch?v=m3JFaFzrevM)

# Dynamic 2FA Jump Container POC
As I was playing around with some things in the IBM bluemix environment I started wondering about using ephemeral container jump-hosts to pivot into cloud environments. As a proof of concept toy, I wanted to experiment with how one might use Docker to spawn jump-hosts that could be used to log into other hosts.

Note: If you're trying to solve a gated access issue you're better off looking at technologies like [ssh keybox](https://github.com/skavanagh/KeyBox),   [teleport](https://gravitational.com/teleport/) or [tycotic](https://thycotic.com/)

For my imaginary scenario, I have a jump box positioned between my client and the servers that I want to modify.

```
----------      -----------      ----------
| client | ---> | jumpbox | ---> | server |
----------      -----------      ----------
      pubkey + 2fa        password
```

This repository contains two folders, each has dockerfiles for building containers, scripts to run on container invocation etc.

## JumpBox-2FA
The eventual idea here is that you might want to have jumpboxes that spawn sessions for users to connect via, which is why this jumpbox creates a lot of things when it starts up.

What I think is interesting is the way it also dynamically provisions 2FA services for Google Authenticator.

## Server
This one's pretty simple, a small Alpine container that's just intended as an SSH endpoint in order for the jumpbox to have something to forward connections onto.

## Getting started
- Clone this repository
- From within the repository folder
- Create a ssh keypair to use for your user
  - ```sshkeygen -f ./id_rsa```

## Getting started | JumpBox
- Build the container
```
cd JumpBox-2FA
docker build -t 2fajumpbox .
```
- Run the container, providing username and public ssh key
```
docker run -d -p 1122:22 \
-e USER=op9 \
-e SSH_PUBKEY="$(cat ../id_rsa.pub)"
2fajumpbox
```
- The container will start, it will run a local copy of the ```run.sh``` script which creates a user in this case called 'op9', imports a pubkey for that user and configures google authenticator
- Get the logs from the container and use them to access the OTP code for the container

## Getting started | Server
Build the server container and start it as described above for the 2fa jumpbox
- Get the password for the user from the docker logs for that container

At this point you should be able to connect to the 2fa box using pubkey and 2fa, and to the server using password.

## Example video
[![Video of operation](https://img.youtube.com/vi/m3JFaFzrevM/0.jpg)](https://www.youtube.com/watch?v=m3JFaFzrevM)

# Fulcrum - a system for creating conterized pivots (jump hosts) into secure environments
As I was playing around with some things in the IBM bluemix environment I started wondering about using ephemeral container jump-hosts to pivot into cloud environments. As a proof of concept toy, I wanted to experiment with how one might use Docker to spawn jump-hosts that could be used to log into other hosts.

Using containers as ephemeral bastion hosts has some really interesting properties:
* Ephemerality: if operators try to drop ssh keys, access tokens, tools etc on the jump box, they're magically deleted once they loose access.
* Scalability: the process for scaling this sort of access is trivial.
* Security: Containers use all the fun technologies that we would use to try to stop a shell doing bad things on a bastion hosts (i.e MAC, SECCOMP, Namespaces, CGroups, etc) however using docker buys us extremely useful lifecycle management and introspection capabilities.

For this POC the Jumpbox uses SSH Certificates to manage access to back-end infrastructure. This again has some useful properties over a more traditional ssh-key (eurgh!) or password (just nasty!) approach:
* Limit access time: No need to worry about how long a user has the certificate for or how it might need to be protected in the longer term - ssh certificates have expiries! I can issue a user with a certificate valid for an hour - that's the default here.
* Key distribution: Got a team of 30 operators who need access to 10000 machines? Do operators change frequently? No problem with certificates, much like with the more hierarchical X.509 certificate system, simply distribute a signing certificate (like a CA) for your operators onto all machines. That's one thing to manage and update and it can be done centrally. No need to manage indipendant users.
* Host identitfication: Operators will regularly log into systems they've never accessed before - when they do they'll get that UNKOWN HOST warning! Do you know what (almost) every operator in the world does, they say "That's ok, I've not been here before, I'll accept" - with SSH certificates you can perform host identification. Now Operators (and the Jump-Containers) don't need to know about every one of the 10000 machines, they only need to trust one CA - WOW!

This project also dynamically provisions Google Authenticator 2FA into each ephemeral jump host, the idea here was really just to play with dynamic 2FA and to explore how it might be used in these sorts of scenarios. It works really well!

Note: If you're trying to solve a gated access issue you're better off looking at technologies like [ssh keybox](https://github.com/skavanagh/KeyBox),   [teleport](https://gravitational.com/teleport/) or [thycotic](https://thycotic.com/)

For my imaginary scenario, I have a jump box positioned between my client and the servers that I want to modify. You dear reader play the part of the provsioning/authorization system. When running the commands and exploring the stuff that I've scratched together to orchestrate the containers keep in mind that these would likely be performed by an auth system. The normal flow being that an operator would:
* Go to the authorization portal and provide business need (pager duty / jira ticket / audio recording of screaming customer) for audit purposes.
* Authorization portal would provision a dynamic jump box for access by this operator and pre-populate it with a certificate that allows onward use (to a specific subset of machines) for as long as required, ideally as short as possible (This is the role you play reader, as you run these scripts.
* Operator then logs into (or pivots through, depending on your configuration) the Jump Box and fixes the target system.

```
----------      -----------      ----------
| client | ---> | jumpbox | ---> | server |
----------      -----------      ----------
      pubkey + 2fa        ssh certificate
```
The client authenticates with the JumpBox using their SSH public key and Google Authenticator. The jumpbox is pre-configured with a SSH certificate that provides access onwards to the server for that specific user.

This repository contains two folders, each has dockerfiles for building containers, scripts to run on container invocation etc.

## TODO:
* Add recording capabilities to JumpAuth
* Run alpine hardening (script is there already but needs tweaking)
* Considerations around forcing the user to issue commands from the jumpbox vs pivoting to the endpoint
* Add more logging capabilities
* Build a UI / portal

## Server
This one's pretty simple, a small Alpine container that's just intended as an SSH endpoint in order for the jumpbox to have something to forward connections onto.

Start the server by running the bootstrap_server.sh script

## JumpAuth
This is where most of the magic happens, it's pretty simple magic but getting the various options in the various technologies to play nicely together was non-trivial. 

Running the boostrap_jumpauth.sh will get everything up and running. Note: Run this after starting your server. The server isn't super important in real terms but the boostrap_jumpauth.sh script talks to docker to find the IP address of the server that our operator is to access.

## You need keys!
You can provide your own keys if you like, in this scenario we create keys for the operator and the CA keys (we have a user_CA and a host_CA) - there's a handy create_keys.sh you can run if desired. The boostrap scripts use some hard-coded values so it's worth running the script once to see what it creates.

## Getting started
Create (or provide) the keys that our 'client' will use along with

- Generate the keys
- Boostrap the example 'server'
- Bootstrap the JumpAuth system
- Log in - the operator will be challenged for their 2FA token, see the logs from the JumpAuth container to access the google authenticator OTP barcode.

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

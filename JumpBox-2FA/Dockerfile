FROM alpine:edge

ENV TERM=xterm-256color

RUN  apk update \
  && apk add --no-cache openssh \
  && apk add --no-cache google-authenticator \
  && apk add openssh-server-pam

COPY sshd_config /etc/ssh/
COPY pam_sshd /etc/pam.d/sshd

EXPOSE 22

ADD run.sh /run.sh
ADD motd /etc/motd

RUN mkdir /var/run/sshd \
  && chmod +x /run.sh

CMD /run.sh

FROM alpine:edge

ENV TERM=xterm-256color

RUN apk add --no-cache openssh

ADD sshd_config /etc/ssh/

EXPOSE 22

ADD run.sh /run.sh
ADD motd /etc/motd

RUN mkdir /var/run/sshd \
  && chmod +x /run.sh

CMD /run.sh

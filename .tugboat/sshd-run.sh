#!/bin/sh

if test -f /etc/default/ssh; then
    . /etc/default/ssh
fi

if [ ! -d /run/sshd ]; then
    mkdir /run/sshd
    chmod 0755 /run/sshd
fi

exec /usr/sbin/sshd -D $SSHD_OPTS

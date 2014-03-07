#!/bin/sh

perl -pe "s/^address=\/#/#address=\/#/" /etc/dnsmasq.conf > /tmp/dnsmasq.conf
mv /tmp/dnsmasq.conf /etc/dnsmasq.conf
if [ -x /usr/bin/systemctl ]; then
  systemctl restart dnsmasq
else
  service dnsmasq restart
fi

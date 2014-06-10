#!/bin/bash

/usr/bin/perl -pe "s/address=\/#/#address=\/#/" /etc/dnsmasq.conf.orig > /tmp/dnsmasq.conf
mv /tmp/dnsmasq.conf /etc/dnsmasq.conf
if [ -x /usr/bin/systemctl ]; then
  systemctl restart dnsmasq
else
  service dnsmasq restart
fi

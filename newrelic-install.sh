#!/bin/sh

CURDIR=$(pwd)

cd /root/src

#tar xvzf newrelic-php5-7.1.0.187-linux-musl.tar.gz
#cd newrelic-php5-7.1.0.187-linux-musl
tar xvzf newrelic-php5-7.2.0.191-linux-musl.tar.gz
cd newrelic-php5-7.2.0.191-linux-musl

sh newrelic-install install << EOF
y
our_secret_key
EOF

#cp /etc/newrelic/newrelic.cfg.template /etc/newrelic/newrelic.cfg

cd $CURDIR

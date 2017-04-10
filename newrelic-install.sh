#!/bin/sh

CURDIR=$(pwd)

cd /root/src

tar xvzf newrelic-php5-7.1.0.187-linux-musl.tar.gz
cd newrelic-php5-7.1.0.187-linux-musl

sh newrelic-install install << EOF
1395c36ef8f513749aa05c18e50abf1172b351b9
EOF

cp /etc/newrelic/newrelic.cfg.template /etc/newrelic/newrelic.cfg

cd $CURDIR

#!/bin/sh

sed -i -e 's/newrelic.appname = "PHP Application"/newrelic.appname = \"'"$APP_NAME"'\"/' /etc/php7/conf.d/newrelic.ini

echo 'newrelic.daemon.port = "@newrelic-daemon"' >> /etc/php7/conf.d/newrelic.ini

echo 'newrelic.daemon.utilization.detect_docker = true' >> /etc/php7/conf.d/newrelic.ini

/usr/bin/newrelic-daemon -c /etc/newrelic/newrelic.cfg --pidfile /var/run/newrelic-daemon.pid -f

/usr/local/bin/httpd-foreground

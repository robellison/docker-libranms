#!/bin/bash


# == Fetch proper librenms version

cd /tmp &&

wget https://github.com/librenms/librenms/archive/$librenms_RELEASE.tar.gz &&
tar xvf $librenms_RELEASE.tar.gz &&
rm $librenms_RELEASE.tar.gz
mv librenms-$librenms_RELEASE librenms

cp -r /tmp/librenms/* /opt/librenms/

# Web interface directories

cd /opt/librenms
chmod 775 rrd

# setup logrotate

cp /tmp/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms


# configure librenms package







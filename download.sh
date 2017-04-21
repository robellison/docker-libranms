#!/bin/bash
# Add librenms user

useradd librenms -d /opt/librenms -M -r
usermod -a -G librenms www-data

# == Fetch proper librenms version

cd /tmp &&

wget https://github.com/librenms/librenms/archive/$librenms_RELEASE.tar.gz &&
tar xvf $librenms_RELEASE.tar.gz &&
mv librenms-$librenms_RELEASE librenms
rm $librenms_RELEASE.tar.gz

# I know this seems ridiculous, but since /opt/librenms/html is an external
# volume mount, svn throws a fit about it conflicting with the tree. Pulling
# SVN to temp directory and copying contents into /opt/librenms was just the
# first way thought of to avoid dealing with the svn conflict resolution from
# script.
cp -r /tmp/librenms/* /opt/librenms/

# Web interface directories

cd /opt/librenms
mkdir rrd logs
chmod 775 rrd

# setup logrotate

cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms


# configure librenms package







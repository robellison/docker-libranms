#!/bin/bash
# == Fetch proper librenms version

cp -r /tmp/librenms/* /opt/librenms/
cp /tmp/config.php.default /opt/librenms/config.php.default
cd /opt/librenms && \
cp config.php.default config.php && \
sed -i -e "s/= 'localhost';/= '$librenms_DB_HOST';/g" config.php && \
sed -i -e "s/= 'USERNAME';/= '$librenms_DB_USER';/g" config.php && \
sed -i -e "s/= 'PASSWORD';/= '$librenms_DB_PASS';/g" config.php && \
sed -i -e "s/= 'librenms';/= '$librenms_DB_NAME';/g" config.php

chown -R librenms:librenms /opt/librenms
chmod 755 -R /opt/librenms/rrd 
chmod 755 -R /opt/librenms/logs

# == Configuration section

# Queue jobs for later execution while configuration is being sorted out
atd

# Check for `config.php`. If it doesn't exist, use `config.php.default`,
# substituting SQL credentials with librenms/"random".

FIRST_TIME_LOCKED=/opt/librenms/lock/librenms-init.locked

if [ ! -f $FIRST_TIME_LOCKED ]
then
  echo "Connecting to librenms database container ..."
  count=0
  rc=1
  while [ $count -lt 12 -a $rc -ne 0 ]
  do
     echo "select 1" | mysql -h $librenms_DB_HOST -u $librenms_DB_USER --password=$librenms_DB_PASS $librenms_DB_NAME
     rc=$?
     [ $rc -ne 0 ] && sleep 5
     count=`expr $count + 1`
  done

  if [ $rc -eq 0 ]
  then
     echo "Initializing database schema in first time running for librenms ..."
     php /opt/librenms/build-base.php
     /opt/librenms/adduser.php $librenms_ADMIN_USER $librenms_ADMIN_PASS 10
     touch $FIRST_TIME_LOCKED
  else
     echo "Skipping initializing database ..."
  fi
else
  echo "Database schema initialization has been done already ..."
fi

phpenmod mcrypt
a2dismod mpm_event
a2enmod mpm_prefork
a2enmod php7.0
a2enmod rewrite


chown librenms:librenms -R /opt/librenms/html
touch /etc/crontab

# Prepend environemt variables to the crontab
env |cat - /etc/crontab > /tmp/crontab
mv /tmp/crontab /etc/crontab



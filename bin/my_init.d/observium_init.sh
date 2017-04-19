#!/bin/bash

# == Configuration section

# Queue jobs for later execution while configuration is being sorted out
atd

# Check for `config.php`. If it doesn't exist, use `config.php.default`,
# substituting SQL credentials with observium/"random".

mkdir /opt/observium/lock
FIRST_TIME_LOCKED=/opt/observium/lock/observium-init.locked

if [ ! -f $FIRST_TIME_LOCKED ]
then
  echo "Connecting to Observium database container ..."
  count=0
  rc=1
  while [ $count -lt 12 -a $rc -ne 0 ]
  do
     echo "select 1" | mysql -h $OBSERVIUM_DB_HOST -u $OBSERVIUM_DB_USER --password=$OBSERVIUM_DB_PASS $OBSERVIUM_DB_NAME
     rc=$?
     [ $rc -ne 0 ] && sleep 5
     count=`expr $count + 1`
  done

  if [ $rc -eq 0 ]
  then
     echo "Initializing database schema in first time running for observium ..."
     /opt/observium/discovery.php -u
     /opt/observium/adduser.php $OBSERVIUM_ADMIN_USER $OBSERVIUM_ADMIN_PASS 10
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
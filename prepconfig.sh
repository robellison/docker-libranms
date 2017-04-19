#!/bin/bash
# == Fetch proper Observium version

cp -r /tmp/observium/* /opt/observium/
cd /opt/observium && \
sed -i -e "s/= getenv('OBSERVIUM_DB_HOST');/= '$OBSERVIUM_DB_HOST' ;/g" config.php && \
sed -i -e "s/= getenv('OBSERVIUM_DB_USER');/= '$OBSERVIUM_DB_USER' ;/g" config.php && \
sed -i -e "s/= getenv('OBSERVIUM_DB_PASS');/= '$OBSERVIUM_DB_PASS' ;/g" config.php && \
sed -i -e "s/= getenv('OBSERVIUM_DB_NAME');/= '$OBSERVIUM_DB_NAME' ;/g" config.php
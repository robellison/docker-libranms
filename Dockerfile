# == librenms
#
# The following volumes may be used with their descriptions next to them:
#
#   /opt/librenms/html         : Provided to ease adding plugis (weathermap!)
#   /opt/librenms/logs         : Would be nice to store these somewhere
#                                 non-volatile!
#   /opt/librenms/rrd          : Will consume the most storage.
#
#
FROM ubuntu:16.04
MAINTAINER rob.ellison@bt.com
EXPOSE 8000/tcp
VOLUME ["/config", \
        "/opt/librenms/html", \
        "/opt/librenms/logs", \
        "/opt/librenms/rrd", \
        "/var/run/mysqld/mysqld.sock"]


# === General System

# BT plc./librenms env mostly for reference
ENV WEATHERMAP false
ENV CUSTOM_PHP_INI false
ENV HOUSEKEEPING_ARGS '-yet'
ENV USE_SVN false
ENV SVN_USER ''
ENV SVN_PASS ''
ENV SVN_REPO ''
ENV librenms_RELEASE '1.26'

ARG librenms_ADMIN_USER=admin
ARG librenms_ADMIN_PASS=passw0rd
ARG librenms_DB_HOST=librenmsdb
ARG librenms_DB_USER=librenms
ARG librenms_DB_PASS=passw0rd
ARG librenms_DB_NAME=librenms

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV librenms_DB_HOST=$librenms_DB_HOST
ENV librenms_DB_USER=$librenms_DB_USER
ENV librenms_DB_PASS=$librenms_DB_PASS
ENV librenms_DB_NAME=$librenms_DB_NAME

# Avoid any interactive prompting
ENV DEBIAN_FRONTEND noninteractive

# Language specifics
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8


# Install librenms prereqs
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
      at \
      fping \
      git \
      cron \
      supervisor \
      graphviz \
      graphviz \
      imagemagick \
      ipmitool \
      libvirt-bin \
      mariadb-client \
      mtr-tiny \
      nmap \
      libapache2-mod-php7.0 \
      php7.0-cli \
      php7.0-mysql \
      php7.0-curl \
      php7.0-snmp \
      php7.0-mysqli \
      php7.0-gd \
      php7.0-mcrypt \
      php7.0-json \      
      php-pear \
      php-net-ipv4 \
      php-net-ipv6 \
      pwgen \
      python-mysqldb \
      python-pip \
      rrdcached \
      rrdtool \
      snmp \
      software-properties-common \
      subversion \
      unzip \
      wget \
      whois \
      apache2

RUN pip install --upgrade pip devcron

RUN mkdir -p \
        /config \
        /opt/librenms/html \
        /opt/librenms/lock \
        /var/lib/rrdcached/journal \
        /opt/librenms/logs \
        /opt/librenms/rrd \

# === Webserver - Apache + PHP5

RUN php5enmod mcrypt && \
    a2enmod rewrite

RUN mkdir -p /etc/container_environment/

# Add librenms user

RUN useradd librenms -d /opt/librenms -M -r
RUN usermod -a -G librenms librenms


# Boot-time init scripts for phusion/baseimage
COPY bin/my_init.d /etc/my_init.d/
RUN chmod +x /etc/my_init.d/* && \
    chown -R nobody:users /opt/librenms && \
    chown -R nobody:users /config && \
    chmod 755 -R /opt/librenms && \
    chmod 755 -R /config

# Configure apache2 to serve librenms app
COPY ["conf/apache2.conf", "conf/ports.conf", "/etc/apache2/"]
COPY conf/apache-librenms /etc/apache2/sites-available/000-default.conf
COPY conf/rrdcached /etc/default/rrdcached
RUN rm /etc/apache2/sites-available/default-ssl.conf && \
    echo librenms > /etc/container_environment/APACHE_RUN_USER && \
    echo librenms > /etc/container_environment/APACHE_RUN_GROUP && \
    echo /var/log/apache2 > /etc/container_environment/APACHE_LOG_DIR && \
    echo /var/lock/apache2 > /etc/container_environment/APACHE_LOCK_DIR && \
    echo /var/run/apache2.pid > /etc/container_environment/APACHE_PID_FILE && \
    echo /var/run/apache2 > /etc/container_environment/APACHE_RUN_DIR && \
    chown -R librenms:librenms /var/log/apache2 && \
    rm -Rf /var/www && \
    ln -s /opt/librenms/html /var/www

# === Cron and finishing
COPY cron.d /etc/cron.d/
RUN chmod g-w /etc/cron.d/librenms.nonroot.cron
RUN touch /var/log/cron.log
RUN touch /etc/crontab /etc/cron.d/*

# === phusion/baseimage post-work
# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY download.sh /tmp/download.sh
RUN chmod +x /tmp/download.sh
RUN sh /tmp/download.sh

COPY startapp.sh /opt/startapp.sh
RUN chmod +x /opt/startapp.sh

#COPY devcron.py /opt/devcron.py
#RUN chmod +x /opt/devcron.py

COPY config.php.default /tmp/config.php.default
RUN mkdir -p /opt/librenms/lock

RUN chmod u+s /usr/bin/fping
RUN chmod u+s /usr/bin/fping6

# configure container interfaces
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]

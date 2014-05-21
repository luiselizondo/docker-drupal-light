FROM ubuntu:14.04

Maintainer Luis Elizondo "lelizondo@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# Update system
RUN apt-get update && apt-get dist-upgrade -y

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install PHP
RUN apt-get -y install php5-fpm php5-mysql php-apc php5-imap php5-mcrypt php5-curl php5-cli php5-gd php5-common php-pear curl php5-json

# Install Nginx
RUN apt-get -y install nginx

# Install MySQL
RUN apt-get -y install mysql-client mysql-server

# Install pwgen
RUN apt-get -y install pwgen

# Prevent daemon start during install
RUN	echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# Install Supervisor
RUN apt-get install -y supervisor 
RUN mkdir -p /var/log/supervisor

# Add Nginx file
ADD ./config/default /etc/nginx/sites-available/default

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

###
### Configurations
###

# Add start.sh
ADD ./config/start.sh /start.sh
RUN chmod +x /start.sh

# Supervisor starts everything
ADD	./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure MySQL
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# Configure PHP RPM
RUN sed -i 's/memory_limit = .*/memory_limit = 196M/' /etc/php5/fpm/php.ini

EXPOSE 80
EXPOSE 3306

# Supervisord
CMD ["/start.sh"]
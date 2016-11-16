FROM ubuntu:16.04
MAINTAINER Deepak Sinnamani <skdeepak.nz@gmail.com>

# Install base packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
        curl \
        apache2 \
        libapache2-mod-php7.0 \
        php7.0-mysql \
        php7.0-mcrypt \
        php7.0-gd \
        php7.0-curl \
        php-pear \
        php-apcu

# Clean the apt cache
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

RUN /usr/sbin/phpenmod mcrypt
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php/7.0/apache2/php.ini

ENV ALLOW_OVERRIDE **False**

# Add image configuration and scripts
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html
ADD sample/ /app

RUN usermod -u www-data www-data

# Custom config to handle logs
ADD config/apache.conf /etc/apache2/sites-available/000-default.conf
RUN service apache2 restart

EXPOSE 80
WORKDIR /app
CMD ["/run.sh"]
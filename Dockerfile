# Honeytrap Dockerfile by MO / AV
#
# VERSION 0.6
FROM ubuntu:14.04.1
MAINTAINER MO

# Setup apt
RUN apt-get update -y
RUN apt-get dist-upgrade -y
ENV DEBIAN_FRONTEND noninteractive

# Install packages
RUN apt-get install -y supervisor iptables git build-essential autoconf libnetfilter-queue1 libnetfilter-queue-dev libtool libpq5 libpq-dev

# Install honeytrap from source
RUN cd /root/ && git clone git://git.carnivore.it/honeytrap.git
RUN cd /root/honeytrap/ && autoreconf -fi && ./configure --with-stream-mon=nfq --with-logattacker --prefix=/opt/honeytrap && make && make install 

# Setup user, groups and configs
RUN addgroup --gid 2000 tpot 
RUN adduser --system --no-create-home --shell /bin/bash --uid 2000 --disabled-password --disabled-login --gid 2000 tpot 
RUN mkdir -p /data/honeytrap/log/ /data/honeytrap/attacks/ /data/honeytrap/downloads/
RUN chmod 760 -R /data && chown tpot:tpot -R /data
ADD honeytrap.conf /opt/honeytrap/etc/honeytrap/
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Clean up 
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm -rf /root/honeytrap

# Start honeytrap
CMD ["/usr/bin/supervisord"]

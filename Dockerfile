# Honeytrap Dockerfile by MO / AV
#
# VERSION 16.03.1
FROM ubuntu:14.04.3
MAINTAINER MO

# Setup apt
RUN apt-get update -y
RUN apt-get dist-upgrade -y
ENV DEBIAN_FRONTEND noninteractive

# Install packages
RUN apt-get install -y supervisor iptables git build-essential autoconf libnetfilter-queue1 libnetfilter-queue-dev libtool libpq5 libpq-dev

# Install honeytrap from source
RUN cd /root/ && git clone https://github.com/armedpot/honeytrap
RUN cd /root/honeytrap/ && autoreconf -fi && ./configure --with-stream-mon=nfq --with-logattacker --prefix=/opt/honeytrap && make && make install 

# Setup user, groups and configs
RUN addgroup --gid 2000 tpot 
RUN adduser --system --no-create-home --shell /bin/bash --uid 2000 --disabled-password --disabled-login --gid 2000 tpot 
RUN mkdir -p /data/honeytrap/log/ /data/honeytrap/attacks/ /data/honeytrap/downloads/
RUN chmod 760 -R /data && chown tpot:tpot -R /data
ADD honeytrap.conf /opt/honeytrap/etc/honeytrap/
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup ewsposter
RUN apt-get install -y python-lxml python-mysqldb python-requests
RUN git clone https://github.com/rep/hpfeeds.git /opt/hpfeeds && cd /opt/hpfeeds && python setup.py install && \
git clone https://github.com/armedpot/ewsposter.git /opt/ewsposter
RUN mkdir -p /opt/ewsposter/spool /opt/ewsposter/log

# Clean up 
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm -rf /root/honeytrap

# Start honeytrap
CMD ["/usr/bin/supervisord"]

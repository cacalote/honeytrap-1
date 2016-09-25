# Honeytrap Dockerfile by MO / AV
#
# VERSION 16.10
FROM debian:jessie
MAINTAINER MO

ENV DEBIAN_FRONTEND noninteractive

# Include dist
ADD dist/ /root/dist/

# Setup apt
RUN apt-get update -y && \
    apt-get dist-upgrade -y && \

# Install packages
    apt-get install -y supervisor iptables git build-essential autoconf libnetfilter-queue1 \
                       libnetfilter-queue-dev libjson-c-dev libtool libpq5 libpq-dev && \

# Install honeytrap from source
    cd /root/ && \
    git clone -b json-logging https://github.com/adepasquale/honeytrap && \
    cd /root/honeytrap/ && \
    autoreconf -fi && \
    ./configure --with-stream-mon=nfq --with-logattacker --with-logjson --prefix=/opt/honeytrap && \
    make && make install && make clean && \

# Setup user, groups and configs
    addgroup --gid 2000 tpot && \
    adduser --system --no-create-home --shell /bin/bash --uid 2000 --disabled-password --disabled-login --gid 2000 tpot && \
    mkdir -p /opt/honeytrap/etc/honeytrap/ && \
    mv /root/dist/honeytrap.conf /opt/honeytrap/etc/honeytrap/ && \
    mv /root/dist/supervisord.conf /etc/supervisor/conf.d/supervisord.conf && \

# Setup ewsposter
    apt-get install -y python-lxml python-mysqldb python-requests && \
    git clone https://github.com/rep/hpfeeds.git /opt/hpfeeds && cd /opt/hpfeeds && python setup.py install && \
    git clone https://github.com/armedpot/ewsposter.git /opt/ewsposter && \
    mkdir -p /opt/ewsposter/spool /opt/ewsposter/log && \

# Clean up
    rm -rf /root/* && \
    apt-get purge git build-essential autoconf -y && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Start honeytrap
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]

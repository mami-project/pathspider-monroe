
FROM monroe/base
MAINTAINER Iain R. Learmonth <irl@fsfe.org>

# Set up APT pinning and install dependencies
RUN echo "deb http://ftp.debian.org/debian testing main" >> /etc/apt/sources.list
COPY files/apt.preferences /etc/apt/preferences
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -t testing python3-pycurl python3-libtrace python3-pyroute2 && apt-get clean && rm -rf /var/lib/apt/lists/*
# Install pathspider wrapper
COPY files/multispider /usr/bin
COPY files/ /opt/monroe/
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -t testing python3-setuptools && ( cd /opt/monroe/pathspider ; pwd ; ls ; python3 setup.py install ) && apt-get purge -y python3-setuptools && apt-get clean && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["dumb-init", "--", "/usr/bin/multispider"]

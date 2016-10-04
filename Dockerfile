
FROM monroe/base
MAINTAINER Iain R. Learmonth <irl@fsfe.org>

# Set up APT pinning and install dependencies
RUN echo "deb http://ftp.debian.org/debian testing main" >> /etc/apt/sources.list
COPY files/apt.preferences /etc/apt/preferences
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y apt-transport-https && apt-get clean
RUN gpg --keyserver keyring.debian.org --recv-key 0xA8F7BA5041E133339CBA169676D58093F540ABCD && gpg --export -a 0xA8F7BA5041E133339CBA169676D58093F540ABCD | apt-key add - && echo "deb https://people.debian.org/~irl/experimental unstable/" >> /etc/apt/sources.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -t testing python3-pip python3-libtrace python3-pyroute2 python3-pkg-resources && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -t unstable pathspider && apt-get clean
# Install pathspider wrapper
COPY files/multispider /usr/bin
COPY files/* /opt/monroe/
COPY files/dscpspider.py /usr/lib/python3/dist-packages/pathspider/plugins/dscpspider.py
ENV DSCP 1
RUN cd /opt/monroe

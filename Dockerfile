
FROM monroe/base
MAINTAINER Iain R. Learmonth <irl@fsfe.org>

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https
RUN gpg --keyserver keyring.debian.org --recv-key 0x1F72607C5FF2CCD53F01600D56FF9EA4E9846C49
RUN gpg --export -a 0x1F72607C5FF2CCD53F01600D56FF9EA4E9846C49 | apt-key add -
RUN echo "deb https://people.debian.org/~irl/experimental unstable/" >> /etc/apt/sources.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pathspider

COPY files/* /opt/monroe/

ENTRYPOINT ["dumb-init", "--", "/opt/monroe/run_pathspider.sh"]


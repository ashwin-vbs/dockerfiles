FROM ashwinvbs/xpra:latest

USER root

###################################
### XPRA defines
###################################

ENV DEBIAN_FRONTEND=noninteractive

### Base image upgrades
RUN apt update \
  && apt -y upgrade \
  && apt install -yq --no-install-recommends  ca-certificates  curl  git  gpg-agent  software-properties-common sudo wget \
  && apt clean

RUN { echo && echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" ; } >> /etc/sudoers

### XPRA installation and autostart
RUN wget -q https://xpra.org/gpg.asc -O- | apt-key add -
RUN add-apt-repository -y "deb https://xpra.org/ $(lsb_release --codename --short) main" \
    && apt update \
    && apt -y upgrade \
    && apt install -yq --no-install-recommends xpra xpra-html5 \
    && apt clean

ENV DISPLAY=:42
RUN echo "nohup xpra start --bind-tcp=localhost:10000 $DISPLAY > /dev/null 2>&1" >> /etc/bash.bashrc

EXPOSE 10000

###################################
### Chromium defines
###################################

RUN apt-get -y install --no-install-recommends python-is-python2 python-setuptools \
    && apt clean

### Chromium requirements
RUN curl "https://chromium.googlesource.com/chromium/src/+/master/build/install-build-deps.sh?format=TEXT"| base64 --decode > install-build-deps.sh
RUN mv install-build-deps.sh /root/ \
    && sed -i 's/snapcraft/wget/g' /root/install-build-deps.sh \
    && chmod +x /root/install-build-deps.sh \
    && /root/install-build-deps.sh --no-prompt --no-chromeos-fonts \
    && apt clean

### Depot tools
RUN mkdir -p /opt/depot_tools \
    && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /opt/depot_tools \
    && chmod -R 777 /opt/depot_tools
ENV PATH=$PATH:/opt/depot_tools

USER 1000
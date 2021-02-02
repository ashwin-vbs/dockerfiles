FROM mcr.microsoft.com/vscode/devcontainers/base:focal

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

USER 1000
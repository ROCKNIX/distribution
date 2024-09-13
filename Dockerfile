FROM ubuntu:jammy

ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/usr/bin/bash", "-c"]

RUN apt-get update --fix-missing\
 && apt-get dist-upgrade -y \
 && apt-get install -y locales sudo

RUN locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN adduser --disabled-password --gecos '' docker \
 && adduser docker sudo \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt-get install -y \
    bc default-jre file gawk gcc git golang-go gperf libjson-perl libncurses5-dev \
    libparse-yapp-perl libxml-parser-perl lzop make patchutils python-is-python3  \
    python3 parted unzip wget curl xfonts-utils xsltproc zip zstd rdfind automake \
    xmlstarlet

### Cross compiling on ARM
RUN if [ "$(uname -m)" = "aarch64" ]; then apt-get install -y --no-install-recommends qemu-user-binfmt libc6-dev-amd64-cross; fi
RUN if [ ! -d /lib64 ]; then ln -sf /usr/x86_64-rocknix-linux-gnu/lib64 /lib64; fi
RUN if [ ! -d /lib/x86_64-rocknix-linux-gnu ]; then ln -sf /usr/x86_64-rocknix-linux-gnu/lib /lib/x86_64-rocknix-linux-gnu; fi

RUN mkdir -p /work && chown docker /work

WORKDIR /work
USER docker

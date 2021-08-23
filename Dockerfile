FROM ubuntu:18.04
MAINTAINER Matt Godbolt <matt@godbolt.org>

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update -y -q && apt upgrade -y -q && apt update -y -q && \
    apt install -y -q \
    bison \
    bzip2 \
    curl \
    file \
    flex \
    g++ \
    gcc \
    git \
    libc6-dev-i386 \
    linux-libc-dev \
    make \
    ninja-build \
    patch \
    python \
    subversion \
    texinfo \
    unzip \
    wget \
    xz-utils \
    zlib1g-dev && \
    cd /tmp && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws*


WORKDIR /root

RUN wget https://github.com/Kitware/CMake/releases/download/v3.18.0/cmake-3.18.0-Linux-x86_64.tar.gz && \
    tar xzvf cmake-3.18.0-Linux-x86_64.tar.gz
RUN ln -s /root/cmake-3.18.0-Linux-x86_64/bin/cmake /bin/cmake

RUN mkdir -p /root
COPY build /root/

WORKDIR /root

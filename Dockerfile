FROM ubuntu:18.04
MAINTAINER Matt Godbolt <matt@godbolt.org>

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update -y -q && apt upgrade -y -q && apt update -y -q && \
    apt install -y -q \
    bison \
    bzip2 \
    cmake \
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


RUN mkdir -p /root
COPY build /root/

WORKDIR /root

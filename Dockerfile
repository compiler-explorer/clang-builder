FROM ubuntu:18.04
# NB needs to be an older glibc, as comes with 18.04 in order to build 9.* and earlier.
# otherwise we somehow need to apply 947f9692440836dcb8d88b74b69dd379d85974ce to get the sanitizer
# to build.
# @Endill suggests newer glibcs won't be necessary in any reasonable timeframe after consulting with
# the libc++ folks.
LABEL MAINTAINER Matt Godbolt <matt@godbolt.org>

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
    python3 \
    python3-dev \
    subversion \
    texinfo \
    unzip \
    wget \
    xz-utils \
    zlib1g-dev


WORKDIR /root

RUN curl -sL https://github.com/Kitware/CMake/releases/download/v3.26.3/cmake-3.26.3-Linux-x86_64.tar.gz \
    | tar zxvf - -C /usr --strip-components=1

# Workaround for older clangs that expect xlocale.h
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

RUN mkdir -p /root
COPY build /root/

WORKDIR /root

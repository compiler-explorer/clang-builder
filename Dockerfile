FROM ubuntu:18.04
MAINTAINER Matt Godbolt <matt@godbolt.org>

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update -y -q && apt install -y -q software-properties-common && \
    add-apt-repository ppa:git-core/ppa -y && \
    apt update -y -q && apt upgrade -y -q && \
    apt install -y -q \
    bison \
    bzip2 \
    curl \
    file \
    flex \
    g++ \
    gcc \
    git \
    jq \
    libc6-dev-i386 \
    linux-libc-dev \
    make \
    ninja-build \
    patch \
    pv \
    python \
    python3 \
    subversion \
    time \
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
RUN mkdir -p /opt

RUN curl -sL https://github.com/Kitware/CMake/releases/download/v3.18.0/cmake-3.18.0-Linux-x86_64.tar.gz | tar zxf -  -C /opt && \
    ln -s /opt/cmake-3.18.0-Linux-x86_64/bin/* /bin/

RUN curl -sL https://github.com/elfshaker/elfshaker/releases/download/v0.9.0/elfshaker_v0.9.0_x86_64-unknown-linux-musl.tar.gz | tar zxf - && \
    mv elfshaker/elfshaker /bin/ && rm -rf elfshaker

RUN mkdir -p /opt/compiler-explorer && \
    curl -sL https://s3.amazonaws.com/compiler-explorer/opt/clang-12.0.1.tar.xz | tar Jxf - -C /opt && \
    ln -s /opt/clang-12.0.1/bin/clang /bin/clang-12 && \
    ln -s /opt/clang-12.0.1/bin/clang++ /bin/clang++-12

RUN git clone -n https://github.com/olsner/jobclient && \
    cd jobclient && git checkout dfee24346304711f015d321e4e4d6df806549b0e && make -j$(nproc) && mv jobserver /bin && cd .. && rm -rf jobclient

RUN curl -sL https://go.dev/dl/go1.18.2.linux-amd64.tar.gz | tar zxf - -C /opt && \
    ln -sf /opt/go/bin/go /bin

RUN git clone -n https://github.com/stefanb2/ninja.git && cd ninja && \
    git checkout f404f0059d71c8c86da7b56c48794266b5befd10 && \
    cmake . && cmake --build . --parallel $(nproc) && cp ./ninja /usr/local/bin/ninja-jobclient && cd .. && rm -rf ninja

RUN mkdir -p /root
COPY build /root/

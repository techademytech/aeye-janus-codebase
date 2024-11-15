FROM ubuntu:20.04

LABEL maintainer="Abhishek Khanna"
LABEL description="Provides an image with Janus Gateway"

ENV TZ=Asia/Indian
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update
RUN apt install -y tzdata

RUN apt-get update -y \
    && apt-get upgrade -y

RUN apt-get install -y \
    git \
    libmicrohttpd-dev \
    libjansson-dev \
    libssl-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    libopus-dev \
    libogg-dev \
    libcurl4-openssl-dev \
    liblua5.3-dev \
    libconfig-dev \
    pkg-config \
    gengetopt \
    libtool \
    gtk-doc-tools \
    automake \
    wget \
    doxygen \
    graphviz \
    pip \
    sudo

RUN pip3 install meson
RUN apt-get install build-essential libssl-dev

RUN pip install meson ninja \
    && cd ~ \
    && git clone https://gitlab.freedesktop.org/libnice/libnice \
    && cd libnice \
    && meson --prefix=/usr build && ninja -C build && sudo ninja -C build install



RUN cd ~ \
    && wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz \
    && tar xfv v2.2.0.tar.gz \
    && cd libsrtp-2.2.0 \
    && ./configure --prefix=/usr --enable-openssl \
    && make shared_library \
    && sudo make install


RUN cd ~ \
    && git clone https://github.com/sctplab/usrsctp \
    && cd usrsctp \
    && ./bootstrap \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install

RUN apt-get update -y
RUN apt-get install -y ninja-build -y
RUN apt-get install python3 python3-pip -y


RUN cd /tmp \
    && wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1.tar.gz \
    && tar -zxvf cmake-3.22.1.tar.gz \
    && cd cmake-3.22.1 \
    && ./bootstrap \
    && make \
    && sudo make install

RUN apt-get update -y
RUN apt install software-properties-common -y

RUN add-apt-repository ppa:deadsnakes/ppa 



RUN cd ~ \
    && git clone https://libwebsockets.org/repo/libwebsockets \
    && cd libwebsockets \
    && git checkout v4.3-stable \
    && mkdir build \
    && cd build \
    && cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
    && make \
    && sudo make install


RUN cd ~ \
    && git clone https://github.com/eclipse/paho.mqtt.c.git \
    && cd paho.mqtt.c \
    && prefix=/usr \
    && make \
    && sudo make install


RUN apt-get update -y
RUN apt-get install -y libnanomsg-dev


RUN cd ~ \
    && git clone https://github.com/alanxz/rabbitmq-c \
    && cd rabbitmq-c \
    && git submodule init \
    && git submodule update \
    && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr .. \
    && make && sudo make install

RUN cd ~ \
    && git clone https://github.com/IIHT-Proctoring/janus-code-base.git \
    && cd janus-code-base/ \
    && git checkout nov-master-stable-14 \
    && cd janus-gateway-1/ \
    && sh autogen.sh \
    && ./configure --prefix=/opt/janus --enable-mqtt --disable-docs \
    && make CFLAGS='-std=c99' \
    && sudo make install \
    && sudo make configs



CMD /opt/janus/bin/janus --debug-level 4

EXPOSE 80 7088 8088 8188 8089
EXPOSE 10000-10200/udp
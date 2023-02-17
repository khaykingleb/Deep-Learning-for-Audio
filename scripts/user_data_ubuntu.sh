#!/bin/bash

sudo file -s /dev/xvdb \
&& sudo mkfs -t ext4 /dev/xvdb \
&& sudo mkdir data \
&& sudo mount /dev/xvdb data

sudo apt -y update \
&& sudo apt -y upgrade \
&& sudo apt -y dist-upgrade \
&& sudo apt -y install build-essential \
                       python-dev \
                       python-setuptools \
                       python-pip \
                       python-smbus \
                       libncursesw5-dev \
                       libgdbm-dev \
                       libc6-dev \
                       zlib1g-dev \
                       libsqlite3-dev \
                       tk-dev \
                       libssl-dev \
                       openssl \
                       openssl11-devel \
                       libffi-dev \
                       liblzma-dev \
                       lzma \
                       libbz2-dev\
                       bzip2-devel \
                       libffi-devel \
                       git \
                       wget \

wget https://www.python.org/ftp/python/3.10.4/Python-3.10.4.tgz \
&& tar -xf Python-3.10.4.tgz \
&& cd Python-3.10.4 \
&& ./configure \
&& make -j $(nproc) \
&& sudo make altinstall \
&& cd .. \
&& rm Python-3.10.4.tgz

cd data \
&& git clone https://github.com/khaykingleb/Deep-Learning-for-Audio.git \
&& cd Deep-Learning-for-Audio \
&& pip3 install poetry \
&& poetry install --only main

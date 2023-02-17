#!/bin/bash

sudo file -s /dev/xvdb \
&& sudo mkfs -t ext4 /dev/xvdb \
&& sudo mkdir data \
&& sudo mount /dev/xvdb data

sudo yum -y update \
&& sudo yum -y groupinstall "Development Tools" \
&& sudo yum -y install openssl11 \
                       openssl11-devel \
                       libffi-devel \
                       bzip2-devel \
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

#!/usr/bin/env bash

set -e # exit on error
set -x # echo commands

JOBS=$((`nproc`+1))

if [ -n "${CONTINUOUS_INTEGRATION}" ]; then 
    export WORKDIR=/tmp
    cd ${WORKDIR}
else
    export WORKDIR=${PWD}
fi

apt-get update && apt-get install -y software-properties-common
add-apt-repository ppa:gnuradio/gnuradio-releases
apt update
apt install -y gnuradio gnuradio-dev libxml2 libxml2-dev bison flex cmake git libaio-dev libboost-all-dev swig

# Download and build libiio
git clone https://github.com/analogdevicesinc/libiio.git
cd libiio
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DPYTHON_BINDINGS=ON ..
make -j${JOBS}
make install
cd ${WORKDIR}

# Download and build libad9361-iio
git clone https://github.com/analogdevicesinc/libad9361-iio.git
cd libad9361-iio
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ..
make -j${JOBS}
make install
cd ${WORKDIR}

# Download and build gr-iio
git clone https://github.com/analogdevicesinc/gr-iio.git
cd gr-iio
git checkout upgrade-3.8
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ..
make -j${JOBS}
make install
cd ${WORKDIR}
ldconfig

# cleanup temporary files to reduce image size
cd /tmp
rm -rf ./*
apt autoclean
rm -rf /var/lib/apt/lists/*
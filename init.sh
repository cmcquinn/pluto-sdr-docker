#!/usr/bin/env bash

set -e # exit on error
set -x # echo commands

JOBS=$((`nproc`+1))

export WORKDIR=/tmp
cd ${WORKDIR}

apt-get update

# Install GNU Radio and other dependencies
apt-get -y install gnuradio-dev libxml2 libxml2-dev bison flex cmake git libaio-dev libboost-all-dev swig

# Download and build libiio
git clone https://github.com/analogdevicesinc/libiio.git
cd libiio
mkdir build
cd build
cmake ..
make -j${JOBS}
make install
cd ${WORKDIR}

# Download and build libad9361-iio
git clone https://github.com/analogdevicesinc/libad9361-iio.git
cd libad9361-iio
mkdir build
cd build
cmake ..
make -j${JOBS}
make install
cd ${WORKDIR}

# Download and build gr-iio
git clone https://github.com/analogdevicesinc/gr-iio.git
cd gr-iio
mkdir build
cd build
cmake ..
make -j${JOBS}
make install
cd ${WORKDIR}
ldconfig

# Dependencies for GNSS-SDR
apt-get install -y build-essential cmake git pkg-config libboost-dev \
   libboost-date-time-dev libboost-system-dev libboost-filesystem-dev \
   libboost-thread-dev libboost-chrono-dev libboost-serialization-dev \
   libboost-program-options-dev libboost-test-dev liblog4cpp5-dev \
   libuhd-dev gnuradio-dev gr-osmosdr libblas-dev liblapack-dev \
   libarmadillo-dev libgflags-dev libgoogle-glog-dev libhdf5-dev \
   libgnutls-openssl-dev libmatio-dev libpugixml-dev libpcap-dev \
   libprotobuf-dev protobuf-compiler libgtest-dev googletest \
   python3-mako python3-six

# Build and install GNSS-SDR
git clone https://github.com/gnss-sdr/gnss-sdr
cd gnss-sdr/build
git checkout next
cmake ..
make -j${JOBS}
make install

# cleanup temporary files to reduce image size
cd /tmp
rm -rf ./*
apt autoclean
rm -rf /var/lib/apt/lists/*
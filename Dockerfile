FROM ubuntu:bionic
LABEL maintainer="cameron.mcquinn@gmail.com"

WORKDIR /tmp
# set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive
#install tzdata package
RUN apt-get update \
    && apt-get install -y tzdata
# set your timezone
RUN ln -fs /usr/share/zoneinfo/America/Denver /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:gnuradio/gnuradio-releases
RUN apt update && apt install -y gnuradio gnuradio-dev libxml2 libxml2-dev bison flex cmake git libaio-dev libboost-all-dev swig

# Download and build libiio
RUN git clone https://github.com/analogdevicesinc/libiio.git
WORKDIR /tmp/libiio
RUN mkdir build
WORKDIR /tmp/libiio/build

RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DPYTHON_BINDINGS=ON ..
RUN make -j${JOBS} \
    && make install
WORKDIR /tmp

# Download and build libad9361-iio
RUN git clone https://github.com/analogdevicesinc/libad9361-iio.git
WORKDIR  libad9361-iio
RUN mkdir build
WORKDIR /tmp/libad9361-iio/build
RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ..
RUN make -j${JOBS} \
    && make install
WORKDIR /tmp

# Download and build gr-iio
RUN git clone https://github.com/analogdevicesinc/gr-iio.git
WORKDIR /tmp/gr-iio
RUN git checkout upgrade-3.8
RUN mkdir build
WORKDIR /tmp/gr-iio/build
RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ..
RUN make -j${JOBS} \
    && make install
RUN ldconfig

# Install packages to expose GTK+ libs to python3
RUN apt install -y python3-gi gobject-introspection gir1.2-gtk-3.0

# Suppress a warning from dbind
ENV NO_AT_BRIDGE=1 

# Generate machine id
RUN dbus-uuidgen > /var/lib/dbus/machine-id

RUN apt-get clean
CMD ["/usr/bin/gnuradio-companion"]
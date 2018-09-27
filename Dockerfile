From ubuntu:latest

env http_proxy http://10.35.255.65:8080
env https_proxy http://10.35.255.65:10443

# http://sublimerobots.com/2018/06/installing-snort-3-b245-in-ubuntu/
ARG build_deps="wget liblzma-dev openssl libssl-dev cpputest libsqlite3-dev uuid-dev libtool git autoconf cmake build-essential autotools-dev libdumbnet-dev libluajit-5.1-dev libpcap-dev libpcre3-dev zlib1g-dev pkg-config libhwloc-dev"
ARG runtime_deps="python bison flex"

RUN apt-get update && \
    apt-get install -y $runtime_deps $build_deps

# install optionals  safec, gperftools, Hyperscan
RUN mkdir ~/snort_src && \
cd ~/snort_src && \
wget http://downloads.sourceforge.net/project/safeclib/libsafec-10052013.tar.gz && \
tar -xzvf libsafec-10052013.tar.gz && \
cd libsafec-10052013 && \
./configure && \
make && \
make install

RUN cd ~/snort_src && \
wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.7/gperftools-2.7.tar.gz && \
tar xzvf gperftools-2.7.tar.gz && \
cd gperftools-2.7 && \
./configure && \
make && \
make install

RUN cd ~/snort_src && \
wget http://www.colm.net/files/ragel/ragel-6.10.tar.gz && \
tar -xzvf ragel-6.10.tar.gz && \
cd ragel-6.10 && \
./configure && \
make && \
make install

RUN cd ~/snort_src && \
wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz && \
tar -xvzf boost_1_67_0.tar.gz

RUN cd ~/snort_src && \
wget https://github.com/intel/hyperscan/archive/v4.7.0.tar.gz && \
tar -xvzf v4.7.0.tar.gz && \
cd hyperscan-4.7.0/ && \
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DBOOST_ROOT=~/snort_src/boost_1_67_0/ ../hyperscan-4.7.0 && \
make && \
make install

RUN cd ~/snort_src && \
cd hyperscan-4.7.0/ && \
./bin/unit-hyperscan

RUN cd ~/snort_src && \
wget https://github.com/google/flatbuffers/archive/v1.9.0.tar.gz -O flatbuffers-v1.9.0.tar.gz && \
tar -xzvf flatbuffers-v1.9.0.tar.gz && \
mkdir flatbuffers-build && \
cd flatbuffers-build && \
cmake ../flatbuffers-1.9.0 && \
make && \
make install

RUN cd ~/snort_src && \
wget https://www.snort.org/downloads/snortplus/daq-2.2.2.tar.gz && \
tar -xvzf daq-2.2.2.tar.gz && \
cd daq-2.2.2 && \
./configure && \
make && \
make install && \
ldconfig

# install snort3
RUN git clone git://github.com/snortadmin/snort3.git && \
cd snort3 && \
./configure_cmake.sh --prefix=/usr/local && \
cd build && \
make && \
make install

RUN   apt-get remove -y $build_deps && \
 apt-get autoclean -y && apt-get clean -y
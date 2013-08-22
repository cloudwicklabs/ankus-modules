#!/bin/bash
name=libzmq1
arch=`arch` # Change to your architecture
version=2.1.7
url='http://www.zeromq.org/'
package="http://download.zeromq.org/zeromq-${version}.tar.gz"
buildroot=build
fakeroot=libzmq1
origdir=$(pwd)
prefix="/usr"
description='The 0MQ lightweight messaging kernel is a library which extends the
    standard socket interfaces with features traditionally provided by
    specialised messaging middleware products. 0MQ sockets provide an
    abstraction of asynchronous message queues, multiple messaging
    patterns, message filtering (subscriptions), seamless access to
    multiple transport protocols and more.
    .
    This package contains the ZeroMQ shared library.'

# install dependencies
yum install -y uuid-devel autoconf automake gcc gcc-c++ kernel-devel libtool libuuid-devel wget

# fpmd deps
# yum install ruby ruby-devel ruby-ri ruby-rdoc rubygems rpm-build
# gem install fpm --no-ri --no-rdoc

#_ MAIN _#
rm -rf ${name}*.rpm
#_ MAKE DIRECTORIES _#
rm -rf ${fakeroot}
mkdir -p ${fakeroot}
rm -rf ${buildroot}
mkdir -p ${buildroot}
#_ DOWNLOAD & COMPILE _#
cd ${fakeroot}
wget ${package}
tar -zxvf *.gz
cd zeromq-${version}/
./configure --prefix=${prefix}
make
make install DESTDIR=${origdir}/${buildroot}

#_ MAKE RPM _#
cd ${origdir}/${buildroot}
fpm -t rpm -n ${name} \
  -v ${version} \
  --description "${description}" \
  --url="${url}" \
  -a ${arch} \
  --prefix=/ \
  -d 'glibc-devel'  -d 'libgcc'  -d 'libstdc++'  -d 'libuuid' \
  -s dir -- .
mv ${origdir}/${buildroot}/*.rpm ${origdir}
cd ${origdir}
#!/bin/bash
name=libjzmq
arch=`arch` # Change to your architecture
version=2.1.7
url='https://github.com/nathanmarz/jzmq.git'
buildroot=build
fakeroot=jzmq
origdir=$(pwd)
prefix="/usr"
description='JZMQ is the Java bindings for ZeroMQ'
# Make sure JAVA_HOME is set. Uncomment if necessary
export JAVA_HOME=/opt/java/jdk1.6.0_31

yum -y install git

#_ MAIN _#
rm -rf ${name}*.rpm
rm -rf jzmq
rm -rf ${buildroot}
mkdir -p ${buildroot}
git clone ${url}
cd jzmq
./autogen.sh
./configure --prefix=${prefix}
# Something in the Makefile doesn't work right with
# Ubuntu Precise.  See:
# https://github.com/zeromq/jzmq/issues/114#issuecomment-6927797
touch src/classdist_noinst.stamp
cd src/
CLASSPATH=.:./.:$CLASSPATH
$JAVA_HOME/bin/javac -d . org/zeromq/ZMQ.java org/zeromq/App.java org/zeromq/ZMQForwarder.java org/zeromq/EmbeddedLibraryTools.java org/zeromq/ZMQQueue.java org/zeromq/ZMQStreamer.java org/zeromq/ZMQException.java
cd ..
make
make install DESTDIR=${origdir}/${buildroot}

#_ MAKE DEBIAN _#
cd ${origdir}/${buildroot}
fpm -t rpm -n ${name} -v ${version} --description "${description}" --url="${url}" -a ${arch} --prefix=/ -d "libzmq1 >= 2.1.7" -s dir -- .
mv ${origdir}/${buildroot}/*.rpm ${origdir}
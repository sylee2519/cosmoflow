#!/bin/bash
mkdir install
installdir=`pwd`/install

wget https://github.com/libarchive/libarchive/releases/download/v3.5.1/libarchive-3.5.1.tar.gz
tar -zxf libarchive-3.5.1.tar.gz
cd libarchive-3.5.1
  ./configure --prefix=$installdir
  make install
cd ..

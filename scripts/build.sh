#!/bin/sh
# BASED ON: https://stackoverflow.com/questions/42721210/build-static-sox-with-lame-and-flac-support-for-aws-lambda#42796058

set -ex

cd $BUILD_DIR

# now grab sox and its dependencies
mkdir -p unpacked
mkdir -p sox-build
wget -O sox-14.4.2.tar.bz2 "http://downloads.sourceforge.net/project/sox/sox/14.4.2/sox-14.4.2.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fsox%2Ffiles%2Fsox%2F14.4.2%2F&ts=1416316415&use_mirror=heanet"
wget -O libmad-0.15.1b.tar.gz "http://downloads.sourceforge.net/project/mad/libmad/0.15.1b/libmad-0.15.1b.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fmad%2Ffiles%2Flibmad%2F0.15.1b%2F&ts=1416316482&use_mirror=heanet"
wget -O lame-3.99.5.tar.gz "http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flame%2Ffiles%2Flame%2F3.99%2F&ts=1416316457&use_mirror=kent"
wget -O libogg-1.3.4.tar.gz "http://downloads.xiph.org/releases/ogg/libogg-1.3.4.tar.gz"
wget -O libvorbis-1.3.5.tar.xz "http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.xz"
wget -O flac-1.3.2.tar.xz "https://ufpr.dl.sourceforge.net/project/flac/flac-src/flac-1.3.2.tar.xz"

# unpack the dependencie
pushd unpacked
tar xvfp ../sox-14.4.2.tar.bz2
tar xvfp ../libmad-0.15.1b.tar.gz
tar xvfp ../lame-3.99.5.tar.gz
tar xvfp ../libogg-1.3.4.tar.gz
tar xvfp ../libvorbis-1.3.5.tar.xz
tar xvfp ../flac-1.3.2.tar.xz
popd

# build libmad, statically
pushd unpacked/libmad-0.15.1b
./configure --disable-shared --enable-static --prefix=/usr --libdir=/usr/lib64
# Patch makefile to remove -fforce-mem
sed s/-fforce-mem//g < Makefile > Makefile.patched
cp Makefile.patched Makefile
make
make install
popd

# build lame, statically
pushd unpacked/lame-3.99.5
./configure --disable-shared --enable-static --prefix=/usr --libdir=/usr/lib64
make
make install
popd

# Build libogg, statically
pushd unpacked/libogg-1.3.4
./configure --disable-shared --prefix=/usr --libdir=/usr/lib64
make
make install
popd

# build libvorbis, statically
pushd unpacked/libvorbis-1.3.5
./configure --disable-shared --enable-static --prefix=/usr --libdir=/usr/lib64
make
make install
popd

# build flac, statically
pushd unpacked/flac-1.3.2
./configure --disable-shared --enable-static --prefix=/usr --libdir=/usr/lib64 --with-ogg
make
make install
popd

# build sox, statically
pushd unpacked/sox-14.4.2
./configure --disable-shared --enable-static --prefix=$(realpath ../../sox-build) --libdir=/usr/lib64 \
    --with-mad --with-lame --with-oggvorbis --with-flac --without-oss --without-sndfile
make -s
make install
popd

ls sox-build/bin
cp -r sox-build/bin -t .

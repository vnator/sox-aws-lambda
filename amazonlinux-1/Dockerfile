FROM amazonlinux:1
RUN yum -y update
RUN yum -y install make cmake autogen automake libtool gcc gcc-c++ \
  wget git tar gzip zip xz which \
  zlib-static libpng-static boost-static \
  libcurl-devel bzip2-devel boost-devel python-devel gd-devel

RUN yum -y install bzip2

ARG BUILD_DIR=/build
ARG SCRIPTS_DIR=/scripts

ENV BUILD_DIR=$BUILD_DIR
ENV SCRIPTS_DIR=$SCRIPTS_DIR

RUN mkdir $BUILD_DIR && mkdir $SCRIPTS_DIR

WORKDIR /root

CMD $SCRIPTS_DIR/build.sh

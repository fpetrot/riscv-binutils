# vim: tw=0: ai: sw=2: ts=2: sts=2: lbr: et: list

FROM debian:bookworm-slim

LABEL maintainer="Frédéric Pétrot <frederic.petrot@univ-grenoble-alpes.fr>"
LABEL Description="Image to (cross-)build the binutils in maintainer mode"

#
# Set environment
#
# Compile stuff in /root/src,
# install non packaged dependencies in /opt/tools,
# and do the rest as user fred
ENV ROOTSRCS=/root/src
ENV INSTPATH=/opt/tools
ENV USER=fred

#
# Dependencies
#
RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
            build-essential bison flex \
            libmpfr-dev libgmp-dev libexpat1-dev libdebuginfod-dev \
            ca-certificates git curl xsltproc babeltrace \
            file texinfo gperf expect vim vim-gitgutter openssh-client && \
    apt-get autoclean && \
    mkdir -p $INSTPATH $ROOTSRCS

#
# According to binutils README-maintainer-mode, we need
# autoconf 2.69
# automake 1.15.1
# libtool 2.2.6
# gettext 0.16.1
# dejagnu 1.5.3
# All from https://ftp.gnu.org/gnu/
#

WORKDIR $ROOTSRCS

RUN curl --remote-name-all \
         https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz \
         https://ftp.gnu.org/gnu/automake/automake-1.15.1.tar.xz \
         https://ftp.gnu.org/gnu/libtool/libtool-2.2.6b.tar.lzma \
         https://ftp.gnu.org/gnu/gettext/gettext-0.16.1.tar.gz \
         https://ftp.gnu.org/gnu/dejagnu/dejagnu-1.5.3.tar.gz

RUN tar xf autoconf-2.69.tar.xz && \
    tar xf automake-1.15.1.tar.xz && \
    tar xf libtool-2.2.6b.tar.lzma && \
    tar xf gettext-0.16.1.tar.gz && \
    tar xf dejagnu-1.5.3.tar.gz

ENV PATH=$INSTPATH/bin:$PATH

RUN cd autoconf-2.69 && \
    ./configure --prefix=$INSTPATH && \
    make -j $(nproc) && make install && \
    cd ../automake-1.15.1 && \
    ./configure --prefix=$INSTPATH && \
    make -j $(nproc) && make install && \
    cd ../libtool-2.2.6b && \
    ./configure --prefix=$INSTPATH && \
    make -j $(nproc) && make install && \
    cd ../gettext-0.16.1 && \
    ./configure --prefix=$INSTPATH && \
    make -j $(nproc) && make install && \
    cd ../dejagnu-1.5.3 && \
    ./configure --prefix=$INSTPATH && \
    make -j $(nproc) && make install

#
# Create a user so that development and installation
# takes place in a non-root environment
#
RUN useradd -ms /bin/bash $USER
USER $USER
ENV HOMEDIR /home/$USER
WORKDIR $HOMEDIR

#
# Give access for external ssh key so that the docker image can be shared
# while being able to use git with ssh
# FIMXE: I could not have that work, back onto https then
#RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
#RUN --mount=type=ssh ssh -A -v -l git github.com

#
# Fetch the binutils sources
#
RUN git clone --origin origin https://github.com/fpetrot/riscv-binutils.git
#
# Configure them so as to run in 128-bit, local install path
# Removing the -O2 flags helps avoid run-time errors, ...
# To be fixed at some point, live with it for now
#
RUN cd riscv-binutils && \
    git checkout 128up && \
    mkdir build-128up && \
    cd build-128up && \
    CFLAGS=-g ../configure --prefix=$HOMEDIR/sandbox --enable-maintainer-mode \
                 --target=riscv128-unknown-elf
#
# Compile them
# cxx is a killer when all procs are used, so let leave some space
#
RUN cd riscv-binutils/build-128up && \
    make -j $((1 + $(nproc) / 2)) && make install
#
# Add upstream repo for rebasing regularly
#
RUN cd riscv-binutils && \
    git remote add upstream https://sourceware.org/git/binutils-gdb.git

USER root
RUN apt-get install -y --no-install-recommends --no-install-suggests \
            python3-minimal meson ninja-build pkgconf libglib2.0-dev \
            libpixman-1-dev libcapstone-dev
USER $USER
#
# Fetch QEMU
#
RUN git clone --origin origin https://github.com/fpetrot/qemu-riscv128.git
#
# Configure for 128-bit, local install path
#
RUN cd qemu-riscv128 && \
    git checkout elf128 && \
    mkdir build-elf128 && \
    cd build-elf128 && \
    ../configure --prefix=$HOMEDIR/sandbox --target-list=riscv64-softmmu \
                 --enable-debug --enable-capstone
#
# Compile it
#
RUN cd qemu-riscv128/build-elf128 && \
    ninja && ninja install

#
# Add upstream repo for rebasing regularly
#
RUN cd qemu-riscv128 && \
    git remote add upstream https://github.com/qemu/qemu

#
# Finally fetch the existing 128-bit tests, as examples
#
RUN git clone --origin origin https://github.com/fpetrot/128-test.git

#
# We unfortunately need to debug our stuff, so let us install gdb
#
USER root
RUN apt-get install -y --no-install-recommends --no-install-suggests \
            gdb
USER $USER

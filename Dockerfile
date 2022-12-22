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
            file texinfo gperf expect vim vim-gitgutter && \
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
# Fetch the binutils sources
#
RUN git clone --origin upstream https://sourceware.org/git/binutils-gdb.git
#
# Configure them, local install path
#
RUN cd binutils-gdb && \
    mkdir build && \
    cd build && \
    ../configure --prefix=$HOMEDIR/sandbox --enable-maintainer-mode \
                 --target=riscv64-linux-gnu --with-arch=rv64imafdc --with-abi=lp64d
#
# Compile them
#
RUN cd binutils-gdb/build && \
    make -j $(nproc) && make install

# && \ rm -r /src/riscv-gnu-toolchain

# Expose port to connect GDB and Qemu
#EXPOSE 1234

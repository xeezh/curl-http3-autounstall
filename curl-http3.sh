#!/bin/bash
sudo apt update
sudo apt install libtool-bin
sudo apt install libpsl-dev
sudo apt install autoconf

echo "Input libs installation directory absolute path: "
read prefix

cd $prefix
mkdir temp
cd temp

git clone https://github.com/wolfSSL/wolfssl.git
cd wolfssl
autoreconf -fi
./configure --prefix=$prefix/wolfssl --enable-quic --enable-session-ticket --enable-earlydata --enable-psk --enable-harden --enable-altcertchains
make
make install

cd ..
git clone -b v1.1.0 https://github.com/ngtcp2/nghttp3
cd nghttp3
git submodule update --init
autoreconf -fi
./configure --prefix=$prefix/nghttp3 --enable-lib-only
make
make install

cd ..
git clone -b v1.2.0 https://github.com/ngtcp2/ngtcp2
cd ngtcp2
autoreconf -fi
./configure PKG_CONFIG_PATH=$prefix/wolfssl/lib/pkgconfig:$prefix/nghttp3/lib/pkgconfig LDFLAGS="-Wl,-rpath,$prefix/nghttp3/lib" --prefix=$prefix/ngtcp2 --enable-lib-only --with-wolfssl
make
make install

cd ..
git clone https://github.com/curl/curl
cd curl
autoreconf -fi
./configure --with-wolfssl=$prefix/wolfssl --with-nghttp3=$prefix/nghttp3 --with-ngtcp2=$prefix/ngtcp2
make
make install

sudo ldconfig

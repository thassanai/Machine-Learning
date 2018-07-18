#!/usr/bin/env bash
#
# nginx_ssl_transparency.sh
# Script for compile nginx with nginx_ct and others.
# By Thassanai Mhuansean
# E-mail: thassanai.mh@gmail.com
#

# names of latest versions of each package
export NGINX_VERSION=1.15.1
export VERSION_PCRE=pcre-8.42
export VERSION_NGINX=nginx-$NGINX_VERSION
export HEADERMOD_VER=0.33
export OPENSSL_VER=1.0.2o
export ZLIB=1.2.11

 
# URLs to the source directories
#export SOURCE_LIBRESSL=http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/
export SOURCE_PCRE=https://ftp.pcre.org/pub/pcre/
export SOURCE_NGINX=http://nginx.org/download/
export SOURCE_NGINX_HEAD=https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERMOD_VER}.tar.gz
export SOURCE_OPENSSL=https://www.openssl.org/source/openssl-${OPENSSL_VER}.tar.gz
export SOURCE_ZLIB=https://www.zlib.net/zlib-${ZLIB}.tar.gz

# clean out any files from previous runs of this script
rm -rf build
mkdir build

# proc for building faster
NB_PROC=$(grep -c ^processor /proc/cpuinfo)
 
# ensure that we have the required software to compile our own nginx
sudo apt-get -y install curl wget build-essential libgd-dev libgeoip-dev checkinstall git
sudo apt-get -y install golang cmake
sudo apt-get -y install build-essential libpcre3 libpcre3-dev zlib1g-dev
sudo apt-get -y install libtexluajit2 libtexluajit-dev

# grab the source files
echo "Download sources"
wget -P ./build $SOURCE_PCRE$VERSION_PCRE.tar.gz
wget -P ./build $SOURCE_NGINX$VERSION_NGINX.tar.gz
wget -P ./build $SOURCE_NGINX_HEAD
wget -P ./build $SOURCE_OPENSSL
wget -P ./build $SOURCE_ZLIB

# expand the source files
echo "Extract Packages"
cd build
tar xzf $VERSION_NGINX.tar.gz
tar xzf $VERSION_PCRE.tar.gz
tar xzf v${HEADERMOD_VER}.tar.gz
tar xzf openssl-${OPENSSL_VER}.tar.gz
tar xzf zlib-${ZLIB}.tar.gz

cd ../
# set where nginx will be built
export BPATH=$(pwd)/build

# Brotti, Better compression than gzip.
cd $BPATH
git clone https://github.com/google/ngx_brotli.git
cd $BPATH/ngx_brotli
git submodule update --init

# NGINX_CT
cd $BPATH
git clone https://github.com/grahamedgecombe/nginx-ct --depth=1

cd $BPATH
# build static OPENSSL
echo "Configure & Build OPENSSL"
cd $BPATH/openssl-${OPENSSL_VER}
wget https://raw.githubusercontent.com/cloudflare/sslconfig/master/patches/openssl__chacha20_poly1305_draft_and_rfc_ossl102j.patch -O chacha.patch
patch -p1 < chacha.patch

./config --prefix=/usr --openssldir=/usr/lib/ssl --libdir=/usr/lib/x86_64-linux-gnu enable-weak-ssl-ciphers
make -j $NB_PROC
make install

# build nginx, with various modules included/excluded
echo "Configure & Build Nginx"
cd $BPATH/$VERSION_NGINX
echo "Download and apply path"
wget https://raw.githubusercontent.com/cloudflare/sslconfig/master/patches/nginx__1.13.0_http2_spdy.patch -O spdy.patch
patch -p1 < spdy.patch

##echo "TLS patch"
wget https://raw.githubusercontent.com/cloudflare/sslconfig/master/patches/nginx__1.11.5_dynamic_tls_records.patch -O tcp-tls.patch
patch -p1 < tcp-tls.patch

./configure --prefix=/etc/nginx \
--with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' \
--with-cc-opt="-D FD_SETSIZE=2048" \
--with-ld-opt="-Wl,-rpath,/usr/local/lib" \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/lib/nginx/body \
--http-proxy-temp-path=/var/lib/nginx/proxy \
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
--http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
--http-scgi-temp-path=/var/lib/nginx/scgi \
--user=nginx \
--group=nginx \
--with-cpu-opt=amd64 \
--with-ld-opt="-lrt"  \
--with-openssl=/usr/src/build/openssl-${OPENSSL_VER} \
--with-openssl-opt=enable-weak-ssl-ciphers \
--with-openssl-opt=enable-ec_nistp_64_gcc_128 \
--with-pcre=$BPATH/$VERSION_PCRE \
--with-zlib=$BPATH/zlib-${ZLIB} \
--with-compat \
--with-http_ssl_module \
--with-http_spdy_module \
--with-http_v2_module \
--with-file-aio \
--with-google_perftools_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_stub_status_module \
--with-http_image_filter_module=dynamic \
--without-mail_pop3_module \
--without-mail_smtp_module \
--without-mail_imap_module \
--with-stream \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-stream_geoip_module \
--with-threads \
--with-stream=dynamic \
 --lock-path=/var/lock/nginx.lock \
 --pid-path=/run/nginx.pid \
 --http-client-body-temp-path=/var/lib/nginx/body \
 --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
 --http-proxy-temp-path=/var/lib/nginx/proxy \
 --http-scgi-temp-path=/var/lib/nginx/scgi \
 --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
 --with-pcre-jit \
 --with-http_stub_status_module \
 --with-http_realip_module \
 --with-http_auth_request_module \
 --with-http_addition_module \
 --with-http_geoip_module \
--add-module=$BPATH/headers-more-nginx-module-${HEADERMOD_VER} \
--add-module=$BPATH/ngx_brotli \
--add-dynamic-module=$BPATH/nginx-ct \

make -j $NB_PROC 
make install

echo "All done.";
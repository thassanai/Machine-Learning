export LDFLAGS="$LDFLAGS -lpthread"
./configure --prefix=/usr/local \
 --enable-exif \
--with-libdir=/lib64 \
--disable-ipv6 \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-shared \
--enable-mbstring=all \
--enable-mbregex \
--enable-ftp \
--enable-inline-optimization \
--enable-libxml \
--enable-soap \
--enable-sockets \
--enable-calendar \
--enable-opcache \
--enable-bcmath \
--enable-gd-native-ttf \
--enable-sysvsem \
--enable-sysvshm \
--enable-pcntl \
--enable-zip \
--enable-phar \
--enable-fpm \
--with-fpm-user="nginx" \
--with-fpm-group="nginx" \
--with-pcre-regex \
--with-curl \
--with-gd \
--with-zlib \
--with-xpm-dir="/usr/lib" \
--with-jpeg-dir="/usr/local" \
--with-png-dir="/usr" \
--with-zlib-dir="/usr/local" \
--with-libxml-dir="/usr/local/libxml2" \
--with-pgsql \
--with-iconv \
--with-mysqli \
--with-pdo-mysql \
--with-freetype-dir="/usr" \
--with-openssl \
--with-mhash=/usr \
--with-mcrypt=/usr/local \
--with-gettext="/usr" \
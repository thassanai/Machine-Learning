./configure –prefix=/etc/nginx \
–with-cc-opt=”-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong –param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic” \
–with-cc-opt=”-D FD_SETSIZE=2048″ \
–sbin-path=/usr/sbin/nginx \
–conf-path=/etc/nginx/nginx.conf \
–error-log-path=/var/log/nginx/error.log \
–http-log-path=/var/log/nginx/access.log \
–pid-path=/var/run/nginx.pid \
–lock-path=/var/run/nginx.lock \
–http-client-body-temp-path=/var/lib/nginx/body \
–http-proxy-temp-path=/var/lib/nginx/proxy \
–http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
–http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
–http-scgi-temp-path=/var/lib/nginx/scgi \
–user=nginx \
–group=nginx \
–with-cpu-opt=amd64 \
–with-ld-opt=”-lrt” \
–with-http_v2_module \
–with-file-aio \
–with-http_gunzip_module \
–with-http_gzip_static_module \
–with-http_stub_status_module \
–without-mail_pop3_module \
–without-mail_smtp_module \
–without-mail_imap_module \
–lock-path=/var/lock/nginx.lock \
–pid-path=/run/nginx.pid \
–http-client-body-temp-path=/var/lib/nginx/body \
–http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
–http-proxy-temp-path=/var/lib/nginx/proxy \
–http-scgi-temp-path=/var/lib/nginx/scgi \
–http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
–with-pcre-jit \
–with-http_stub_status_module \
–with-http_realip_module \
–with-http_auth_request_module \
–with-http_addition_module \
–with-http_geoip_module \

# proc for building faster
NB_PROC=$(grep -c ^processor /proc/cpuinfo)
make -j $NB_PROC && make install
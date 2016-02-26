#!/bin/bash
# Build NGINX and modules on Heroku.

NGINX_VERSION=1.9.12
PCRE_VERSION=8.38
HEADERS_MORE_VERSION=0.29

nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
pcre_tarball_url=https://sourceforge.net/projects/pcre/files/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz
headers_more_nginx_module_url=https://github.com/agentzh/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz

temp_dir=$(mktemp -d /tmp/nginx.XXXXXXXXXX)

cd $temp_dir
echo "Temp dir: $temp_dir"

echo "Downloading and extracting $nginx_tarball_url"
(cd $temp_dir; curl -L# $nginx_tarball_url | tar xz)

echo "Downloading and extracting $pcre_tarball_url"
(cd nginx-${NGINX_VERSION}; curl -L# $pcre_tarball_url | tar xz)

echo "Downloading and extracting $headers_more_nginx_module_url"
(cd nginx-${NGINX_VERSION}; curl -L# $headers_more_nginx_module_url | tar xz)

(
	cd nginx-${NGINX_VERSION}
	./configure \
		--with-pcre=pcre-${PCRE_VERSION} \
		--prefix=/tmp/nginx \
		--with-http_sub_module \
		--add-module=/${temp_dir}/nginx-${NGINX_VERSION}/headers-more-nginx-module-${HEADERS_MORE_VERSION}
	make install
)

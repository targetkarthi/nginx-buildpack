#!/bin/bash
# Build NGINX and modules on Heroku.

NGINX_VERSION=1.9.12
PCRE_VERSION=8.38
HEADERS_MORE_VERSION=0.29

NGINX_TARBALL_URL=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
PCRE_TARBALL_URL=https://sourceforge.net/projects/pcre/files/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz
HEADERS_MORE_NGINX_MODULE_TARBALL_URL=https://github.com/agentzh/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz

BUILD_DIR=$(mktemp -d /tmp/nginx.XXXXXXXXXX)
echo "Build dir: $BUILD_DIR"

echo "Downloading and extracting $NGINX_TARBALL_URL"
(cd $BUILD_DIR; curl -L# $NGINX_TARBALL_URL | tar xz)

echo "Downloading and extracting $PCRE_TARBALL_URL"
(cd nginx-${NGINX_VERSION}; curl -L# $PCRE_TARBALL_URL | tar xz)

echo "Downloading and extracting $HEADERS_MORE_NGINX_MODULE_TARBALL_URL"
(cd nginx-${NGINX_VERSION}; curl -L# $HEADERS_MORE_NGINX_MODULE_TARBALL_URL | tar xz)

(
	cd nginx-${NGINX_VERSION}
	./configure \
		--with-pcre=pcre-${PCRE_VERSION} \
		--prefix=/tmp/nginx \
		--with-http_sub_module \
		--add-module=/${temp_dir}/nginx-${NGINX_VERSION}/headers-more-nginx-module-${HEADERS_MORE_VERSION}
	make install
)

(cp /tmp/nginx/sbin/nginx ../bin)
(cp /tmp/nginx/conf/mime.types ../config)

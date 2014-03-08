#!/bin/sh
 
#NGINX_VERSION=1.5.11
#nginx_tarball_url=http://nginx.org/download/nginx-1.5.11.tar.gz

# capture root dir
root=$(pwd)
 
# change into subdir of archive
cd $root/nginx-*
 
# configure 
./configure

# compile
make install PREFIX=/app/vendor
 
# remove source files
rm -rf $root/*
 
# copy build artifacts back into the root
mv /app/vendor $root/


# anvil build http://nginx.org/download/nginx-1.5.11.tar.gz -b scripts/anvil.sh
#!/bin/bash
#
#
yum makecache
#
yum install -y openssl openssl-devel make gcc-c++ cmake bison-devel ncurses-devel automake pcre pcre-devel zlip zlib-devel vim wget
#
mkdir /apps
#
exit

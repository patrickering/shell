#!/bin/bash
#
######################################################################
#
# author@patrick
# 
# 功能作用：
# 生成各种随机数和随即字母的例子
# 
######################################################################
#
#生成纯数字的随机数
#
#第一种
tr -cd '0-9' < /dev/urandom | head -c 8
#第二种
tr -cd '0-9' < /proc/sys/kernel/random/uuid | head -c 8
#第三种
date | md5sum | tr -cd '0-9' | head -c 8
#
#
#生成字母数字组合的随机数
#
#第一种
tr -cd '[:alnum:]' < /dev/urandom | head -c 8
#第三种
date | md5sum | head -c 8
#第三种
cat /proc/sys/kernel/random/uuid | head -c 8
cat /proc/sys/kernel/random/uuid | awk -F- '{print $1}'
#
#
#生成随机纯英文的
#第一种
tr -cd 'a-z' < /dev/urandom | head -c 8
#第二种
tr -cd 'a-z' < /proc/sys/kernel/random/uuid | head -c 8
#第三种
date | md5sum | tr -cd 'a-z' | head -c 8
#
#




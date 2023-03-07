#!/bin/bash
#
#author dosion@patrick
#
#定义自变量
#
#下载目录
Version=5.0.3
DownLoadDir=/apps/redis
RedisPackage=/apps/redis/redis*.tar.gz
RedisInstallPackage=/apps/redis/redis*
RedisConf=/apps/redis/etc/redis.conf
StartFile=/apps/redis/redis*/utils/redis_init_script
InitFile=/etc/init.d/redis
RedisLink=https://download.redis.io/releases/redis-$Version.tar.gz
#
#加载初始提示信息
#
echo "---------------Install Redis-5.0.3---------------"
echo "-------启动命令:   /etc/init.d/redis start    ---"
echo "-------停止命令:   /etc/init.d/redis stop     ---"
echo "-------安装目录：  /apps/redis                ---"
echo "-------数据目录：  /apps/redis/date           ---"
echo "---配置文件目录：  /apps/redis/etc/redis.conf ---"
echo "-------------------------------------------------"
#
#
#解压软件源码安装包
function TarPackage {
    tar -xf $RedisPackage -C $DownLoadDir &> /dev/null
    if [ $? -ne 0 ];then
       echo "软件包解压失败请手动解压"
       exit
    fi
}
#下载解压软件
function DownLoadApp {
    rpm -qa | grep wget &> /dev/null
    if [ $? -eq 0 ]; then
        echo "准备下载安装包..."
        wget -P $DownLoadDir $RedisLink
        if [ $? -eq 0 ]; then
           echo "安装包已准备完毕..."
           TarPackage
        else
           echo "redis-5.0.3下载失败，请重新下载...已退出"
           exit
        fi
    else
        echo "未安装wget下载软件...已退出"
        exit
    fi
}
#判断是否有解压完成的包,如过有就执行后面安装，如果没有就检查是否有目录
if [ ! -d $DownLoadDir/redis-$Version ]; then
   #检查是否有下载目录
   if [ -d $DownLoad ]; then
      #检查是否有源码包
      if [ -f $RedisPackage ]; then
         echo "源码包已准备完毕..."
         #解压源码包
         TarPackage
      else
         #下载解压源码包
         mkdir -p $DownLoadDir
         DownLoadApp
      fi
   else
       #创建下载目录，下载软件源码
       mkdir -p $DownLoadDir
       DownLoadApp
   fi
fi
#编译安装
function MakeInstallApp {
    echo "正在准备编译软件..."
    cd $RedisInstallPackage && make &> /dev/null
    if [ $? -eq 0 ]; then
       echo "软件编译已完成..."
    else
       echo "软件编译失败...已退出"
       exit
    fi
    make install &> /dev/null
    if [ $? -ne 0 ]; then
       echo "软件安装失败...已退出"
       exit
    fi
}
MakeInstallApp
#创建目录移动配置文件
function CreateDir {
    mkdir -p $DownLoadDir/{date,etc,log} &> /dev/null
    cp -a $RedisInstallPackage/redis.conf $RedisConf
}
CreateDir
#修改配置文件解决警告问题
function UpdateConf {
    echo "net.core.somaxconn = 1024" >> /etc/sysctl.conf &> /dev/null
    echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf &> /dev/null
    echo never > /sys/kernel/mm/transparent_hugepage/enabled &> /dev/null
    sysctl -p &> /dev/null
    if [ -f $RedisConf ]; then
       sed -i "s/^daemonize no/daemonize yes/g" $RedisConf
       if [ $? -eq 0 ]; then
          echo "配置文件已准备完毕..."
       else
          echo "配置文件已准备失败..."
       fi
    fi
}
UpdateConf
#创建redis用户
#CreateRedisUser
function CreateRedisUser {
    groupadd redis && useradd redis -s /sbin/nologin 2>&1
    chown redis.redis -R $DownLoadDir 2>&1
}
#设置开机自启动
function StartEnable {
    cp -a $StartFile $InitFile 2>&1
    #修改启动文件
    sed -i "5a\# chkconfig: 2345 90 10" $InitFile 2>&1
    sed -i "5a\# description: Redis is a persistent key-value database" $InitFile 2>&1
    sed -i "s#^CONF=.*#CONF=$RedisConf#g" $InitFile 2>&1
    chkconfig --add redis && chkconfig redis on 2>&1
    if [ $? -eq 0 ]; then
        echo "开机自启已设置完毕..."
    else
        echo "开机自启准备失败..."
    fi
}
StartEnable
#
echo "-----------------安装已完成----------------------"
exit


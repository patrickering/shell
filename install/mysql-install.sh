#!/bin/bash
#
#author patrick@mail@patricksg@qq.com
#
#定义自变量
#
#下载目录
#
Version=5.7.33
DownLoadDir=/apps/mysql
MysqlPackage=/apps/mysql/mysql-$Version.tar.gz
MysqlInstallPackage=/apps/mysql/mysql-$Version
MysqlConf=/etc/my.cnf
InitFile=/etc/init.d/mysql
DataDir=/apps/mysql/data
SockDir=/apps/mysql/sock
InstallDir=/apps/mysql/mysql
MysqlLink=https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-$Version.tar.gz
BoostDir=/usr/local/boost
BoostLink=http://www.sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
ServerId=`date | md5sum | tr -cd '0-9' | head -c 4`
#
#加载初始提示信息
#
echo "---------------Install Mysql-5.7.33----------------"
echo "-------启动命令:   /etc/init.d/mysql start      ---"
echo "-------停止命令:   /etc/init.d/mysql stop       ---"
echo "-------配置文件:   /etc/my.cnf                  ---"
echo "-------安装目录：  /apps/mysql/mysql            ---"
echo "-------数据目录：  /apps/mysql/data             ---"
echo "---------------------------------------------------"

#
#删除已有的安装包
#
function DeleteRpm {
    echo "正在擦除已安装的安装包..."
    /bin/rpm -e $(/bin/rpm -qa | grep mysql|xargs) --nodeps 2>&1
    /bin/rpm -e $(/bin/rpm -qa | grep mariadb|xargs) --nodeps 2>&1
}

#
#安装boost编译工具
#
function Boost {
    echo "正在准备boost工具..."
    if [ ! -d $BoostDir/boost_1_59_0.tar.gz ]; then
	mkdir -p $BoostDir
	wget $BoostLink --no-check-certificate -P $BoostDir
	tar -xf $BoostDir/boost_1_59_0.tar.gz -C $BoostDir &> /dev/null
	if [ $? -ne 0 ];then
	    echo "boost包解压失败...已退出..."
	    exit
	fi
    fi
}

#
#解压软件源码安装包
#
function TarPackage {
    tar -xf $MysqlPackage -C $DownLoadDir &> /dev/null
    if [ $? -ne 0 ];then
       echo "软件包解压失败...已退出..."
       exit
    fi
}

#
#下载解压软件
#
function DownLoadApp {
    rpm -qa | grep wget &> /dev/null
    if [ $? -eq 0 ]; then
        echo "准备下载安装包..."
        wget -P $DownLoadDir $MysqlLink
        if [ $? -eq 0 ]; then
           echo "安装包已准备完毕..."
           TarPackage
        else
           echo "mysql-5.0.3下载失败，请重新下载...已退出"
           exit
        fi
    else
        echo "未安装wget下载软件...已退出"
        exit
    fi
}

#
#判断是否有解压完成的包,如过有就执行后面安装，如果没有就检查是否有目录
#
function chackpackage {
if [ ! -d $DownLoadDir/mysql-$Version ]; then
   #检查是否有下载目录
   if [ -d $DownLoad ]; then
      #检查是否有源码包
      if [ -f $MysqlPackage ]; then
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
}
#
#创建编译环境和目录
#
function EnvDir {
    #创建数据目录和sock目录
    mkdir -p {$DataDir,$SockDir}
    #创建用户和权限
    id mysql &> /dev/null
    if [ $? -eq 1 ]; then
        groupadd mysql 2>&1
	useradd -g mysql mysql -M -s /sbin/nologin 2>&1
    fi
    chown -R mysql:mysql $DownLoadDir
    chown -R mysql:mysql $DataDir
}

#
#执行编译安装
#
function MakeInstallApp {
    echo "正在准备编译软件..."
    cd $MysqlInstallPackage && /usr/bin/cmake \
-DCMAKE_INSTALL_PREFIX=$DownLoadDir/mysql \
-DMYSQL_DATADIR=$DataDir \
-DSYSCONFDIR=/etc \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_UNIX_ADDR=$SockDir/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_BOOST=$BoostDir \
&> /dev/null
#
    echo "----------开始编译安装-----------"
    make && make install
    if [ $? -ne 0 ]; then
       echo "软件安装失败...已退出"
       exit
    fi
}

#
#配置初始化数据库
#
function InitMysql {
    #初始化数据库
    echo "初始化数据库..."
    $DownLoadDir/mysql/bin/mysqld --basedir=$DownLoadDir/mysql --datadir=$DataDir --user=mysql --initialize
    echo "初始化完毕...使用上面密码手动登录修改！"
}

#
#配置my.cnf配置文文件
#
function mycnf {
cat >> /etc/my.cnf << EOF
[client]
port = 3306
socket = $SockDir/mysql.sock
[mysqld]
port = 3306
socket = $SockDir/mysql.sock
basedir = $InstallDir
datadir = $DataDir
pid-file = $DataDir/mysql.pid
user = mysql
log-bin=mysql-bin
server-id=$ServerId
binlog_format=ROW
EOF
}

#
#设置开机自启
#
function StartEnable {
    cp -a $DownLoadDir/mysql/support-files/mysql.server $InitFile 2>&1
    chmod +x $InitFile
    #不修改启动文件
    #
    chkconfig --add mysql && chkconfig mysql on 2>&1
    if [ $? -eq 0 ]; then
        echo "开机自启已设置完毕..."
    else
        echo "开机自启准备失败..."
    fi
}

#
#设置环境变量
#
function Profile {
    echo "export PATH=$PATH:/apps/mysql/mysql/bin" >> /etc/profile 
    echo "环境变量已配置完毕......手动执行命令--source /etc/profile--"
}


#
#删除已有的安装包
DeleteRpm

#安装boost
Boost

#检查是否有安装软件包
chackpackage

#创建编译环境和目录
EnvDir

#执行编译安装
MakeInstallApp

#配置初始化数据库
InitMysql

#配置my.cnf配置文文件
mycnf

#设置开机自启
StartEnable

#设置环境变量
Profile

#
#
echo "-----------------安装已完成----------------------"
exit
#

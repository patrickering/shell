#!/bin/bash
#
#autor patrick@mail@patricksg@qq.com
#
#设置变量
#
Version=jdk1.8.0_141
DownLoadDir=/apps/jdk
JdkPackage=/apps/jdk/jdk-8u141-linux-x64.tar.gz
JdkLink=http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.tar.gz
#
#加载初始提示信息
echo "---------------Install Jdk-1.8-----------------"
echo "-------启动命令:   java                     ---"
echo "-------安装目录：  /apps/jdk                ---"
echo "-----------------------------------------------"
#
#
#解压软件源码安装包
function TarPackage {
    tar -xf $JdkPackage -C $DownLoadDir &> /dev/null
    if [ $? -ne 0 ];then
       echo "软件包解压失败...已退出...";
       exit;
    fi
}
#下载解压软件
function DownLoadApp {
    rpm -qa | grep wget &> /dev/null
    if [ $? -eq 0 ]; then
        echo "准备下载安装包..."
        wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http://www.oracle.com/; oraclelicense=accept-securebackup-cookie" $JdkLink -P $DownLoadDir
        if [ $? -eq 0 ]; then
           echo "安装包已准备完毕...";
           TarPackage;
        else
           echo "jdk-1.8下载失败，请重新下载...已退出";
           exit;
        fi
    else
        echo "未安装wget下载软件...已退出";
        exit;
    fi
}
#判断是否有解压完成的包,如过有就执行后面安装，如果没有就检查是否有目录
if [ ! -d $DownLoadDir/$Version ]; then
   #检查是否有下载目录
   if [ -d $DownLoad ]; then
      #检查是否有源码包
      if [ -f $JdkPackage ]; then
         echo "源码包已准备完毕...";
         #解压源码包
         TarPackage;
      else
         #下载解压源码包
         mkdir -p $DownLoadDir;
         DownLoadApp;
      fi
   else
       #创建下载目录，下载软件源码
       mkdir -p $DownLoadDir;
       DownLoadApp;
   fi
fi
#
#设置环境变量设置全局变量
#
echo "export JAVA_HOME=$DownLoadDir/$Version" >> /etc/profile
echo "PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
source /etc/profile
#
java -version
if [ $? -eq 0 ]; then
    echo "jdk环境变量已设置完毕..."
else
    echo "jdk环境变量设置错误，已退出..."
    exit
fi
#
#
echo "-----------------安装已完成----------------------"
exit
#

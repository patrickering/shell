#!/bin/bash
#
#author dosion@patrick-shen
#
#定义自变量
#
#下载目录
Version=apache-tomcat-9.0.41
DownLoadDir=/apps/tomcat
TomcatPackage=/apps/tomcat/$Version.tar.gz
TomcatInstallPackage=/apps/tomcat/$Version
TomcatConf=/apps/tomcat/$Version/conf/server.xml
InitFile=/etc/init.d/tomcat
TomcatLink=https://mirrors.bfsu.edu.cn/apache/tomcat/tomcat-9/v9.0.41/bin/$Version.tar.gz
#加载初始提示信息
echo "--------------------Install Tomcat-9.0.41-------------------"
echo "-------启动命令:                                      "
echo "         ./apps/tomcat/$Version/bin/startup.sh--"
echo "-------停止命令:                                      "
echo "         ./apps/tomcat/$Version/bin/startup.sh--"
echo "-------安装目录：/apps/tomcat    ---------------------------"
echo "---配置文件目录: "
echo "      $TomcatConf"
echo "------------------------------------------------------------"
#
#
#解压软件源码安装包
function TarPackage {
    tar -xf $TomcatPackage -C $DownLoadDir &> /dev/null
    if [ $? -ne 0 ];then
       echo "软件包解压失败...已退出..."
       exit
    fi
}
#下载解压软件
function DownLoadApp {
    rpm -qa | grep wget &> /dev/null
    if [ $? -eq 0 ]; then
        echo "准备下载安装包..."
        wget -P $DownLoadDir $TomcatLink
        if [ $? -eq 0 ]; then
           echo "安装包已准备完毕..."
           TarPackage
        else
           echo "tomcat-9.0.41下载失败，请重新下载...已退出"
           exit
        fi
    else
        echo "未安装wget下载软件...已退出"
        exit
    fi
}
#判断是否有解压完成的包,如过有就执行后面安装，如果没有就检查是否有目录
if [ ! -d $DownLoadDir/$Version ]; then
   #检查是否有下载目录
   if [ -d $DownLoad ]; then
      #检查是否有源码包
      if [ -f $TomcatPackage ]; then
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
#
echo "安装完毕..."
#
echo "-----------------安装已完成----------------------"
exit
#

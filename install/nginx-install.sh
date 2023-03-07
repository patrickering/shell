#!/bin/bash
#
#author dosion@patrick-shen
#
#定义自变量
#
#下载目录
Version=1.18.0
DownLoadDir=/apps/nginx
NginxPackage=/apps/nginx/nginx*.tar.gz
NginxInstallPackage=/apps/nginx/nginx*
NginxConf=/apps/nginx/conf/nginx.conf
InitFile=/etc/init.d/nginx
NginxLink=http://nginx.org/download/nginx-$Version.tar.gz
#加载初始提示信息
echo "---------------Install Nginx-5.0.3-----------------"
echo "-------启动命令:   /etc/init.d/nginx start      ---"
echo "-------停止命令:   /etc/init.d/nginx stop       ---"
echo "重新加载配置文件:  /apps/nginx/sbin/nginx -s reload"
echo "-------安装目录：  /apps/nginx                  ---"
echo "---配置文件目录：  /apps/nginx/conf/nginx.conf  ---"
echo "---配置文件目录：  /apps/nginx/conf/conf.d/*.conf  "
echo "---------------------------------------------------"
#
#
#解压软件源码安装包
function TarPackage {
    tar -xf $NginxPackage -C $DownLoadDir &> /dev/null
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
        wget -P $DownLoadDir $NginxLink
        if [ $? -eq 0 ]; then
           echo "安装包已准备完毕..."
           TarPackage
        else
           echo "nginx-5.0.3下载失败，请重新下载...已退出"
           exit
        fi
    else
        echo "未安装wget下载软件...已退出"
        exit
    fi
}
#判断是否有解压完成的包,如过有就执行后面安装，如果没有就检查是否有目录
if [ ! -d $DownLoadDir/nginx-$Version ]; then
   #检查是否有下载目录
   if [ -d $DownLoad ]; then
      #检查是否有源码包
      if [ -f $NginxPackage ]; then
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
    cd $NginxInstallPackage && ./configure --prefix=$DownLoadDir \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_realip_module \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--with-pcre \
--with-stream \
--with-stream_ssl_module \
--with-stream_realip_module \
&> /dev/null
#
    make &> /dev/null
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
#创建包含的配置文件目录
function CreateDir {
    mkdir -p $DownLoadDir/conf/conf.d/ &> /dev/null
#    cp -a $NginxInstallPackage/nginx.conf $NginxConf
}
CreateDir
#创建nginx用户
#CreateNginxUser
function CreateNginxUser {
    useradd nginx -s /sbin/nologin -u 2000 2>&1
    chown nginx.nginx -R $DownLoadDir 2>&1
}
#设置开机自启动
function StartEnable {
	touch $InitFile && chmod +x $InitFile
cat >> $InitFile << EOF
#!/bin/sh
# Simple Nginx init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.
# chkconfig: 2345 90 10
# description: Nginx is a persistent key-value database
PIDFILE=/apps/nginx/logs/nginx.pid
ExecStart=/apps/nginx/sbin
case "\$1" in
    start)
        if [ -f \$PIDFILE ]
        then
                echo "\$PIDFILE exists, process is already running or crashed"
        else
                \$ExecStart/nginx -t
                if [ \$? -eq 0 ]; then
                   echo "Starting Nginx server..."
                   \$ExecStart/nginx
                else
                   exit
                fi
        fi
        ;;
    stop)
        if [ ! -f \$PIDFILE ]
        then
                echo "\$PIDFILE does not exist, process is not running"
        else
                PID=\$(cat \$PIDFILE)
                echo "Stopping ..."
                /bin/sh -c "/bin/kill -s TERM \$(/bin/cat \$PIDFILE)"
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for Nginx to shutdown ..."
                    sleep 1
                done
                echo "Nginx stopped"
        fi
        ;;
    *)
        echo "Please use start or stop as first argument"
        ;;
esac
EOF
    chkconfig --add nginx && chkconfig nginx on 2>&1
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
#

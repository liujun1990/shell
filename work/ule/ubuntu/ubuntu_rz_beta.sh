#!/bin/bash

#
#
passwd ubuntu<<EOF
ubuntu
ubuntu
EOF
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service ssh restart


IP=`/sbin/ifconfig |grep 172.25|grep -oP "(?<=inet addr:).*(?= Bcast)"`
NAME=$(echo $IP|awk -F"." '{print $3$4}')
sed -i "/$IP/d" /etc/hosts
echo $IP ct$NAME >> /etc/hosts
IP=`/sbin/ifconfig |grep 172.25|grep -oP "(?<=inet addr:).*(?= Bcast)"`
NAME=$(echo $IP|awk -F"." '{print $3$4}')
NET=`/sbin/ifconfig |grep -o "inet addr:172.25[^ ]*" |awk -F. '{print $3}'`
hostname ct$NAME
echo ct$NAME >/etc/hostname


sed -i 's/source/#source/g'  /etc/network/interfaces
echo "auto eth0" >> /etc/network/interfaces
echo " iface eth0 inet static" >> /etc/network/interfaces
echo " address $IP" >> /etc/network/interfaces
echo " netmask 255.255.255.0" >> /etc/network/interfaces
echo " gateway 172.25.$NET.1" >> /etc/network/interfaces
echo " dns-nameservers 172.25.130.31 172.25.130.32" >> /etc/network/interfaces
echo "up route add -host 169.254.169.254 gw 172.25.$NET.31" >> /etc/network/interfaces
if [ $NET == 148 ];then
	sed -i 's/172.25.148.41/172.25.148.30/g' /etc/network/interfaces
fi

#echo "nameserver 172.25.130.31" > /etc/resolvconf/resolv.conf.d/tail
#echo "nameserver 172.25.130.32" >> /etc/resolvconf/resolv.conf.d/tail


mv /etc/apt/sources.list /etc/apt/sources.list.bak
wget http://172.24.138.32/software/sources.list.ubuntu -O /etc/apt/sources.list


apt-get update || exit 3
apt-get install apache2-utils vim ntp -y

mv /etc/ntp.conf /etc/ntp.conf.bak 

cat >> /etc/ntp.conf <<EOF
driftfile /var/lib/ntp/ntp.drift
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable
server 172.25.130.31  iburst
server 172.25.130.32  iburst
restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery
restrict 127.0.0.1
restrict ::1
EOF

/etc/init.d/ntp restart

echo "colorscheme peachpuff" >> /etc/vim/vimrc
apt-get install bc pciutils dmidecode  -y

curl -sSL http://172.24.138.32/software/zabbix-agent_3.0.8-1+trusty_amd64.deb -o /tmp/zabbix-agent_3.0.8-1+trusty_amd64.deb
dpkg -i  /tmp/zabbix-agent_3.0.8-1+trusty_amd64.deb
sed -i  's/Server=/Server=zabbix.beta.uledns.com,zabbix.prd.uledns.com,/g' /etc/zabbix/zabbix_agentd.conf
sed -i  's/ServerActive=/ServerActive=zabbix.beta.uledns.com,/g' /etc/zabbix/zabbix_agentd.conf
chown -R zabbix.zabbix  /etc/zabbix
mkdir -p /home/zabbix
chown -R zabbix.zabbix  /home/zabbix
usermod -d /home/zabbix -s /bin/bash zabbix
mkdir -p /var/run/zabbix/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLqoxYeNXD65ZK9FQvmqDCnrVZ6sCuD9U9RBdBnjGu1tMtlqqRv0rq+HjQnHT8QrrRl2ApAnv6VcKCsueV81GN4cUn6eGP2tKdLlT70gO7FnajkV
EaE5i48sqEYMla8YENlwZsX8bq82N6hyZvp+VjU/ph1xw4Mh3HWQtxTxNHWFjAIyXczgdexEX4v5o5O1Qlm4fk/z7FyB9KrtpXivNqZ74nEH3LgyMOYGpjCtCoR3ef2X7dUwPFEUkJBbOnEpA9p5DZddyw++
JjZvQqm9SpeQFVGN9uGDUPmKwrmnsjdFV4pFX6Fsc1MVkLA112QL65/NYeysnBAxHfIkZ3QusZ web@tu138173" >>/var/run/zabbix/.ssh/authorized_keys
/etc/init.d/zabbix-agent restart

passwd  << EOF
Aiwoyoule#123
Aiwoyoule#123
EOF

useradd -m -d /home/logview -s /bin/bash logview
passwd logview << EOF
viewlog
viewlog
EOF


passwd zabbix << EOF
ule.zabbix
ule.zabbix
EOF

cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo 'Asia/Shanghai' >/etc/timezone

hwclock -w


ln -svf /usr/bin/rotatelogs /usr/sbin/rotatelogs
 mkdir -p /data/soft
 mkdir -p /data/logs
 apt-get install libxtst6 -y


if ! ls /usr/local/jdk ;then
	mkdir -p /data/soft
	cd /data/soft
#	wget http://172.24.138.32/software/jdk-6u27-linux-x64.bin
	wget http://172.24.138.32/software/jdk1.6.tar.gz
	wget http://172.24.138.32/software/jdk1.8.0_45.tar.gz
#	wget http://172.24.138.32/software/jdk-7u71-linux-x64.gz
	tar xf jdk1.6.tar.gz
	tar xf jdk1.8.0_45.tar.gz
#	tar xf jdk-7u71-linux-x64.gz
#	mv jdk1.7.0_71  jdk1.7
	mv  jdk1.8.0_45 jdk1.8
#	cp -a jdk jdk1.7  jdk1.8 /usr/local/
	cp -a jdk jdk1.8 /usr/local/
	cd /usr/local/ 	
	ln -svf jdk jdk1
	export JAVA_HOME=/usr/local/jdk
	export PATH=$PATH:$JAVA_HOME/bin
	export CLASSPATH=.:$JAVA_HOME/lib
	export JAVA_HOME CLASSPATH PATH
	echo 'export JAVA_HOME=/usr/local/jdk' >> /etc/profile
	echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
	echo 'export CLASSPATH=.:$JAVA_HOME/lib' >> /etc/profile
	echo 'export JAVA_HOME CLASSPATH PATH' >> /etc/profile
fi

#cat >> /var/spool/cron/crontabs/root <<EOF
# Edit this file to introduce tasks to be run by cron.
# 
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
# 
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').# 
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
# 
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# 
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
# 
# For more information see the manual pages of crontab(5) and cron(8)
# 
# m h  dom mon dow   command
#EOF

#echo "*/10 * * * * /usr/sbin/ntpdate 172.25.130.31" >>/var/spool/cron/crontabs/root

#立即同步
#/usr/sbin/ntpdate 172.25.130.31

key_setup(){
#设置172.24.138.100 root-key认证登录
mkdir -p /root/.ssh/
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5ADiAMoa8grNRkW8xB2gKlm7Hex6BB4dy3RFv+4PK1SFXawf475cTXDdpNflAX/FAxtUB+uE24C7jZUiikzTxZwWttFyij0NICblmpSW7p/9tOyxdpYvhSfi4I2zTqXgeP+wRmcHyEh/ese5BcS4bBSQNl9U81Yvhx5R5gR3jEzQUNTbQoYatwjFgnM8FinO7m4+fy52DsFcnvntdVrarBUMo2PteKRTl/f7l3M98ys5XoaHvo3wNS9+Cljb9MIr79XWs342Kf9OMaPMFRo1iKGH16b+61clegmkIhaU2gWFLL4B74EI4SkA3V8CJIJI6KdDmTrOHP1CKZs36vf4ew== root@Monitor" >>/root/.ssh/authorized_keys
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAtfoPp7Svz/WpteR57Tjuytg+2sC9PqJy7IkFcnm9VcQORVr+Lm/mrrwIR5BUNvF14MX7NR8MDmKkyVCHDeE/jIhoL2VdoVHugB2czR+Ut+vrRNn1YCpV6w1ifFUVWUUhpphf1S2C0nQ28U8XUtCDMaf2z/u8zPurPYJpjYgGPAM= root@ebay15" >>/root/.ssh/authorized_keys
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvV+cdkWSZ80CNBEIjZRKyr/bwXhepvWilSgEOlkZOwOTsv8aP8mahOZkrqV6Hrbb9nZOkMNcDzbyI8w8SVOm6iZ5pBsvK4p5A1ZHfgrbVqMX7cJvSZRm5gc5jj4npjew0AYlzNOsA72nzRV5Mr96i/BpcRPzwLmbjuOiQH/9ACMgED8xgqS0+ydmx5cmEHrUo3eoloshatgjWpMu64VdTTEQdQms1uKS0PG/LTNIWnEo5FsZ5HsQ67U91G0Mrtd61m3z/XmPUDG1RH3YMPU+QjZBpZemfdhwlZV2Ef36xCrPkxbnpMkUdb+MEF2Q/GyySc9u6ks6HE45LI8iaPZGoQ== root@ebay46"  >>/root/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvC7V7jp49KJBGgraicF/cQQW7P5w/OidPOx3vR3awF5lNJFtm+lpBvaQ2JsRY82AGk7ufWunVGqfDA3lTovfYBedjXRgWcjcsFDxoonb732UcztkZs4+ADNcr1ZRSF2aO/MfI/aEZ9Qpql69dg5ydDpqe9vwgQwtKyFb4/tgrUdeu+IAwWjNJ4N84fLtD3tfuqGn5MuAqIqVWMUnWjalqMAgmWqgNSduM/hmPqt6V53G9mzL13+4aLrXogAdhhJ6qZ1vV3ktUgnYhDHEpDPDxg2P8TzbqjFB0rCOajgY2LSBTc7uywnRUPN+7sFtxrtekn7Dq8Xi3Q+AkLipHODTV root@tu147240" >> /root/.ssh/authorized_keys
#设置172.24.138.79 web-key登陆
id web
if [ $? != 0 ]
then
	useradd -m -d /home/web -s /bin/bash web
passwd web << EOF
ule.prd#123
ule.prd#123
EOF
	mkdir -p /home/web/.ssh
	touch /home/web/.ssh/authorized_keys
	chmod 600 /home/web/.ssh/authorized_keys
	chown -R web.users /home/web/.ssh/authorized_keys
fi
	mkdir -p /home/web/.ssh
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAralqfhe6S/a6U+h8ALRY/HaZJRbRPteHs25h6g4tazsYpN2YdV61S0U2A2ujnzOMv/whN83ja5QNPGZ3lGTKs/kHTqET2yogTTvbNADZXU+EJfWmY+LH9n/ZB3OX5l6q3YicBE8Nykl7ShpfF5l+45zGvt+2444QJZteBQc1qdqXmVX92GmT6tyN4Ii381Jgg8TPLC40AU+PrethCIgE+lMl9ev07Gp35PABhK0GvXy3SQkFM9C87OmicIfcb6m31gvgVX7eQ7GUO4UsQtiKDcWNjqvHtOQ14qyp/6m1IU4ooDexaJsAmUe3Dnsn9LDRM3WZBd6n7nJNOEgIdYUOeQ== web@ebay53" >> /home/web/.ssh/authorized_keys
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDic2vQiqZ0lMDwqxfjXuBxYpHnLUrpe0e4u2FGnpnQJYmlVI9n21J96O0DMZ+gq4K5XTiQi8WR6HhaLz4lSRMPPjo11cWCOdXDc93OeQgjj0Jyw7fvlSu9tNdXpAfBpYmyHjQWuIfANRv7DvNeWDYtiBfX+c8jQC8Qm67dZQSBoQtXVklU7SQctQ6wQQlhnPvDZ8nRDCdyVmLdwKGYmNWCfIKFZOjHO7DlycO5V01yJUCaLz0GWeqzz0QYyhqsWxpPkx1PUxpVrLYklJ7EudS+TCY79AsToadpICQxLNoh/1r1fVePbPuesqjF0PZJCahrTw6HKoZCYYmCnWz/qD/D web@debian"  >> /home/web/.ssh/authorized_keys
	chmod 600 /home/web/.ssh/authorized_keys
	chown -R web.users /home/web/.ssh/authorized_keys

#设置240 ubuntu用户免密码登录服务器
        mkdir -p /home/ubuntu/.ssh
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDic2vQiqZ0lMDwqxfjXuBxYpHnLUrpe0e4u2FGnpnQJYmlVI9n21J96O0DMZ+gq4K5XTiQi8WR6HhaLz4lSRMPPjo11cWCOdXDc93OeQgjj0Jyw7fvlSu9tNdXpAfBpYmyHjQWuIfANRv7DvNeWDYtiBfX+c8jQC8Qm67dZQSBoQtXVklU7SQctQ6wQQlhnPvDZ8nRDCdyVmLdwKGYmNWCfIKFZOjHO7DlycO5V01yJUCaLz0GWeqzz0QYyhqsWxpPkx1PUxpVrLYklJ7EudS+TCY79AsToadpICQxLNoh/1r1fVePbPuesqjF0PZJCahrTw6HKoZCYYmCnWz/qD/D web@debian" >> /home/ubuntu/.ssh/authorized_keys
	chmod 600 /home/ubuntu/.ssh/authorized_keys
	chown -R ubuntu.users /home/ubuntu/.ssh/authorized_keys


#初始化SSH配置，禁用SSH反向查询DNS，禁止ROOT密码交互登陆

wget http://172.24.138.32/software/yuhao/sshd_config.ubuntu -O /etc/ssh/sshd_config
service ssh restart
}


sys_para(){

#设置系统优化参数
cat << EOF >>/etc/sysctl.conf 
net.ipv4.ip_forward = 0
#net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 30
fs.file-max = 6553600
net.ipv4.tcp_sack = 0
net.ipv4.ip_local_port_range = 30000    65000
net.ipv4.conf.default.rp_filter = 0
net.core.optmem_max = 65535
vm.swappiness = 5
kernel.pid_max = 65534
EOF
sysctl -p


#echo "ulimit -HSn 65536" >>/etc/rc.local
echo "*    soft    nofile    655360" >>/etc/security/limits.conf
echo "*    hard    nofile    655360" >>/etc/security/limits.conf 
echo "ulimit -HSn 655360" >>/root/.bashrc
sed -i '/exit 0/i\ulimit -HSn 65536'  /etc/rc.local 
cp /etc/fstab /etc/fstab.bak
sed -i '/#/!s/defaults/defaults,nodiratime,noatime,nobarrier/' /etc/fstab
sed -i '/#/!s/errors=remount-ro/errors=remount-ro,nodiratime,noatime,nobarrier/' /etc/fstab
echo 'net.ipv6.conf.all.disable_ipv6=1' > /etc/sysctl.d/disableipv6.conf 

 




echo 10 > /proc/sys/vm/swappiness
echo 5 > /proc/sys/vm/dirty_background_ratio
echo 10 > /proc/sys/vm/dirty_ratio



}

history_profile(){
#设置登录后多长时间没有活动自动退出

echo "HISTFILESIZE=3000" >>/etc/profile
echo "HISTSIZE=3000" >>/etc/profile
echo "export HISTTIMEFORMAT=\"%F %T\"" >>/etc/profile


#设置登录显示的应用、系统接口人信息
echo -e "系统接口人: 系统运维部 28943666-转4036"  >>/etc/motd.tail
echo -e "系统接口人: 系统运维部 28943666-转4036" >>/etc/motd
#设置resolve

}

history_profile


key_setup
sys_para

echo "创建邮乐基础应用目录"
mkdir -p /data/postmall
mkdir -p /data/tomcat
mkdir -p /data/jboss
mkdir -p /data/logs/apache
mkdir -p /data/logs/tomcat
mkdir -p /data/logs/jboss
chown -R web.web /data/*
chmod 700 /data/postmall
chmod 700 /data/tomcat
chmod 700 /data/jboss
chmod 755 /data/logs

reboot

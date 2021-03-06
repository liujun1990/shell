###########################################################################
#!/bin/bash
#To install and configure postgresql from tar source package automatically
#Made by liujun, liujun_live@msn.com, 2014-11-21
###########################################################################
#:<<TEST_SYNTAX
#########################################################
#Check source file 
#########################################################
if [ "$1" == "" ];then
        echo -e "\e[33;1mUsage\e[0m: \e[32;1m$0\e[0m \e[31;1mpostgresql-x.x.x.tar.gz\e[0m"
	exit 1
fi

#########################################################
#Check user & group 
#########################################################
user_group(){
postgresql_user=postgres
postgresql_group=postgres
user_flag=$(cat /etc/passwd|cut -d: -f1 |grep $postgresql_user)
group_flag=$(cat /etc/group|cut -d: -f1 |grep $postgresql_group)

echo "--------------------------------------------"
echo -e "Check \e[31;1muser & group\e[0m"
echo ""
if [ "$group_flag" = "" ];then
	groupadd -r $postgresql_group 
	echo -e "Group \e[32;1m$postgresql_group\e[0m is \e[33;1madded\e[0m"
else 
	echo -e "Group \e[32;1m$postgresql_group\e[0m is \e[31;1mexist\e[0m"
fi

if [ "$user_flag" = "" ];then
	useradd -r -m $postgresql_user -g $postgresql_user
	echo -e "User \e[32;1m$postgresql_user\e[0m is \e[33;1madded\e[0m"
else
	echo -e "User \e[32;1m$postgresql_user\e[0m is \e[31;1mexist\e[0m"
fi
sleep 1
echo ""
echo ""
echo ""
}
#########################################################
#Install libs developed
#########################################################
libs(){
echo "--------------------------------------------"
echo -e "Check \e[31;1mlibs developed\e[0m"
echo ""
package="zlib-devel unzip gzip bzip2"
for i in $package
do
	flag=$(rpm -q $i|egrep "(not installed)|未安装软件包")
	if [ "$flag" != "" ];then
		yum -y install $i
	else
		echo -e "\e[32;1m$i\e[0m is installed"
	fi
done
}


#########################################################
#Variables
#########################################################
export build_dir="/opt"
export postgresql_base_dir="$build_dir/pgsql"
export postgresql_data_dir="$postgresql_base_dir/data"
export postgresql_log="$postgresql_base_dir/log/postgresql.log"
export postgresql_tar=$1

#########################################################
#Building & Install
#########################################################
postgresql_install(){
user_group
libs
sleep 1
#########################################################
#Uncompress
#########################################################
#postgresql
tar -xvf $postgresql_tar -C $build_dir
[ $? == 0 ] && echo -e "\e[31;1mInstall\e[0m \e[32;1mOK!\e[0m"
#########################################################
#bin PATH & man PATH
#########################################################
echo "PATH=\$PATH:$postgresql_base_dir/bin" >>/etc/profile
source /etc/profile
echo "MANPATH $postgresql_base_dir/share/man" >>/etc/man.config
echo ""

#########################################################
#init postgresql
#########################################################
echo -e "\e[31;1mPostgreSQL \e[0m \e[32;1minit ...\e[0m"
sleep 2
mkdir -p $postgresql_base_dir/log
chown -R $postgresql_user:$postgresql_group $postgresql_base_dir/
su - $postgresql_user -c "$postgresql_base_dir/bin/initdb -D $postgresql_data_dir"
echo ""
echo -e "\e[31;1mInit \e[0m \e[32;1mOK!\e[0m"

#########################################################
#Config file
#########################################################
postgresql_conf_main="$postgresql_data_dir/postgresql.conf"
postgresql_conf_hba="$postgresql_data_dir/pg_hba.conf"
echo ""
sleep 2
cp -f $postgresql_conf_main ${postgresql_conf_main}.default
cp -f $postgresql_conf_hba ${postgresql_conf_hba}.default
sed -i "/listen_addresses/a listen_addresses = '*'" $postgresql_conf_main
sed -i "s/ident/md5/g" $postgresql_conf_hba
echo -e "\e[31;1mCreate $postgresql_conf_file \e[0m \e[32;1msuccessfully!\e[0m"

#########################################################
#Check logrotate for postgresql
#########################################################
cat >/etc/logrotate.d/postgresql-log-rotate <<EOF
$postgresql_log {
	missingok
	compress
	notifempty
	daily
	rotate 5
	create 0600 $postgresql_user $postgresql_group
}
EOF

echo ""
su - $postgresql_user -c "$postgresql_base_dir/bin/pg_ctl -D $postgresql_data_dir -l $postgresql_log start"
if [ $? == 0 ];then
	echo -e "\e[31;1mPostgreSQL started \e[0m \e[32;1msuccessfully!\e[0m"
fi
}
echo "--------------------------------------------"
echo -e "\e[31;1mWether postgresql is installed or not\e[0m"
echo ""
if [ -z $(which pg_ctl 2>/dev/null) ];then
echo ""
echo -e "\e[31;1mInstalling postgresql\e[0m \e[34;1m... ...\e[0m"
#function
postgresql_install
else
	echo -e "\e[32;1mPostgreSQL\e[0m is installed"
	exit 0
fi

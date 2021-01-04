#!/bin/bash
#$1:主机名	$2:数据库名
if [[ "$1" != "" && "$2" != "" ]];then
	#创建一个以数据库命名的文件夹用来存放存储过程
	if[ ! -d /home/dsadm/chengkai/$2 ];then
		mkdir -p /home/dsadm/chengkai/$2
	fi
	#show plsql functions 列出用户定义存储过程名字（不含参数）放到$2_plsql_name.txt
	beeline -u jdbc:hive2://$1:10000/$2 --showHeader=false --maxwidth=10000 -e "show plsql functions"
	|grep -v '+'|grep -v 'call_'|sed 'info/d'|sed 's/|//g'|sed "s/(.*)//g"
	|sed 'System functions/,/User defined/d' > /home/dsadm/chengkai/tmp/$2_plsql_name.txt
	#按行读取$2_plsql_name.txt
	cat /home/dsadm/chengkai/tmp/$2_plsql_name.txt|while read line
	do
		#库名.存储过程名 以.分割 取第二段（存储过程名）转化成大写
		proc_name=`echo $line|awk -F '.' '{print $2}'|tr a-z A-Z`
		#将
		#use $2;
		#!set plsqlClientDialect db2;
		#set plsql.server.dialect=db2;
		#set hive.exec.dynamic.partition=true;
		#set hive.crud.dynamic.partition=true;
		#插入到存储过程文件$2/$proc_name.sql最前面
		echo "use $2;
		!set plsqlClientDialect db2;
		set plsql.server.dialect=db2;
		set hive.exec.dynamic.partition=true;
		set hive.crud.dynamic.partition=true;" > /home/dsadm/chengkai/$2/$proc_name.sql
		#用desc plsql function extended $line;查看存储过程内容处理好追加到$2/$proc_name.sql
		beeline -u jdbc:hive2://$1:10000/$2 --showHeader=false --maxwidth=10000 -e "desc plsql function extended $line;"
		|sed '1d'|sed '$d'|sed 's/^|//g'|sed 's/|$//g'|sed 's/^ //g'|sed '1,3d'
		|sed '/Prototype:/,$d'|sed 's/[ ]*$//g'|sed '$a '/'' >> /home/dsadm/chengkai/$2/$proc_name.sql
		
	done
else 
	echo 'Usage :sh desc_plsql.sh server database!'
fi
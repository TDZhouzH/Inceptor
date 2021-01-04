#!/bin/bash
BEELINE="beeline -u jdbc:hive2://HostIP:10000 --maxwidth=10000 --showHeader=false"
#创建文件夹sql用来存放建表语句文件
if [ ! -d sql ];then
	mkdir sql
fi
#table_info.sql文件中格式为每行 库名.表名 脚本之后会在sql目录生成每个表的建表语句
if [ ! -f table_info.sql ];then
	echo "table_info.sql文件不存在"
	exit 1
fi
#遍历这个文件
for info in `cat table_info.sql`
do
	#如果不为空
	if [ ! -n "${info}" ];then
	continue
	fi
	#显示建表语句插入到sql/${info}.sql
	${BEELINE} -e "show create table ${info};" >> sql/${info}.sql
	#执行成功与否标志
	if [ "$?"=="0" ];then
		echo "${BEELINE} -e \"${sql} ${info\" SUCESS"
	else
		echo "${BEELINE} -e \"${sql} ${info}\" ERROR"
	fi
	#删除第一行到第二行
	sed -i '1,2d' sql/${info}.sql
	#把+,|,-都替换成空
	sed -i 's/[+|-]//g' sql/${info}.sql
	#把一个或者多个 \t替换成空
	sed -i 's/[ \t]*$//g' sql/${info}.sql
	#将localtion开头的行删除
	sed -i '/LOCALTION/d' sql/${info}.sql
	#将以hdfs://nameservice开头的行删除
	sed -i '/hdfs:\/\/nameservice/d' sql/${info}.sql
	#将从开头到结尾的空格行删除
	sed -i '/^$/d' sql/${info}.sql
done
#!/usr/bin/python
# -*- coding:UTF-8 -*-

import os
#将字符串赋值给变量
BEELINE="beeline -u jdbc:hive2://hostIP:port//database_name --maxwidth=10000 --color=true -e 'show create table table_name;'>create_table_name.sql"
#执行Linux命令将建表语句保存在create_table_name.sql文件
os.system(BEELINE)
#定义一个变量
file_data=''
#打开文件
with open('create_table_name.sql',"rt") as f:
#遍历文件的每一行
	for line in f:
#判断该行是否包含字符串'|',如果包含则将其替换为空
		if '|' in line:
			line=line.replace("|","")
#判断该行是否包含字符串'createtab_stmt',如果包含则将其替换为空
			line=line.replace("createtab_stmt","")
			file_data +=line
#打开文件
with open('create_table_name.sql','w') as f:
	f.write(file_data)
#打开文件
with open('create_table_name.sql','rt') as f:
#一次性读取多行,不穿参数表示读取全部,返回一个列表list,每行是列表中的一个元素
	res=f.readlines()
#将列表中的元素以空格分隔
	res=[x for x in res if x.split()]
#打开文件
with open('create_table_name.sql','w') as f:
#将去掉空格后的元素连接在一起
	f.write("".join(res))
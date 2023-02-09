#!/bin/bash

count=1;

for i in {b..o}; do
  command1=$(sudo mkfs.ext4 -F /dev/sd$i 2>&1);
  value_stderr=${command1:28:60};
  echo $value_stderr"...";
  if [ "$value_stderr" = "The file /dev/sd"$i" does not exist and no size was specified." ]; then
    echo "Skipping /dev/sd"$i
  else
    command2= sudo mkdir /data$count;
    command3= sudo blkid /dev/sd$i | awk '{print "UUID="substr($2, 7, 36)" /data'$count' ext4 defaults,noatime,nodiratime 1 2"}' >> /etc/fstab;
    command4= sudo mount /dev/sd$i;
    echo "sd$i mounted";
    ((count=count+1))

  fi 
done

# https://www.cnblogs.com/badboy200800/p/11121880.html (2>&1)

# value_stderr=${command1:28:60};
# 切割变量输出字符显示长度（28-60字符）
# https://blog.csdn.net/weixin_37766087/article/details/99975723 

# awk '{print "UUID="substr($2, 7, 36)" /data'$count' ext4 defaults,noatime,nodiratime 1 2"}'
# awk内置substr（）截取字段，第7个字符开始，截取36个字符
# 另一种思路也可以用这个实现：blkid /dev/sdb1 | awk -F'"' '{print"UUID="$2}'
# https://likegeeks.com/awk-command/
# https://blog.csdn.net/abc517638821/article/details/50670791

# shell 中各种括号的作用()、(())、[]、[[]]、{}
# https://www.runoob.com/w3cnote/linux-shell-brackets-features.html

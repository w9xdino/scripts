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

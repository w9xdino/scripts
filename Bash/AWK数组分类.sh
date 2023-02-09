#!/bin/bash

cat fruits.txt | awk '{s[$1] += $2 } END { for(c in s) {print c,s[c] }}'

awk是支持数组array的，它提供了更加强大的功能操作，如上为创建了一个叫s的数组，数组的索引值为第一列，因为我们这里只需要用到索引值，所以只写了s[$1]，因为未赋值的变量都初始默认为0，所以这里相当于s[$1]=0，而在后面的for(i in s)的循环中，i为s的索引值，所以就遍历出了所有的水果种类
cnblogs.com/zejin2008/p/13509318.html

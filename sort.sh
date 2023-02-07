#!/bin/bash

cat fruits.txt | awk '{sum[$1] += $2 } END { for(c in sum) {print c,sum[c] }}'

#!/bin/bash

for x in 0 1 2 3 4 5 6 7 8 9 10 11
do
    a='0-'
    procs="$a$x"
    sudo turbostat taskset -c $procs stress -t 1 -m 12 2>&1 | awk '{print $21}' | tr -s '\n' ',' >> mempower.dat2
done

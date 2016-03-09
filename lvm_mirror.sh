#!/bin/bash
extendvg 
extendvg xxxvg  xxxdisk xxdisk 
/usr/sbin/extendvg '-f' 'testvg' 'hdisk11'
#aix  
time  /usr/sbin/mirrorvg xxxvg  hdiskxx  hdiskxx 
time  /usr/sbin/mirrorvg  -c'2' xxxvg  hdiskxx  hdiskxx 

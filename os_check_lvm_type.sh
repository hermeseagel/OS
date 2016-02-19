#!/bin/bash
#to get each VG PPSIZE  for future new Server design new VG size

AIX_OS_Data_collect() {
	dest='/tmp'
	logfile=`hostname`'-AIX.log'
	echo 'Saving Logfile in' $dest/$logfile
	echo "[OS Version]" `oslevel -s` > $dest/$logfile
	echo "[Hardward Infomation] " >> $dest/$logfile
	prtconf >>  $dest/$logfile
	echo "[Current PVS]"
	lspv >> $dest/$logfile 
	echo "[Current VGS]"
	lsvg >> $dest/$logfile
	echo '[VG PP size]' 
	vgs=`lsvg`
	for vg in $vgs
	do 
		echo "$vg:" `lsvg $vg | grep "PP SIZE" | awk '{ print $(NF-1)":"$(NF) }' `>> $dest/$logfile
		
		echo "$vg's lvs:" `lsvg $vg ` >> $dest/$logfile
	done
	echo "{Coollect System Envirment Varaibes}" >> $dest/$logfile
	echo "TIMEZONE:$TZ"  >> $dest/$logfile
	echo "LANGUAGE:$LANG" >>  $dest/$logfile
	echo "collect NETWORKINFO:" >> $dest/$logfile
	ifconfig -a >>  $dest/$logfile
	
}
Linux_OS_Data_collect(){
	dest='/tmp'
	logfile=`hostname`'-Linux.log'
	echo 'Saving Logfile in' $dest/$logfile 
	echo '[OS Version]'`lsb_release -a` > $dest/$logfile
	echo '[/OS Version]' >>$dest/$logfile
	echo '[Hardward Infomation]' >> $dest/$logfile
	dmidecode >> $dest/$logfile
	btrfs=`lsblk -f | awk 'NR>=1 {print $2} '| | egrep -i '.|btrfs' | uniq`
	
	if [ -d /etc/lvm ] ; then 
		echo '[PVS]' >> $dest/$logfile 
	   lvs >> $dest/$logfile
	   echo '[VGS]' `vgs -v` >> $dest/$logfile
	   echo '[lvs]' `lvs --all` >>  $dest/$logfile
	fi
	if [ $btrfs == 'btrfs' ] ; then 
		echo '[Btrfs infomation]' >> $dest/$logfile 
		mnts=`grep 'brtfs' /etc/fstab | awk '{ print $2 }'`
		for mnt in mnts 
		do
		echo '[Btrfs mountpoint' $mnt 'detail]'>> $dest/$logfile
		btrfs filesystem df $mnt >> $dest/$logfile
		done
		
	fi
}
SUN_OS_Data_collect(){
	dest='/tmp'
	logfile=`hostname`'-SunOS.log'
	echo 'Saving Logfile in' $dest/$logfile 
	echo '[OS Version]'  > $dest/$logfile
	cat /etc/release >> $dest/$logfile 
	echo '[Hardward Infomation]' >> $dest/$logfile
	prtconf >> $dest/$logfile
	echo '[/Hardward Infomation]' >> $dest/$logfile
	echo '[Disk Usages or Pool Usages ][/Disk]'>> $dest/$logfile
	if [ -f /sbin/zpool ] ; then 
		zpoolsize=`zpool list | awk 'NR>1 {print $1} '| wc -l`
		if [ $zpoolsize != 0 ] ; then 
			echo '[Zpool information]' >> $dest/$logfile
			zpool list >> $dest/$logfile 
			poolids=`zpool list | awk 'NR>1 {print $1} '`
			for  poolid in $poolids 
			do 
			echo '[ZPOOL]' $poolid >> $dest/$logfile
			zpool status $poolid >> $dest/$logfile
			echo '[/ZPOOL]' $poolid >> $dest/$logfile
			done
			echo '[ZFS usage]' >> $dest/$logfile
			zfs list >> $dest/$logfile
			echo '[/ZFS usage]' >> $dest/$logfile
		fi
	elif [ `grep -i 'ufs' /etc/vfstab | wc -l ` != 0 ] ; then
	 echo '[Ufs usage]' >> $dest/$logfile 
	 df -h  >> $dest/$logfile 
	fi
	echo '[Network infomation]' >> $dest/$logfile
	ifconfig -a >> $dest/$logfile
}

ostype=`uname`
if [ $ostype == 'AIX' ] ; then
	echo 'AIX Envirment '
	echo 'Begin collection Machine Info'
	AIX_OS_Data_collect
elif [ $ostype == 'Linux' ]; then
	echo 'Linux Envirment'
	echo 'Begin collection Machine Info'
	Linux_OS_Data_collect
elif [ $ostype == 'SunOS' ]; then 
	echo 'Solaris Envirment'
	echo 'Begin collection Machine Info'
	SUN_OS_Data_collect
elif [ $ostype == 'Darwin'  ] ; then 
	echo 'You are using MACOS, But I do not support for this platform'
elif [ $ostype == 'FreeBSD'  ] ; then 
	echo 'You are using FreeBSD, But I do not support for this platform'
else 
	echo "Don't Support"
fi 
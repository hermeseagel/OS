#!/bin/bash
#to get each VG PPSIZE  for future new Server design new VG size

AIX_OS_Data_collect() {
	dest='/tmp'
	logfile=`hostname`'-AIX.log'
	echo 'Saving Logfile in' $dest/$logfile
	echo "[OS Version]"  >  $dest/$logfile
	oslevel -s >> $dest/$logfile
	echo "[/OS Version]" >> $dest/$logfile

	echo "[Hardward Infomation] " >> $dest/$logfile
	prtconf >>  $dest/$logfile
	echo "[/Hardward Infomation] " >> $dest/$logfile
	echo "[Current PVS]"
	lspv >> $dest/$logfile 
	echo "[/Current PVS]" >> $dest/$logfile
	echo "[Current VGS]" >> $dest/$logfile
	lsvg >> $dest/$logfile
	echo "[/Current VGS]" >> $dest/$logfile
	echo '[VG PP size ]' >> $dest/$logfile
	vgs=`lsvg`
	
	
	for vg in $vgs
	do 
		echo "$vg PPSIZE:" `lsvg $vg | grep "PP SIZE" | awk '{ print $(NF-1)":"$(NF) }' `>> $dest/$logfile
		echo '[/VG PP size]'>> $dest/$logfile
		echo "[$vg's lvs:]"   >> $dest/$logfile
		lsvg -l $vg >> $dest/$logfile
		echo "[/$vg's lvs:]"   >> $dest/$logfile
	done
	 
	echo "[Coollect System Envirment Varaibes]" >> $dest/$logfile
	echo "TIMEZONE:$TZ"  >> $dest/$logfile
	echo "LANGUAGE:$LANG" >>  $dest/$logfile
	echo "collect NETWORKINFO:" >> $dest/$logfile
	ifconfig -a >>  $dest/$logfile
	echo "[collect fiber info]" >> $dest/$logfile
	fcs=`lsdev -C | grep fc | grep Available|awk '{ print $1}' `
	for fc in $fcs 
	do 
		echo "$fc WWN:" `lscfg -vl $fc | grep "Network Address"| awk -F. '{ print $(NF) }' ` >> $dest/$logfile
	done
	echo "[/ Coollect System Envirment Varaibes]" >> $dest/$logfile
	echo "[collect all filesystems]" >> $dest/$logfile
	df -m >> $dest/$logfile
	echo "[/collect all filesystems]" >> $dest/$logfile
	echo "[emc powerpath all lun]"  >> $dest/$logfile
	powermt display dev=all >> $dest/$logfile 
	echo "[/emc powerpath all lun]"  >> $dest/$logfile
	echo "[emc powerpath  all paths ]"  >> $dest/$logfile
	powermt display paths  >> $dest/$logfile
	echo "[/emc powerpath  all paths ]"  >> $dest/$logfile

	echo "[emc powerpath  all ports ]"  >> $dest/$logfile
	powermt display port_mode >> $dest/$logfile
	echo "[/emc powerpath  all ports ]"  >> $dest/$logfile

	echo "[emc powerpath  register infomation ]" >> $dest/$logfile
	powermt check_registration >> $dest/$logfile
	echo "[/emc powerpath  register infomation ]" >> $dest/$logfile
}

Linux_OS_Data_collect(){
	dest='/tmp'
	logfile=`hostname`'-Linux.log'
	echo 'Saving Logfile in' $dest/$logfile 
	echo '[OS Version]'`lsb_release -a` > $dest/$logfile
	echo '[/OS Version]' >>$dest/$logfile
	echo '[Hardward Infomation]' >> $dest/$logfile
	dmidecode >> $dest/$logfile
	btrfs=`lsblk -f | awk 'NR>=1 {print $2} '| egrep -i '.|btrfs' | uniq`
	
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
		fc_exist=`find / -name 'systool'`
	if [ $fc_exist != '' ] ; then 
		fc_flag=`systool -c fc_host | awk '{ print $1 }'`
		if [ "$fc_flag" != "Error" ] ; then 
			systool -c fc_host |grep Class |grep -v fc_host |awk '{print $4}' |cut -d '"' -f 2  >> $dest/$logfile 
		fi
	#elif 

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
	 echo '[/Ufs usage]' >> $dest/$logfile
	fi
	echo '[Network infomation]' >> $dest/$logfile
	ifconfig -a >> $dest/$logfile
	echo '[/Network infomation]' >> $dest/$logfile
	echo  '[]'
	
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
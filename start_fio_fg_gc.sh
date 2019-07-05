#!/bin/bash


function benchmark {
	umount /mnt
	if [ -z "$1" ]; then
		echo "Usage: $0 Test-name"
		exit
	fi
	echo "$1"
	cd ~/f2fs-tools/mkfs
	./mkfs.f2fs -t1 -a0 -m -f /dev/sdb1
	if [ $? != 0 ]; then
		exit
	fi
	mount -t f2fs /dev/sdb1 /mnt
	echo "mounted /dev/sdb1 /mnt"
	if [ $? != 0 ]; then
		exit
	fi
	echo 2313682943 > /sys/fs/f2fs/sdb1/gc_max_sleep_time
	echo 2313682943 > /sys/fs/f2fs/sdb1/gc_min_sleep_time
	echo 2313682943 > /sys/fs/f2fs/sdb1/gc_no_gc_sleep_time
	echo "gc parameters set"
	file="/home/surbhi/fio/examples/$1.fio"
	stat $file
	if [ $? != 0 ]; then
		umount /mnt
		exit
	fi
	cd /mnt
	for i in {1..95}
	do
		dir="/mnt/$i"
		echo $dir
		mkdir $dir
		cd $dir
		fio $file
		use=`df -h /mnt | tr -s " " | cut -d " " -f 5 | tail -1 | sed 's/\%//g'`
		if [ $use -gt 80 ]
		then
			break
		fi
	done
	./start_fio_fg_gc_2.sh
	ls -lh /mnt/
	#rm /mnt/$1
	mkdir -p /home/surbhi/benchmarks/fg_gc/bs_4K/$1
	#mv /mnt/* /home/surbhi/benchmarks/fg_gc/bs_4K/$1/
	#umount /mnt
}


echo "Starting benchmarking"
echo "-------------------------------"
echo "Blocksize = 4K"
echo "sequential read and write"
benchmark ftruncate 
#echo "sequential write"
#benchmark fio-seq-write
#echo "sequential read"
#benchmark fio-seq-read
echo "-------------------------------"

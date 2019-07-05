#!/bin/bash


function benchmark {
	if [ -z "$1" ]; then
		echo "Usage: $0 Test-name"
		exit
	fi
	echo "$1"

	file="/home/surbhi/linux/fio/examples/$1.fio"
	stat $file
	if [ $? != 0 ]; then
		exit
	fi
	cd /mnt
	mkdir /mnt/$1
	cd /mnt/$1
	fio $file
	if [ $? != 0 ]; then
		exit
	fi
	ls -lh /mnt/
}

function init {
	umount /mnt
	cd ~/linux/f2fs-tools/mkfs
	./mkfs.f2fs -t1 -a0 -m -f /dev/sdc1
	if [ $? != 0 ]; then
		exit
	fi
	mount -t f2fs /dev/sdc1 /mnt
	echo "mounted /dev/sdc1 /mnt"
	if [ $? != 0 ]; then
		exit
	fi
	echo 23313682943 > /sys/fs/f2fs/sdc/gc_max_sleep_time
	echo 2313682943 > /sys/fs/f2fs/sdc/gc_min_sleep_time
	echo 2313682943 > /sys/fs/f2fs/sdc/gc_no_gc_sleep_time
	echo "gc parameters set"
	for i in [1..2000]
	do
		benchmark ftruncate
		use=`df -h /mnt | tr -s " " | cut -f 5 -d " " | tail -1 | sed 's/\%//g'`
		if [ $use -gt 50 ]; then
			break;
		fi
	done

	echo 600 > /sys/fs/f2fs/sdc/gc_max_sleep_time
	echo 600 > /sys/fs/f2fs/sdc/gc_min_sleep_time
	echo 600 > /sys/fs/f2fs/sdc/gc_no_gc_sleep_time
	echo "gc parameters reset"
}
echo "Starting benchmarking"
echo "-------------------------------"
init
echo "Blocksize = 4K"
echo "sequential read and write"
benchmark fio-seq-RW
mkdir -p /home/surbhi/benchmarks/bg_gc/bs_4K/fio-seq-RW
cp /mnt/* /home/surbhi/benchmarks/bg_gc/bs_4K/fio-seq-RW
#echo "sequential write"
#benchmark fio-seq-write
echo "sequential read"
benchmark fio-seq-read
echo "-------------------------------"
umount /mnt

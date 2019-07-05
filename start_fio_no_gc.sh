#!/bin/bash


function benchmark {
	umount /mnt
	if [ -z "$1" ]; then
		echo "Usage: $0 Test-name"
		exit
	fi
	echo "$1"
	cd ~/f2fs-tools/mkfs
	./mkfs.f2fs -t1 -a0 -m -f /dev/sdb
	if [ $? != 0 ]; then
		exit
	fi
	mount -t f2fs /dev/sdb /mnt
	echo "mounted /dev/sdb /mnt"
	if [ $? != 0 ]; then
		exit
	fi
	echo 2313682943 > /sys/fs/f2fs/sdb/gc_max_sleep_time
	echo 2313682943 > /sys/fs/f2fs/sdb/gc_min_sleep_time
	echo 2313682943 > /sys/fs/f2fs/sdb/gc_no_gc_sleep_time
	echo "gc parameters set"
	file="/home/surbhi/fio/examples/$1.fio"
	stat $file
	if [ $? != 0 ]; then
		umount /mnt
		exit
	fi
	cd /mnt
	fio $file
	if [ $? != 0 ]; then
		exit
	fi
	ls -lh /mnt/
	rm /mnt/$1
	mkdir -p /home/surbhi/benchmarks/no-gc/bs_4K/$1
	mv /mnt/* /home/surbhi/benchmarks/no-gc/bs_4K/$1/
	umount /mnt
}


echo "Starting benchmarking"
echo "-------------------------------"
echo "Blocksize = 4K"
#echo "sequential read and write"
#benchmark fio-seq-RW
#echo "sequential write"
#benchmark fio-seq-write
echo "sequential read"
benchmark fio-seq-read
echo "-------------------------------"

#!/bin/bash


function benchmark {
	if [ -z "$1" ]; then
		echo "Usage: $0 Test-name"
		exit
	fi
	echo "$1"
	echo 600 > /sys/fs/f2fs/sdb/gc_max_sleep_time
	echo 600 > /sys/fs/f2fs/sdb/gc_min_sleep_time
	echo 600 > /sys/fs/f2fs/sdb/gc_no_gc_sleep_time
	echo "gc parameters set"
	file="/home/surbhi/fio/examples/$1.fio"
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
	mkdir -p /home/surbhi/benchmarks/bg-gc/bs_4K/$1
	cp /mnt/$1/*.log /home/surbhi/benchmarks/fg-gc/bs_4K/$1/
}

echo "Starting benchmarking"
echo "-------------------------------"
echo "Blocksize = 4K"
benchmark fio-seq-RW
#echo "sequential write"
#benchmark fio-seq-write
#echo "sequential read"
#benchmark fio-seq-read
#umount /mnt
echo "-------------------------------"

#!/bin/bash

OPTION_TYPE=$1
cache_size=$2
kv_size=$3
TEST=$4

if [ "$#" -lt "4" ]; then
	echo "insert option type, cache_size, kv_size, TEST"
	exit 1
fi

output_name_key="${OPTION_TYPE}_key_${kv_size}_t"
output_name_size="_${cache_size}mb"
output_name_txt=".txt"
output_name_csv=".csv"
all="*"
sum="_sum.txt"
data_dir="/samsung_zssd/YCSB/unify_${kv_size}"

cp ../rocksdb/java/target/rocksdbjni-7.3.0.jar rocksdb/target/dependency

#array=(1 2 4 8 12 16 20 24)
array=(64)
for threads in "${array[@]}"
do
	echo 3 > /proc/sys/vm/drop_caches

	if [ $TEST -eq 1 ]; then
		output_name=${output_name_key}${threads}${output_name_size}${output_name_txt}
		rm -r output/bandwidth/$output_name_key$threads$output_name_size
		mkdir output/bandwidth/$output_name_key$threads$output_name_size
	else
		echo "Only for TEST"
	fi

	killall iostat 2> /dev/null
	killall vmstat 2> /dev/null

	if [ $TEST -eq 1 ]; then
		iostat -m 1 >& output/bandwidth/$output_name &
		iopid=$!

		vmstat -a 1 >& output/vmstat/$output_name &
		vmpid=$!
	fi

#	while :; do du -hs $dbdir; date ; sleep 10; done >& output/duid/$output_name &
#	duid1=$!

#	while :; do ps aux | grep db_bench | grep -v grep | tail -1; sleep 10; done >& output/psid/$output_name &
#	psid=$!

#	bin/ycsb.sh run rocksdb -s -P workloads/workloadc -p rocksdb.dir=/home/jwpark/zssd/YCSB/YCSB_key_48 -threads $threads -p zeropadding=44 -p fieldlength=33 -p fieldcount=1 -p maxexecutiontime=100 | tee output/$output_name
	
	if [ $TEST -eq 1 ]; then
        head /proc/stat -n 1 > before_cpu_${cache_size}mb_kv${kv_size}_${threads}.txt
		cat /proc/diskstats > before_disk_${cache_size}mb_kv${kv_size}_${threads}.txt
    fi

	if [ ${kv_size} -eq 100 ]; then
        flength=56
    elif [ ${kv_size} -eq 1024 ]; then
        flength=980
	elif [ ${kv_size} -eq 4096 ]; then
		flength=4052
    fi

	bin/ycsb.sh run rocksdb -s -P workloads/workloadc_${kv_size} -p rocksdb.dir=${data_dir} -threads $threads -p fieldlength=${flength} -p fieldcount=1 -p maxexecutiontime=1000 2>&1 | tee output/out/${output_name}

	if [ $TEST -eq 1 ]; then
		head /proc/stat -n 1 > after_cpu_${cache_size}mb_kv${kv_size}_${threads}.txt
		cat /proc/diskstats > after_disk_${cache_size}mb_kv${kv_size}_${threads}.txt

		kill $iopid
	    kill $vmpid
#    kill $duid1
#    kill $psid
		cd output/bandwidth
		mv $output_name_key$threads$output_name_size$output_name_txt $output_name
		python3 bw.py $output_name
	    output_name="$output_name_key$threads$output_name_size$output_name_csv"
	    sum_output="$output_name_key$threads$output_name_size$sum"
    	python3 sum.py $output_name > $sum_output
    	mv $output_name_key$threads$output_name_size$all $output_name_key$threads$output_name_size
    	cd ../../
	fi

done
#bin/ycsb.sh run rocksdb -s -P workloads/workloadc -p rocksdb.dir=/home/jwpark/zssd/uniform_test -p maxexecutiontime=100 -threads 8
#bin/ycsb.sh run rocksdb -s -P workloads/workloadc -p rocksdb.dir=/home/jwpark/zssd/YCSB/YCSB_key_48 -threads 24 #-p maxexecution=100


#bin/ycsb.sh run rocksdb -s -P workloads/workloadc -p rocksdb.dir=/home/jwpark/zssd/YCSB/test -threads 12 -p maxexecutiontime=100


# for 3GB
#echo 3 > /proc/sys/vm/drop_caches
#cp ../rocksdb/java/target/rocksdbjni-7.3.0.jar rocksdb/target/dependency
#bin/ycsb.sh run rocksdb -s -P workloads/workloadc -p rocksdb.dir=/home/jwpark/zssd/uniform_test -p maxexecutiontime=100 -threads 8

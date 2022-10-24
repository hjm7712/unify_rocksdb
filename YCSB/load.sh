load_file_name=$1
kv_size=$2

if [ "$#" -lt "2" ]; then
    echo "Enter load file name, kv_size"
    exit 1
fi

n_thrd=32

data_dir="/samsung_zssd/YCSB/unify_${kv_size}_8k"

rm ${data_dir}/*
echo 3 > /proc/sys/vm/drop_caches
cp ../rocksdb/java/target/rocksdbjni-7.3.0.jar rocksdb/target/dependency
#bin/ycsb.sh load rocksdb -s -P workloads/workloadc -p rocksdb.dir=/home/mldb01/work/test -threads 16

#bin/ycsb.sh load rocksdb -s -P workloads/workloadc -p rocksdb.dir=/home/mldb01/work/100G_test -threads 16
#bin/ycsb.sh load rocksdb -s -P workloads/workloadc -p rocksdb.dir=/home/jwpark/zssd/YCSB/ycsb_key_48 -threads 24 -p maxexecutiontime=10 -p zeropadding=44 -p fieldlength=29 -p fieldcount=1

if [ ${kv_size} -eq 100 ]; then
	flength=56
elif [ ${kv_size} -eq 1024 ]; then
	flength=980
elif [ ${kv_size} -eq 4096 ]; then
	flength=4052
fi

#killall iostat 2> /dev/null
#killall vmstat 2> /dev/null

bin/ycsb.sh load rocksdb -s -P workloads/workloadc_1 -p rocksdb.dir=${data_dir} -threads ${n_thrd} -p fieldlength=${flength} -p fieldcount=1 #-p maxexecutiontime=1


#iostat -m 1 >& load_data/load_KV_${kv_size}.txt
#iopid=$!

#vmstat -m 1 >& load_data/load_KV_${kv_size}.txt
#vmpid=$!

head /proc/stat -n 1 > load_data/before_cpu_${load_type}_KV_${kv_size}_8k.txt
cat /proc/diskstats > load_data/before_disk_${load_type}_KV_${kv_size}_8k.txt

bin/ycsb.sh load rocksdb -s -P workloads/workloadc_${kv_size} -p rocksdb.dir=${data_dir} -threads ${n_thrd} -p fieldlength=${flength} -p fieldcount=1 2>&1 | tee load_data/${load_file_name}.txt

head /proc/stat -n 1 > load_data/after_cpu_${load_type}_KV_${kv_size}_8k.txt
cat /proc/diskstats > load_data/after_disk_${load_type}_KV_${kv_size}_8k.txt

#kill $iopid
#kill $vmpid



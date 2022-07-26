#threads=$1
output_name_key="key_48_t"
output_name_size="_10mb"
output_name_txt=".txt"
output_name_csv=".csv"
all="*"
sum="_sum.txt"

#array=(1 2 4 8 12 16 20 24)
array=(24)
for threads in "${array[@]}"
do
	echo 3 > /proc/sys/vm/drop_caches

	output_name="$output_name_key$threads$output_name_size$output_name_txt"
	rm -r output/bandwidth/$output_name_key$threads$output_name_size
	mkdir output/bandwidth/$output_name_key$threads$output_name_size
	timeout 101s iostat -m 1 > output/bandwidth/$output_name &
	./script_db_bench.sh $threads | tee output/$output_name

	sleep 1

	cd output/bandwidth
	python3 bw.py $output_name
	output_name="$output_name_key$threads$output_name_size$output_name_csv"
	sum_output="$output_name_key$threads$output_name_size$sum"
	python3 sum.py $output_name > $sum_output
	mv $output_name_key$threads$output_name_size$all $output_name_key$threads$output_name_size
	cd ../../
done

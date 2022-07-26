_10_mb=$((10*1024*1024))
_60_mb=$((60*1024*1024))
_100_mb=$((100*1024*1024))
_256_mb=$((256*1024*1024))
_10_gb=$((10*1024*1024*1024))

THREADS=$1
########## SEED ##########
# mixgraph/origin: seed 1
##########################

:<<'END'
./db_bench \
		--benchmarks=mixgraph \
		--threads=8 \
		--key_size=24 \
		--value_size=1000 \
		--cache_size=${cache_size} \
		--num=3000000000 \
		--use_direct_reads=true \
		--use_direct_io_for_flush_and_compaction \
		--use_existing_db \
		--db=/home/jwpark/zssd/db_bench \
		--duration=60 \
		-mix_put_ratio=0 \
		-mix_get_ratio=1 \
		-compression_type=none \
		-cache_index_and_filter_blocks=true \
		-bloom_bits=10 \
		-pin_top_level_index_and_filter=true \
		-partition_index_and_filters=true \
		-histogram=true
END

:<<'END'
./db_bench \
  --benchmarks="mixgraph" \
  --threads=8 \
  --use_existing_db \
  --db=/home/jwpark/zssd/db_bench \
  --key_size=24 \
  --value_size=1000 \
  -use_direct_io_for_flush_and_compaction=true \
  -use_direct_reads=true \
  -cache_size=${_256_mb} \
  -keyrange_dist_a=14.18 \
  -keyrange_dist_b=-2.917 \
  -keyrange_dist_c=0.0164 \
  -keyrange_dist_d=-0.08082 \
  -keyrange_num=30 \
  -value_k=0.2615 \
  -value_sigma=25.45 \
  -iter_k=2.517 \
  -iter_sigma=14.236 \
  -mix_get_ratio=1 \
  -mix_put_ratio=0 \
  -mix_seek_ratio=0 \
  -sine_mix_rate_interval_milliseconds=5000 \
  -sine_a=1000 \
  -sine_b=0.000073 \
  -sine_d=4500 \
  --perf_level=2 \
  -num=100000000 \
  --duration=200 
#  -cache_index_and_filter_blocks=true \
#  -bloom_bits=10 \
#  -pin_top_level_index_and_filter=true \
#  -partition_index_and_filters=true \
END

#all_random
:<<'END'
./db_bench \
  --benchmarks="mixgraph" \
  --threads=$THREADS \
  -seed=1 \
  --use_existing_db \
  --db=/home/jwpark/zssd/mixgraph/origin \
  -key_size=48 \
  -cache_index_and_filter_blocks=true \
  -bloom_bits=10 \
  -partition_index_and_filters=true \
  -pin_top_level_index_and_filter=false \
  -use_direct_io_for_flush_and_compaction=true \
  -use_direct_reads=true \
  -cache_size=${_10_mb} \
  -keyrange_dist_a=14.18 \
  -keyrange_dist_b=-2.917 \
  -keyrange_dist_c=0.0164 \
  -keyrange_dist_d=-0.08082 \
  -keyrange_num=1 \
  -value_k=0.2615 \
  -value_sigma=25.45 \
  -iter_k=2.517 \
  -iter_sigma=14.236 \
  -mix_get_ratio=1 \
  -mix_put_ratio=0 \
  -mix_seek_ratio=0 \
  -sine_mix_rate_interval_milliseconds=5000 \
  -sine_a=1000 \
  -sine_b=0.000073 \
  -sine_d=4500 \
  --perf_level=1 \
  -num=1600000000 \
  -compression_type=none \
  -duration=100 \
  --statistics
END


#all_dist
:<<'END'
./db_bench \
  --benchmarks="mixgraph" \
  --threads=$THREADS \
  -seed=1 \
  --use_existing_db \
  --db=/home/jwpark/zssd/mixgraph/origin \
  -key_size=48 \
  -value_size=43 \
  -cache_index_and_filter_blocks=true \
  -bloom_bits=10 \
  -partition_index_and_filters=true \
  -pin_top_level_index_and_filter=false \
  -use_direct_io_for_flush_and_compaction=true \
  -use_direct_reads=true \
  -cache_size=${_10_mb} \
  -key_dist_a=0.002312 \
  -key_dist_b=0.3467 \
  -keyrange_num=1 \
  -value_k=0.2615 \
  -value_sigma=25.45 \
  -iter_k=2.517 \
  -iter_sigma=14.236 \
  -mix_get_ratio=1 \
  -mix_put_ratio=0 \
  -mix_seek_ratio=0 \
  -sine_mix_rate_interval_milliseconds=5000 \
  -sine_a=1000 \
  -sine_b=0.000073 \
  -sine_d=4500 \
  --perf_level=1 \
  -num=1600000000 \
  -compression_type=none \
  -duration=100 \
  --statistics
END

#prefix_random
:<<'END'
./db_bench \
  --benchmarks="mixgraph" \
  --threads=$THREADS \
  -seed=1 \
  --use_existing_db \
  --db=/home/jwpark/zssd/mixgraph/origin \
  -key_size=48 \
  -cache_index_and_filter_blocks=true \
  -bloom_bits=10 \
  -partition_index_and_filters=true \
  -pin_top_level_index_and_filter=false \
  -use_direct_io_for_flush_and_compaction=true \
  -use_direct_reads=true \
  -cache_size=${_10_mb} \
  -keyrange_dist_a=14.18 \
  -keyrange_dist_b=-2.917 \
  -keyrange_dist_c=0.0164 \
  -keyrange_dist_d=-0.08082 \
  -keyrange_num=30 \
  -value_k=0.2615 \
  -value_sigma=25.45 \
  -iter_k=2.517 \
  -iter_sigma=14.236 \
  -mix_get_ratio=1 \
  -mix_put_ratio=0 \
  -mix_seek_ratio=0 \
  -sine_mix_rate_interval_milliseconds=5000 \
  -sine_a=1000 \
  -sine_b=0.000073 \
  -sine_d=4500 \
  --perf_level=1 \
  -num=1600000000 \
  -compression_type=none \
  -duration=100 \
  --statistics
END

#prefix_dist
#:<<'END'
./db_bench \
  --benchmarks="mixgraph" \
  --threads=$THREADS \
  -seed=1 \
  --use_existing_db=1 \
  --db=/home/jwpark/zssd/mixgraph/origin \
  -key_size=48 \
  -cache_index_and_filter_blocks=true \
  -bloom_bits=10 \
  -partition_index=true \
  -partition_index_and_filters=true \
  -pin_top_level_index_and_filter=false \
  -use_direct_io_for_flush_and_compaction=true \
  -use_direct_reads=true \
  -cache_size=${_60_mb} \
  -key_dist_a=0.002312 \
  -key_dist_b=0.3467 \
  -keyrange_dist_a=14.18 \
  -keyrange_dist_b=-2.917 \
  -keyrange_dist_c=0.0164 \
  -keyrange_dist_d=-0.08082 \
  -keyrange_num=30 \
  -value_k=0.2615 \
  -value_sigma=25.45 \
  -iter_k=2.517 \
  -iter_sigma=14.236 \
  -mix_get_ratio=1 \
  -mix_put_ratio=0 \
  -mix_seek_ratio=0 \
  -sine_mix_rate_interval_milliseconds=5000 \
  -sine_a=1000 \
  -sine_b=0.000073 \
  -sine_d=4500 \
  -num=1600000000 \
  -compression_type=none \
  -duration=10 \
  --statistics
#  --perf_level=1 \
#END


:<<'END'
./db_bench \
		--benchmarks="fillrandom" \
		--threads=1 \
		-seed=1 \
		-use_direct_io_for_flush_and_compaction=true \
		-use_direct_reads=true \
		--db=/home/jwpark/zssd/mixgraph/origin \
		-max_background_compactions=17 \
		-max_background_flushes=6 \
		--cache_size=${_10_gb} \
		--key_size=48 \
		--value_size=43 \
		-num=1600000000 \
		-cache_index_and_filter_blocks=true \
		-bloom_bits=10 \
		-pin_top_level_index_and_filter=true \
		-partition_index_and_filters=true \
		-writable_file_max_buffer_size=67108864 \
		-subcompactions=6 \
		-level0_file_num_compaction_trigger=8 \
		-max_write_buffer_number=8 \
		-level0_slowdown_writes_trigger=60 \
		-compression_type=none 
#		-numdistinct=100000000 \
#		-compression_ratio=1 \
END

#prefix_dist_write
:<<'END'
./db_bench \
  --benchmarks="mixgraph" \
  --threads=$THREADS \
  -seed=2 \
  --db=/home/jwpark/zssd/mixgraph/tmp \
  --key_size=48 \
  --value_size=43 \
  -cache_index_and_filter_blocks=true \
  -bloom_bits=10 \
  -partition_index_and_filters=true \
  -pin_top_level_index_and_filter=false \
  -use_direct_io_for_flush_and_compaction=true \
  -use_direct_reads=true \
  -cache_size=${_10_gb} \
  -key_dist_a=0.002312 \
  -key_dist_b=0.3467 \
  -keyrange_dist_a=14.18 \
  -keyrange_dist_b=-2.917 \
  -keyrange_dist_c=0.0164 \
  -keyrange_dist_d=-0.08082 \
  -keyrange_num=30 \
  -value_k=0.2615 \
  -value_sigma=25.45 \
  -iter_k=2.517 \
  -iter_sigma=14.236 \
  -mix_get_ratio=0 \
  -mix_put_ratio=1 \
  -mix_seek_ratio=0 \
  -sine_mix_rate_interval_milliseconds=5000 \
  -sine_a=1000 \
  -sine_b=0.000073 \
  -sine_d=4500 \
  --perf_level=1 \
  -num=160000000 \
  -compression_type=none \
  -duration=100 \
  --statistics
END


# Yahoo! Cloud System Benchmark
# Workload C: Read only
#   Application example: user profile cache, where profiles are constructed elsewhere (e.g., Hadoop)
#                        
#   Read/update ratio: 100/0
#   Default data size: 1 KB records (10 fields, 100 bytes each, plus key)
#   Request distribution: zipfian

#recordcount=200000000
#operationcount=200000000
#recordcount=1600000000
#operationcount=16000000
#operationcount=400000
#operationcount=64000000

#recordcount=1100000000
#operationcount=1100000000

recordcount=16000000
operationcount=16000000

workload=com.yahoo.ycsb.workloads.CoreWorkload

readproportion=1
updateproportion=0
scanproportion=0
insertproportion=0

requestdistribution=zipfian

fieldlength=43

fieldcount=1

readallfields=true

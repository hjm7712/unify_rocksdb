import pandas as pd
import sys
if __name__ == "__main__":
	file_name = sys.argv[1]
	trace_input_file = open(file_name, 'r')
	lines = trace_input_file.readlines()
	sum_ = 0
	count = 0
	for line in lines:
		if line.split(',')[0] == "Read Bandwidth":
			continue
		sum_ += int(line.split(',')[0])
		count += 1
	print(sum_/count)
	trace_input_file.close()


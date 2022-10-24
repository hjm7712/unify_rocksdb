import pandas as pd
import sys
if __name__ == "__main__":
	file_name = sys.argv[1]
	trace_input_file = open(file_name, 'r')
	lines = trace_input_file.readlines()
	bandwidth = []
	
	for line in lines:
		value_count = 0
		zero_stream_start = False
		read_bandwidth = 0
		write_bandwidth = 0
		if len(line)>1 and line.split()[0] == "nvme0n1":
			rb = int(line.split()[5])
			wb = int(line.split()[6])
			bandwidth.append([rb, wb])
	bandwidth_df = pd.DataFrame(bandwidth, columns=['Read Bandwidth', 'Write Bandwidth'])
	bandwidth_df.to_csv("Bandwidth.csv", index=None)
	trace_input_file.close()


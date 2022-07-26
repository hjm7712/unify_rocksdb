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
#			for iter_ in range(len(line)):
#				if line[iter_] == ' ' and zero_stream_start == False:
#					zero_stream_start = True
#					continue
#				elif line[iter_] != ' ' and zero_stream_start == True:
#					zero_stream_start = False
#					value_count += 1
#				if value_count == 5:
#					parse_string = int(line[iter_:].split()[0])
#					read_bandwidth = parse_string
#				elif value_count == 6:
#					parse_string = int(line[iter_:].split()[0])
#					write_bandwidth = parse_string
#					bandwidth.append([read_bandwidth, write_bandwidth])
#					break
	bandwidth_df = pd.DataFrame(bandwidth, columns=['Read Bandwidth', 'Write Bandwidth'])
	output_name = file_name.split('.')[0]+(".csv")
	bandwidth_df.to_csv(output_name, index=None)
	trace_input_file.close()


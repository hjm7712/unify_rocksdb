import pandas as pd
import sys
if __name__ == "__main__":
	file_name = sys.argv[1]
	trace_input_file = open(file_name, 'r')
	lines = trace_input_file.readlines()
	throughput = []
	f_on = 0
	i_on = 0
	d_on = 0
	f = []
	i = []
	d = []
	check = 0
	for line in lines:
		if line == '\n':
			continue
		if line.find("[READ:") != -1:
			thr = int(line.split(sep="[READ:")[1].split(sep="Count=")[1].split(',')[0])
			throughput.append([thr])
		if line.find("TIME_END") != -1:
			break
		if line.find("TIME") != -1:
			check = 1
			continue
		if check == 1:
			if line.find("FILTER") != -1:
				f_on = 1
				continue
			if line.find("INDEX") != -1:
				f_on = 0
				i_on = 1
				continue
			if line.find("DATA") != -1:
				i_on = 0
				d_on = 1
				continue
			if f_on == 1:
				f.append(int(line.split('\n')[0]))
			if i_on == 1:
				i.append(int(line.split('\n')[0]))
			if d_on == 1:
				d.append(int(line.split('\n')[0]))

	throughput_df = pd.DataFrame(throughput, columns=['Throughput'])
	f_io_df = pd.DataFrame(f, columns=['Filter'])
	i_io_df = pd.DataFrame(i, columns=['Index'])
	d_io_df = pd.DataFrame(d, columns=['Data'])

	output_name = file_name.split('/')[2].split('.')[0]+(".csv")
	throughput_df.to_csv(output_name, index=None)

#	f_output_name = file_name.split('/')[2].split('.')[0]+("_filter.csv")
#	f_io_df.to_csv(f_output_name, index=None)

#	i_output_name = file_name.split('/')[2].split('.')[0]+("_index.csv")
#	i_io_df.to_csv(i_output_name, index=None)

#	d_output_name = file_name.split('/')[2].split('.')[0]+("_data.csv")
#	d_io_df.to_csv(d_output_name, index=None)

	trace_input_file.close()

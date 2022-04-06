# Script to convert .edf files to the CSV format

import numpy as np
import mne
import sys 

edf = mne.io.read_raw_edf(f'{sys.argv[1]}')
header = ','.join(edf.ch_names)
np.savetxt('your_csv_file.csv', edf.get_data().T, delimiter=',', header=header)


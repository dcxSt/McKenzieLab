# mouse data

The toy data is a 1.3G .edf file containing invasive EEG mouse recordings. When converted to the .csv data format the filesize balloons to 16G. I was unable to efficiently run the relevant IHKA on such files, so I going to take a 15minute sample and perform all my tests on that. The 16G CSV is a 24h recording, we can divide this number by 24\*4 for our sample, which is roughly 166M. 

To start with, I couldn't find the sample rate, but I assume it's roughly 2000Hz because I used 2000000 data points and the resulting file size was 194M. 



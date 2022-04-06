f = open("data_20min.csv",'r')
fnew = open("data_15min.csv","w")

for i in range(2000000):
    fnew.write(f.readline())

f.close()
fnew.close()


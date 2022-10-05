import numpy as np

#Year, doy, hour w1 w2 w3 w4 w5 w6
#0;1;2;17;18;19;20;21;22

def process(years, path):
	with open('OMNI_W1_W6.dat', 'w') as file:
		for iYear in years:#read all prepared "final" files
			with open(path + str(iYear) + "_out_final.dat", 'r') as inFile:
				lines = inFile.readlines()#[::12]
				for line in lines:#append all lines with minute 0 to properly formatted output file
					sLine = np.array(line.split())
					if(int(sLine[3]) != 0): #only consider lines where minute of the hour is 0
						continue
					(year, doy, hour, w1, w2, w3, w4, w5, w6) = np.take(sLine, [0,1,2,17,18,19,20,21,22]) #extract only columns needed further
					(year, doy, hour, w1, w2, w3, w4, w5, w6) = (int(year), int(doy), int(hour), float(w1), float(w2), float(w3), float(w4), float(w5), float(w6))
					outLine = "{0:4d} {1:3d} {2:2d} {3:6.2f} {4:6.2f} {5:6.2f} {6:6.2f} {7:6.2f} {8:6.2f}\n".format(year, doy, hour, w1, w2, w3, w4, w5, w6)
					#outLine = "{} {} {} {} {} {} {} {} {}\n".format(year, doy, hour, w1, w2, w3, w4, w5, w6) #more compact youput format
					#print(outLine)
					file.write(outLine)

#yearsGlob = range(1995, 2022+1)
#process(yearsGlob, "./temp_dir/")

import requests, sys, os, subprocess
import numpy as np
import process_w
from datetime import datetime
from astropy.time import Time
from astropy.time import TimeDelta
from html.parser import HTMLParser
from pyquery import PyQuery
from multiprocessing import Pool, cpu_count

varsArray = [
    '4','5','6','7',
    '8','9','10','11','12',
    '13','14','15','16',
    '17','18','19','20',
    '21','22','23','24',
    '25','26','27','28',
    '29','30',
    '31','32','33',
    '34','35','36',
    ]
varsArray = [
    '4','5','6','7',
    '8','9','10','11','12',
    '13','14','15','16',
    '17','18','19','20',
    '21','22','23','24',
    '25','26','44',
    '27','28','29',
    '30','45',
    '31','32','33',
    '34','35','36',
    '37','38','39',

    '40','41','42','43',
    '46','47','48',
    ]
varsLen = len(varsArray)

def getTrueEndDate():
    trueEndDatetime = Time(datetime.utcnow(), scale='utc').strftime('%Y%m%d')
    payload = {'activity': 'retrieve', 'res': '5min', 'spacecraft': 'omni_5min_def', 'start_date': trueEndDatetime, 'end_date': trueEndDatetime, 'vars': varsArray}
    r = requests.get(baseUrl, params=payload)
    pq = PyQuery(r.text)

    if pq('h1').text() == "Error":
        trueEndDatetime = pq('tt').text().split()[-1]
    (year, month, day) = (int(trueEndDatetime[0:4]), int(trueEndDatetime[4:6]), int(trueEndDatetime[6:8]))
    print(year, month, day)
    endDatetimeGlobal = Time(datetime(year, month, day))
    return endDatetimeGlobal

def get5minDataForDates(startDate, endDate):
    print(startDate, endDate)
    payload = {'activity': 'retrieve', 'res': '5min', 'spacecraft': 'omni_5min_def', 'start_date': startDate, 'end_date': endDate, 'vars': varsArray}
    r = requests.get(baseUrl, params=payload)
    outputArray = r.text.split('\n')
    trimmedArray = outputArray[(7 + varsLen):-16]
    return "\n".join(trimmedArray)

def runTsyganenkoRoutines(dirName, year):
    result = subprocess.run(["./fortran/wIndices0", dirName+str(year)+".dat", dirName+str(year)+"_out_0.dat"], capture_output=True, text=True)
    print(result.stdout)
    print(result.stderr)
    print("--------------------")
    result = subprocess.run(["./fortran/wIndices1", dirName+str(year)+"_out_0.dat", dirName+str(year)+"_out_1.dat"], capture_output=True, text=True)
    print(result.stdout)
    print(result.stderr)
    print("--------------------")
    result = subprocess.run(["./fortran/wIndices2", dirName+str(year)+"_out_1.dat", dirName+str(year)+"_lists.dat"], capture_output=True, text=True)
    print(result.stdout)
    print(result.stderr)
    print("--------------------")
    result = subprocess.run(["./fortran/wIndices3", dirName+str(year)+"_out_1.dat", dirName+str(year)+"_out_final.dat", dirName+str(year)+"_lists.dat", str(year)], capture_output=True, text=True)
    print(result.stdout)
    print(result.stderr)
    print("--------------------")

def parallelPullOmni(year):
	st = Time(str(year)+'-01-01 00:00:00', scale='utc').strftime('%Y%m%d')
	end = Time(str(year)+'-12-31 00:00:00', scale='utc').strftime('%Y%m%d')
	if(year == lastYear):
		end = endDatetimeGlobal.strftime('%Y%m%d')
	dataArray = get5minDataForDates(st, end)
	with open("temp_dir/"+str(year)+".dat", 'w') as file:
		file.write(dataArray)

baseUrl = "https://omniweb.gsfc.nasa.gov/cgi/nx1.cgi"
endDatetimeGlobal = getTrueEndDate()
print(str(endDatetimeGlobal.strftime('%Y%m%d')))
lastYear = int(Time(datetime.utcnow(), scale='utc').strftime('%Y'))

os.makedirs("temp_dir",exist_ok=True)

with Pool(processes = cpu_count()) as pool:
	for year in range(1995, lastYear + 1):
		pool.apply_async(parallelPullOmni, [year])
	pool.close()
	pool.join()

with open('update_history.dat', 'a') as file:
   file.write(str(Time(datetime.utcnow(), scale='utc').strftime('%Y%m%d %H:%M:%S')) + " " + endDatetimeGlobal.strftime('%Y%m%d') + "\n")

with Pool(processes = cpu_count()) as pool:
	for year in range(1995, lastYear + 1):
		pool.apply_async(runTsyganenkoRoutines, ["temp_dir/", year])
	pool.close()
	pool.join()

process_w.process(range(1995, lastYear + 1), "./temp_dir/")

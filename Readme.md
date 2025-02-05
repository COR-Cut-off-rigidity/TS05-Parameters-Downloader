# TS05 Parameters Downloader

This script downloads **5 minute interval** data from **omni_5min_def** spacecraft (dataset) from [OmniWeb](https://omniweb.gsfc.nasa.gov/). Data is valid for interval **1.1.1995** until **newest available data**. Which are then used to evaluate W1..W6 indices needed for [TS05](https://geo.phys.spbu.ru/~tsyganenko/empirical-models/magnetic_field/ts05) external magnetic field model. This script uses multithreading and so will utilize your CPU as much as possible.

## Requirements

To run the script you need [Python](https://www.python.org/) and [pip](https://pypi.org/project/pip/) installed. This script was developed with **Python 3.10.6**, but it might work with earlier versions. To install the required packages just run `pip3 install -r requirements.txt`.

### Additional requirements

This script relies on Fortran programs originally developed by Dr. N. A. Tsyganenko available from his [website](https://geo.phys.spbu.ru/~tsyganenko/TS05_data_and_stuff/). To compile them you will need a Fortran compiler for example the [GNU Fortran](https://www.gnu.org/software/gcc//fortran/) compiler. On Ubuntu, you can install it with the command `sudo apt install gfortran`. Original versions of these scripts can be found here:

- [Fill_IMF_gaps.for](https://geo.phys.spbu.ru/~tsyganenko/TS05_data_and_stuff/Fill_IMF_gaps.for)
- [Fill_SW_gaps.for](https://geo.phys.spbu.ru/~tsyganenko/TS05_data_and_stuff/Fill_SW_gaps.for)
- [Prepare_intervals_1.for](https://geo.phys.spbu.ru/~tsyganenko/TS05_data_and_stuff/Prepare_intervals_1.for)
- [Prepare_input_4.for](https://geo.phys.spbu.ru/~tsyganenko/TS05_data_and_stuff/Prepare_input_4.for)

For better interoperability changes were made. These programs can be found in the **/fortran/** directory. To compile them run `bash compile.sh` and to test them run `bash test.sh`.

Besides them, you will also need the [Parameters.par](https://geo.phys.spbu.ru/~tsyganenko/models/ts05/Parameters.par) file.

## Run instructions

If you have all the requirements, you just need to run `python3 ./pull_w.py`

## Output file description

Data is stored in the output file with the name `OMNI_W1_W6.dat` which contains 9 columns. The description of each column is following:

1. `year` specifying the year;
2. `doy` specifying the Day of Year;
3. `hour` specifying the hour;
4. `W1` parameter value for a given timestamp
5. `W2` parameter value for a given timestamp
6. `W3` parameter value for a given timestamp
7. `W4` parameter value for a given timestamp
8. `W5` parameter value for a given timestamp
9. `W6` parameter value for a given timestamp

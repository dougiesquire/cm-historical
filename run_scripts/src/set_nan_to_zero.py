#!/bin/bash

import sys
import numpy as np
import os.path
from netCDF4 import Dataset

#=========================================================================
if __name__ == '__main__':

    print("\n=========================================================")
    print("Running code {0}".format(sys.argv[0]))
    if (len(sys.argv)!=2):
        print("   Invalid number of arguments.")
        print("   Usage: {0} <filename>\n".format(sys.argv[0]))
        print("      number of arguments provided = {0}".format(len(sys.argv)-1))
        sys.exit()
    filename  = sys.argv[1]

    print("\nReading file {0} ...".format(filename))
    ifile_fid   = Dataset(filename, 'r+')
    print(list(ifile_fid.variables.keys()))

    for var_name in list(ifile_fid.variables.keys()):
        field = ifile_fid.variables[var_name][:]
        filt = (field>-1.0e20)
        field[~filt] = 0.0
        ifile_fid.variables[var_name][:] = field
    ifile_fid.close(); del ifile_fid
    
    print("\nEnd of Program")
    print("=========================================================\n\n")


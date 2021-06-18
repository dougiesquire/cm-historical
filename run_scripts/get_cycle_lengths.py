#!/usr/bin/env python3

import sys
import datetime

if __name__ == '__main__':
        if (len(sys.argv)<4):
                print("   Invalid number of arguments.")
                print("   Usage: {0} <year(s)> <reference_year> <reference_month> <reference_day> <run_length_in_months>\n".format(sys.argv[0]))
                print("      number of arguments provided = {0}".format(len(sys.argv)-1))
                sys.exit()
        years = sys.argv[1:-4]
        reference_year = sys.argv[-4]
        reference_month = sys.argv[-3]
        reference_day = sys.argv[-2]
        run_length = sys.argv[-1]
        start_date = datetime.datetime(int(reference_year), int(reference_month), int(reference_day))
        num_months = []
        for year in years:
            end_date = datetime.datetime(int(year), 1, 1)
            num_months.append((end_date.year - start_date.year) * 12 + (end_date.month - start_date.month))
            start_date = end_date
        num_months.append(int(run_length) - sum(num_months))
        print(' '.join([str(n) for n in num_months]))

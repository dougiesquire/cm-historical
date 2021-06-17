#!/bin/bash

. settings.sh

num_cycles=`cat CYCLE_END.txt`
Y_CA=`echo $this_date | cut -b1-4`
M_CA=`echo $this_date | cut -b6-7`

for (( mem = 1; mem <= ENSSIZE; mem += 1 )) ; do
	for (( month = M_CA ; month <= M_CA + 11 + 12 * ( FORECAST_CYCLE_LEN_IN_YEARS * num_cycles - 1 ) ; ++month )) ; do
		this_month=$month
		this_year=$Y_CA
		while (( this_month > 12 )) ; do
			(( this_year = this_year + 1 ))
			(( this_month = this_month - 12 ))
		done
		$PYTHON $WDIR/add_meta_data.py ${this_year} ${this_month} 1 $mem
	done	
done


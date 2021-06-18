#!/bin/bash

. settings.sh

NML_YEARS=( `echo $this_date_print | cut -b1-4` ${YEARS_TO_UPDATE_NAMELIST[@]} )
NML_CYCLE_LENS=( 0 ${PER_RUN_FORECAST_CYCLE_LEN_IN_MONTHS[@]} )

for i in "${!NML_YEARS[@]}"; do
	namelist_name="${NML_CYCLE_LENS[i]}"-"${NML_CYCLE_LENS[((i+1))]}"

	# Copy logic from forecasting scripts -----
	Y_CA=${NML_YEARS[i]}

	AX=`echo "${Y_CA: -1}"`
	(( AYEAR = Y_CA - AX + 5 ))
	if [ $AYEAR -gt 2015 ]; then
	        AYEAR=2015
	fi
	
	if [ $Y_CA -gt 2000 ]; then
	        REPEAT_VOLCANO_YEAR='repeat_volcano_year=.true.'
		VOLCANO_YEAR_USED='volcano_year_used = 2008,'
	else
	        REPEAT_VOLCANO_YEAR='! repeat_volcano_year=.true.'
	        VOLCANO_YEAR_USED='! volcano_year_used = 2008,'
	fi
	
	ADAPT=.false.
	JULBASE_YEAR=`echo $JULBASE | cut -b1-4`
	JULBASE_MONTH=`echo $JULBASE | cut -b5-6`
	JULBASE_DAY=`echo $JULBASE | cut -b7-8`
	
	if [ $Y_CA -gt 2004 ]; then
	        BASIC_OZONE_TYPE=fixed_year
	        OZONE_DATASET_ENTRY='ozone_dataset_entry=2014, 1, 1, 0, 0, 0,'
	        FILENAME=cm3_2014_o3.padded.nc
	else
	        BASIC_OZONE_TYPE=time_varying
	        OZONE_DATASET_ENTRY='!ozone_dataset_entry=2014, 1, 1, 0, 0, 0,'
	        FILENAME=CM3_CMIP6_1950-2014_O3.nc
	fi
	
	cat $WDIR/MOM/input.in \
	        | sed "s/INPUT_AEROSOL_TIME/${AYEAR}, 1, 1, 0, 0, 0/"\
	        | sed "s/INPUT_DAYS/days = 0/"\
	        | sed "s/CURRENT_DATE/current_date = ${JULBASE_YEAR},${JULBASE_MONTH},${JULBASE_DAY},0,0,0/"\
	        | sed "s/USE_ADAPTIVE_RESTORE/use_adaptive_restore=${ADAPT}/" \
	        | sed "s/REPEAT_VOLCANO_YEAR/${REPEAT_VOLCANO_YEAR}/" \
	        | sed "s/VOLCANO_YEAR_USED/${VOLCANO_YEAR_USED}/" \
	        | sed "s/BASIC_OZONE_TYPE/basic_ozone_type = '${BASIC_OZONE_TYPE}'/" \
	        | sed "s/OZONE_DATASET_ENTRY/${OZONE_DATASET_ENTRY}/" \
	        | sed "s/FILENAME/filename = "${FILENAME}"/" \
	        > $WDIR/MOM/input.nml.${namelist_name}
done

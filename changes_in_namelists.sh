#!/bin/bash

DIR=$1
START_DATE=$2

inputs=( `ls ${DIR}/MOM/input.nml.*-* | sort --version-sort` )
n_inputs=${#inputs[@]}
for i in $(seq 0 $(( $n_inputs - 2 ))); do
	 DIFF=$(diff ${inputs[i]} ${inputs[i+1]})
	 if [ "$DIFF" != "" ]; then
		 LEAD=$(cut -d "-" -f2- <<< `basename ${inputs[i]}`)
		 DATE=$(date -d "$START_DATE+$LEAD month" +%Y%m%d)
		 echo "==================================================="
		 echo "The following changes are made in $DATE:"
		 echo "==================================================="
		 echo -e "$DIFF"
		 echo ""
	 fi
done


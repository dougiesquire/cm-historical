#!/bin/bash

set -euo pipefail

echo "combining output from each cpu"
#for ext in 0000 0030
for ext in 0000
do
    echo "extension = $ext"
    if ! stat -t *.nc.${ext} >/dev/null 2>&1
    then
	echo "  error: no files to merge, exiting"
	exit 1
    fi

    for ncfile in *.nc.${ext}
    do
	base=${ncfile%.${ext}}
	if [ ! -f "$base" ]
	then
	    echo -n "merging ${base}..."
	    if [ "$ext" = "0000" ]
	    then
		./mppnccombine -n4 -z -d 1 -h 16000 $base
		#./mppnccombine -h 16000 $base
	    else
		./mppnccombine -n4 -z -d 1 -h 16000 -n 30 $base
		#./mppnccombine -h 16000 -n 30 $base
	    fi
	    if [ -f "$base" ]
	    then
		echo " done"
		rm ${base}.0*
	    else
		echo " failed"
		exit 1
	    fi
	else
	    echo "${base} already exists, skipping"
	    touch abort
	fi
    done
done

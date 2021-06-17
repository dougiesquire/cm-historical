#!/bin/bash

#####################################################################
# File: launch.sh
# Author: Vassili Kitsios, adopted from Paul Sandery, adapted from Pavel Sakov
# Created: 2020
# Purpose: launching script for CAFE60 forecasts
# Description: initially launches a run from a source directory; re-starts the run from the run directory
#####################################################################

. settings.sh

RUNSCRIPTNAME=run_${SYSTEMNAME}_forecasts.sh

set -eu
CWD=`pwd`
mkdir -p $WDIR
mkdir -p $SAVE_EXP_DIR
chmod 755 $SAVE_EXP_DIR

if [ ! -f "${WDIR}/JULDAY.txt" ] ; then
	echo $JULDAY > ${WDIR}/JULDAY.txt
	git log | head -n1 > $WDIR/cm-forecast.version.txt
	cd $MOM_SRC_DIR ; git log | head -n1 > $WDIR/mom_cafe.version.txt ; cd $CWD
	cd $POSTPROCESSING_SRCDIR ; git log | head -n1 > $WDIR/post-processing.version.txt ; cd $CWD
	$dn2date $JULDAY $JULBASE > $WDIR/experiment_start_date.txt
	if [ "${machine}" = "gadi.nci.org.au" ] ; then
		mdss -P v14 mkdir ${TAPE_DIR}
	fi
fi

echo "  running ${EXPNAME}"
cd $WDIR
WDIR_pwd=`pwd`
cd $CWD
if [ "$CWD" != "$WDIR_pwd" ] ; then
	cp -r $0 settings.sh src ref $WDIR
fi

cp src/add_meta_data.py src/add_meta_data.sh ${WDIR}
cp $HEADER_MASTER ${WDIR}/${RUNSCRIPTNAME}
cat src/${RUNSCRIPTNAME}.in | sed "s|INPUT_NPMASTER|${NP_MASTER}|" >> ${WDIR}/${RUNSCRIPTNAME}
cd $WDIR

if [ "${queue}" = "pbs" ] ; then
	qsub -N ${this_date_print} ./${RUNSCRIPTNAME}
elif [ "${queue}" = "slurm" ] ; then
	sbatch -J ${this_date_print} -o ${this_date_print}.out ./${RUNSCRIPTNAME}
else
	echo 'Unsupported queing system'
	exit
fi


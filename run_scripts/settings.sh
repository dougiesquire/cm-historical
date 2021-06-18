#!/bin/bash

#=======================================================================
DESCRIPTION='CAFE-60 historical run'

ENSSIZE=1
FIRST_MEMBER=1

CONTROL=false # Keep forcing fixed

FORECAST_CYCLE_LEN_IN_MONTHS=960 # (8*120) to get to 2040 from 1960
PER_RUN_FORECAST_CYCLE_LEN_IN_MONTHS=120 # not used if CONTROL=false, in which case cycle lengths are determined from YEARS_TO_UPDATE_NAMELIST 
YEARS_TO_UPDATE_NAMELIST=( 1970 1980 1990 2000 2005 2010 2020 2030 ) # not used if CONTROL=true, in which case cycle lengths are determined from PER_RUN_FORECAST_CYCLE_LEN_IN_MONTHS. Update aerosol forcing every decade, switch to fixed (2014) ozone forcing in 2005.

suffix='_test'  # In definition of experiment name

ZARR_CONFIG_FILE=zarr_specs_CAFE-f6.json
CHECK_CONFIG_FILE=check_specs_CAFE-f6.json

this_date=" 1960  11 1"
JULBASE="1800 1 1"

#=======================================================================
# Update PER_RUN_FORECAST_CYCLE_LEN_IN_MONTHS to be an array for each run
if [ "$CONTROL" = true ] ; then
	sum=0
	t=()
	while [ $sum -lt $FORECAST_CYCLE_LEN_IN_MONTHS ]; do 
		t+=("${PER_RUN_FORECAST_CYCLE_LEN_IN_MONTHS}")
		sum=$((sum + $PER_RUN_FORECAST_CYCLE_LEN_IN_MONTHS))
	done
	if [ $sum -ne $FORECAST_CYCLE_LEN_IN_MONTHS ]; then
		t[-1]=$(($PER_RUN_FORECAST_CYCLE_LEN_IN_MONTHS-$sum+$FORECAST_CYCLE_LEN_IN_MONTHS))
	fi
	unset PER_RUN_FORECAST_CYCLE_LEN_IN_MONTHS	
	PER_RUN_FORECAST_CYCLE_LEN_IN_MONTHS=${t[@]}
else
	unset PER_RUN_FORECAST_CYCLE_LEN_IN_MONTHS
	PER_RUN_FORECAST_CYCLE_LEN_IN_MONTHS=($(./get_cycle_lengths.py ${YEARS_TO_UPDATE_NAMELIST[@]} ${this_date[@]} ${FORECAST_CYCLE_LEN_IN_MONTHS}))
fi

#=======================================================================
# Important directories
echo ${HOSTNAME}
if [ "${HOSTNAME:0:1}" = "g" ] ; then
        machine='gadi.nci.org.au'
        data_mover="${USER}@gadi-dm.nci.org.au"
        MOM_SRC_DIR="/home/548/pas548/src/mom_cafe"
        OUTPUT_DIR="/scratch/ux06/ds0092/CAFE/historical/WIP/"
       	SAVE_DIR="/g/data/xv83/ds0092/CAFE/historical/WIP/"
        INITENSDIR_BASE="/g/data/xv83/ds0092/CAFE/data_assimilation/d60/save"
        BASE_DIR="/g/data/v14/vxk563/CAFE/CM21_c5"
        NP_MASTER=48
        queue='pbs'
        MOM_COMMAND="mpirun -np 128"
        BGC_PARAM_DIR=${BASE_DIR}"/INIT/bgc_para/"
        MOM_BIN_DIR=${MOM_SRC_DIR}"/exec/"${machine}"/CM2M/"
        dn2date=/home/548/pas548/bin/dn2date
        date2dn=/home/548/pas548/bin/date2dn
	PYTHON="/g/data/v14/ds0092/software/miniconda3/envs/zarrify/bin"
	POSTPROCESSING_SRCDIR="/g/data/v14/ds0092/active_projects/post-processing"
	ZARR_PATH="/g/data/v14/ds0092/software/zarrtools"
elif [ "${HOSTNAME:0:1}" = "m" ] ||  [ "${HOSTNAME:0:1}" = "n" ] ; then
	machine='magnus.pawsey.org.au'
	data_mover="${USER}@hpc-data.pawsey.org.au"
	MOM_SRC_DIR="/group/pawsey0315/vkitsios/2code/mom_cafe/"
	PROJECT_DIR="/group/pawsey0315/CAFE/forecasts/f5/WIP"
	BASE_DIR="/group/pawsey0315/CAFE/CM21_c5"
	INITENSDIR_BASE="/group/pawsey0315/CAFE/data_assimilation/d60/save"
	OUTPUT_DIR=${PROJECT_DIR}
	SAVE_DIR=${PROJECT_DIR}
	NP_MASTER=24
	queue='slurm'
	MOM_COMMAND="srun -N6 -n 128"
	BGC_PARAM_DIR=${BASE_DIR}"/INIT/bgc_para"
	MOM_BIN_DIR=${MOM_SRC_DIR}"/exec/"${machine}"/CM2M/"
	dn2date=./src/dn2date/dn2date
	date2dn=./src/dn2date/date2dn
	PYTHON="/group/pawsey0315/dsquire/miniconda3/envs/zarrify/bin"
	POSTPROCESSING_SRCDIR="/group/pawsey0315/dsquire/work/active_projects/post-processing"
	ZARR_PATH="/group/pawsey0315/dsquire/work/software/zarrtools"
fi

echo "Running on machine "$machine
EXECNAME=fms_CM2M.x
SYSTEMNAME=CAFE

#=======================================================================
# Metadata settings
control_name=c5
data_assimilation_name=d60
perturbation_name=pX
if [ "$CONTROL" = true ] ; then
	forecast_name=ctrl
else
	forecast_name=hist
contact_name="Dougie Squire"
# Note, need to update references with CAFE-60 paper once published.
references="O'Kane, T.J., Sandery, P.A., Monselesan, D.P., Sakov, P., Chamberlain, M.A., Matear, R.J., Collier, M., Squire, D. and Stevens, L., 2019, 'Coupled data assimilation and ensemble initialisation with application to multi-year ENSO prediction', Journal of Climate."

#=======================================================================
# Restart file locations on pearcey
JULDAY=`$date2dn $this_date $JULBASE`
if (( JULDAY > 73991 )) ; then
	RESTART_ARCHIVE_DIR="/OSM/CBR/OA_DCFP/data3/model_output/CAFE/data_assimilation/CAFE60/scratch/v14/tok599/cm-runs/CAFE-60/save/RESTART_"${JULDAY}
else
	RESTART_ARCHIVE_DIR="/datasets/work/oa-dcfp/reference/data5/model_output/CAFE/data_assimilation/CAFE60/short/v14/tok599/cm-runs/CAFE-60/save/RESTART_"${JULDAY}
fi
RESTART_ENS_MEAN_ARCHIVE_DIR="/OSM/CBR/OA_DCFP/data3/model_output/CAFE/data_assimilation/CAFE60/scratch/v14/tok599/cm-runs/CAFE-60/save/RESTART_ENS_MEAN_"${JULDAY}

INITENSDIR=$INITENSDIR_BASE"/RESTART_"${JULDAY}
INITENSDIR_ENS_MEAN=$INITENSDIR_BASE"/RESTART_ENS_MEAN_"${JULDAY}
if [ ! -d "${INITENSDIR}" ] ; then
	mkdir ${INITENSDIR}
	echo ""
	echo "Run following as a batch job on pearcey-dm:"
	echo "#!/bin/bash"
	echo "#SBATCH -p io"
	echo "#SBATCH --time=01:00:00"
	echo "#SBATCH --ntasks-per-node=10"
	echo "#SBATCH --mem=8gb"
	echo "module load rsync parallel"
	echo "rsync -vhsrlt --chmod=Dg+s ${RESTART_ENS_MEAN_ARCHIVE_DIR} ${data_mover}:${INITENSDIR_BASE}"
	echo "find ${RESTART_ARCHIVE_DIR}/mem??? -type d > RESTART_${JULDAY}_filelist.txt"
	echo "time cat RESTART_${JULDAY}_filelist.txt | parallel -j 10 'rsync -ailP --chmod=Dg+s -e "\""ssh -T -c aes128-ctr"\"" {} ${data_mover}:${INITENSDIR}'"
	echo "rm RESTART_${JULDAY}_filelist.txt"
	#echo "rsync -vhsrlt --chmod=Dg+s ${RESTART_ENS_MEAN_ARCHIVE_DIR} ${RESTART_ARCHIVE_DIR} ${data_mover}:${INITENSDIR_BASE}"
	echo ""
	exit
fi

#=======================================================================
# System settings
this_date_print=`$dn2date $JULDAY ${JULBASE}`
EXPNAME=${control_name}-${data_assimilation_name}-${perturbation_name}-${forecast_name}-${this_date_print}${suffix}
WDIR=${OUTPUT_DIR}/${EXPNAME}
SAVE_EXP_DIR=${SAVE_DIR}/${EXPNAME}
TAPE_DIR=${forecast_name}/${EXPNAME}
REF_DIR=${WDIR}"/ref"
HEADER_MASTER=${REF_DIR}"/header_master."${machine}
HEADER_MOM=${REF_DIR}"/header_mom."${machine}
DT="1800"

#=======================================================================
# EOF
#=======================================================================

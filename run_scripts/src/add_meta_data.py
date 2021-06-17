#!/usr/bin/env python3
import os
import sys
import glob
import json
import time
from netCDF4 import Dataset
import numpy as np

#=========================================================================
# Usage - to be run from the base directory.
#	python3 add_meta_data <year> <month> <day> <member number (optional)>

#=========================================================================
def determine_run_variant_name(forecast_name, perturbation_name, data_assimilation_name, control_name):
	if forecast_name != "not applicable":
		return 'forecast'
	elif perturbation_name != "not applicable":
		return 'pertubation'
	elif data_assimilation_name != "not applicable":
		return 'data assimilation'
	elif control_name != "not applicable":
		return 'control'
	else:
		print('### ERROR - run variant cannot be determined ###')
		sys.exit()

#=========================================================================
def get_creation_date(filename):
	print("    Getting creation date from {0} ...".format(filename)) 	
	return time.ctime(os.path.getctime(filename))

#=========================================================================
def get_settings_field(settings_filename, key):
	print("    Getting {0} field from {1} ...".format(key,settings_filename)) 	
	description = "not applicable"
	for line in open(settings_filename):
		if key.lower() == line.strip().lower()[:len(key)]:
			line_without_comments = line.strip().split('#')[0]
			this_description = line_without_comments[len(key):].strip().replace("'","").replace('"','')
			if len(this_description)>1:
				description = this_description[1:]
	return description

#=========================================================================
def get_calendar(mom_input_filename):
	print("    Getting calendar from {0} ...".format(mom_input_filename)) 	
	calendar = 'not applicable'
	for line in open(mom_input_filename):
		test_string = "calendar"
		if test_string == line.strip().lower()[:len(test_string)]:
			calendar = line.strip()[len(test_string):].strip().translate({ord(i):None for i in '=,"'}).translate({ord(i):None for i in "'"})
	return calendar

#=========================================================================
def get_nominal_resolution(atmos_filename, ocean_filename):
	print("    Getting normal atmospheric resolution from {0} ...".format(atmos_filename))
	fid   = Dataset(atmos_filename, 'r')
	atmos_delta_lat = np.median(np.abs(fid['lat'][1:] - fid['lat'][0:-1]))
	atmos_delta_lon = np.median(np.abs(fid['lon'][1:] - fid['lon'][0:-1]))
	fid.close()
	print("    Getting normal oceanic resolution from {0} ...".format(ocean_filename))
	fid   = Dataset(ocean_filename, 'r')
	ocean_delta_lat = np.median(np.abs(fid['xt_ocean'][1:] - fid['xt_ocean'][0:-1]))
	ocean_delta_lon = np.median(np.abs(fid['yt_ocean'][1:] - fid['yt_ocean'][0:-1]))
	fid.close()
	return 'Atmosphere delta lat = {0:.2f}degrees ; Atmosphere delta lon = {1:.2f}degrees ; Ocean delta lat = {2:.2f}degrees ; Ocean delta lon = {3:.2f}degrees'.format(atmos_delta_lat, atmos_delta_lon, ocean_delta_lat, ocean_delta_lon)

#=========================================================================
def get_metadata_description():
	description = '''
	Each of the metadata keys added via the CAFE system are listed below under various subheadings, each with a brief description.

	* General tags:
	metadata_description     = This tag describing each of the metadata tags.
	institution              = Institution that created this data file.
	further_info_url         = URL where further information on the group can be found.
	references               = Key papers to be references when referring to this data.
	licence                  = Licence agreement for using this data.
	contact_name             = Contact person pertaining to this run.
	description              = Brief description of this experiment.
	creation_date            = Date at which this file was created.
	calendar                 = Calendar type infered from model namelist.
	nominal_resoltuion       = Nominal resolution of the atmosphere and ocean in degrees, calculated from the output fields.

	* Reference names:
	control_name             = Reference name given to the associated control run.
	data_assimilation_name   = Reference name given to the associated data assimilation run (if applicable).
	perturbation_name        = Reference name given to the associated optimal perturbation generation run (if applicable).
	forecast_name            = Reference name given to the associated forecast run (if applicable).
	run_variant_name         = Type of run i.e. control, data assimilation, perturbation, or forecast.
	experiment_start_date 	 = date of initial restarts in format YYYYMMDD

	* Source code versions:
	model_source             = hash of lastest mom_cafe git commit
	cm-forecast_source       = hash of lastest cm-forecast git commit

	* File specific:
	ens_member_number        = ensemble member number, or ensemble average (field, background, analysis, or in observational space)

	'''
	return description

#=========================================================================
def generate_global_metadata_tags(atmos_file,ocean_file,print_dict=False):
	metadata_dict = dict()
	metadata_dict['metadata_description']   = get_metadata_description()
	metadata_dict['institution']            = 'CSIRO CAFE'
	metadata_dict['further_info_url']       = 'https://research.csiro.au/dfp/'
	metadata_dict['licence']                = '### To be advised ###'
	metadata_dict['creation_date']          = get_creation_date(atmos_file)
	metadata_dict['calendar']               = get_calendar('./mem001/input.nml')
	metadata_dict['nominal_resoltuion']     = get_nominal_resolution(atmos_file, ocean_file)
	metadata_dict['model_source']           = open("./mom_cafe.version.txt", "r").readlines()[0].strip()
	metadata_dict['cm-forecast_source']         = open("./cm-forecast.version.txt", "r").readlines()[0].strip()
	metadata_dict['experiment_start_date']  = open("./experiment_start_date.txt", "r").readlines()[0].strip()
	for key in ['description', 'references', 'contact_name']:
		metadata_dict[key]              = get_settings_field('./settings.sh', key)

	for key in ['control_name', 'data_assimilation_name', 'perturbation_name', 'forecast_name']:
		metadata_dict[key]              = get_metadata_from_restart('./mem001/INPUT/fv_rst.res.nc', key)
		if metadata_dict[key] == 'not applicable':
			metadata_dict[key]      = get_settings_field('./settings.sh', key)
	metadata_dict['run_variant_name']       = determine_run_variant_name(metadata_dict['forecast_name'], metadata_dict['perturbation_name'], \
							metadata_dict['data_assimilation_name'], metadata_dict['control_name'])
	print('\n'+json.dumps(metadata_dict,indent=4))
	return metadata_dict

#=========================================================================
def get_metadata_from_restart(filename, key):
	value = 'not applicable'
	if os.path.exists(filename):
		ifile_fid = Dataset(filename, 'r+')
		if key in ifile_fid.ncattrs():
			value = getattr(ifile_fid,key)
		ifile_fid.close(); del ifile_fid
	return value

#=========================================================================
def get_ensemble_member_number(member_dir):
	return int(member_dir.strip('./save/mem')[-3:].strip().strip('/'))

#=========================================================================
def add_metadata(filename,ens_member_number,metadata_dict,print_output=True):
	if os.path.exists(filename):
		print('    Processing file {0} ...'.format(filename))
		ifile_fid                   = Dataset(filename, 'r+')
		ifile_fid.ens_member_number = ens_member_number
		for key in metadata_dict.keys():
			setattr(ifile_fid, key, metadata_dict[key])
		ifile_fid.close(); del ifile_fid	
	else:
		print('    ### WARNING file {0} does not exist ###'.format(filename))


#=========================================================================
if __name__ == '__main__':
	print("\n=========================================================")
	print("Running code {0}".format(sys.argv[0]))
	if (len(sys.argv)<4):
		print("   Invalid number of arguments.")
		print("   Usage: {0} <year> <month> <day> <member number (optional)>\n".format(sys.argv[0]))
		print("      number of arguments provided = {0}".format(len(sys.argv)-1))
		sys.exit()
	year_str    = sys.argv[1]
	month_str   = sys.argv[2].zfill(2)
	day_str     = sys.argv[3].zfill(2)

	suffix_day           = '_' + year_str + '_' + month_str + '_' + day_str + '.nc'
	suffix_days_of_month = '_' + year_str + '_' + month_str + '_*.nc'
	suffix_month         = '_' + year_str + '_' + month_str + '.nc'
	stat_dir             = './' + year_str + month_str + day_str

	if len(sys.argv)==5:
		# Do member <input_member_number>. If 0 then do statistics. 
		input_member_number = int(sys.argv[4])
		memstr = 'mem{0:03d}'.format(input_member_number)
	else:
		# Do everything
		input_member_number = 0
		memstr = './mem*'
	atmos_file = sorted(glob.glob('./mem*/atmos_daily'+suffix_month))[0]
	ocean_file = sorted(glob.glob('./mem*/ocean_month'+suffix_month))[0]

	#------------------------------------------------------------------
	print('\nGenerating metadata tags')
	metadata_dict = generate_global_metadata_tags(atmos_file,ocean_file,print_dict=True)

	#------------------------------------------------------------------
	print('\nProcess output files for each member')
	for member_dir in sorted(glob.glob(memstr)):
		ens_member_number = get_ensemble_member_number(member_dir) 
		for filename in sorted(glob.glob(member_dir + '/*' + suffix_month)):
			add_metadata(filename,ens_member_number,metadata_dict)
		#for filename in sorted(glob.glob(member_dir + '/*' + suffix_days_of_month)):
		#	add_metadata(filename,ens_member_number,metadata_dict)

	#------------------------------------------------------------------
	jul_day = open("./JULDAY.txt", "r").readlines()[0].strip()
	
	print("\nEnd of Program")
	print("=========================================================\n\n")


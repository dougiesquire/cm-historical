# Overview

It is common practice when assessing decadal forecasts to quantify the added value of initialisation. For example, from the CMIP5 experiment design documentation, section 3c (https://pcmdi.llnl.gov/mips/cmip5/docs/Taylor_CMIP5_design.pdf):

   > For those models that are able to produce 20th century climate runs, the CMIP5 20th century / RCP4.5 runs should be increased in number to create an ensemble of the desired size of continuous runs extending to 2035. Details as per CMIP5 long-term integrations. Ensemble size to match those used in 1.1 and 1.2. These runs form a “control” against which the value of initializing near-term climate and decadal forecasts can be measured.

We currently have no such baseline for the CAFE forecast, which makes skill assessment more difficult to interpret. In this repo, I try to explore details of the f6 forecast runs to develop a quick approach for running such a baseline.

# In this repo

#### `notebooks/` : exploratory notebooks
 - `c5_f6_forcing.ipynb` : exploration of the forcings specified in the c5 control run and f6 forecast runs
 - `hist_mem001.ipynb` : premliminary inspection/investigation of the single member historical and control runs to check that everything is going as expected
 - `hist.ipynb` : premliminary inspection/investigation of the 96 member historical run on Gadi to check that everything is going as expected
 - `ctrl.ipynb` : premliminary inspection/investigation of the 20 member control run on Pawsey to check that everything is going as expected
 - `complete_MERGE_step.ipynb` : notebook for picking and completing up MERGE step when it is cut short by walltime limit

#### `resources/` : copies of (small) files used in the notebooks in this repo, saved such that their original location is clear

#### `run_scripts/` : scripts for setting up and running the historical runs

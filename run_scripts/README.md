Historical run scripts
============================================================================

The "historical run" is simply run as a long set of forecasts from the 1960-11-01 CAFE60 restarts (I tried starting from 1960-01-01 but the model was not happy with these restarts). The hope is that by 1981, when I plan to start using the data as a baseline for the forecasts, all members will be independent. 

Hence these scripts are hacked versions of https://github.com/csiro-dcfp/cm-forecasts.


Notes
----------------------------------------------------------------------

* Begin by running a single member (mem001) and a corresponding control run with fixed 1960 forcing. We are expecting to see some transient behaviour in the early years of the forecast given that c5 is run with 1990s forcing and CAFE60 is started in 1960. Comparison of mem001 and it's control run should give an indication of how long this transient behaviour persists.
* While performing the single member runs, I found an issue that our model is sensitive to the atmospheric time step (see `notebooks/hist_mem001.ipynb` in this repo). Prior to finding this, it was common practice for us to reduce all of `dt_ocean`, `dt_atmos` and `dt_cpld` to get the model through periods of numerical instability, but this sends the model towards a new "happy place" (changing from 1800s to 1200s induces a change in global average sst of approximately 1 deg C in approximate 1 year!). I isolated the issue to the atmosphere and found that `dt_ocean` can be reduced without (obviously) effecting the model's happy place.
* I've also played about with the effect of some of the forcing terms in the single member runs. See some summary plots in `notebooks/hist_mem001.ipynb`.
* I'm running a 96 member historical run with forcing identical to our f6 forecasts at zero lead. This is running on Gadi. I rerun members that fall over with `dt_ocean=900`
* Similarly, I'm running a 20 member control run on Pawsey.



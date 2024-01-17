Shared resources for ESMValTool
===============================

This directory contains the following shared resources for ESMValTool

``config/`` : User and developer config files.

``tested_recipes/`` : Some recipes that have been tested with esmvaltool for the IPCC node installation with NorESM1/2 supported.


Auxiliary data
--------------
Auxiliary data are needed to run some esmvaltool recipes, e.g. shapefiles for map plotting or data extraction.
A common ``auxiliary_data`` directory is located on
- nird: ``/nird/datalake/NS9560K/ESGF/auxiliary_data/``
- ipcc.nird: ``/projects/NS9560K-datalake/ESGF/auxiliary_data/``


Standard recipes
----------------
Standard recipes that are bundled with the esmvaltool installation are now available by running:
```
   esmvaltool recipes list
   esmvaltool recipes get <my_recipe>
   esmvaltool run --config_file=<my_config_file> <my_recipe>
```


Official ESMValTool recipe test results
---------------------------------------
ESMValTool publish an official [list of tested recipes](https://esmvaltool.dkrz.de/shared/esmvaltool/stable_release/debug.html) in connection with each stable release. Currenlty NIRD only stores a relatively small subset of the datasets required for theses recipes. Please open a discussion if you want support for additional datasets for the Nird installation.


ESMValTool 2.8.0 tested recipes
-------------------------------

```
CATEGORY/subcategory/directory    :
  recipe (.yml file)              : dataset    : status : memory   : run time
--------------------------------------------------------------------------------

examples/
  recipe_check_obs                : default    : ERROR  :          :
  recipe_concatenate_exps         : default    : OK     :   2.8 GB : 00:00:20
  recipe_concatenate_exps         : NorESM1    : OK     :   1.7 GB : 00:00:06
  recipe_correlation              : default    : OK     :   3.2 GB : 00:00:09
  recipe_decadal                  : default    : ERROR  :          :
  recipe_extract_shape            : default    : OK     :   1.7 GB : 00:00:06
  recipe_julia                    : default    : ERROR  :          :
  recipe_ncl                      : default    : OK     :   1.7 GB : 00:00:04
  recipe_preprocessor_derive_test : default    : ERROR  :          :
  recipe_preprocessor_test        : default    : OK     :   8.3 GB : 00:00:46
  recipe_python                   : default    : OK     :   2.8 GB : 00:00:11
  recipe_r                        : default    : OK     :   1.6 GB : 00:00:02
  recipe_variable_groups          : default    : ERROR  :
  recipe_variable_groups          : NorESM1    : OK     :   2.7 GB : 00:00:29

=== ATMOSPHERE ===
consecutive dry days:
  recipe_consecdrydays            : NorESM1/2  : OK     :   3.0 GB : 00:00:22
modes of variability:
  recipe_modes_of_variability     : default    : OK     :   3.7 GB : 00:00:30
precipitation quantile bias:
  recipe_quantilebias             : default    : OK     :   1.9 GB : 00:00:07
zonal and meridional means:
  recipe_validation               : NorESM1    : OK     :   4.9 GB : 00:00:28
  recipe_validation_CMIP6         : default    : OK     :   6.0 GB : 00:00:21
  recipe_validation_CMIP6         : NorESM2    : OK     :   6.8 GB : 00:00:22

=== LAND ===
runoff, precipitation, evapotranspiration:
  recipe_runoff_et                : default    : OK     :   3.1 GB : 00:00:36

=== OCEAN ===
arctic ocean:
  recipe_arctic_ocean             : default    : OK     :  55.8 GB : 00:27:36
  recipe_arctic_ocean             : NorESM1    : OK     :  56.0 GB : 00:22:48
  recipe_arctic_ocean             : NorESM2    : OK     :  62.7 GB : 00:10:35
ocean chlorophyll in ESMs compared to ESA-CCI observations
  recipe_esacci_oc                : default    : OK     :   5.7 GB : 00:01:50
ocean diagnostics:
  recipe_ocean_Landschuetzer2016  : default    : OK     :   6.5 GB : 00:00:14
  recipe_ocean_Landschuetzer2016  : NorESM1-ME : OK     :   6.0 GB : 00:00:24
  recipe_ocean_Landschuetzer2016  : NorESM2-MM : OK     :   5.9 GB : 00:00:31
  recipe_ocean_amoc               : default    : OK     :   6.8 GB : 00:01:33
  recipe_ocean_bgc                : default    : OK     :  17.8 GB : 00:00:51
  recipe_ocean_bgc                : NorESM1-ME : OK     :  55.8 GB : 00:11:42
  recipe_ocean_bgc                : NorESM2-LM : OK     :  54.9 GB : 02:26:00
  recipe_ocean_example            : default    : OK     :  24.5 GB : 00:02:22
  recipe_ocean_ice_extent         : default    : OK     :   5.7 GB : 00:00:31
  recipe_ocean_multimap           : default    : OK     :   3.3 GB : 00:04:12
  recipe_ocean_quadmap            : default    : OK     :   1.6 GB : 00:00:08
  recipe_ocean_scalar_fields      : default    : OK     :   1.9 GB : 00:09:08
sea surface salinity evaluation:
  recipe_sea_surface_salinity     : default    : OK     : 115.5 GB : 00:08:59

=== SEA ICE ===
  recipe_seaice                   : default    : ERROR  :          :
  recipe_seaice_drift             : default    : ERROR  :          :
  recipe_seaice_feedback          : default    : OK     :   4.1 GB : 00:18:37
  recipe_seaice_feedback          : NorESM1-ME : OK     :   2.7 GB : 00:00:29
```


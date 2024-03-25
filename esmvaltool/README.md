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
ESMValTool publish an official [list of tested recipes](https://esmvaltool.dkrz.de/shared/esmvaltool/stable_release/debug.html) in connection with each stable release. Currently NIRD only stores a relatively small subset of the datasets required for theses recipes. Please open a discussion if you want support for additional datasets for the Nird installation.

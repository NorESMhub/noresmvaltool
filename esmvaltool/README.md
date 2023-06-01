Shared resources for ESMValTool
===============================

This directory contains the following shared resources for ESMValTool

``config/`` : User and developer config files.

``tested_recipes/`` : Some recipes that have been tested with esmvaltool for the IPCC node installation with NorESM1/2 supported.

``README-standard_recipes.md`` : List of standard recipes that have been tested for the esmvaltool installation.


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
     esmvaltool recipes get <standard-recipe>
```

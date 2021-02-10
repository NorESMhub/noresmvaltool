List of working recipes for the Nird IPCC node ESMValTool installation
======================================================================

* Standard recipes come with the esmvaltool installation. To list, copy and run recipes, do the following

```
esmvaltool recipes list
esmvaltool recipes get <my_recipe>
esmvaltool run --config_file=<my_config_file> <my_recipe>
```

* Custom recipes, those you make yourself are are supplied by other users, mayrequire an additional config-developer.yml file (e.g. when using model output other than CMIP3, CMIP5 or CMIP6) and possibly a config-references.yml file if authors and bibtex entries are not in the default files.


ESMValTool v2.1.1
-----------------

## Standard Recipes

```
examples/
  examples/recipe_python.yml
  
ocean recipes:
  recipe_ocean_amoc.yml
  recipe_ocean_bgc.yml
  recipe_ocean_example.yml
  recipe_ocean_ice_extent.yml
  recipe_ocean_Landschuetzer2016.yml
  recipe_ocean_multimap.yml
  recipe_ocean_quadmap.yml
  recipe_ocean_scalar_fields.yml
```

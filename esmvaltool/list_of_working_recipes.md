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

The esmvaltool run is timed with the `time` fuction, using configureation files with 1 and 4 compute nodes. This gives some indication about the run time you should expect for each of the reipes, and potential speedup when running on multiple nodes.

```
CATEGORY/subcategory/directory        : run time ("*" -- 1n <= 4n)
  recipe                              :   1 node    :   4 nodes
------------------------------------------------------------------

examples/
  examples/recipe_python.yml          :   0m44.607s :   0m23.524s

=== OCEAN ===
arctic ocean:
  recipe_arctic_ocean                 :  40m00.914s :  35m13.035s

ocean diagnostics:
  recipe_ocean_amoc.yml               :   5m10.653s :   2m39.970s
  recipe_ocean_bgc.yml                :   3m49.605s :   1m09.870s
  recipe_ocean_example.yml            :   5m13.925s :   1m46.961s
  recipe_ocean_ice_extent.yml         :   1m34.831s :   0m29.697s
  recipe_ocean_Landschuetzer2016.yml  :   0m45.418s :   0m19.065s
  recipe_ocean_multimap.yml           :   5m09.962s :   5m31.685s *
  recipe_ocean_quadmap.yml            :   0m13.133s :   0m11.407s
  recipe_ocean_scalar_fields.yml      :   6m05.351s :   6m20.367s *
```


## Standard recipes -- NorESM

The `standard_recipes_NorESM` folder contain standard esmvaltool that have been modified to use NorESM model data instead of, or in addition to, the default datasets.

```
CATEGORY/subcategory/directory        : run time ("*" -- 1n <= 4n)
  recipe                              :   1 node    :   4 nodes
------------------------------------------------------------------

examples/
  examples/recipe_python_NorESM.yml   :   1m13.614s :   0m37.579s
```


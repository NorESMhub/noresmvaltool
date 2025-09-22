#!/bin/bash

# script to make manual sort of downloaded data.
# written by L.S.Graff (MetNO), modified by Y.C.He (NERSC)
# 22 09 2025

create_folders () {
    echo "Create version folder: $1"
    #echo "Create link folder: $2"
   
    [ -d $1 ] || mkdir -p $1
    #[ -d $2 ] || mkdir -p $2

}


process_file () {

    #cwd=$PWD
    institute=NCAR
    model=CESM2
    exp=amip
    tableId=Amon
    grid=gn
    
    odir=/nird/datalake/NS9560K/ESGF/CMIP6/CMIP
    idir=/nird/datalake/NS9560K/ESGF/rawdata/model/tmpdata

    var=$1
    member=$2
    version=$3
    years=$4

    ifile=${var}_${tableId}_${model}_${exp}_${member}_${grid}_$years.nc

    odir_version=$odir/$institute/$model/$exp/$member/$tableId/$var/$grid/$version
    odir_link=$odir/$institute/$model/$exp/$member/$tableId/$var/$grid/latest

    echo odir_version: $odir_version
    echo odir_link: $odir_link
    #create_folders $odir_version $odir_link
    create_folders $odir_version
        
    mv $idir/$ifile ${odir_version}/.
    #ln -s ${odir_version}/$ifile ${odir_link}/.
    cd ${odir_version}/../
    ln -s $version latest
    #ln -s ${odir_version} ${odir_link}/.

}


echo "Sort data"




# File: ta_Amon_CESM2_amip_r2i1p1f1_gn_195001-201412.nc
variable=ta
member=r2i1p1f1
version=v20190220
years=195001-201412
process_file $variable $member $version $years 

# File: ta_Amon_CESM2_amip_r3i1p1f1_gn_195001-201412.nc
variable=ta
member=r3i1p1f1
version=v20190220
years=195001-201412
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r2i1p1f1_gn_195001-201412.nc
variable=ua
member=r2i1p1f1
version=v20190220
years=195001-201412
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r3i1p1f1_gn_195001-201412.nc
variable=ua
member=r3i1p1f1
version=v20190220
years=195001-201412
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r4i1p1f1_gn_195001-199912.nc
variable=ua
member=r4i1p1f1
version=v20200226
years=195001-201412
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r4i1p1f1_gn_200001-201412.nc
variable=ua
member=r4i1p1f1
version=v20200226
years=195001-201412
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r5i1p1f1_gn_195001-199912.nc
variable=ua
member=r5i1p1f1
version=v20200226
years=195001-199912
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r5i1p1f1_gn_200001-201412.nc
variable=ua
member=r5i1p1f1
version=v20200226
years=200001-201412
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r6i1p1f1_gn_195001-199912.nc
variable=ua
member=r6i1p1f1
version=v20200226
years=195001-199912
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r6i1p1f1_gn_200001-201412.nc
variable=ua
member=r6i1p1f1
version=v20200226
years=200001-201412
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r7i1p1f1_gn_195001-199912.nc
variable=ua
member=r7i1p1f1
version=v20200226
years=195001-199912
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r7i1p1f1_gn_200001-201412.nc
variable=ua
member=r7i1p1f1
version=v20200226
years=200001-201412
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r8i1p1f1_gn_195001-199912.nc
variable=ua
member=r8i1p1f1
version=v20200226
years=195001-199912
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r8i1p1f1_gn_200001-201412.nc
variable=ua
member=r8i1p1f1
version=v20200226
years=200001-201412
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r9i1p1f1_gn_195001-199912.nc
variable=ua
member=r9i1p1f1
version=v20200226
years=195001-199912
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r9i1p1f1_gn_200001-201412.nc
variable=ua
member=r9i1p1f1
version=v20200226
years=200001-201412
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r10i1p1f1_gn_195001-199912.nc
variable=ua
member=r10i1p1f1
version=v20200226
years=195001-199912
process_file $variable $member $version $years 

# File: ua_Amon_CESM2_amip_r10i1p1f1_gn_200001-201412.nc
variable=ua
member=r10i1p1f1
version=v20200226
years=200001-201412
process_file $variable $member $version $years 





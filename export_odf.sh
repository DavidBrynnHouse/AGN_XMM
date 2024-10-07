#!/bin/zsh

# Prompt the user for the file containing the list of ODF folder names
echo "Please enter the filename with the list of ODF folder names:"
read list_file

# Read the list of names from the file
for odf_number in $(cat ../$list_file); do

  # Create a folder for each ODF folder name if it doesn't exist
  mkdir -p "/Users/davidhouse/Documents/my_work/$odf_number"

  # Set the SAS_ODF environment variable
  export SAS_ODF="/Volumes/TOSHIBA_EXT/xmm_obs/$odf_number/odf"

  # Enter new odf folder
  cd ../$odf_number
  
  # Run the SAS tasks
  echo "cifbuild run $odf_number"
  cifbuild > /dev/null 2>&1
  export SAS_CCF=`pwd`/ccf.cif
  echo "odfingest run $odf_number"
  odfingest > /dev/null 2>&1
  
  # Update the SAS_ODF environment variable with the path to the SUM.SAS file
  export SAS_ODF=`pwd`/`ls -1 *SUM.SAS`
  
  # Process the data
  echo "emproc run $odf_number"
  emproc > /dev/null 2>&1
  echo "epproc run $odf_number"
  epproc > /dev/null 2>&1
  
  # Leave observation folder
  cd ../scripts
  
done

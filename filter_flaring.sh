#!/bin/zsh
cd ..
# Loop through each folder in the current directory
for folder in */; do
  # Remove trailing slash from folder name
  folder=${folder%/}

  echo "Processing folder: $folder"

  # Navigate into the folder
  cd "$folder" || { echo "Failed to enter folder $folder"; continue; }

  # Find the SCX00000SUM.SAS file in the folder
  sas_file=$(ls *_SCX00000SUM.SAS 2>/dev/null)

  if [[ -f "ccf.cif" && -n "$sas_file" ]]; then
    echo "Found SCX00000SUM.SAS file: $sas_file"

    # List files in the folder to check patterns
    echo "Files in folder:"
    ls *_ImagingEvts.ds

    # Produce the MOS image
    # Adjust the file name pattern based on actual files listed
    EMOS1_file=$(ls *_EMOS1_*_ImagingEvts.ds 2>/dev/null)
    EMOS2_file=$(ls *_EMOS2_*_ImagingEvts.ds 2>/dev/null)
    EPN_file=$(ls *_EPN_*_ImagingEvts.ds 2>/dev/null)

    if [[ -n "$EMOS1_file" && -n "$EMOS2_file" && -n "$EPN_file" ]]; then
      echo "Found event files:"
      echo "  EMOS1 file: $EMOS1_file"
      echo "  EMOS2 file: $EMOS2_file"
      echo "  EPN file: $EPN_file"

      # Create rate files
      evselect table="$EMOS1_file" withrateset=Y rateset=rateEPIC-EMOS1.ds \
        maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
        expression='#XMMEA_EM && (PI>10000) && (PATTERN==0)'

      evselect table="$EMOS2_file" withrateset=Y rateset=rateEPIC-EMOS2.ds \
        maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
        expression='#XMMEA_EM && (PI>10000) && (PATTERN==0)'

      evselect table="$EPN_file" withrateset=Y rateset=rateEPIC-EPN.ds \
        maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
        expression='#XMMEA_EP && (PI>10000 && PI<12000) && (PATTERN==0)'

      # Create GTIs
      tabgtigen table=rateEPIC-EMOS1.ds expression='RATE<=0.35' gtiset=EPICgti-EMOS1.ds
      tabgtigen table=rateEPIC-EMOS2.ds expression='RATE<=0.35' gtiset=EPICgti-EMOS2.ds
      tabgtigen table=rateEPIC-EPN.ds expression='RATE<=0.4' gtiset=EPICgti-EPN.ds

      # Create filtered event files
      evselect table="$EMOS1_file" withfilteredset=Y filteredset=EPICclean-EMOS1.ds \
        destruct=Y keepfilteroutput=T \
        expression='#XMMEA_EM && gti(EPICgti-EMOS1.ds,TIME) && (PI>150)'
      evselect table="$EMOS2_file" withfilteredset=Y filteredset=EPICclean-EMOS2.ds \
        destruct=Y keepfilteroutput=T \
        expression='#XMMEA_EM && gti(EPICgti-EMOS2.ds,TIME) && (PI>150)'
      evselect table="$EPN_file" withfilteredset=Y filteredset=EPICclean-EPN.ds \
        destruct=Y keepfilteroutput=T \
        expression='#XMMEA_EP && gti(EPICgti-EPN.ds,TIME) && (PI>150)'

    else
      echo "No matching event files found for $folder"
    fi

  else
    echo "Necessary files are missing in $folder"
  fi

  # Return to the parent directory
  cd ../scripts
done


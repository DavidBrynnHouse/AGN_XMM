#!/bin/zsh
cd ..
# Loop through each folder in the current directory
for folder in */; do
  # Remove trailing slash from folder name
  folder=${folder%/}

  echo "Processing folder: $folder"
  
  # Navigate into the folder
  cd "$folder" || { echo "Failed to enter folder $folder"; continue; }
  
  echo "%%%%%%%%%%%%%%%%%%Processing folder: %%%%%%%%%%%%%%%%"
  ls *_*_AttHk.ds
  att_file=(*_*_AttHk.ds)
  export SAS_CCF=ccf.cif

  echo "evselect running"
  evselect table=EPICclean-EMOS1.ds:EVENTS imagebinning='binSize' \
     imageset='MOS1_image_full.ds' withimageset=yes xcolumn='X' ycolumn='Y' \
     ximagebinsize=80 yimagebinsize=80 \
     expression='#XMMEA_EM && (PI>10000) && (PATTERN==0)' > /dev/null -V 2
  evselect table=EPICclean-EMOS2.ds:EVENTS imagebinning='binSize' \
     imageset='MOS2_image_full.ds' withimageset=yes xcolumn='X' ycolumn='Y' \
     ximagebinsize=80 yimagebinsize=80 \
     expression='#XMMEA_EM && (PI>10000) && (PATTERN==0)' > /dev/null -V 2
  evselect table=EPICclean-EPN.ds:EVENTS imagebinning='binSize' \
     imageset='PN_image_full.ds' withimageset=yes xcolumn='X' ycolumn='Y' \
     ximagebinsize=80 yimagebinsize=80 \
     expression='#XMMEA_EP && (PI>10000&&PI<12000) && (PATTERN==0)' > /dev/null -V 2

  echo "expmap running"
  eexpmap attitudeset=$att_file eventset=EPICclean-EMOS1.ds imageset=MOS1_image_full.ds \
     expimageset=MOS1_expmap.ds pimin="200" pimax="10000" > /dev/null -V 2
  eexpmap attitudeset=$att_file eventset=EPICclean-EMOS2.ds imageset=MOS2_image_full.ds \
     expimageset=MOS2_expmap.ds pimin="200" pimax="10000" > /dev/null -V 2
  eexpmap attitudeset=$att_file eventset=EPICclean-EPN.ds imageset=PN_image_full.ds \
     expimageset=PN_expmap.ds pimin="200" pimax="10000" > /dev/null -V 2

  echo "emask running"
  emask expimageset=MOS1_expmap.ds threshold1=0.25 detmaskset=MOS1_mask.ds > /dev/null -V 2
  emask expimageset=MOS2_expmap.ds threshold1=0.25 detmaskset=MOS2_mask.ds > /dev/null -V 2
  emask expimageset=PN_expmap.ds threshold1=0.25 detmaskset=PN_mask.ds > /dev/null -V 2

  echo "eboxdetect running"
  eboxdetect usemap=no likemin=8 withdetmask=yes detmasksets=MOS1_mask.ds \
     imagesets=MOS1_image_full.ds expimagesets=MOS1_expmap.ds pimin=200 \
     pimax=10000 boxlistset=eboxlist_local_1.ds > /dev/null -V 2
  eboxdetect usemap=no likemin=8 withdetmask=yes detmasksets=MOS2_mask.ds \
     imagesets=MOS2_image_full.ds expimagesets=MOS2_expmap.ds pimin=200 \
     pimax=10000 boxlistset=eboxlist_local_2.ds > /dev/null -V 2
  eboxdetect usemap=no likemin=8 withdetmask=yes detmasksets=PN_mask.ds \
     imagesets=PN_image_full.ds expimagesets=PN_expmap.ds pimin=200 \
     pimax=10000 boxlistset=eboxlist_local_pn.ds > /dev/null -V 2

  echo "esplinemap running"
  esplinemap bkgimageset=MOS1_bkg.ds scut=0.005 imageset=MOS1_image_full.ds \
     nsplinenodes=16 withdetmask=yes detmaskset=MOS1_mask.ds withexpimage=yes \
     expimageset=MOS1_expmap.ds boxlistset=eboxlist_local_1.ds > /dev/null -V 2
  esplinemap bkgimageset=MOS2_bkg.ds scut=0.005 imageset=MOS2_image_full.ds \
     nsplinenodes=16 withdetmask=yes detmaskset=MOS2_mask.ds withexpimage=yes \
     expimageset=MOS2_expmap.ds boxlistset=eboxlist_local_2.ds > /dev/null -V 2
  esplinemap bkgimageset=PN_bkg.ds scut=0.005 imageset=PN_image_full.ds \
     nsplinenodes=16 withdetmask=yes detmaskset=PN_mask.ds withexpimage=yes \
     expimageset=PN_expmap.ds boxlistset=eboxlist_local_pn.ds > /dev/null -V 2

  echo "eboxdetect running 2"
  eboxdetect usemap=yes bkgimagesets=MOS1_bkg.ds likemin=8 withdetmask=yes detmasksets=MOS1_mask.ds \
     imagesets=MOS1_image_full.ds expimagesets=MOS1_expmap.ds pimin=200 \
     pimax=10000 boxlistset=eboxlist_map_1.ds > /dev/null -V 2
  eboxdetect usemap=yes bkgimagesets=MOS2_bkg.ds likemin=8 withdetmask=yes detmasksets=MOS2_mask.ds \
     imagesets=MOS2_image_full.ds expimagesets=MOS2_expmap.ds pimin=200 \
     pimax=10000 boxlistset=eboxlist_map_2.ds > /dev/null -V 2
  eboxdetect usemap=yes bkgimagesets=PN_bkg.ds likemin=8 withdetmask=yes detmasksets=PN_mask.ds \
     imagesets=PN_image_full.ds expimagesets=PN_expmap.ds pimin=200 \
     pimax=10000 boxlistset=eboxlist_map_pn.ds > /dev/null -V 2

  echo "emldetect running"
  emldetect imagesets=MOS1_image_full.ds expimagesets=MOS1_expmap.ds \
     bkgimagesets=MOS1_bkg.ds boxlistset=eboxlist_map_1.ds ecf=2.0 \
     mllistset=emllist_1.ds mlmin=10 determineerrors=yes > /dev/null -V 2
  emldetect imagesets=MOS2_image_full.ds expimagesets=MOS2_expmap.ds \
     bkgimagesets=MOS2_bkg.ds boxlistset=eboxlist_map_2.ds ecf=2.0 \
     mllistset=emllist_2.ds mlmin=10 determineerrors=yes > /dev/null -V 2
  emldetect imagesets=PN_image_full.ds expimagesets=PN_expmap.ds \
     bkgimagesets=PN_bkg.ds boxlistset=eboxlist_map_pn.ds ecf=2.0 \
     mllistset=emllist_pn.ds mlmin=10 determineerrors=yes > /dev/null -V 2

  echo "esensmap running"
  esensmap expimagesets=MOS1_expmap.ds bkgimagesets=MOS1_bkg.ds \
     detmasksets=MOS1_mask.ds mlmin=10 sensimageset=MOS1_sens_map.ds > /dev/null -V 2
  esensmap expimagesets=MOS2_expmap.ds bkgimagesets=MOS2_bkg.ds \
     detmasksets=MOS2_mask.ds mlmin=10 sensimageset=MOS2_sens_map.ds > /dev/null -V 2
  esensmap expimagesets=PN_expmap.ds bkgimagesets=PN_bkg.ds \
     detmasksets=PN_mask.ds mlmin=10 sensimageset=PN_sens_map.ds > /dev/null -V 2
  echo "Complete"
  
  # Return to the parent directory
  cd ../scripts
done

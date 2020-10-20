#!/bin/sh
# $1 - unit no of usrbin output.
# $2 - Number of parallel runs
##############################################################
## This script is to process many USRTRACK output files.
##
## The script receives 2 parameters:
##              1st: is the name where your output files are stored, without "output" prefix
##              2nd: is the number of the bin
##
## Modify FLUPRO line with your FLUKA directory path



module load fluka/2011
CURFOLD=${PWD##*/}
##USBSUW=$HOME/Fluka_Scripts/usbsuw
##USBREA=$HOME/Fluka_Scripts/usbrea
USBSUW=$FLUPRO/flutil/usbsuw
USBREA=$FLUPRO/flutil/usbrea
mkdir -p OUTPUT
for i in $(seq 1 $2); do
mv run$i/*.$1 OUTPUT/
done

chmod 755 -R OUTPUT/

$USBSUW << EOF
`find ./OUTPUT/ -name *fort.$1`

Usrbin$1.bnn
EOF

chmod 755 -R OUTPUT/

$USBREA << EOF2
Usrbin$1.bnn
Usrbin$1.lis 
EOF2

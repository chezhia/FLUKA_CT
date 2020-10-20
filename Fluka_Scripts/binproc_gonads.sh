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
for i in $(seq 1 $1); do
mv run$i/*.51 OUTPUT/
mv run$i/*.61 OUTPUT/
mv run$i/*.62 OUTPUT/
mv run$i/*.71 OUTPUT/
mv run$i/*.52 OUTPUT/
mv run$i/*.53 OUTPUT/
done

chmod 755 -R OUTPUT/

$USBSUW << EOF
`find ./OUTPUT/ -name *fort.51`

Usrbin51.bnn
EOF

$USBSUW << EOF
`find ./OUTPUT/ -name *fort.61`

Usrbin61.bnn
EOF

$USBSUW << EOF
`find ./OUTPUT/ -name *fort.62`

Usrbin62.bnn
EOF

$USBSUW << EOF
`find ./OUTPUT/ -name *fort.71`

Usrbin71.bnn
EOF

$USBSUW << EOF
`find ./OUTPUT/ -name *fort.52`

Usrbin52.bnn
EOF

$USBSUW << EOF
`find ./OUTPUT/ -name *fort.53`

Usrbin53.bnn
EOF

chmod 755 -R OUTPUT/

$USBREA << EOF2
Usrbin51.bnn
Usrbin51.lis 
EOF2

$USBREA << EOF2
Usrbin52.bnn
Usrbin52.lis 
EOF2

$USBREA << EOF2
Usrbin53.bnn
Usrbin53.lis 
EOF2

$USBREA << EOF2
Usrbin62.bnn
Usrbin62.lis 
EOF2

$USBREA << EOF2
Usrbin61.bnn
Usrbin61.lis 
EOF2

$USBREA << EOF2
Usrbin71.bnn
Usrbin71.lis 
EOF2

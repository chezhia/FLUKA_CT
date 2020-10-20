#!/bin/sh
# $1 - unit no of track output.
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
USTSUW=$FLUPRO/flutil/ustsuw
mkdir -p OUTPUT
for i in $(seq 1 $2); do
mv run$i/*.$1 OUTPUT/
done

chmod 755 -R OUTPUT/

$USTSUW << EOF
`find ./OUTPUT/ -name *fort.$1`

Usrtrack$1.sum.lis
EOF
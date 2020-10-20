#!/bin/bash
# Launch from the folder containing the input fluka file - single core run
# $1 = input file (.inp), $2 = Fluka executable
module load fluka/2011
FLUKAEXE="/users/somd7w/FLUKA-CT/RunFluka/myfluka/$2"
CURFOLD=${PWD##*/}
RFLUKA=$FLUPRO/flutil/rfluka
printf '%s\n' "${PWD##*/}"
echo "FLUKA EXE is " $FLUKAEXE
echo "Current Folder is " $CURFOLD
bsub -J $CURFOLD -M 2000 -W 60 -n 1 -eo output.err -oo ouput.out "$RFLUKA -e $FLUKAEXE -N0 -M1 $1.inp"

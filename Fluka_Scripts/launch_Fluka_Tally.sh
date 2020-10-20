#!/bin/bash
# Launch from the folder containing the input fluka file - parallel execution
# Automatically runs the postprocessing scripts after the simulation is done
# Also calculates the clock time from start to end of simulation and saves in RUNTIME.txt
# $1 = input file (.inp), $2 = Fluka executable, $3 - Number of Cycles (=cores)
rm -rf run*
rm -rf OUTPUT
module load fluka/2011
FLUKAEXE="/users/somd7w/FLUKA-CT/RunFluka/myfluka/$2"
CURFOLD=${PWD##*/}
RFLUKA=$FLUPRO/flutil/rfluka
POSTPROC="/users/somd7w/FLUKA-CT/RunFluka/Fluka_Scripts/postprocess.sh"
RTIME="/users/somd7w/FLUKA-CT/RunFluka/Fluka_Scripts/runtime.sh"
NRUNS=$3

# Get Tallies in main script for postprocessing
DOSEBINS="$(awk '$1 ~ /^USRBIN/&& $3 ~/DOSE/ {print -$4;}' $1.inp | sort | uniq)"
DOSEBINS=($DOSEBINS)
echo "No of DOSEBINS =" ${#DOSEBINS[@]}
TRACKBINS="$(awk '$1 ~ /^USRTRACK/&& $3 ~/ENERGY/ {print -$4;}' $1.inp | sort | uniq)"
TRACKBINS=($TRACKBINS)
echo "No of TRACKBINS =" ${#TRACKBINS[@]} $TRACKBINS
# Default seed is 1234598765
seed=1234598765.
#* Set the random number seed         1. 
t1=$( date +'%s.%N' ) ### get the current time (in seconds)
for i in $(seq 1 $3); do
    echo "Starting Run " $i
    seed=$RANDOM
	echo 'Seed is ' $seed
	seed=$(echo 0000$seed | tail -c 6)
	sed 's/RANDOMIZ          1./RANDOMIZ          1.    '"$seed"'./' <$1.inp >$1$i.inp
	mkdir run$i
	mv $1$i.inp run$i
	cd run$i
bsub -J $CURFOLD -M 2000 -W 60 -n 1 -o output.err -o output.out "$RFLUKA -e $FLUKAEXE -N0 -M1 $1$i.inp"
    cd ..
done
if [ ${#DOSEBINS[@]} -gt 0 ]
then
for i in $(seq 1 ${#DOSEBINS[@]}); do
TALNO=$(echo "$i - 1" | bc)
echo "Tally No is " ${DOSEBINS[$TALNO]} $TALNO
bsub -P FLK -w  "done($CURFOLD)"  -J "MERGE" -eo procbin$i.err -oo procbin$i.out  "$POSTPROC ${DOSEBINS[$TALNO]} $NRUNS 1"
done
fi
if [ ${#TRACKBINS[@]} -gt 0 ]
then
for i in $(seq 1 ${#TRACKBINS[@]}); do
TALNO=$(echo "$i - 1" | bc)
bsub -w  "done($CURFOLD)" -J "MERGE" -e proctrack$i.err -o proctrack$i.out  "$POSTPROC ${TRACKBINS[$TALNO]} $NRUNS 2"
done
fi
bsub -w  "done("MERGE")" -J "RUNTIME" -e rtime.err -o rtime.out  "$RTIME $t1"
echo "Current Folder is " $CURFOLD
echo "FLUKA EXE is " $FLUKAEXE
#END

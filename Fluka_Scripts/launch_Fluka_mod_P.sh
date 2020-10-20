#!/bin/bash
# Launch from the folder containing the input fluka file - parallel execution
# Postprocessing scripts must be run manually
# $1 = input file (.inp), $2 = Fluka executable, $3 - Number of Cycles (=cores)
module load fluka/2011
FLUKAEXE="/users/somd7w/FLUKA-CT/RunFluka/myfluka/$2"
FLUKASCR="/users/somd7w/FLUKA-CT/RunFluka/Fluka_Scripts"
CURFOLD=${PWD##*/}
RFLUKA=$FLUPRO/flutil/rfluka
# Default seed is 1234598765
seed=1234598765.
#* Set the random number seed
#RANDOMIZ          1.
t1=$( date +'%s.%N' ) ### get the current time (in seconds)
for i in $(seq 1 $3); do
    echo "Starting Run " $i
    seed=$RANDOM
	echo 'Seed is ' $seed
	seed=$(echo 0000$seed | tail -c 6)
	sed 's/RANDOMIZ          1./RANDOMIZ          1.    '"$seed"'./' <$1.inp >$1$i.inp
	rm -rf run$i
	mkdir run$i
	mv $1$i.inp run$i
	cd run$i
bsub < $FLUKASCR/submitjob.lsf 
    cd ..
done

echo "FLUKA EXE is " $FLUKAEXE
echo "Current Folder is " $CURFOLD

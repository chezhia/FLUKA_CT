#!/bin/bash
# Script to do the postprocessing once the simulation is done
# $1 - Tally No.
# $2 - No. of Runs
# $3 - Flag bin (1) or track (2)
sleep 10
if [ $3 -eq 1 ]
then
	sh binproc.sh $1 $2
fi
if [ $3 -eq 2 ]
then
	sh trackproc.sh $1 $2 
fi

#BSUB -P FLK
#BSUB -J TEST
#BSUB -M 2000
#BSUB -W 10.00
#BSUB -n 1
#BSUB -eo output.err
#BSUB -oo output.out

module load fluka/2011

FLUKAEXE="/users/somd7w/FLUKA-CT/RunFluka/myfluka/CTTCMnew"
RFLUKA=$FLUPRO/flutil/rfluka
echo "Launching FLUKA here"
$RFLUKA -e $FLUKAEXE -N0 -M1 *.inp


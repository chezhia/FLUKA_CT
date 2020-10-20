#!/bin/bash
# Shortcut script to compile new FLUKA executable with a modified source file
module load fluka/2011
FLUPRO=/usr/local/fluka/2011
export FLUPRO
$FLUPRO/flutil/fff $1.f
$FLUPRO/flutil/lfluka -o $2 -m fluka $1.o
mv $2 ~/FLUKA-CT/RunFluka/myfluka

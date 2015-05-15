#!/bin/csh

#SETUP IDL ENVIRONMENT                                                                                   
#########################################################                                                
if (-e /Applications/exelis) then
set IDLDIR='/Applications/exelis/idl'
else
set IDLDIR='/Applications/itt/idl/idl'
endif

setenv IDL_STARTUP ~/.idl_startup.pro

setenv IDL_PATH +${HOME}/projects/idlutils:+${MDIR}projects/IDLAstro:+${IDLDIR}/lib
setenv IDL_PATH +${HOME}/projects/IDLAstro:${IDL_PATH}
setenv IDL_PATH +${HOME}/projects/VUMPS/COMMISSIONING/code:${IDL_PATH}

set PROPATH = ${HOME}'/projects/VUMPS/COMMISSIONING/code'

echo "Now setting the path to "$IDL_PATH
echo "Now changing the directory to: "$PROPATH
cd $PROPATH
idl

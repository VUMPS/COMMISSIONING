#!/bin/csh

#########################################################                                                
# SETUP IDL ENVIRONMENT                                                                                   
#########################################################                                                
if (-e /Applications/exelis) then
set IDLDIR='/Applications/exelis/idl'
else
set IDLDIR='/Applications/itt/idl/idl'
endif

setenv IDL_STARTUP ~/.idl_startup.pro

# ADD DEPENDENCIES TO PATH:
# 1st and 2nd dependencies: IDLAstro Package and the built in IDL lib:
# https://github.com/wlandsman/IDLAstro
setenv IDL_PATH +${HOME}/projects/IDLAstro/pro:+${IDLDIR}/lib

# 3rd dependency: idlutils
# https://github.com/mattgiguere/idlutils
setenv IDL_PATH +${HOME}/projects/idlutils:${IDL_PATH}

# Now add the recursive path to the VUMPS commissioning code:
setenv IDL_PATH +${HOME}/projects/VUMPS/COMMISSIONING/code:${IDL_PATH}

set PROPATH = ${HOME}'/projects/VUMPS/COMMISSIONING/code'

echo "Now setting the path to "$IDL_PATH
echo "Now changing the directory to: "$PROPATH
cd $PROPATH
idl

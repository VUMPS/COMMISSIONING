#!/bin/csh

#########################################################
# SETUP IDL ENVIRONMENT
#########################################################
if (-e /Applications/exelis) then
	set IDLDIR='/Applications/exelis/idl'
else if (-e /Applications/itt) then
	set IDLDIR='/usr/local/exelis/idl'
else if (-e /usr/local/exelis) then
	set IDLDIR='/usr/local/exelis/idl'
else 
	set IDLDIR='/usr/local/itt/idl'
endif

setenv IDL_STARTUP ~/.idl_startup.pro

# ADD DEPENDENCIES TO PATH:
setenv IDL_PATH +${IDLDIR}/lib
setenv IDL_PATH +${HOME}/projects/coyote:${IDL_PATH}
setenv IDL_PATH +${HOME}/projects/IDLAstro/pro:${IDL_PATH}

setenv IDL_PATH +${HOME}/projects/idlutils:${IDL_PATH}

setenv IDL_PATH +${HOME}/idl/mpfit:${IDL_PATH}
setenv IDL_PATH +${HOME}/projects/VUMPS/COMMISSIONING/code:${IDL_PATH}

set PROPATH = ${HOME}'/projects/VUMPS/COMMISSIONING/code'

echo "Now setting the path to "$IDL_PATH
echo "Now changing the directory to: "$PROPATH
cd $PROPATH
idl

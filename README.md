# COMMISSIONING
**A repo for commissioning the VUMPS Spectrometer**

This repository contains code used for the commissioning of VUMPS.

###Dependencies

1. The built-in [IDL](http://www.exelisvis.com/ProductsServices/IDL.aspx) library
2. The [IDLAstro](https://github.com/mattgiguere/IDLAstro) package
3. The [idlutils](https://github.com/mattgiguere/idlutils) package
4. The [MPFIT](https://www.physics.wisc.edu/~craigm/idl/fitting.html) package
5. The [coyote](http://www.idlcoyote.com/documents/programs.php) library

###Getting Started
To run code in this repo, startup IDL by executing the VUMPS commissioning startup script:

    ./vumpsc.sh

  This will startup IDL in the `VUMPS/COMMISSIONING/code` directory and add
  all dependencies to the IDL PATH:

```sh
./vumpsc.sh
Now setting the path to +/Users/matt/projects/VUMPS/COMMISSIONING/code:+/Users/matt/projects/idlutils:+/Users/matt/projects/IDLAstro/pro:+/Applications/exelis/idl/lib
Now changing the directory to: /Users/matt/projects/VUMPS/COMMISSIONING/code
IDL Version 8.2.2, Mac OS X (darwin x86_64 m64). (c) 2012, Exelis Visual Information Solutions, Inc.
IDL> pwd
% Compiled module: PWD.
/Users/matt/projects/VUMPS/COMMISSIONING/code
```

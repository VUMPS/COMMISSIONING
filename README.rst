=============
COMMISSIONING
=============

**A repo for commissioning the VUMPS Spectrometer**

This repository contains code used for the commissioning of VUMPS.

Dependencies
============

Both the `reduction code`_ and commissioning code are written in the IDL_
programming language, and they are both dependent on the following
libraries:

1. The built-in IDL_ library
2. The IDLAstro_ package
3. The idlutils_ package
4. The MPFIT_ package
5. The coyote_ library

.. _`reduction code`: https://github.com/VUMPS/REDUCTION
.. _IDL: http://www.exelisvis.com/ProductsServices/IDL.aspx
.. _IDLAstro: https://github.com/mattgiguere/IDLAstro
.. _idlutils: https://github.com/mattgiguere/idlutils
.. _MPFIT: https://www.physics.wisc.edu/~craigm/idl/fitting.html
.. _coyote: http://www.idlcoyote.com/documents/programs.php

---------------
Getting Started
---------------

Install the dependencies
------------------------

::

    cd ~/projects
    git clone https://github.com/mattgiguere/IDLAstro.git
    git clone https://github.com/mattgiguere/idlutils.git
    wget https://www.physics.wisc.edu/~craigm/idl/down/mpfit.tar.gz
    mkdir mpfit; tar -xvf mpfit.tar.gz -C mpfit
    wget http://www.idlcoyote.com/programs/zip_files/coyoteprograms.zip
    unzip coyoteprograms.zip -d .


Update the startup script
-------------------------

Included in this repository is a convenience script, `vumpsc.sh`,
that sets up the environment for the commissioning code. Once the
dependencies described above are installed, update `vumpsc.sh` with
the appropriate path information, and then start the script from
the command line. This will correctly set the IDL path and startup
IDL in the ``VUMPS/COMMISSIONING/code`` directory:

::

    cd ~/projects/VUMPS/COMMISSIONING
    ./vumpsc.sh
    Now setting the path to +/Users/matt/projects/VUMPS/COMMISSIONING/code:+/Users/matt/projects/idlutils:+/Users/matt/projects/IDLAstro/pro:+/Applications/exelis/idl/lib
    Now changing the directory to: /Users/matt/projects/VUMPS/COMMISSIONING/code
    IDL Version 8.2.2, Mac OS X (darwin x86_64 m64). (c) 2012, Exelis Visual Information Solutions, Inc.
    IDL> pwd
    % Compiled module: PWD.
    /Users/matt/projects/VUMPS/COMMISSIONING/code

------------------------
Commissioning Procedures
------------------------

This section describes several routines included in this package and
shows examples of how to use them and their output.

Centering the Blaze Peak
-------------------------

Positioning the peak of the Blaze function at the center of the chip will ensure that the full free spectral range is on chip. The routine `find_blaze_center.pro` can help with this task.

To use `find_blaze_center`, take an unsaturated quartz exposure in any resolution mode. Next, startup of the vumps commissioning environment and pass in the filename of the quartz exposure as a keyword argument:

    find_blaze_center, fname='/raw/vumps/150522/vumps150522.1234.fit'


Rotating the CCD
----------------

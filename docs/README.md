#VUMPS commissioning README

This document describes the commissioning of the VUMPS
Spectrometer.

##1. Blaze Centering

Once the optical elements were aligned, the first step was to
center the blaze function on the CCD. This ensures that the
extracted pixels have the maximal SNR.

To center the blaze function, we used the routine `find_blaze_center.pro`. This is an IDL routine that assists in centering the blaze peak by performing the following tasks:
- reads in a FITS file of an exposure taken with VUMPS
- displays the image on screen
- prompts the user to coarsely trace an order manually
- extracts the order by fitting a polynomial to the manual trace
- fits a Gaussian to the extracted order
- calculates the shift from the center of the detector

The blaze peak should be centered in the echelle order that is near the center of the full wavelength range of the spectrometer. Since VUMPS is a near-Littrow design, the "drift" in the blaze peak across the detector should not change much. This is in contrast to a design like CHIRON, which has a significant "drift" as a function of order due to the 16 degree tilt of the echelle grating.



##Running OWL

- Type `owl` at the command line
- Controller -> Setup on the RHS
- Click `APPLY`
- Ensure the readout method is `Quad CCD`

To turn the lamps on:

    cd vumps-spx
    labview spxMain.vi &

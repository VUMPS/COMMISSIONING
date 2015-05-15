#VUMPS commissioning README

This document describes the commissioning of the VUMPS
Spectrometer.

##1. Blaze Centering

Once the optical elements were aligned, the first step was to
center the blaze function on the CCD. This ensures that the
extracted pixels have the maximal SNR.

To center the blaze function, we used the routine `find_blaze_center.pro`. This is an IDL routine that reads in a FITS file of an exposure taken with VUMPS, displays the image
on screen prompting the user to coarsely trace an order manually, extracts the order by fitting a polynomial to the manual trace, fits a Gaussian to the extracted order, and calculates the shift from the center of the detector.

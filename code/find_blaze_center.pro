;+
;
;  NAME: 
;     find_blaze_center
;
;  PURPOSE: To find the peak of the blaze function. This
;	routine is helpful for centering the blaze function
;	on the detector during instrument commissioning.
;
;  CATEGORY:
;      CHIRON
;
;  CALLING SEQUENCE:
;
;      find_blaze_center
;
;  INPUTS:
;		FILENAME: The name of the quartz image to load and use
;			during the analysis.
;		BFNAME: The name of the bias frame that will be 
;			subtracted from the quartz image.
;
;  OPTIONAL INPUTS:
;		POSTPLOT: Output the plot to encapsulated postscript form.
;		INPUTORDLOC: Input the location of the order from a previous
;			attempt (e.g., for reproducibility or tweaking a plot).
;
;  OUTPUTS:
;
;  OPTIONAL OUTPUTS:
;
;  KEYWORD PARAMETERS:
;    
;  EXAMPLE:
;      find_blaze_center
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2011.01.21
;
;-
pro find_blaze_center, $
bfname=bfname, $
fname=fname, $
inputordloc=inputordloc, $
postplot=postplot, $
nobias=nobias, $
xrange=xrange, $
yrange=yrange

;Call used to produce figure in thesis:
;find_blaze_center, fname='/raw/mir7/141118/chi141118.1300.fits', $
;bfname='/raw/mir7/141118/chi141118.1272.fits', $
;/postplot, inputordloc=[76.912178, 1697.1502, 545.04015, 1670.7436, $
;1073.0040, 1645.5945, 1488.3356, 1631.7624, 1812.1535, 1624.2177, $
;2178.2084, 1619.1879, 2498.5065, 1616.6729, 2924.3973, 1615.4155, $
;3459.4007, 1624.2177, 4004.9634, 1638.0497]

resolve_routine, 'imgscl', /compile_full_file, /either
;resolve_routine, 'imgexp', /compile_full_file, /either
;resolve_routine, 'display', /compile_full_file, /either

if ~keyword_set(fname) then fname='/Users/matt/projects/VUMPS/COMMISSIONING/data/ImageName182.fit'
res = readfits(fname, head)
;res_to = double(transpose(res))
res_to = res
window, 1, xpos=720, ypos=450

if ~keyword_set(nobias) then begin
	if ~keyword_set(bfname) then bfname='/Users/matt/projects/VUMPS/COMMISSIONING/data/mono883.0.fits'
	;subtract bias frame:
	res1 = readfits(bfname, head)
	res_t1 = double(transpose(res1))
	res_t = res_to - res_t1
endif else begin
res_t = res_to 
endelse;KW(nobias)

;get the dimensions of the image:
dims = size(res_t)
xdim = dims[1]
ydim = dims[2]

usersymbol, 'circle', size_of_sym=1, /fill

loadct, 39, /silent
;stop
display, res_t, xran = [0d, xdim], yran = [1400d, 1500d], $
xtitle='CCD Column Number', ytitle='CCD Row Number'

ntim = 10d
x = dblarr(ntim)
y = dblarr(ntim)
if ~keyword_set(inputordloc) then begin
	print, 'Mark the center order a few times'
	for i=0, ntim-1 do begin
		cursor, x1, y1, 4
		x[i] = x1 & y[i] = y1
		print, x1, y1
		oplot, [x[i],x[i]], [y[i],y[i]], ps=8, color=250
	endfor
	print, "OK, that's good!"
endif else begin
	ntim = n_elements(inputordloc)/2
	x = dblarr(ntim)
	y = dblarr(ntim)
	for i=0, ntim-1 do begin
		x[i] = inputordloc[2*i]
		y[i] = inputordloc[2*i + 1]
	endfor
endelse
usersymbol, 'circle', size_of_sym=0.25, /fill

if keyword_set(postplot) then begin
	ps_open, nextnameeps('find_blaze_center_orders'), /encaps, /color
	thick, 3
	!p.charsize=1

	display, res_t, xran = [0d, xdim], yran = [1250d, 2050d], $
	xtitle='CCD Column Number', ytitle='CCD Row Number'
endif

rslt = poly_fit(x,y,2, yfit=yfit)
yth = dindgen(xdim)
yth1 = rslt[0] + rslt[1]*yth + rslt[2]*yth^2
oplot, yth1, ps=8, color=240

buf = 15
oplot, yth1-buf, ps=8, color=10
oplot, yth1+buf, ps=8, color=10
;stop
if keyword_set(postplot) then begin
	ps_close
	ps_open, nextnameeps('find_blaze_center'), /color, /encaps
	thick, 3
	!x.charsize=1.5
	!y.charsize=1.5
	!x.margin = [10, 3]
	!y.margin = [5, 2]
endif else window, 2, xpos=720, ypos=0


sumarr = dblarr(xdim)
for i=0L, round(xdim-1d) do begin
sumarr[i] = total(res_t[i, (yth1[i]-buf):(yth1[i]+buf)])
endfor

minval = 1997
midval = 2048
maxval = 2098
gaindif = total(sumarr[minval:(midval-1)])/double(total(sumarr[midval:maxval]))
sumarr_o = sumarr
sumarr[midval:*] *= gaindif
print, 'the gain difference is: ', gaindif

xarr = dindgen(xdim)

;make the axes and text printed in black, but no data:
plot, xarr[16:4080], sumarr_o[16:4080]/1d4, ps=8, /ysty, /xsty, $
xtitle='CCD Column Number', ytitle='Counts/10!u4!n', /nodata

;now superimpose the original data in green:
oplot, xarr[16:4080], sumarr_o[16:4080]/1d4, ps=8, col=120

;and superimpose the gain-corrected data in black:
oplot, xarr[16:4080], sumarr[16:4080]/1d4, ps=8

rslt = poly_fit(xarr,sumarr,6, yfit=yfit)

;plot a vertical line showing the middle of the chip:
oplot, [midval, midval], [0, max(sumarr/1d4)]

; fit a gaussian to the data.
;0th coefficient: amplitude
;1: mean
;2: sigma
;3: offset
;4: linear term
;5: parabolic term
yerr = 3*sqrt(sumarr) + 5d3

resg = gaussfit(xarr, sumarr, Acoef, est = [2.5d5, 2048d, 1d6, 0d], nterms=4, measure_errors=yerr)
print, 'The best fit coefficients are: '
print, Acoef
stop
xceng = Acoef[1]
print, 'The center of the gaussian is: ', xceng

oplot, resg/1d4, color=250, ps=8

initial_offset = 0d
initial_mean = 2048d
initial_sigma = 1d3
initial_amplitude = 2.5d5
initial_area = initial_amplitude * sqrt(!dpi)

start = [initial_offset, initial_mean, initial_sigma, initial_area]
result = MPFITFUN('MYGAUSS', xarr, sumarr, yerr, start)
stop
g = acoef[0]*exp(-1. * ((xarr - acoef[1])^2/acoef[2])) + acoef[3] + acoef[4]*xarr + acoef[5]*xarr^2

items=['Original', 'Gain-Corrected', 'Gaussian Fit']
al_legend, items, psym=[8,8,8], color=[120, 0, 250], /right

items = ['CCD Center', 'Fit Center']
al_legend, items, linestyle=[0,0], color=[0, 250], /left

;plot a vertical line showing the center of the gaussian fit:
oplot, [xceng, xceng], [0, max(sumarr/1d4)], col=250

if keyword_set(postplot) then ps_close

offamg = abs(xdim / 2d - xceng)
print, "You're off by ", strt(offamg), ' pixels from center.'
if abs(offamg) lt 25 then print, "Nice Work!" else print, "Keep Trying!"
end;find_blaze_center.pro
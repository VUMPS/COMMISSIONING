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
;		VUMPS: Use this keyword if you are using images taken with the
;			VUMPS spectrometer. When this keyword is set, the overscan
;			region in the center of the orders is removed. When fitting
;			for the blaze peak.
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
yrange=yrange, $
vumps=vumps, $
chop_order_wings=chop_order_wings

;Call used to produce figure in thesis:
;find_blaze_center, fname='/raw/mir7/141118/chi141118.1300.fits', $
;bfname='/raw/mir7/141118/chi141118.1272.fits', $
;/postplot, inputordloc=[76.912178, 1697.1502, 545.04015, 1670.7436, $
;1073.0040, 1645.5945, 1488.3356, 1631.7624, 1812.1535, 1624.2177, $
;2178.2084, 1619.1879, 2498.5065, 1616.6729, 2924.3973, 1615.4155, $
;3459.4007, 1624.2177, 4004.9634, 1638.0497]

if 1 eq 0 then begin
inputordloc = [226.33168,       1841.2501, $
			   633.74276,       1880.6679, $
			   994.85713,       1910.9893,$
			   1383.7495,       1936.7624,$
			   1800.4200,       1958.7454,$
			   2309.6838,       1972.3900,$
			   2800.4290,       1974.6641,$
			   3193.9511,       1967.8418,$
			   3638.3995,       1954.1972,$
			   3953.2172,       1938.2785]
endif


if ~keyword_set(fname) then fname='/raw/vumps/150522/vumps150522.1030.fit'
res = double(readfits(fname, head))
;res_to = double(transpose(res))
res_to = res
;window, 1, xpos=720, ypos=450
stop
if ~keyword_set(nobias) then begin
	if ~keyword_set(bfname) then bfname='/raw/vumps/150522/vumps150522.1031.fit'
	;subtract bias frame:
	res1 = double(readfits(bfname, head))
	;res_t1 = double(transpose(res1))
	res_t1 = res1
	res_t = res_to - res_t1
endif else begin
res_t = res_to 
endelse;KW(nobias)

if keyword_set(vumps) then begin
	left = res_t[0:2043, *]
	right = res_t[2156:*, *]
	res_t = [left, right]
endif

;get the dimensions of the image:
dims = size(res_t)
xdim = dims[1]
ydim = dims[2]

usersymbol, 'circle', size_of_sym=1, /fill

loadct, 39, /silent
;stop
display, res_t, xran = [0d, xdim], yran = [1700d, 2100d], $
xtitle='CCD Column Number', ytitle='CCD Row Number'

ntim = 10d
x = dblarr(ntim)
y = dblarr(ntim)
if ~keyword_set(inputordloc) then begin
	print, 'Mark the center order '+strt(round(ntim))+' times'
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

;NOW ADJUST FOR THE DIFFERENCE IN GAIN BETWEEN THE LEFT AND RIGHT AMPS
;minval: the leftmost point on the left amp to average over
minval = 1944
;midval: the first element on the right amplifier
midval = 2044
;now create the same length range to avg over on the right amp:
maxval = midval + (midval - minval) - 1
;figure out the left/right gain ration
gaindif = total(sumarr[minval:(midval-1)])/double(total(sumarr[midval:maxval]))

;remove funky business in the order wings to improve the gaussian
;fit to the blaze peak:
chop_amount = 0
if keyword_set(chop_order_wings) then begin
	full_len = n_elements(sumarr)
	if chop_order_wings gt 1 then begin
		chop_amount = chop_order_wings
	endif else begin
		chop_amount = 400
	endelse
	sumarr = sumarr[chop_amount:(full_len - 2. * chop_amount)]
	minval -= chop_amount
	midval -= chop_amount
	maxval -= chop_amount
endif;KW(chop_order_wings)

sumarr_o = sumarr
;now correct for the gain difference:
sumarr[midval:*] *= gaindif
print, 'the gain difference is: ', gaindif

xarr = dindgen(n_elements(sumarr))

;make the axes and text printed in black, but no data:
plot, xarr + chop_amount, sumarr_o/1d4, ps=8, /ysty, /xsty, $
xtitle='CCD Column Number', ytitle='Counts/10!u4!n', /nodata
;now superimpose the original data in green:
oplot, xarr + chop_amount, sumarr_o/1d4, ps=8, col=120

;and superimpose the gain-corrected data in black:
oplot, xarr + chop_amount, sumarr/1d4, ps=8

;superimpose the regions used for gain correction in red and blue:
oplot, xarr[minval:(midval-1)] + chop_amount, sumarr_o[minval:(midval-1)]/1d4, col=250
oplot, xarr[midval:maxval] + chop_amount, sumarr_o[midval:maxval]/1d4, col=70
print, 'len of lhs: ', n_elements(sumarr_o[minval:(midval-1)])
print, 'len of rhs: ', n_elements(sumarr_o[midval:maxval])

;plot a vertical line showing the middle of the chip:
oplot, [midval, midval] + chop_amount, [0, max(sumarr/1d4)]

; fit a gaussian to the data. Coefficients in mygauss.pro are:
;0th: amplitude
;1: mean
;2: sigma
;3: offset
;4: linear term
;5: parabolic term

initial_offset = 0d
initial_mean = midval
initial_sigma = 1d3
initial_amplitude = max(sumarr)
initial_linear_trend = 0d

start = [initial_amplitude, initial_mean, initial_sigma, initial_offset, initial_linear_trend]

yerr = 3*sqrt(sumarr) + 5d3
result = MPFITFUN('MYGAUSS', xarr, sumarr, yerr, start)
print, 'MPFIT Result:'
print, result
oplot, xarr + chop_amount, mygauss(xarr, result)/1d4, col=250

;what is the x position of the center of the gaussian?
xceng = result[1]

items=['Original', 'Gain-Corrected', 'Gaussian Fit']
al_legend, items, psym=[8,8,8], color=[120, 0, 250], /right

items = ['CCD Center', 'Fit Center']
al_legend, items, linestyle=[0,0], color=[0, 250], /left

;plot a vertical line showing the center of the gaussian fit:
oplot, [xceng, xceng] + chop_amount, [0, max(sumarr/1d4)], col=250

xyouts, 0.5, 0.1, 'Difference between blaze peak and center of chip: ' + strt(abs(midval - xceng), f='(F12.1)') +' px', /normal, align=0.5

if keyword_set(postplot) then ps_close

offamg = abs(midval - xceng)
print, "You're off by ", strt(offamg), ' pixels from center.'
if abs(offamg) lt 25 then print, "Nice Work!" else print, "Keep Trying!"
stop
end;find_blaze_center.pro
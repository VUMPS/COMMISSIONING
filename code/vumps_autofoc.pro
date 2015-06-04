;+
;
;  NAME: 
;     vumps_autofoc
;
;  PURPOSE: 
;   
;
;  CATEGORY:
;      CHIRON
;
;  CALLING SEQUENCE:
;
;      vumps_autofoc
;
;  INPUTS:
;
;  OPTIONAL INPUTS:
;
;		SHOWDISP: Show a zoom into the same region of the image
;			for all the images. This serves as a reality check
;			"focus by eye".
;
;		NOSTOPFOC: Do NOT stop after every image has been run
;			through foc.pro
;
;  OUTPUTS:
;
;  OPTIONAL OUTPUTS:
;
;  KEYWORD PARAMETERS:
;    
;  EXAMPLE:
;      vumps_autofoc
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2015-05-20T15:53:32
;
;-
pro vumps_autofoc, $
postplot = postplot, $
showdisp=showdisp, $
nostopfoc=nostopfoc

angstrom = '!6!sA!r!u!9 %!6!n'
!p.color=0
!p.background=255
loadct, 39, /silent
usersymbol, 'circle', /fill, size_of_sym = 0.5
spawn, 'echo $home', mdir
mdir = mdir+'/'

dir = '/raw/vumps/150520/'
files = [$
	'Focus_034607.fits', $
	'Focus_034740.fits', $
	'Focus_034654.fits', $
	'Focus_034630.fits', $
	'Focus_034717.fits', $
	'Focus_034543.fits', $
	'Focus_034520.fits', $
	'Focus_034457.fits', $
	'Focus_034433.fits', $
	'Focus_034410.fits']

files = [$
'Focus_044343.fits', $
'Focus_044406.fits', $
'Focus_044429.fits', $
'Focus_044452.fits', $
'Focus_044516.fits', $
'Focus_044539.fits', $
'Focus_044602.fits', $
'Focus_044625.fits', $
'Focus_044648.fits', $
'Focus_044712.fits', $
'Focus_044735.fits', $
'Focus_044758.fits', $
'Focus_044821.fits', $
'Focus_044844.fits', $
'Focus_044907.fits', $
'Focus_044930.fits', $
'Focus_044954.fits', $
'Focus_045017.fits']


dir = '/raw/vumps/150521/'
files = [$
'Focus_105859.fits', $
'Focus_105924.fits', $
'Focus_105949.fits', $
'Focus_110014.fits', $
'Focus_110039.fits', $
'Focus_110104.fits', $
'Focus_110129.fits', $
'Focus_110154.fits', $
'Focus_110219.fits', $
'Focus_110244.fits', $
'Focus_110309.fits', $
'Focus_110334.fits', $
'Focus_110359.fits', $
'Focus_110424.fits', $
'Focus_110449.fits', $
'Focus_110514.fits', $
'Focus_110539.fits', $
'Focus_110604.fits', $
'Focus_110629.fits', $
'Focus_110654.fits']

spawn, 'hostname', hostname

if hostname eq 'mao1.astro.yale.edu' then begin
	dir = '/data/raw/vumps/150523/'
endif else begin
	dir = '/raw/vumps/150523/'
endelse
files = [$
'vumps150523.1013.fit', $
'vumps150523.1014.fit', $
'vumps150523.1015.fit', $
'vumps150523.1016.fit', $
'vumps150523.1017.fit', $
'vumps150523.1018.fit', $
'vumps150523.1019.fit', $
'vumps150523.1020.fit', $
'vumps150523.1021.fit', $
'vumps150523.1024.fit', $
'vumps150523.1025.fit', $
'vumps150523.1026.fit']

if keyword_set(showdisp) then begin
for f=0, n_elements(files)-1 do begin
	print, 'file: ', dir, files[f]
	im = readfits(dir+files[f])
	display, im, xrange=[1250,1750], yrange=[1000,2000],/log
	stop
endfor
print, 'END OF FOCUS IMAGES'
STOP
endif;KW(showdisp)

positionarr = dblarr(n_elements(files))
fwhmarr = dblarr(n_elements(files))
for f=0, n_elements(files)-1 do begin
	print, 'Now on file: ', files[f]
	foc,/plt,inpfile=dir+files[f], slicevals=slicevals
	print, 'FWHM: ', slicevals.avgfwhm
	positionarr[f] = slicevals.position
	fwhmarr[f] = slicevals.avgfwhm
	if ~keyword_set(nostopfoc) then stop
endfor

positionarr = [$
90000 , $
100000, $
110000, $
120000, $
130000, $
140000, $
150000, $
160000, $
170000, $
125000, $
135000, $
145000]

stop

if keyword_set(postplot) then begin
   fn = nextnameeps('plot')
   thick, 2
   ps_open, fn, /encaps, /color
endif


plot, positionarr, fwhmarr, ps=8, $
xtitle='Focus Position', $
ytitle='Average FWHM'

y_offset = min(fwhmarr)
focus_center = positionarr[where(fwhmarr eq min(fwhmarr))]

;fix the linear and cubic terms to make them stay zero:
fixed = [0, 1, 0, 1, 0, 0]

poly_init = [y_offset, 0, 1d-1, 0, 1d-1, focus_center]
pars = mpfit_poly(positionarr, fwhmarr, order=4, init=poly_init, fixed=fixed)

nfine = 1d2
posfine = dindgen(nfine)*(max(positionarr) - min(positionarr))/nfine + min(positionarr)
yfit = mypoly(posfine, pars)
oplot, posfine, yfit, col=250

print, '********************************************'
print, 'The best focus position is: ', pars[-1]
print, '********************************************'

if keyword_set(postplot) then begin
   ps_close
endif

stop
end;vumps_autofoc.pro
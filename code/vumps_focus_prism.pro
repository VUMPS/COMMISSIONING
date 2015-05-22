;+
;
;  NAME: 
;     vumps_focus_prism
;
;  PURPOSE: 
;   
;
;  CATEGORY:
;      CHIRON
;
;  CALLING SEQUENCE:
;
;      vumps_focus_prism
;
;  INPUTS:
;
;  OPTIONAL INPUTS:
;
;  OUTPUTS:
;
;  OPTIONAL OUTPUTS:
;
;  KEYWORD PARAMETERS:
;    
;  EXAMPLE:
;      vumps_focus_prism
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2015-05-22T10:34:38
;
;-
pro vumps_focus_prism, $
postplot = postplot

angstrom = '!6!sA!r!u!9 %!6!n'
!p.color=0
!p.background=255
loadct, 39, /silent
usersymbol, 'circle', /fill, size_of_sym = 0.5
spawn, 'echo $home', mdir
mdir = mdir+'/'

dir = '/raw/vumps/150522/'

files = [$
'vumps150522.1011.fit', $
'vumps150522.1012.fit', $
'vumps150522.1013.fit', $
'vumps150522.1014.fit', $
'vumps150522.1015.fit', $
'vumps150522.1016.fit', $
'vumps150522.1017.fit', $
'vumps150522.1018.fit', $
'vumps150522.1019.fit', $
'vumps150522.1020.fit', $
'vumps150522.1021.fit', $
'vumps150522.1022.fit', $
'vumps150522.1023.fit']

posarr = [$
88000, $
68000, $
58000, $
48000, $
38000, $
28000, $
18000, $
8000, $
0, $
4000, $
6000, $
10000, $
12000]

posarr /= 1d4

stdarr = dblarr(n_elements(posarr))
!p.multi=[0, 2, 1]
xmin = 840
xmax = 870
ymin = 3040
ymax = 3090
for i=0, n_elements(files)-1 do begin
im = readfits(dir+files[i])
;display, im, /log, xrange=[xmin, xmax], yrange=[ymin, ymax]
mash1 = total(im[xmin:xmax, ymin:ymax], 1)
mash2 = total(im[xmin:xmax, ymin:ymax], 2)
xarr = dindgen(xmax-xmin)+xmin
yarr = dindgen(ymax - ymin)+ymin

initial_offset = 1.6d4
initial_mean_x = (xmax - xmin)/2. + xmin + 4.
initial_sigma = 1.
initial_amplitude = max(mash2)
;initial_linear_trend = 0d
start = [initial_amplitude, initial_mean_x, initial_sigma, initial_offset];, initial_linear_trend]

yerr = sqrt(mash2) + 1d3
result = MPFITFUN('MYGAUSS', xarr, mash2, yerr, start)
stdarr[i] = result[2]

plot, xarr, mash2, ps=-8, $
xtitle='Column (Echelle Dispersion) Direction'

;initial guess:
;oplot, xarr, mygauss(xarr, start), col=70, ps=-8
oplot, xarr, mygauss(xarr, result), col=250, ps=-8
print, 'standard deviation: ', result[2]
plot, yarr, mash1, ps=-8, $
xtitle='Row (Prism Dispersion) Direction'
stop
endfor
stop

!p.multi=[0, 1, 1]
plot, posarr, stdarr, ps=-8

focus_center = 1d
y_offset = 1d
poly_init = [y_offset, 0, 1d-1, focus_center]

pars = mpfit_poly(posarr, stdarr, order=2, init=poly_init)
oplot, posarr, mypoly(posarr, pars), col=250

if keyword_set(postplot) then begin
   fn = nextnameeps('plot')
   thick, 2
   ps_open, fn, /encaps, /color
endif

if keyword_set(postplot) then begin
   ps_close
endif

stop
end;vumps_focus_prism.pro

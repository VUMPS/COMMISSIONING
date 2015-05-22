;+
;
;  NAME: 
;     vumps_echelle_masking
;
;  PURPOSE: 
;   
;
;  CATEGORY:
;      VUMPS
;
;  CALLING SEQUENCE:
;
;      vumps_echelle_masking
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
;      vumps_echelle_masking
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2015-05-21T18:37:39
;
;-
pro vumps_echelle_masking, $
postplot = postplot, $
skipclick=skipclick

angstrom = '!6!sA!r!u!9 %!6!n'
!p.color=0
!p.background=255
loadct, 39, /silent
usersymbol, 'circle', /fill, size_of_sym = 0.5
spawn, 'echo $home', mdir
mdir = mdir+'/'

loadct, 39, /silent
boxsz = 15
;unobstructed echelle
fn = '/raw/vumps/150521/vumps150521.0059.fit'
im = readfits(fn, hd)
display, im, /log, xrange=[1000,2000], yran=[1500,2500], min=460
if ~keyword_set(skipclick) then begin
cursor, x, y
print, x, y
endif else begin
x = 1553.8422
y = 2027.4320
endelse
oplot, [x-boxsz, x+boxsz], [y-boxsz,y-boxsz], col=250
oplot, [x-boxsz, x+boxsz], [y+boxsz,y+boxsz], col=250
oplot, [x-boxsz, x-boxsz], [y-boxsz,y+boxsz], col=250
oplot, [x+boxsz, x+boxsz], [y-boxsz,y+boxsz], col=250
window, /free
xarr1 = dindgen(boxsz*2) - boxsz
yarr1 = total(im[x-boxsz:x+boxsz, y-boxsz:y+boxsz], 2)

;top half covered
fn0500 = '/raw/vumps/150521/vumps150521.0053.fit'
im0500 = readfits(fn0500, hd)
;top quarter covered
fn0250 = '/raw/vumps/150521/vumps150521.0061.fit'
im0250 = readfits(fn0250, hd)
;top eighth covered
fn0125 = '/raw/vumps/150521/vumps150521.0062.fit'
im0125 = readfits(fn0125, hd)
;top sixteenth covered
fn0063 = '/raw/vumps/150521/vumps150521.0063.fit'
im0063 = readfits(fn0063, hd)

yarr0500 = total(im0500[x-boxsz:x+boxsz, y-boxsz:y+boxsz], 2)
yarr0250 = total(im0250[x-boxsz:x+boxsz, y-boxsz:y+boxsz], 2)
yarr0125 = total(im0125[x-boxsz:x+boxsz, y-boxsz:y+boxsz], 2)
yarr0063 = total(im0063[x-boxsz:x+boxsz, y-boxsz:y+boxsz], 2)

if keyword_set(postplot) then begin
   fn = nextnameeps('plot')
   thick, 2
   ps_open, fn, /encaps, /color
endif

plot, xarr1, yarr1/max(yarr1), /ysty, /xsty, $
xtitle='Dispersion Direction', $
ytitle='Normalized Counts'

oplot, xarr1, yarr0500/max(yarr1), col=40
oplot, xarr1, yarr0250/max(yarr1), col=70
oplot, xarr1, yarr0125/max(yarr1), col=100
oplot, xarr1, yarr0063/max(yarr1), col=250

items=[$
'Full Echelle', $
'Top Sixteenth Masked', $
'Top Eighth Masked', $
'Top Quarter Masked', $
'Top Half Masked']

al_legend, items, colors=[0, 250, 100, 70, 40], linestyle=0
stop
if keyword_set(postplot) then begin
   ps_close
endif

stop
end;vumps_echelle_masking.pro
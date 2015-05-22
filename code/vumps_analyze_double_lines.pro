;+
;
;  NAME: 
;     vumps_analyze_double_lines
;
;  PURPOSE: 
;   
;
;  CATEGORY:
;      VUMPS
;
;  CALLING SEQUENCE:
;
;      vumps_analyze_double_lines
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
;      vumps_analyze_double_lines
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2015-05-21T13:54:16
;
;-
pro vumps_analyze_double_lines, $
postplot = postplot

loadct, 39, /silent
boxsz = 15
fn = '/raw/vumps/150521/vumps150521.0017.fit'
im = readfits(fn, hd)
display, im, /log, xrange=[1000,3000], yran=[1500,2500], min=600
cursor, x, y
print, x, y
oplot, [x-boxsz, x+boxsz], [y-boxsz,y-boxsz], col=250
oplot, [x-boxsz, x+boxsz], [y+boxsz,y+boxsz], col=250
oplot, [x-boxsz, x-boxsz], [y-boxsz,y+boxsz], col=250
oplot, [x+boxsz, x+boxsz], [y-boxsz,y+boxsz], col=250
window, /free
xarr1 = dindgen(boxsz*2) - boxsz
yarr1 = total(im[x-boxsz:x+boxsz, y-boxsz:y+boxsz], 2)
plot, xarr1, yarr1, /ysty, /xsty
;stop

fn2 = '/raw/vumps/150521/vumps150521.0034.fit'
im2 = readfits(fn2, hd)
display, im2, /log, xrange=[1000,3000], yran=[1500,2500], min=600
cursor, x2, y2
print, x2, y2
oplot, [x2-boxsz, x2+boxsz], [y2-boxsz,y2-boxsz], col=250
oplot, [x2-boxsz, x2+boxsz], [y2+boxsz,y2+boxsz], col=250
oplot, [x2-boxsz, x2-boxsz], [y2-boxsz,y2+boxsz], col=250
oplot, [x2+boxsz, x2+boxsz], [y2-boxsz,y2+boxsz], col=250
window, /free
xarr2 = dindgen(boxsz*2) - boxsz
yarr2 = total(im2[x2-boxsz:x2+boxsz, y2-boxsz:y2+boxsz], 2)

fn3 = '/raw/vumps/150521/vumps150521.0036.fit'
im3 = readfits(fn3, hd)
display, im3, /log, xrange=[1000,3000], yran=[1500,2500], min=600
cursor, x3, y3
print, x3, y3
xarr3 = dindgen(boxsz*2) - boxsz
yarr3 = total(im3[x3-boxsz:x3+boxsz, y3-boxsz:y3+boxsz], 2)

plot, xarr2-2.5, yarr2/max(yarr2), /ysty, /xsty, yran=[0, 1.1], $
xtitle='Dispersion Direction', ytitle='Normalized Counts'
oplot, xarr1+0.75, yarr1/max(yarr1), col=250
oplot, xarr3-1.5, yarr3/max(yarr3), col=70

items = ['Initial', 'Dewar Down', 'Dewar Up']
al_legend, items, colors=[0, 250, 70], linestyle=0

stop


angstrom = '!6!sA!r!u!9 %!6!n'
!p.color=0
!p.background=255
loadct, 39, /silent
usersymbol, 'circle', /fill, size_of_sym = 0.5
spawn, 'echo $home', mdir
mdir = mdir+'/'

stop
if keyword_set(postplot) then begin
   fn = nextnameeps('plot')
   thick, 2
   ps_open, fn, /encaps, /color
endif

if keyword_set(postplot) then begin
   ps_close
endif

stop
end;vumps_analyze_double_lines.pro
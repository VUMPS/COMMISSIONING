;+
;
;  NAME: 
;     plot_vumps_foc
;
;  PURPOSE: 
;   
;
;  CATEGORY:
;      VUMPS
;
;  CALLING SEQUENCE:
;
;      plot_vumps_foc
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
;      plot_vumps_foc
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2015-05-20T11:33:51
;
;-
pro plot_vumps_foc, $
postplot = postplot

nimages = 27
posarr = findgen(nimages)+85.

fwhmarr = [$
4.446, $
4.389, $
4.387, $
4.355, $
4.330, $
4.270, $
4.258, $
4.185, $
4.158, $
4.225, $
4.187, $
4.146, $
4.183, $
4.160, $
4.150, $
4.296, $
4.268, $
4.331, $
4.286, $
4.309, $
4.324, $
4.408, $
4.380, $
4.462, $
4.647, $
4.555, $
4.436]



usersymbol, 'circle', /fill
plot, posarr, fwhmarr, /ysty, ps=8


print, posarr
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
end;plot_vumps_foc.pro
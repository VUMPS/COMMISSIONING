;+
;;  NAME: 
;     chi_autofoc
;;  PURPOSE: 
;   To autofocus CHIRON
;
;  CATEGORY:
;      CHIRON
;
;  CALLING SEQUENCE:
;
;      chi_autofoc
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
;      chi_autofoc
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2011.06.17 04:08:06 PM
;
;-
pro chi_autofoc

nsteps = 1
steps = dindgen(nsteps)/10d + 9.55d
print, steps



spawn, 'date "+%y%m%d"', date
date=strt(date)
spawn, 'ssh ctioe1 mkdir /data/'+date
chi_dir = '/data/'+date
ct1_dir = '/mir7/raw/'+date

spawn, 'ssh ctioe1 pan appmacro set_roi FULL'

spawn, 'ssh ctioe1 pan appmacro set_binning 3 1'

spawn, 'ssh ctioe1 pan appmacro speed_fast'

spawn, 'ssh ctioe1 slicer MOVE narrow_slit'

spawn, 'ssh ctioe1 iodcell get iodine', pos
posx = strsplit(pos, ' ', /extract)


if (posx[1] eq "OFF" ) OR (posx[1] eq "OUT") then begin
  print, 'The iodine cell was already out'
endif else begin
  spawn, 'ssh ctioe1 iodcell set iodine OUT'
endelse

spawn, 'ssh ctioe1 lamp set TH-AR on'

spawn, 'ssh ctioe1 pan set exptime 1000'

spawn, 'ssh ctioe1 pan set image.title "focus"'

spawn, 'ssh ctioe1 image.basename "qa37."'

spawn, 'ssh ctioe1 image.number 10'

spawn, 'ssh ctioe1 pan set obs.numreads 1'

spawn, 'ssh ctioe1 dhe set obs.observer Slartibartfast'

spawn, 'ssh ctioe1 pan set obs.obstype "Calibration"'

spawn, 'ssh ctioe1 pan set autoshutter on'

spawn, 'ssh ctioe1 pan set image.directory '+chi_dir


for i=0, nsteps - 1 do begin

spawn, 'ssh ctioe1 CHIRON FOCUS MOVE'+strt(steps[i], f='(F8.2)')

spawn, 'ssh ctioe1 pan expose'

endfor


spawn, 'mkdir /mir7/raw/'+date
spawn, 'rsync -zuva ctioe1:/data/'+date+'/ /mir7/raw/'+date+'/'

spawn, 'ls -1 '+ct1_dir, files

nfiles = n_elements(files) - 1
focpos = dblarr(nfiles)
focfwhm = dblarr(nfiles)
for i=0, nfiles-1 do begin
inpfile = ct1_dir+'/'+files[i+1]
im = mrdfits(inpfile, 0, hd)
focpos[i] = sxpar(hd, 'FOCUS')
foc, inpfile=inpfile, slicevals = slicevals
stop
focfwhm[i] = slicevals.avgfwhm


endfor



stop
end;chi_autofoc.pro
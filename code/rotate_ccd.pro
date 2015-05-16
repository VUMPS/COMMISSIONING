;+
;
;  NAME: 
;     rotate_ccd
;
;  PURPOSE: 
;   To rotate the CCD to maintain resolution while
;	allowing for on-chip binning. 
;
;  CATEGORY:
;      CHIRON
;
;  CALLING SEQUENCE:
;
;      rotate_ccd
;
;  INPUTS:
;		FILENAME: The 1x1 ThAr filename to be used for the CCD
;			rotation analysis. 
;
;		BIASFN: The 1x1 bias frame to be used.
;
;		INPUTLINES: For reproducibility, you can manually enter the 
;			line pairs you want to use. Input should be of the form
;			inputlines = [x_ij,y_ij] = [x_11,y_11,x_12,y_12,x_21,x_22,x_22,x_22,...]
;			where i is for the line number, and j is for the right (1) and left (2)
;			instances of each line.
;
;		NLINES: The number of lines to average over when computing
;			the rotation.
;
;		NPLOTCOL: The number of columns for the plot of the line
;			profiles. If this is not specified, 2 columns will be
;			used if nlines > 1.
;
;		NPLOTROW: The number of rows for the plot of the line profiles.
;			If not specified there will be 2 plots per row.
;
;  OPTIONAL INPUTS:
;		POSTPLOT: output plot to postscript
;
;  OUTPUTS:
;
;  OPTIONAL OUTPUTS:
;
;  KEYWORD PARAMETERS:
;    
;  EXAMPLE:
;      rotate_ccd
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2011.03.11 11:58:41 AM
;
;-
pro rotate_ccd, $
filename=filename, $
biasfn=biasfn, $
inputlines=inputlines, $
nlines=nlines, $
nplotcol=nplotcol, $
nplotrow=nplotrow, $
postplot=postplot


;COMMAND FOR THESIS FIGURES:
;rotate_ccd, filename='/raw/mir7/141118/chi141118.1091.fits', biasfn='/raw/mir7/141118/chi141118.1059.fits', $
;nlines=3, nplotcol=1, nplotrow=3, /postplot, inputlines = [3247.0902, 1672.4433, 532.48214, 1671.5567, $
;3249.4714, 1472.0660, 420.56409, 1473.8392, 3416.1578, 1191.0058, 396.75174, 1190.1191]




if ~keyword_set(filename) then filename = '/mir7/n1/qa30_0146.fits'
if ~keyword_set(biasfn) then biasfn = '/raw/mir7/data/110310/qa31.1000.fits'
if ~keyword_set(nlines) then nlines=1
bias = readfits(biasfn)
bias_t = double(transpose(bias))
imo = double(readfits(filename, header))

loadct, 39, /silent
;returns x1, y1, x2, y2
bblarr = str_coord_split(sxpar(header, 'bsec11')) - 1d
bbrarr = str_coord_split(sxpar(header, 'bsec12')) - 1d
bularr = str_coord_split(sxpar(header, 'bsec21')) - 1d
burarr = str_coord_split(sxpar(header, 'bsec22')) - 1d

datblarr = str_coord_split(sxpar(header, 'dsec11')) - 1d
datbrarr = str_coord_split(sxpar(header, 'dsec12')) - 1d
datularr = str_coord_split(sxpar(header, 'dsec21')) - 1d
daturarr = str_coord_split(sxpar(header, 'dsec22')) - 1d
;stop

;subtract the bias from the bottom left:
;bbl (11)
for i=datblarr[2], datblarr[3] do begin
  imo[datblarr[0]:datblarr[1], i] = $
  imo[datblarr[0]:datblarr[1], i] - $
  median(imo[(bblarr[0]+2):(bblarr[1]-3), i])
  ;median(imo[1:47, i])
endfor

;subtract the bias from the bottom right:
;bul (21)
for i=datularr[2], datularr[3] do begin
  imo[datularr[0]:datularr[1], i] = $
  imo[datularr[0]:datularr[1], i] - $
  median(imo[(bularr[0]+2):(bularr[1]-3), i])
  ;imo[101:2148, i] = imo[101:2148, i] - median(imo[1:47, i])
endfor

;subtract the bias from the bottom right:
;bbr (12)
;for i=0, 2047 do begin
for i=datbrarr[2], datbrarr[3] do begin
  imo[datbrarr[0]:datbrarr[1], i] = $
  imo[datbrarr[0]:datbrarr[1], i] - $
  median(imo[(bbrarr[0]+2):(bbrarr[1]-3), i])
 ;imo[2149:4196, i] = imo[2149:4196, i] - median(imo[4249:4294, i])
endfor

;bur (22)
;for i=2048, 4095 do begin
for i=daturarr[2], daturarr[3] do begin
  imo[daturarr[0]:daturarr[1], i] = $
  imo[daturarr[0]:daturarr[1], i] - $
  median(imo[(burarr[0]+2):(burarr[1]-3), i])
;imo[2149:4196, i] = imo[2149:4196, i] - median(imo[4249:4294, i])
endfor


imo_t = transpose(imo)
im = double(imo_t)
loadct,0, /silent
usersymbol, 'circle', /fill
window, 0, xsize=1800, ysize=1200
titl = '!6 CTIO THORIUM FOCUS LINES'
yt='Row Number'
xt='Column Number'
x0 = 102d
;y0 = 1500d
;y00 = 2000d
y0=1d3
y00=2d3
sizim = size(im)
xvec = indgen(sizim[1]-round(x0))+x0
yvec = indgen(round(y00)-round(y0)+1)+y0

display,im[x0:*, y0:y00],xvec, yvec,ytit=yt,xtit=xt,/log, min=5;, max=50000d;,/log
;stop
loadct, 39, /silent

oplot, [2048, 2048], [0,5000], color=240

;superimpose vertical rainbow lines to guide the eye:
colors = [70, 90, 120, 210, 250, 70, 90, 120, 210, 250]
for i=0, 6 do begin
	oplot, [2048 - (i+1)*256, 2048 - (i+1)*256], [0,5000], color=colors[i], linestyle=3
	oplot, [2048 + (i+1)*256, 2048 + (i+1)*256], [0,5000], color=colors[i], linestyle=3
endfor

;superimpose horizontal lines to guide the eye:
for i=1, 9 do begin
	oplot, [0, 4096], y0+[i*100,i*100], color=colors[i], linestyle=1
endfor

;NOW THE CURSOR PROCEDURE
sz = 10
linecol1 = 80
linecol2 = 210
x1arr = dblarr(nlines)
y1arr = dblarr(nlines)
x2arr = dblarr(nlines)
y2arr = dblarr(nlines)

if keyword_set(inputlines) then begin 
	nlines = n_elements(inputlines)/4L
	for i=0, nlines-1 do begin
		x1arr[i] = inputlines[4*i]
		y1arr[i] = inputlines[4*i + 1]
		x2arr[i] = inputlines[4*i + 2]
		y2arr[i] = inputlines[4*i + 3]
	endfor
endif

;now loop over the number of input lines
;specified to average over. This gets the
;coordinates of each line pair:
for i=0, nlines-1 do begin
  if ~keyword_set(inputlines) then begin
	  cursor, x1, y1, /down
	  x1arr[i] = x1
	  y1arr[i] = y1
  endif
  print, x1arr[i], y1arr[i]
  oplot, [(x1arr[i]-sz),(x1arr[i]+sz)], [(y1arr[i]-sz),(y1arr[i]-sz)], color=linecol1           
  oplot, [(x1arr[i]-sz),(x1arr[i]+sz)], [(y1arr[i]+sz),(y1arr[i]+sz)], color=linecol1
  oplot, [(x1arr[i]-sz),(x1arr[i]-sz)], [(y1arr[i]-sz),(y1arr[i]+sz)], color=linecol1
  oplot, [(x1arr[i]+sz),(x1arr[i]+sz)], [(y1arr[i]-sz),(y1arr[i]+sz)], color=linecol1

  if ~keyword_set(inputlines) then begin
	  cursor, x2, y2, /down
	  x2arr[i] = x2
	  y2arr[i] = y2
  endif
  print, x2arr[i], y2arr[i]
  oplot, [(x2arr[i]-sz),(x2arr[i]+sz)], [(y2arr[i]-sz),(y2arr[i]-sz)], color=linecol2           
  oplot, [(x2arr[i]-sz),(x2arr[i]+sz)], [(y2arr[i]+sz),(y2arr[i]+sz)], color=linecol2
  oplot, [(x2arr[i]-sz),(x2arr[i]-sz)], [(y2arr[i]-sz),(y2arr[i]+sz)], color=linecol2
  oplot, [(x2arr[i]+sz),(x2arr[i]+sz)], [(y2arr[i]-sz),(y2arr[i]+sz)], color=linecol2
endfor;0->nlines

;print out the line number above the box surrounding each line:
for i=0, nlines-1 do begin
	xyouts, x1arr[i], y1arr[i]+1.5*sz, strt(i), color=linecol1
	xyouts, x2arr[i], y2arr[i]+1.5*sz, strt(i), color=linecol2
endfor

if keyword_set(postplot) then begin
  ps_open, nextnameeps('rotation_ccd'), /encaps, /color
  thick, 3
  !p.charsize=1

  ;plot the ThAr image in black and white
  loadct,0, /silent
  display, im[x0:*, y0:y00], xvec, yvec, ytit=yt, xtit=xt, /log, min=5

  ;now switch to rainbow for the overplotted lines:
  loadct,39, /silent

  ;the central vertical line should be solid red:
  oplot, [2048, 2048], [0,5000], color=250

  ;superimpose vertical rainbow lines to guide the eye:
  for i=0, 6 do begin
	oplot, [2048 - (i+1)*256, 2048 - (i+1)*256], [0,5000], color=colors[i], linestyle=3
	oplot, [2048 + (i+1)*256, 2048 + (i+1)*256], [0,5000], color=colors[i], linestyle=3
  endfor

  ;superimpose horizontal lines to guide the eye:
  for i=1, 9 do begin
	oplot, [0, 4096], y0+[i*100,i*100], color=colors[i], linestyle=1
  endfor

  for i=0, nlines-1 do begin
	oplot, [(x1arr[i]-sz),(x1arr[i]+sz)], [(y1arr[i]-sz),(y1arr[i]-sz)], color=linecol1           
	oplot, [(x1arr[i]-sz),(x1arr[i]+sz)], [(y1arr[i]+sz),(y1arr[i]+sz)], color=linecol1
	oplot, [(x1arr[i]-sz),(x1arr[i]-sz)], [(y1arr[i]-sz),(y1arr[i]+sz)], color=linecol1
	oplot, [(x1arr[i]+sz),(x1arr[i]+sz)], [(y1arr[i]-sz),(y1arr[i]+sz)], color=linecol1

	oplot, [(x2arr[i]-sz),(x2arr[i]+sz)], [(y2arr[i]-sz),(y2arr[i]-sz)], color=linecol2           
	oplot, [(x2arr[i]-sz),(x2arr[i]+sz)], [(y2arr[i]+sz),(y2arr[i]+sz)], color=linecol2
	oplot, [(x2arr[i]-sz),(x2arr[i]-sz)], [(y2arr[i]-sz),(y2arr[i]+sz)], color=linecol2
	oplot, [(x2arr[i]+sz),(x2arr[i]+sz)], [(y2arr[i]-sz),(y2arr[i]+sz)], color=linecol2

	;print out the line number above the box surrounding each line:
	xyouts, x1arr[i], y1arr[i]+1.5*sz, strt(i), color=linecol1
	xyouts, x2arr[i], y2arr[i]+1.5*sz, strt(i), color=linecol2
  endfor;0->nlines
  ps_close
endif;KW:postplot

if ~keyword_set(postplot) then begin
	window, /free
endif else begin
	ps_open, nextnameeps('lineprofile'), /color, /encaps
    thick, 3
    !x.charsize=2.
    !y.charsize=2.
    !x.margin = [18, 5]
    !y.margin = [7, 2]
endelse

;if the user does not specify the arrangement of plots
;of the line profiles by using the nplotcol and 
;nplotrow keywords, set the number of columns
;and rows here:
if ~keyword_set(nplotcol) or ~keyword_set(nplotrow) then begin
  if nlines eq 1 then begin
	  nplotcol=1 & nplotrow = 1
  endif else begin
	  nplotcol = 2
	  nplotrow = CEIL(nlines/2.)
  endelse
endif

;create multiple plots per page
!p.multi = [0, nplotcol, nplotrow]
 
;create an array to store the offset values:
offsetarr = dblarr(nlines)

;cycle through line pairs making line profile plots:
for i=0, nlines-1 do begin
	x1 = x1arr[i]
	y1 = y1arr[i]
	x2 = x2arr[i]
	y2 = y2arr[i]
	mash1 = total(im[(x1-sz):(x1+sz), (y1 - sz):(y1 + sz)], 1)
	gfac1 = gaussfit(indgen(2d*sz+1), mash1, acoef1, nterms=4)

	mash1d = total(im[(x1-sz):(x1+sz), (y1 - sz):(y1 + sz)], 2)
	gfac1d = gaussfit(indgen(2d*sz+1), mash1d, acoef1d, nterms=4)
	print, 'the FWHM of the 1st line in the D direction is: ', $
	acoef1d[2] * 2.3548d

	mash2 = total(im[(x2-sz):(x2+sz), (y2 - sz):(y2 + sz)], 1)
	mash2d = total(im[(x0+x2-sz):(x0+x2+sz), (y0+y2 - sz):(y0+y2 + sz)], 2)
	gfac2d = gaussfit(indgen(2d*sz+1), mash2d, acoef2d, nterms=4)
	print, 'the FWHM of the 2nd line in the D direction is: ', $
	acoef2d[2] * 2.3548d

	gfac2 = gaussfit(indgen(2d*sz+1), mash2, acoef2, nterms=4)

	;Set the min to be a few percent lower (pbuf) than the
	;lowest valueof the left-line-pro, left-line-mod,
	;right-line-pro, or right-line-model:
	pbuf = 1.000125
	ymin = (min(mash1)) < $
		   (min(gfac1)) < $
		   (min(mash2)) < $
		   (min(gfac2))

	ymax = (max(mash1)) > $
		   (max(gfac1)) > $
		   (max(mash2)) > $
		   (max(gfac2))
	
	print, 'ymin and ymax: ', ymin, ymax
	
	;make the window with a black frame
	xarr1 = acoef1[1] + y0 + y1 + findgen(n_elements(mash1)) - n_elements(mash1)/2.
	plot, xarr1, mash1, $
	xtitle='Cross Dispersion Position', $
	ytitle='Counts', /nodata, yran = [ymin, ymax]

	;now superimpose the profile of the first line:
	oplot, xarr1, mash1, ps=-8, col=linecol1
	;and superimpose the best-fit to the first line:
	oplot, xarr1, gfac1, color=linecol1, linestyle=3

	;now superimpose the profile of the second line:
	xarr2 = acoef2[1] + y0 + y2 + findgen(n_elements(mash2)) - n_elements(mash2)/2.
	oplot, xarr2, mash2, ps=-8, color=linecol2
	;and superimpose the best-fit to the second line:
	oplot, xarr2, gfac2, color=linecol2, linestyle=3

	;now make a legend:
	items = ['Left Line '+strt(i)+' Profile', 'Left Line Fit', 'Right Line Profile', 'Right Line Fit']
	al_legend, items, linestyle=[0,3,0,3], color=[80, 80, 210, 210], /right

	;compute the line centers:
	cy1 = acoef1[1] + y0 + y1
	cy2 = acoef2[1] + y0 + y2

	print, 'acoef1 is: ', acoef1
	print, 'acoef2 is: ', acoef2
	print, 'y0 is: ', y0
	print, 'y1 is: ', y1
	print, 'y2 is: ', y2
	print, 'the central row of the first line is: ', cy1
	print, 'the central row of the second line is: ', cy2
	print, 'the difference in y is: ', cy2 - cy1
	offsetarr[i] = cy2 - cy1
	print, 'the difference in x is: ', x2 - x1
endfor;loop over # lines
if keyword_set(postplot) then ps_close

print, 'The average offset between the right and left lines was: ', mean(offsetarr)

end; rotate_ccd.pro
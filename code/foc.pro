pro foc,avgpro,plt=plt, dewar=dewar, inpfile=inpfile,mark=mark, $
        findloc=findloc, pr=pr, focalmap=focalmap, slicevals=slicevals, $
        ngoods = ngoods, badheader=badheader
;
; PURPOSE:
; Focus Program for the VUMPS spectrometer

; Computes FWHM of each Thorium line (preselected), and the average FWHM.
; Uses Gaussian fitting to each selected thorium line.
;
; CALLING EXAMPLES:  
;     IDL> foc,/plt,/mark,inpfile='/raw/vumps/150519/vumps150519.1002.fit', /findloc
;
; INPUTS:  
;       1.  Thorium inpfile must exist
;       2.  Thorium line list must exist in: ctio_lines.txt
;
; OUTPUTS: 
;        To screen:  CCD position,  Avg. FWHM
;        x      columns of the line locations
;        fwhmx  FWHM (in dispersion direction)
;
; KEYWORDS: 
;       INPFILE   Invoke Alternative input file of Thorium (instead of scr)
;                 eg.,   foc,inpfile = '/data/d13.ccd'
;       /PLT       Invoke Plotting Diagnostics (strongly advised)
;       /PR        Invoke Printing Diagnostics
;       /MARK     Marks positions of lines
;       /FINDLOC  Allows user to mark and store locations of th lines
;		SLICEVALS: Use this keyword to passback a structure containing various
;					focus values of interest. 
;		NGOODS: Optional output containing the number of good lines used for the calculation
;    
; METHOD:
;       Thorium lines at prescribed pixel locations (given in
;       ctio_lines.txt) are mashed and interpolated
;       by spline.  The FWHM is the number of pixels above the 
;       1/2 peak counts.  FW@10% is # of pixels above "LEVEL" (10%).
;       The ASYM is the displacement of the bisector at 10% relative
;       to that at 50%.

; HISTORY:  
;    24 Oct 1994, Create  G.Marcy,T.Misch,P.Butler
;    10 Jan 1995, Revised for Output of Peak Cts and FWHM and Saturation (GM)
;    14 Jan 1995, Revised for FW10% and Asymmetry parameter and Plotting
;    20 Feb 1995, Revised to do Gaussian fitting.
;    Nov 1999, DAF, revised to include fwhm vs col and row
;    16 May 2008, Revised for CTIO, D. Fischer
;	2011.06.13 ~MJG: created optional keyword "slicevals" to pass out a structure
;				I created that contains focus information of interest. This
;				procedure and this structure will be used by LOGMAKER.PRO
;				to add the focus information to the logsheet headers when auto-generating
;				the logsheets each day. 

 amps = 4
 fname = ' '
 ans = ' '
 usersymbol, 'circle', /fill
;
  IF keyword_set(inpfile) then filename = inpfile
  imo = double(readfits(filename, header))
if keyword_set(plt) then display,imo,/log

pos = sxpar(header, 'encpos')
print, pos

if ~keyword_set(badheader) then begin
;returns x1, y1, x2, y2
;bblarr = str_coord_split(sxpar(header, 'bsec11')) - 1d
;bbrarr = str_coord_split(sxpar(header, 'bsec12')) - 1d
;bularr = str_coord_split(sxpar(header, 'bsec21')) - 1d
;burarr = str_coord_split(sxpar(header, 'bsec22')) - 1d

;datblarr = str_coord_split(sxpar(header, 'dsec11')) - 1d
;datbrarr = str_coord_split(sxpar(header, 'dsec12')) - 1d
;datbrarr = [2100, 4199, 0, 2055]
;datularr = str_coord_split(sxpar(header, 'dsec21')) - 1d
;daturarr = str_coord_split(sxpar(header, 'dsec22')) - 1d

bblarr = [2044,2099,0,2055]
bbrarr = [2100,2155,0,2055]
bularr = [2044,2099,2056,4111]
burarr = [2100,2155,2056,4111]

datblarr = [0,2099,0,2055]
datbrarr = [2100,4199,0,2055]
datularr = [0,2099,2056,4111]
daturarr = [2100,4199,2056,4111]

;bbl (11)
imo[datblarr[0]:datblarr[1], datblarr[2]:datblarr[3]] -= $
	median(imo[bblarr[0]:bblarr[1], bblarr[2]:bblarr[3]])

;bul (21)
imo[datularr[0]:datularr[1],datularr[2]:datularr[3]] -= $
median(imo[bularr[0]:bularr[1],bularr[2]:bularr[3]])

;bbr (12)
imo[datbrarr[0]:datbrarr[1],datbrarr[2]:datbrarr[3]] -= $
median(imo[bbrarr[0]:bbrarr[1],bbrarr[2]:bbrarr[3]])

;bur (22)
imo[daturarr[0]:daturarr[1],daturarr[2]:daturarr[3]] -= $
median(imo[burarr[0]:burarr[1],burarr[2]:burarr[3]])

endif else begin

endelse

;stop


imo = reverse(imo)
;imo_t = transpose(imo)
;im = double(imo_t)

im = double(imo)
window, xsize=1800, ysize=1000
loadct, 39, /silent
;display, im, /log, min = 75
;stop

;  im = im - 0.95*bias_t
  xbad=where(im lt 0.0,nxb)
  if nxb gt 0 then im(xbad) = 1.

  hd=headfits(filename)
;  bl=sxpar(hd,'BSEC21',count=match)
;  bl=median(im[1036:1094,*])
;  br=median(im[1101:1161,*])
;  im[0:1098,*]=im[0:1098,*]-bl
;  im[1099:2185,*]=im[1099:2185,*]-br



  sz=size(im)
  ncol = sz[1]
  nrow = sz[2]
;stop
; Uncomment if locating lines for the first time
if keyword_set(findloc) then begin
!p.color=0
loadct, 39, /silent
  ;FINDLINES,im,x,y;,/silent            ;find x,y positions of Th-Ar lines
endif else begin
 ;RESTORE LINES for IODINE SET-UP
 ; comment out if locating lines for the first time
  readcol, 'vumps_lines.found', x, y, format='a,a'
  x=double(x)
  y=double(y)
  ;not sure where this factor comes from...
;  y = y + 40d
endelse


sz = 12d
boxsz = sz*2+1d          ;11 x 11 pixels around each Th line.
loadct,39, /silent
;MARK the LOCATIONS of the FOCUS Th LINES
  if keyword_set(findloc) then mark=1
  IF keyword_set(mark) then begin  
     wintitle = 'VUMPS Focus Program'
     window,0,xsize=1200,ysize=600,title=wintitle
     !p.multi=0
     minim = median(im)
  xs=indgen(n_elements(im(*,0)))
  ys=indgen(n_elements(im(0,*)))
 ;    xs=indgen(2196)
 ;    ys=indgen(600)
     !p.charsize=1.8
     titl = '!6 VUMPS THORIUM FOCUS LINES'
     yt='ROW #'
     xt='COL #'
     !p.color=300
window, 0, xsize=1400, ysize=1000
     display,im,xs,ys,titl=titl,ytit=yt,xtit=xt,/log; min=20, max=50000d;,/log
;     oplot,x,y,ps=6,symsize=1.8,thick=1,co=255 ;boxes at LINE LOC's (+1 is kludge)
;stop
; SPECIAL SECTION TO FIND LINE LOCATIONS OF NEW CCD
     IF keyword_set(findloc) then begin
                                ;  Find Line Locations on a new CCD chip
;window, 0, xsize=3700, ysize=1300, xpos=200
     ;display,im,xs,ys,/log; min=20, max=50000d;,/log

        print,'New Line Locations will be stored in lines.found '
        openw,2,'lines.found'
        nl = 0d;n_elements(x)      ;Final No. of Th lines
        read,'How many lines do you want to ID?',nl
        x = dblarr(nl)
        y = dblarr(nl)
        
        FOR j=0,nl-1 do begin
           ;window, 0
           cursor,a,b 
           x[j] = a
           y[j] = b
           c1 = a-sz  & c2 = a+sz
           r1 = b-sz  & r2 = b+sz
           box = double(im[c1:c2 , r1:r2])                       ;box within image containing Th line
           bckg = median([box(0,0:boxsz-1),box(boxsz-1,0:boxsz-1)]) ;lft, rt edges
           box = box - bckg                                         ;sub backgr
           mashcol = total(box,1)                                   ;mashed cols w/i box
           mashrow = total(box,2)                                   ;mashed rows
           ;window, 2
           ;plot, mashcol
           ;dum = max(mashcol,rowloc) & 
           rowloc=b;+ 40d ;kludge in cursor position
           ;dum = max(mashrow,colloc) & 
           colloc= a;+c1+.5
           printf,2,colloc, rowloc
           print,colloc,rowloc, im[x[j], y[j]]
           oplot,[x[j],x[j]],[y[j],y[j]],ps=6,symsize=1.8,thick=1,co=255 ;boxes at LINE LOC's (+1 is kludge)
           wait,1
        ENDFOR
        close,2
     ENDIF ELSE BEGIN        ;END FIND LINE LOCATIONS
	  ;boxes at LINE LOC's (+1 is kludge)
	  print, 'x, y'
	  for xymrk = 0, n_elements(x)-1 do print, x[xymrk], y[xymrk]
	  oplot,x,y,ps=6,symsize=1.8,thick=1,co=255 
	  print, 'YOU ENTERED MARK, BUT NO FINDLOC'
     endelse
     read,'Hit <RETURN> to proceed on: ',ans
  ENDIF ;end mark section
if keyword_set(plt) then window, 0, xsize=1800, ysize=1200

;stop
j=0
;           window, 2
           ;!p.multi=[0,1,2]
           ;plot, im[x[j], (y[j]-sz): (y[j]+sz)], ps=8
;           plot, im[(x[j]-sz): (x[j]+sz), y[j]], ps=8
;           cursor, xq1, yq1, /down
;           cursor, xq2, yq2, /down
;           print, xq2 - xq1
;stop
;Set some Parameters
  thresh = 2500      ;thresh for "saturated" signal to be sent.
  level = 0.1         ;level at which Full Width and Asymm are computed
  ind = findgen(boxsz)
  osamp = 50.                        ;oversample 50 subpixels per pixel
  finelen = (boxsz-1)*osamp          ;length of oversampled spectra
  finecen = 0.5*finelen
  fineind = findgen(finelen)/osamp   ;oversampled index
  numcol = dimen(im,0)               ;No. of col's
  numrow = dimen(im,1)               ;No. of rows
  xmid = numcol/2.                   ; middle col of chip
  ymid = numrow/2.                   ; middle row of chip
  nfound = 0
  a = fltarr(3)              ;gauss params: a(1)=cen, a(2)=sigma
;
IF keyword_set(plt) then begin
  !p.charsize=1.
  !p.multi = [0,2,2]
END
;stop
;
;Reject Th lines that lie too close to edges (within sz of edge)
  i = where(x gt sz and x lt numcol-boxsz and $
            y gt sz and y lt numrow-boxsz)     ;indices well within edges
  x = x(i) & y = y(i)      ;Use only Th lines well inside edge of CCD
  nl = n_elements(x)        ;Final No. of Th lines
;
;Initialize Some More Variables (that depend on the # of lines, nl)
  fwhmx = fltarr(nl)   ;FWHM in the COLUMN direction (= 1.18 sigma) 
  fwhmy = fltarr(nl)   ;FWHM in the ROW    direction
  fw10x = fltarr(nl)   ;FW at 10% of peak of each line
  asym  = fltarr(nl)   ;asymmetry index of each line 
  dx    =fltarr(nl)    ;found - expected column position
  dy    =fltarr(nl)    ;found - expected row position
  allprofs= fltarr(finelen,nl)       ;all Thorium profiles
  r     = sqrt((x-xmid)^2 + (y-ymid)^2)   ;radial distance from image center 
;
if keyword_set(pr) then begin
  print,' '
  print,' _____________________________________________________________ '
  print,'|  Column     Row   Peak Cts      FWHM    FW@10%    ASYM      |'  
  print,'|_____________________________________________________________|'
end
 form='(A1,I8,I8,I8,A3,F10.2,F10.2,A5)'
;
;LOOP THROUGH ALL LINES
;

FOR j = 0,nl-1 do begin                ;Loop through all nl lines
  c1 = x(j)-sz  & c2 = x(j)+sz
  r1 = y(j)-sz  & r2 = y(j)+sz
  box = float(im(c1:c2 , r1:r2))       ;box within image containing Th line
  bckg = median([box(0,0:boxsz-1),box(boxsz-1,0:boxsz-1)])   ;lft, rt edges
  box = box - bckg                     ;sub backgr
    mashcol = total(box,1)    ;mashed cols w/i box
    mashrow = total(box,2)    ;mashed rows
    dum = max(mashcol,rowloc) & rowloc=fix(rowloc(0)) ;rowloc is output loc
    dum = max(mashrow,colloc) & colloc=fix(colloc(0))

;
  IF abs(rowloc-sz) gt 6 or abs(colloc-sz) gt 4 then begin
      col = fix(colloc+c1)
      row = fix(rowloc+r1)
      cts = fix(im(colloc+c1,rowloc+r1))
      flag = ' NF'    ;line not found
      fwhmx(j) = 0. 
      fwhmy(j) = 0.
      dx(j)=0. & dy(j)=0.

      if keyword_set(pr) then begin
      
        print, format=form,'|', col, row , cts, flag,fwhmx(j),fw10x(j),' |'
        ;stop
      endif
      x(j)=-1   ;x(j)=-1 means line not found, for later rejection, PB 11/15/94
  ENDIF else begin 
;
;    omashcol = spline(ind,mashcol,fineind,3)    ; oversampled 
     omashrow = spline(ind,mashrow,fineind,3)     ; oversampled, mashed row 
;
; FWHM   (50% level)
; Use Gaussian to get height and width
    fit = gauss_fit(ind,mashrow,a)
    print, 'now on line: ', j
;    print, fit
  

    fwhmx(j) = a(2) * 2.3548 ; a(2)*2.*sqrt(2.*alog(2.)) Convert sigma to FWHM
    fwhmy(j) = a(2) * 2.3548 ; a(2)*2.*sqrt(2.*alog(2.)) Convert sigma to FWHM
    mashrow = mashrow/a(0)        ;normalize height
    omashrow= omashrow/a(0)       ;normalize
    indHM = where(omashrow ge 0.5*max(omashrow),num) ;indices where cts > .5*peak
    midfwhm = a(1) * osamp   ;peak loc. of Gaussian in osamp units
    IF keyword_set(plt) then begin  ;plot each line fit.
      plot,ind,mashrow,ps=8,yr=[0,1.2],/ysty
      gaussian,fineind,a,fit  ;evaluate Gaussian on fine abscissa
      oplot,fineind,fit/a(0)
      xyouts,1,0.95,'c='+strtrim(fix(x(j)),2),size=1.3
      xyouts,1,0.85,'r='+strtrim(fix(y(j)),2),size=1.3
      ;stop
    ENDif
;    if j/4. - j/4 gt 0.7 then wait,1
;
;print, 'FW 10%'
; FW at 10%,  i.e., "level = 0.10"
    indlev = where(omashrow ge level,num) ;indices where cts > .1*peak
    fw10x(j) = num/osamp                      ;Full width at 10% peak
    midlev = 0.5*(indlev(0) + indlev(num-1))  ;midpoint of chord at level (10%)

; ASYMMETRY:  Displacement (from peak location) of 10% bisector.
    asym(j) = (midlev - midfwhm)/osamp    ;dist.to 10% Bisector
;
;The code would previously hang up here if GAUSS_FIT failed. Profiles
;are now only stored if "fit" is not filled with NaNs. 20110623~MJG
;print, ' STORE PROFILES'
if ~finite(fit[0], /nan) then begin
    profsz = osamp*4
    cenprof = shift(omashrow,-1*(midfwhm-finecen))  ;Center profile w/ midFWHM
    allprofs(*,j) = cenprof    ;normalize to peak
endif
;
;print, '   Print diagnostics'
      col = fix(colloc+c1)
      row = fix(rowloc+r1)
      dx(j) = colloc+c1 - x(j)  ;found - expected column position
      dy(j) = rowloc+r1 - y(j)  ;found - expected row position
      cts = fix(max(box))
      flag='   ' & if cts gt thresh then flag='SAT'   ;Saturated???
   if keyword_set(pr) then begin
    print, format=form,'|', col, row , cts, flag,fwhmx(j),fw10x(j),asym(j),' |'
   end
  ENDELSE                                       
;print, 'now at end of line FOR LOOP.'
ENDFOR   ;end LOOP THROUGH ALL LINES
;
IF keyword_set(pr) then begin
  print,'|_____________________________________________________________|'
  print,'|   SAT = Saturated!                                          |'
  print,'|    NF = Line Not Found; rejected from AVG                   |'
  print,'|_____________________________________________________________|'
  print,' '
ENDIF
;
;Reject lines that could not be found above
  good = where(x gt 0,nl)
  xlin = x
  ylin = y
  fwhmlin = fwhmx
  x = x(good)
  y = y(good)
  fwhmx = fwhmx(good)
  fwhmy=fwhmy(good)
  fw10x = fw10x(good)
  asym = asym(good)
  allprofs = allprofs(*,good)
  dx = dx(good)
  dy = dy(good)
  ngoods = n_elements(good)
;
;Reject highest and lowest two values of FWHM 
  ix = sort(fwhmx)    ;index of lowest, next lowest, etc fwhmx values
  itrim = i(2:nl-3)      ;indices of all but lowest 2 and highest 2 FWHM's.
  x = x(itrim)           ;Extract only the above lines
  y = y(itrim)           ;same as above
  fwhmx = fwhmx(itrim)   ;Extract the above lines only
;reject lines that resulted in  NaNs for fits: 
fins = finite(fwhmx, /nan)
fints = where(fins eq 0)
fwhmx = fwhmx[fints]
  fwhmy = fwhmy(itrim)   ;Extract the above lines only
fwhmy = fwhmy[fints]
  fw10x = fw10x(itrim)   ;Extract the above lines only
fw10x = fw10x[fints]
  asym = asym(itrim)     ;Extract the above lines only
asym = asym[fints]
  allprofs = allprofs(*,itrim) ; Extract as above
allprofs = allprofs[*,fints]
  dx = dx(itrim)
dx = dx[fints]
  dy = dy(itrim)
dy = dy[fints]
;
;Take AVERAGES
  avgfwhmx = mean(fwhmx)
  avgfwhmy = mean(fwhmy)
  avgfw10x = mean(fw10x)
  avgasym = mean(asym)
  avgpro = total(allprofs,2)
  avgpro = avgpro/max(avgpro)
  avgdx = mean(dx)
  avgdy = mean(dy)
;
;Reference Gaussian
   xo = fineind(finecen)  ;center of Gaussian in CCD pixels units
;   sig = 0.85  ;in CCD pixels
   sig = 1.00  ;in CCD pixels, RPB 20 July 2004
   gau= exp(-(fineind-xo)^2/(2.*(sig)^2))
;  rdsk,refpro,'refpro.dsk'
   
   dif = avgpro - gau
;   dif = avgpro - refpro
   sigdif = stdev(dif)
   sigdif = strtrim(strmid(string(sigdif),0,9),2)
h0 = 0.0268
h1 = 0.00892
h2 = 0.00217
h3 = 0.000913
;
;PRINT RESULTS
; print,' '
; print,format='(A25,A6)','      CCD Position =',strtrim(string(fix(focus)),2)
  print,' '
 print,'                Obtained   Acceptable'
 print,'--------------------------------------'
 print,format='(A15,F8.3,A13)','AVG FWHM =  ',avgfwhmx,'   2.2 - 2.4 (CTIO)'
 print,format='(A15,F8.3,A13)','AVG FW@10%= ',avgfw10x,'   4.0 - 4.5'
 print,format='(A15,F8.3,A15)','ASYM:10%Bisect=',avgasym,'   -0.05 - 0.05'
print,'--------------------------------------'
;
;
 if abs(avgdx) gt 1 then begin
  print,' '
  print,'*******************************************************************'
  print,'*  WARNING: Thorium lines sit',avgdx,' columns away from nominal  *'
  print,'*******************************************************************'
  end else begin
  print,''
  print,'  No Echelle Grating move needed.'
  print,' '
  endelse

 if abs(avgdy) gt 1.0 then begin
  print,' '
  print,'Warning:  Thorium lines sit',avgdy,' rows away from nominal'
 end
 focstat = sqrt((avgfwhmx-1.55)^2+avgASYM^2)
;
; print,format='(A29,F8.3)','Sqrt[(FWHM-1.55)^2+ASYM^2] =',focstat
IF keyword_set(plt) then begin
  !p.charsize=1.
  !p.multi = [0,2,2]
  !p.color = 300
;
; FWHM vs Column
  titl='!6FWHM  vs  Column#'
  xtit='!6 Column'
  ytit='!6 FWHM (pixels)'
  yr=[min(fwhmx)-.1,max(fwhmx)+.1]
;stop
  plot,x,fwhmx,ps=8,titl=titl,xtit=xtit,ytit=ytit,/ysty,yr=yr,/xsty
  xp = .5*max(x)
  yp = max(fwhmx)+.02  ;-.05*(max(fwhmx)-min(fwhmx))
  st = '!6<FWHM>='+strmid(strtrim(string(avgfwhmx),2),0,5)
  !p.color=270
  oldc = !p.color 
  xyouts,xp, yp,st,size=1.4
;  xyouts,400,yp-0.04,'Hermite #2 = '+string(h2),size=2 
 !p.color = oldc

; FWHM vs Row
  titl='!6FWHM  vs  Row#'
  xtit='!6 Row'
  ytit='!6 FWHM (pixels)'
  yr=[min(fwhmy)-.1,max(fwhmy)+.1]
;stop
  plot,y,fwhmy,ps=8,titl=titl,xtit=xtit,ytit=ytit,/ysty,yr=yr,/xsty
  xp = .5*max(x)
  yp = max(fwhmy)+.02  ;-.05*(max(fwhmx)-min(fwhmx))
  st = '!6<FWHM>='+strmid(strtrim(string(avgfwhmy),2),0,5)
  !p.color=270
  oldc = !p.color 
  xyouts,xp, yp,st,size=1.4
;  xyouts,400,yp-0.04,'Hermite #2 = '+string(h2),size=2 
 !p.color = oldc
;
; FW10% vs Column
;  titl='!6FW@10% vs  Column#'
;  xtit='!6 Column'
;  ytit='!6 FW@10% (pixels)'
;  yr=[min(fw10x)-.2,max(fw10x)+.2]
;  plot,x,fw10x,ps=8,titl=titl,xtit=xtit,ytit=ytit,/ysty,yr=yr,/xsty
;  yp = max(fw10x)+.04  ;-.05*(max(fwhmx)-min(fwhmx))
;  st = '!6<FW10%>='+strmid(strtrim(string(avgfw10x),2),0,5)
;  oldc = !p.color & !p.color=270
;  xyouts,xp, yp,st,size=1.4
;  xyouts,400,yp-0.1,'Hermite #3 = '+string(h3),size=1.8
  !p.color = oldc
;
; ASYMMETRY vs Column
  titl='!6ASYMMETRY (10% Bisector) vs  Column#'
  xtit='!6 Column'
  ytit='!6 Displacement of Bisector at 10%'
  yr=[min(asym)-.1,max(asym)+.1]
  plot,x,asym,ps=8,titl=titl,xtit=xtit,ytit=ytit,/ysty,yr=yr,/xsty
  oldc = !p.color & !p.color=270
  xyouts,xp,max(asym)+0.02,'Asym=' + strmid( string(avgasym),2,7 ),size=1.4
  !p.color = oldc
;
  ti='!6MEAN THORIUM LINE' 
  xt='!6 Pixel'
  yt='!6 CTS'
  xra=[-3,3]

;   sampind = indgen(4.*finelen/osamp)*osamp/4.
   plot,fineind-sz,avgpro,titl=ti,xtit=xt,ytit=yt,$
     xr=xra,/xsty,yr=[-.1,1],/ysty,thick=3
   oplot,[.8,.95],[.9,.9],thick=3
   xyouts,1.,.89,'!6Mean Line',size=1.3

;   

; Subaru/HDS Reference Profile (stored from July 20, 2004)
   col=260
;   oplot,fineind-sz,gau,co=col,thick=.3
;   oplot,[.8,.95],[.8,.8],co=col,thick=.3 
   oplot,fineind-sz,gau,co=151,thick=.3
   oplot,[.8,.95],[.8,.8],co=151,thick=.3 
   !p.color = col
   xyouts,1.,.79,'Gaussian Ref. Prof.',size=1.3,co=151
   xyouts,-2.8,.8,'Sig.Dif.='+sigdif,size=1.3

;   oplot,fineind-sz, dif*3, ps=3   ; DIF
   oplot,fineind-sz, dif, ps=3   ; DIF
   xyouts,-.6,-.07,'!6 DIFFERENCE',size=1
   !p.color = oldc
    !p.multi=0
ENDIF  ;end plotting section

;stop
slicevals = create_struct('position', pos, $
'x', xlin, 'y', ylin, 'fwhm', fwhmlin, 'header', header, 'avgfwhm', avgfwhmx, 'avgdx', avgdx)

if keyword_set(focalmap) then begin
fname = '/mir7/focalmap/slice'
fnamef = nextname(fname, '.dat')
save, slicevals, filename=fnamef
endif;focalmap
;stop
end;foc.pro


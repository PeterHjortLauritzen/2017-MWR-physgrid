;**************************************
;load ne30pg3_omg_locations.nc
;generate sepearate plot for vanilla
;save to netcdf file
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/glade/work/aherring/se_func_lib.ncl"
;**************************************
begin
;****************************************
;****************************************
  Re = 6.37122e3 ;km
  secpday = 60.*60.*24
  pi = 3.14159265358979
  L = 2*pi*Re ;equatorial circumfrence
  g = 9.80616 ;m/s2
  p0   = 100000.

  dir = "/glade2/scratch2/aherring/"
  fname = (/"camtrunk_180925_QPC4_ne30_180928", \
	    "camtrunk_180208_QPC4_ne30pg3_180302"/)
  fdate = ".cam.h2.*"
  nfiles = dimsizes(fname)

  VAR = "OMEGA"
  onemnth = False
  regrid = False
  factor = 1.
  nx = 3

  nbins  = 200

  optpdf          = True
  optpdf@bin_min  = -3.0
  optpdf@bin_max  = 0.
  optpdf@bin_spacing = (optpdf@bin_max-optpdf@bin_min)/nbins
  xaxis = "~F33~w~F21~ (Pa/s)"

  writenetcdf = False
  loadncdf = True
  fname_in = (/"ne30pg3_pdf-nbins100_min30.nc","ne30pg3_pdf-nbins200_min30.nc"/)
  varnams = (/"pdfC","pdfE","pdfM"/)

  dopoly = False

  pltNam = "temp_pdf"
  colors = (/"red","green","blue","sienna1","deepskyblue","magenta","palegreen","yellow","darkorchid1"/)
  colors4 = (/"red4","green4","blue4","sienna4","deepskyblue4","magenta4","palegreen4","yellow4","darkorchid4"/)

;******************************************************
; plot options
;******************************************************
;---Start the graphics
  wks = gsn_open_wks("pdf",pltNam)
  plot = new((/nfiles/),"graphic")

  res                      = True         ; plot modifications desired
  res@gsnDraw              = False        ; don't draw plot
  res@gsnFrame             = False        ; don't advance frame
  ;res@gsnMaximize = True
  ;res@gsnPaperOrientation = "portrait"
  ;res@vpWidthF = 0.7
  ;res@vpHeightF = 0.35
  res@xyYStyle ="Log"
  res@trYMaxF                = 1.

  res@trXReverse            = True
  res@tmBorderThicknessF = 3 ;axes thickness
  res@tmXBMajorOutwardLengthF = 0.
  res@tmYLMajorOutwardLengthF = 0.
  res@tmXBMinorOutwardLengthF = 0.
  res@tmYLMinorOutwardLengthF = 0.
  res@tmXTMajorOutwardLengthF = 0.
  res@tmYRMajorOutwardLengthF = 0.
  res@tmXTMinorOutwardLengthF = 0.
  res@tmYRMinorOutwardLengthF = 0.

  res@pmLegendDisplayMode    = "NoCreate"                      ; turn on legend
  res@pmLegendSide           = "Bottom"                      ; Change location of
  res@pmLegendParallelPosF   = .7                           ; move units right
  res@pmLegendOrthogonalPosF = -1.15                          ; move units down
  res@pmLegendWidthF         = 0.14                          ; Change width and
  res@pmLegendHeightF        = 0.11                           ; height of legend.
  res@lgPerimOn              = False                         ; turn off box around
  res@lgLabelFontHeightF     = .02                          ; label font height

  res@gsnXYBarChart            = True              ; Create bar plot
  res@gsnXYBarChartOutlineOnly = True
  res@xyMonoLineThickness = True
  res@xyLineThicknessF   = 2


do n = 0,nfiles-1

print("Begin case "+n)

if (.not.loadncdf) then

  files = systemfunc ("ls " + dir + fname(n) + "/run/" + fname(n) + fdate)
  nhist = dimsizes(files)

  if (onemnth) then
   nstart = nhist-2
   nfinish = nhist-2
  else
   nstart = 0
   nfinish = nhist-1
  end if
  print("Loading Files(s)...")
  print(files(nstart:nfinish))
  f  = addfiles (files(nstart:nfinish),"r")
  ListSetType(f,"cat")
  delete(files)

  lat1d = f[0]->lat
  indx = ind(lat1d.le.10. .and. lat1d.ge.-10.)
  var = f[:]->$VAR$ ;;;(:,:,indx)
  var = var*factor
  ntime = dimsizes(f[:]->time)
  area = f[0]->area ;;;(indx)
  area = Re^2.*area ;km^2
  delete(f)

end if

  do m = 0,nx-1

   print("Starting pdf " + m)

  if (.not.loadncdf) then

   area_3d = conform(var,area,2)
   w = var
   w@_FillValue = default_fillvalue("float")
   if (m.eq.0) then
     w = where(area_3d .lt. 5000.,w,w@_FillValue)
   else if (m.eq.1) then
     w = where(area_3d .lt. 12000. .and. area_3d .ge. 5000.,w,w@_FillValue)
   else if (m.eq.2) then
     w = where(area_3d .ge. 12000.,w,w@_FillValue)
   end if
   end if
   end if

print("for m = " + m + ",N = " + num( .not.(ismissing(w)) ) )

print("N = " + num(area) )
print("n_small = " + num(area.lt.5000.) )
print("n_med = " + num(area.lt.12000. .and. area.ge.5000.) )
print("n_large = " + num(area.ge.12000.) )

;;;
; if (m.eq.0) then
;  optpdf@bin_min  = -2.977716445922852
;  optpdf@bin_max  = -7.133795290603651e-12
; else if (m.eq.1) then
;  optpdf@bin_min  = -3.366194486618042
;  optpdf@bin_max  = -2.126718766370939e-11
; else if (m.eq.2) then
;  optpdf@bin_min  = -2.664820671081543
;  optpdf@bin_max  = -4.780968034120113e-14
; end if
; end if
; end if
;;;

;;;QOBS - best so far 
 if (m.eq.0) then
  optpdf@bin_min  = -3.366690635681152
  optpdf@bin_max  = -5.537305336478227e-11
 else if (m.eq.1) then
  optpdf@bin_min  = -3.210460186004639
  optpdf@bin_max  = -1.553471934423456e-11
 else if (m.eq.2) then
  optpdf@bin_min  = -2.622666597366333
  optpdf@bin_max  = -2.668374896042103e-11
 end if
 end if
 end if

   if (optpdf) then
     w = where(w.lt.0.,w,w@_FillValue)
     pdfvar = pdfx_lowmem(w,3,nbins,optpdf)
     delete(w)
   else
     w1d = ndtooned(w)
     up = ind(w1d.lt.0.)
     pdfvar = pdfx(w1d(up),nbins,optpdf)
     delete(w1d)
     delete(up)
print("max bin " + pdfvar@bin_bound_max)
print("min bin " + pdfvar@bin_bound_min)
   end if

  else
   if (m.eq.0) then
     ncdf = addfile(fname_in(n) , "r")
   end if
   pdfvar = ncdf->$varnams(m)$

   if (n.eq.0 .and. m.eq.0) then
    pdfvar0 = ncdf->$varnams(0)$
    pdfvar1 = ncdf->$varnams(1)$
    pdfvar2 = ncdf->$varnams(2)$
   else if (n.eq.1 .and. m.eq.0)
    pdfvar3 = ncdf->$varnams(0)$
    pdfvar4 = ncdf->$varnams(1)$
    pdfvar5 = ncdf->$varnams(2)$
   end if
   end if

  end if

   if (n.eq.0) then
     nbins = 100
     res@trYMinF                = 2.e-8
     res@trXMinF                = -2.5;;;
     res@trXMaxF                = 0.05
   else if (n.eq.1) then
     nbins = 200
     res@trYMinF                = 2.e-8
     res@trXMinF                = -2.5;;;
     res@trXMaxF                = 0.05
   end if
   end if

   res@xyLineColors       = colors(m)
   pvals = ind(pdfvar.gt.0.d0)
   xvals = pdfvar@bin_bounds(0:nbins-1)
   if (m.eq.0) then
     if (n.eq.0) then
       res@tiYAxisString          = "Probability (fraction)"
     end if
     res@tiXAxisString          = xaxis
     plot(n)  = gsn_csm_xy(wks,xvals(pvals),pdfvar(pvals)*1.e-2,res)
   else 
     tmp = gsn_csm_xy(wks,xvals(pvals),pdfvar(pvals)*1.e-2,res)
     overlay(plot(n),tmp)
     delete(tmp)

   end if
   delete(pvals)
   delete(xvals)


;;;
   if (n.eq.1 .and. m.eq.2) then
     res@xyCurveDrawOrder = "PreDraw"

     ;;;Plot 2
     nbins = 100
     pvals0 = ind(pdfvar0.gt.0.d0)
     xvals0 = pdfvar0@bin_bounds(0:nbins-1)

     res@xyLineColors       = "grey50"
     tmp = gsn_csm_xy(wks,xvals0(pvals0),pdfvar0(pvals0)*1.e-2,res)
     overlay(plot(n),tmp)
     delete(tmp)

     pvals1 = ind(pdfvar1.gt.0.d0)
     xvals1 = pdfvar1@bin_bounds(0:nbins-1)

     tmp = gsn_csm_xy(wks,xvals1(pvals1),pdfvar1(pvals1)*1.e-2,res)
     overlay(plot(n),tmp)
     delete(tmp)

     pvals2 = ind(pdfvar2.gt.0.d0)
     xvals2 = pdfvar2@bin_bounds(0:nbins-1)

     tmp = gsn_csm_xy(wks,xvals2(pvals2),pdfvar2(pvals2)*1.e-2,res)
     overlay(plot(n),tmp)
     delete(tmp)

     ;;;Plot 1
     nbins = 200
     pvals3 = ind(pdfvar3.gt.0.d0)
     xvals3 = pdfvar3@bin_bounds(0:nbins-1)

     res@xyLineColors       = "grey50"
     tmp = gsn_csm_xy(wks,xvals3(pvals3),pdfvar3(pvals3)*1.e-2,res)
     overlay(plot(0),tmp)
     delete(tmp)

     pvals4 = ind(pdfvar4.gt.0.d0)
     xvals4 = pdfvar4@bin_bounds(0:nbins-1)

     tmp = gsn_csm_xy(wks,xvals4(pvals4),pdfvar4(pvals4)*1.e-2,res)
     overlay(plot(0),tmp)
     delete(tmp)

     pvals5 = ind(pdfvar5.gt.0.d0)
     xvals5 = pdfvar5@bin_bounds(0:nbins-1)

     tmp = gsn_csm_xy(wks,xvals5(pvals5),pdfvar5(pvals5)*1.e-2,res)
     overlay(plot(0),tmp)
     delete(tmp)

   end if
;;;

   if (writenetcdf) then
     if (m.eq.0) then
       ncdf = addfile(fname_out , "c")
     end if
     ncdf->$varnams(m)$ = pdfvar
   end if
   delete(pdfvar)

  end do ;;;loadncdf

  if (.not.loadncdf) then
    delete(var)
  end if

print("done with case " + n)

end do ;nfiles

;*****************************************************
; Manually create and attach legend - plot0
;*****************************************************
  res_text                    = True                  ; text mods desired
  res_text@txFontHeightF      = 0.024                 ; change text size
  res_text@txJust             = "CenterCenter"          ; text justification

  res_lines                   = True                  ; polyline mods desired
  res_lines@gsLineDashPattern = 0                    ; solid line
  res_lines@gsLineThicknessF  = 6.                   ; line thicker

  ;;;Create 3x3 physgrid grid with grid id numbers
  ;;;drawNDCGrid(wks)
  ;;xx = (/0.825,0.86,0.92,0.825,0.86,0.92,0.825,0.86,0.92/)
  ;;yy = (/0.65,0.65,0.65,0.605,0.605,0.605,0.55,0.55,0.55/)

 if (dopoly) then

  colors = (/"red","green","red","green","blue","green","red","green","red"/)
  colors4 = (/"red4","green4","red4","green4","blue4","green4","red4","green4","red4"/)
 
  dfv = .15/3.  

  ;;note xx spans 0.8-0.95
  ;;     yy spans 0.5-0.65

  x0 = (/0.80    ,0.80+dfv  ,0.95-dfv,0.80    ,0.80+dfv,0.95-dfv,0.80    ,0.80+dfv,0.95-dfv/)
  y0 = (/0.65-dfv,0.65-dfv  ,0.65-dfv,0.50+dfv,0.50+dfv,0.50+dfv,0.50    ,0.50    ,0.50    /)

  x1 = (/0.80    ,0.80+dfv  ,0.95-dfv,0.80    ,0.80+dfv,0.95-dfv,0.80    ,0.80+dfv,0.95-dfv/)
  y1 = (/0.65    ,0.65      ,0.65    ,0.65-dfv,0.65-dfv,0.65-dfv,0.50+dfv,0.50+dfv,0.50+dfv/)

  x2 = (/0.80+dfv,0.80+2*dfv,0.95    ,0.80+dfv,0.95-dfv,0.95    ,0.80+dfv,0.95-dfv,0.95    /)
  y2 = (/0.65    ,0.65      ,0.65    ,0.65-dfv,0.65-dfv,0.65-dfv,0.50+dfv,0.50+dfv,0.50+dfv/)

  x3 = (/0.80+dfv,0.80+2*dfv,0.95    ,0.80+dfv,0.95-dfv,0.95    ,0.80+dfv,0.95-dfv,0.95    /)
  y3 = (/0.65-dfv,0.65-dfv  ,0.65-dfv,0.50+dfv,0.50+dfv,0.50+dfv,0.50    ,0.50    ,0.50    /)

  x4 = x0
  y4 = y0

  offx = 0.00;-0.01
  offy = 0.04;0.03

  gsres                = True
  ;;gsres@gsFillOpacityF = 0.5

  do m = 0,8
    gsres@gsFillColor    = colors(m)
    xbox = (/x0(m),x1(m),x2(m),x3(m),x4(m)/)+offx
    ybox = (/y0(m),y1(m),y2(m),y3(m),y4(m)/)+offy
    gsn_polygon_ndc(wks,xbox,ybox,gsres)
    res_lines@gsLineColor = colors4(m)
    gsn_polyline_ndc(wks,xbox,ybox,res_lines)
  end do
  delete(res_lines@gsLineColor)
  res_lines@gsLineThicknessF  = 1.

  ;;;tic-tac-toe 
  xx = (/0.80,0.95/)+offx
  yy = (/0.50+.15/3.,0.50+.15/3./)+offy
  gsn_polyline_ndc(wks,xx,yy,res_lines) 
  yy = yy + .15/3.
  gsn_polyline_ndc(wks,xx,yy,res_lines)

  xx = (/0.80+.15/3.,0.80+.15/3./)+offx
  yy = (/0.50,0.65/)+offy
  gsn_polyline_ndc(wks,xx,yy,res_lines)
  xx = xx + .15/3.
  gsn_polyline_ndc(wks,xx,yy,res_lines)
  delete(xx)
  delete(yy)

  ;;;square outline
  xx = (/0.80,0.80,0.95,0.95,0.80/)+offx
  yy = (/0.50,0.65,0.65,0.50,0.50/)+offy
  gsn_polyline_ndc(wks,xx,yy,res_lines)

  delete(xx)
  delete(yy)

  resmkr = True
  resmkr@gsMarkerIndex = 16
  resmkr@gsMarkerColor = "red"
  resmkr@gsMarkerSizeF = 0.01
  resmkr@gsMarkerThicknessF = 3
  ;;;gll = (/0.0000,0.2764,0.7236,1.0000/)
  gll = (/0.0000,0.04146,0.10854,0.15/)
  xx = (/0.29,0.29+gll(1),0.29+gll(2),0.29+gll(3)/)+offx
  yy = (/0.50,0.50	 ,0.50	     ,0.50	 /)+offy
  ;;;gsn_polymarker_ndc(wks,xx,yy,resmkr)

  ;;corners
  resmkr@gsMarkerColor = "red"
  xx = (/0.29,0.44,0.29,0.44/)+offx
  yy = (/0.50,0.50,0.65,0.65/)+offy
  gsn_polymarker_ndc(wks,xx,yy,resmkr)
  resmkr@gsMarkerIndex = 4
  resmkr@gsMarkerColor = "red4"
  gsn_polymarker_ndc(wks,xx,yy,resmkr)
  resmkr@gsMarkerIndex = 16
  delete(xx)
  delete(yy)

  ;;interior
  resmkr@gsMarkerColor = "blue"
  xx = (/0.29+gll(1),0.44-gll(1),0.29+gll(1),0.44-gll(1)/)+offx
  yy = (/0.50+gll(1),0.50+gll(1),0.65-gll(1),0.65-gll(1)/)+offy
  gsn_polymarker_ndc(wks,xx,yy,resmkr)
  resmkr@gsMarkerIndex = 4
  resmkr@gsMarkerColor = "blue4"
  gsn_polymarker_ndc(wks,xx,yy,resmkr)
  resmkr@gsMarkerIndex = 16
  delete(xx)
  delete(yy)

  ;;edges
  resmkr@gsMarkerColor = "green"
  xx = (/0.29	    ,0.29	,0.44	    ,0.44	,0.29+gll(1),0.29+gll(1),0.44-gll(1),0.44-gll(1)/)+offx
  yy = (/0.50+gll(1),0.65-gll(1),0.50+gll(1),0.65-gll(1),0.50	    ,0.65	,0.50	    ,0.65	/)+offy
  gsn_polymarker_ndc(wks,xx,yy,resmkr)
  resmkr@gsMarkerIndex = 4
  resmkr@gsMarkerColor = "green4"
  gsn_polymarker_ndc(wks,xx,yy,resmkr)
  resmkr@gsMarkerIndex = 16
  delete(xx)
  delete(yy)

  dgll = gll(3) - gll(2)
  dgll = dgll*0.6

  res_lines@gsLineThicknessF  = 3.
  xx = (/0.29-dgll/2.,0.29-dgll/2.,0.44+dgll/2.,0.44+dgll/2.,0.29-dgll/2./)+offx
  yy = (/0.50-dgll/2.,0.65+dgll/2.,0.65+dgll/2.,0.50-dgll/2.,0.50-dgll/2./)+offy
  gsn_polyline_ndc(wks,xx,yy,res_lines)
  delete(xx)
  delete(yy)

  ;;;tic-tac-toe
  xx = (/0.29-dgll/2.,0.44+dgll/2./)+offx
  yy = (/0.50+dgll/2.,0.50+dgll/2./)+offy
  gsn_polyline_ndc(wks,xx,yy,res_lines)
  yy = (/0.65-dgll/2.,0.65-dgll/2./)+offy
  gsn_polyline_ndc(wks,xx,yy,res_lines)

  xx = (/0.29+dgll/2.,0.29+dgll/2./)+offx
  yy = (/0.50-dgll/2.,0.65+dgll/2./)+offy
  gsn_polyline_ndc(wks,xx,yy,res_lines)
  xx = (/0.44-dgll/2.,0.44-dgll/2./)+offx
  gsn_polyline_ndc(wks,xx,yy,res_lines)

  yc = 0.50 - dgll/2. + (0.65 - 0.50 + dgll)/2.
  xc = 0.29 - dgll/2. + (0.44 - 0.29 + dgll)/2.
  xx = (/xc,xc/)+offx
  yy = (/0.50-dgll/2.,0.65+dgll/2./)+offy
  gsn_polyline_ndc(wks,xx,yy,res_lines)
  xx = (/0.29-dgll/2.,0.44+dgll/2./)+offx
  yy = (/yc,yc/)+offy
  gsn_polyline_ndc(wks,xx,yy,res_lines)

 end if

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelFigureStringsFontHeightF = 0.02
  resP@gsnPanelFigureStrings = (/ "a.","b."/)
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@amJust           = "BottomLeft"
  resP@gsnPanelYWhiteSpacePercent = 5.
  gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot
  ;;;drawNDCGrid(wks)
  frame(wks)

end


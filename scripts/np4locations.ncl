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

  dir = "/glade/scratch/aherring/"
  fname = (/"camtrunk_180925_QPC4_ne30pg3_181004"/)
  fdate = ".cam.h2.*"
  nfiles = dimsizes(fname)

  VAR = "OMEGA_gll"
  onemnth = False
  nstart = 0
  regrid = False
  factor = 1.
  nx = 3

  nbins  = 200

  optpdf          = True
  optpdf@bin_min  = -3.0
  optpdf@bin_max  = 0.
  optpdf@bin_spacing = (optpdf@bin_max-optpdf@bin_min)/nbins
  xaxis = "~F33~w~F21~ (Pa/s)"

  writencdf = True
  fname_out = (/"ne30pg3-on-np4_pdf-nbins200_min30.nc"/)
  varnams = (/"pdfC","pdfE","pdfM"/)

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

  files = systemfunc ("ls " + dir + fname(n) + "/run/" + fname(n) + fdate)
  nhist = dimsizes(files)

  if (onemnth) then
   nfinish = ntart
  else
   nfinish = nhist-1
  end if
  print("Loading Files(s)...")
  print(files(nstart:nfinish))
  f  = addfiles (files(nstart:nfinish),"r")
  ListSetType(f,"cat")
  delete(files)

  var = f[:]->$VAR$
  var = var*factor
  ntime = dimsizes(f[:]->time)
  area = f[0]->area_d
  area = Re^2.*area ;km^2
  delete(f)

  do m = 0,nx-1

   print("Starting pdf " + m)

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
; if (m.eq.0) then
;  optpdf@bin_min  = -3.366690635681152
;  optpdf@bin_max  = -5.537305336478227e-11
; else if (m.eq.1) then
;  optpdf@bin_min  = -3.210460186004639
;  optpdf@bin_max  = -1.553471934423456e-11
; else if (m.eq.2) then
;  optpdf@bin_min  = -2.622666597366333
;  optpdf@bin_max  = -2.668374896042103e-11
; end if
; end if
; end if
;;;

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


   if (n.eq.0) then
     res@trYMinF                = 1.e-8
     res@trXMinF                = -2.5
     res@trXMaxF                = 0.05
   else if (n.eq.1) then
     res@trYMinF                = 1.e-8
     res@trXMinF                = -2.5
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
     delete(res@tiYAxisString)
   else 
     tmp = gsn_csm_xy(wks,xvals(pvals),pdfvar(pvals)*1.e-2,res)
     overlay(plot(n),tmp)
     delete(tmp)

   end if
   delete(pvals)
   delete(xvals)


   if (writencdf) then
     if (m.eq.0) then
       ncdf = addfile(fname_out , "c")
     end if
     ncdf->$varnams(m)$ = pdfvar
   end if
   delete(pdfvar)

  end do ;;;nx

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


  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelFigureStringsFontHeightF = 0.02
  resP@gsnPanelFigureStrings = (/ "a.","b."/)
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@amJust           = "BottomLeft"
  resP@gsnPanelYWhiteSpacePercent = 5.
  gsn_panel(wks,plot,(/1,nfiles/),resP)               ; now draw as one plot
  ;;;drawNDCGrid(wks)
  frame(wks)

end


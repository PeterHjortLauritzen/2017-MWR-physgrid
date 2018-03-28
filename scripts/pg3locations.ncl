;**************************************
;
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/glade/p/work/aherring/se_func_lib.ncl"
;**************************************
begin
;****************************************

  nx = 9
  ;;lower left indices of each panel
  indcol = (/0,8100,16200,24300,32400,40500/)

;****************************************
  Re = 6.37122e3 ;km
  secpday = 60.*60.*24
  pi = 3.14159265358979
  L = 2*pi*Re ;equatorial circumfrence
  g = 9.80616 ;m/s2
  p0   = 100000.

  ;;;run is in HPSS
  dir = "/glade2/scratch2/aherring/"
  fname = (/"camtrunk_180208_QPC4_ne30pg3_180302"/)
  fdate = ".cam.h1.*"
  nfiles = dimsizes(fname)

  VAR = "OMEGA"
  onemnth = False
  regrid = False
  factor = 1.

  nbins  = 200
  optpdf          = False
  optpdf@bin_min  = -3.042633771896362;;;-3.93936
  optpdf@bin_max  = -2.236479404449376e-11;;;0.
  optpdf@bin_spacing = (optpdf@bin_max-optpdf@bin_min)/nbins

  xaxis = "~F33~w~F21~ (Pa/s)"

  writenetcdf = True
  fname_out = "ne30pg3_pdfxnbins200.nc"
  varnams = (/"pdf1","pdf2","pdf3","pdf4","pdf5", \
	      "pdf6","pdf7","pdf8","pdf9"/)

  pltNam = "temp"
  colors = (/"red","green","blue","orangered","deepskyblue1","magenta","darkorchid4","dodgerblue","darkseagreen"/)
  label = (/"  1","  2","  3","  4","  5", \
              "  6","  7","  8","  9"/)

;******************************************************
; plot options
;******************************************************
;---Start the graphics
  wks = gsn_open_wks("pdf",pltNam)

  res                      = True         ; plot modifications desired
  res@gsnDraw              = False        ; don't draw plot
  res@gsnFrame             = False        ; don't advance frame
  ;res@gsnMaximize = True
  ;res@gsnPaperOrientation = "portrait"
  ;res@vpWidthF = 0.7
  ;res@vpHeightF = 0.35
  res@xyYStyle ="Log"
  res@trYMaxF                = 1.
  restrYMinF                = 6.e-8
  res@trXMinF                = optpdf@bin_min
  res@trXMaxF                = optpdf@bin_max

  res@trXReverse            = True
  res@tmBorderThicknessF = 4 ;axes thickness
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
  res@xyLineThicknessF   = 3.0


do n = 0,nfiles-1

print("Begin case "+n)

  files = systemfunc ("ls " + dir + fname(n) + "/run/" + fname(n) + fdate)
  nhist = dimsizes(files)

  if (onemnth) then
   nstart = nhist-3
   nfinish = nhist-2
  else
   nstart = 0
   nfinish = nhist-1
  end if
  print("Loading Files(s)...")
  f  = addfiles (files(nstart:nfinish),"r")
  ListSetType(f,"cat")
  delete(files)

  var = f[:]->$VAR$
  var = var*factor
  ntime = dimsizes(f[:]->time)
  delete(f)

  dims = dimsizes(var)
print(dims(2))
print(dims(2)/nx) ;;5400
  vars = new( (/nx,dims(0),dims(1),5400/), "float")

  do m = 0,nx-1

   print("Starting pdf " + m)

 cnt = 0
 do ff = 0,5
   indtmp = indcol(ff)
   do my = 0,29
     do mx = 0,29
       vars(m,:,:,cnt) = var(:,:,indtmp)
       indtmp = indtmp + 9
       cnt = cnt + 1
       print("cnt = " + cnt)
     end do  
   end do    
 print(indtmp-9)
 end do
 indcol = indcol + 1

   w = vars(m,:,:,:)
   if (optpdf) then
     w@_FillValue = default_fillvalue("float")
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

  ;;if (loadnetcdf) then
  ;; if (m.eq.0) then
  ;;   ncdf = addfile(fname_in,"r")
  ;; end if
  ;; pdfvar = ncdf->$varnams(m)$
  ;;end if

   res@xyLineColors       = colors(m)
   pvals = ind(pdfvar.gt.0.d0)
   xvals = pdfvar@bin_bounds(0:nbins-1)
   if (m.eq.0) then
     res@tiYAxisString          = "Probability (fraction)"
     res@tiXAxisString          = xaxis
     plot  = gsn_csm_xy(wks,xvals(pvals),pdfvar(pvals)*1.e-2,res)
   else 
     tmp = gsn_csm_xy(wks,xvals(pvals),pdfvar(pvals)*1.e-2,res)
     overlay(plot,tmp)
     delete(tmp)
   end if
   delete(pvals)
   delete(xvals)

  if (writenetcdf) then
    if (m.eq.0) then
      ncdf = addfile(fname_out , "c")
    end if
    ncdf->$varnams(m)$ = pdfvar
  end if

   delete(pdfvar)

  end do

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
  res_lines@gsLineThicknessF  = 3.                   ; line thicker

  ;;;Create 3x3 physgrid grid with grid id numbers
  ;;;drawNDCGrid(wks)
  yy = (/0.85,0.85,0.85,0.75,0.75,0.75,0.65,0.65,0.65/)
  xx = (/0.65,0.75,0.85,0.65,0.75,0.85,0.65,0.75,0.85/)-0.005
  do m = 0,nx-1
    res_text@txFontColor	= colors(m)
    gsn_text_ndc(wks,label(m),xx(m),yy(m),res_text)
  end do
  delete(xx)
  delete(yy)

  ;;;tic-tac-toe 
  xx = (/0.6,0.9/)
  yy = (/0.8,0.8/)
  gsn_polyline_ndc(wks,xx,yy,res_lines) 
  yy = (/0.7,0.7/)
  gsn_polyline_ndc(wks,xx,yy,res_lines)

  xx = (/0.7,0.7/)
  yy = (/0.6,0.9/)
  gsn_polyline_ndc(wks,xx,yy,res_lines)
  xx = (/0.8,0.8/)
  gsn_polyline_ndc(wks,xx,yy,res_lines)
  delete(xx)
  delete(yy)

  ;;;square outline
  xx = (/0.6,0.6,0.9,0.9,0.6/)
  yy = (/0.6,0.9,0.9,0.6,0.6/)
  gsn_polyline_ndc(wks,xx,yy,res_lines)

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelFigureStringsFontHeightF = 0.02
  ;resP@gsnPanelFigureStrings = (/ "a","b"/)
  resP@gsnPanelFigureStringsPerimOn     = False
  resP@amJust           = "TopRight"
  resP@gsnPanelYWhiteSpacePercent = 5.
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

  frame(wks)

end


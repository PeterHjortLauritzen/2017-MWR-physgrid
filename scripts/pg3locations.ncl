;**************************************
;
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/glade/work/aherring/CESM2/arh-git-scripts/ncl/se_func_lib.ncl"
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
  dir = "/glade/scratch/aherring/"
  fname = (/"camtrunk_180925_QPC4_ne30pg3_180928"/)
  fdate = ".cam.h2.*"
  nfiles = dimsizes(fname)

  VAR = "OMEGA"
  onemnth = False
  regrid = False
  factor = 1.

  nbins  = 100
  optpdf          = True
  optpdf@bin_min  = -3.0;;;;;-3.042633771896362;;;-3.93936
  optpdf@bin_max  = 0.  ;;;-2.236479404449376e-11;;;0.
  optpdf@bin_spacing = (optpdf@bin_max-optpdf@bin_min)/nbins

  xaxis = "~F33~w~F21~ (Pa/s)"

  writenetcdf = True
  fname_out = "ne30pg3_pdf-nbins100_min30.nc"
  varnams = (/"pdfC","pdfE","pdfM"/)

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
  nelem = 5400 ;;;dims(2)/nx)
  vars = new( (/nx,dims(0),dims(1),nelem/), "float")

  do m = 0,nx-1

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

  end do

  ;;;rearrange into 3 groups
  ;;;(/0,2,6,8/) = corners
  ;;;(/1,3,5,7/) = edges
  ;;;(/4/)       = center

  varC = new( (/dims(0),dims(1),nelem*4/), "float" )
  varE = new( (/dims(0),dims(1),nelem*4/), "float" )
  varM = new( (/dims(0),dims(1),nelem/), "float" )

  varC(:,:,       0:nelem-1  ) = vars(0,:,:,:)
  varC(:,:,   nelem:2*nelem-1) = vars(2,:,:,:)
  varC(:,:, 2*nelem:3*nelem-1) = vars(6,:,:,:)
  varC(:,:, 3*nelem:4*nelem-1) = vars(8,:,:,:)

  varE(:,:,       0:nelem-1  ) = vars(1,:,:,:)
  varE(:,:,   nelem:2*nelem-1) = vars(3,:,:,:)
  varE(:,:, 2*nelem:3*nelem-1) = vars(5,:,:,:)
  varE(:,:, 3*nelem:4*nelem-1) = vars(7,:,:,:)

  varM(:,:,       0:nelem-1  ) = vars(4,:,:,:)

  print("Starting pdf " + m)

   if (optpdf) then

     varC@_FillValue = default_fillvalue("float")
     varC = where(varC.lt.0.,varC,varC@_FillValue)
     pdfvarC = pdfx_lowmem(varC,3,nbins,optpdf)

     varE@_FillValue = default_fillvalue("float")
     varE = where(varE.lt.0.,varE,varE@_FillValue)
     pdfvarE = pdfx_lowmem(varE,3,nbins,optpdf)

     varM@_FillValue = default_fillvalue("float")
     varM = where(varM.lt.0.,varM,varM@_FillValue)
     pdfvarM = pdfx_lowmem(varM,3,nbins,optpdf)

   else

     varC1d = ndtooned(varC)
     up = ind(varC1d.lt.0.)
     pdfvarC = pdfx(varC1d(up),nbins,optpdf)
     delete(up)

     varE1d = ndtooned(varE)
     up = ind(varE1d.lt.0.)
     pdfvarE = pdfx(varE1d(up),nbins,optpdf)
     delete(up)

     varM1d = ndtooned(varM)
     up = ind(varM1d.lt.0.)
     pdfvarM = pdfx(varM1d(up),nbins,optpdf)
     delete(up)

   end if

  ;;if (loadnetcdf) then
  ;; if (m.eq.0) then
  ;;   ncdf = addfile(fname_in,"r")
  ;; end if
  ;; pdfvar = ncdf->$varnams(m)$
  ;;end if

;;   res@xyLineColors       = colors(m)
;;   pvals = ind(pdfvar.gt.0.d0)
;;   xvals = pdfvar@bin_bounds(0:nbins-1)
;;   if (m.eq.0) then
;;     res@tiYAxisString          = "Probability (fraction)"
;;     res@tiXAxisString          = xaxis
;;     plot  = gsn_csm_xy(wks,xvals(pvals),pdfvar(pvals)*1.e-2,res)
;;   else 
;;     tmp = gsn_csm_xy(wks,xvals(pvals),pdfvar(pvals)*1.e-2,res)
;;     overlay(plot,tmp)
;;     delete(tmp)
;;   end if
;;   delete(pvals)
;;   delete(xvals)

  if (writenetcdf) then
    ncdf = addfile(fname_out , "c")
    ncdf->$varnams(0)$ = pdfvarC
    ncdf->$varnams(1)$ = pdfvarE
    ncdf->$varnams(2)$ = pdfvarM
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
  res_lines@gsLineThicknessF  = 3.                   ; line thicker

  ;;;Create 3x3 physgrid grid with grid id numbers
  ;;;drawNDCGrid(wks)
;;  yy = (/0.85,0.85,0.85,0.75,0.75,0.75,0.65,0.65,0.65/)
;;  xx = (/0.65,0.75,0.85,0.65,0.75,0.85,0.65,0.75,0.85/)-0.005
;;  do m = 0,nx-1
;;    res_text@txFontColor	= colors(m)
;;    gsn_text_ndc(wks,label(m),xx(m),yy(m),res_text)
;;  end do
;;  delete(xx)
;;  delete(yy)

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelFigureStringsFontHeightF = 0.02
  ;resP@gsnPanelFigureStrings = (/ "a","b"/)
  resP@gsnPanelFigureStringsPerimOn     = False
  resP@amJust           = "TopRight"
  resP@gsnPanelYWhiteSpacePercent = 5.
  ;;gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

  ;;frame(wks)

end


;**************************************
;eof_cam.ncl
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/glade/p/work/aherring/se_func_lib.ncl"
;**************************************
begin
;****************************************
  secpday = 60.*60.*24;
  pi = 3.14159265358979
  g = 9.80616 ;m/s2
  Re = 6371.22

  dir   = "/glade/scratch/aherring/"
  fname = (/"physgrid_180401_QPC4_ne30_180411", \
	    "physgrid_180401_QPC4_ne30pg3_180411"/)
  fdate = (/".cam.h2*",".cam.h2*"/)
  nfiles = dimsizes(fname)

  onemnth = False
  nstart = 0 ;;if False, define nstart

  latlon = False ;;only works with var3d = True

  VAR = (/"FT","FT"/)
  var3d = True
  varlev = 23 ;; 28-1 for QPC6; 24-1 for QPC4
  LAT = (/"lat","lat_d"/)
  LON = (/"lon","lon_d"/)
  factor = 1.

  manlevs = True
  ;;cmin = (/-3.E-6  ,1.2E-10/) ;;;(/0.,     0.2e-9/)   ;;L27bar->;;0.     ;;L27skk->;;0.2e-9
  cmin = (/ 0.  ,1.2E-10/)
  cmax = (/ 2.68E-5, 3.1E-9/) ;;;(/2.86e-5,4.3e-9/)   ;;L27bar->;;2.86e-5;;L27skk->;;4.3e-9
  cspc = (/ 2.E-7  , 2.E-11/) ;;;(/1.91e-7,2.7334E-11/) ;;L27bar->;;1.91e-7;;L27skk->;;2.7334E-11

  seover = True ;;overlay panel boundaries

  regrid = False
  wgtpath = "/home/aherring/regrid/"
  ;wgtfile = "ne30_2_latlon.nc"
  wgtfile = "ne30fvm_2_latlon.nc"

  plabels = True
  labels = (/ "ne30np4","ne30np4","ne30pg3","ne30pg3"/)

  varNam = (/"Mean of ~F10~f~B~T~N~~F21~ on GLL grid (K/s), 930 hPa", \
  	     "Variance of ~F10~f~B~T~N~~F21~ on GLL grid (K~S~2~N~/s~S~2~N~), level 28"/)

  writencdf = False
  fname_out = "bar_skk_mwr_paper-QPC4.nc"
  barnams = (/"bar1","bar2"/)
  skknams = (/"skk1","skk2"/)
  latnams = (/"lat1d1","lat1d2"/)
  lonnams = (/"lon1d1","lon1d2"/)

  loadncdf = True
  fname_in = "bar_skk_mwr_paper-QPC4.nc"

  plotName = "temp_paper"

;************** 
;graphics stuff
;**************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,plotName)
  gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200") ;;"3saw") ;;"BkBlAqGrYeOrReViWh200");;"gui_default");;"MPL_gist_rainbow")
  setvalues NhlGetWorkspaceObjectId()
      "wsMaximumSize": 500000000
  end setvalues

  plot = new( (/2*nfiles/), graphic)
  ;wkstype@wkBackgroundOpacityF    = 0.
  gsn_reverse_colormap(wks)
   res             = True
   res@gsnMaximize = False
   res@gsnDraw     = False      ; Will draw later, after overlaying
   res@gsnFrame    = False      ; all plots

   res@cnFillOn          = True               ; turn on color fill
   res@cnLinesOn         = False
   res@gsnSpreadColors   = True               ; use full range of color map
   res@cnLineLabelsOn       = False
   res@cnInfoLabelOn        = False

   res@lbLabelBarOn         = False

   res@mpCenterLonF = 180.
   res@mpOutlineOn          = False    ; turn off continental outline
   res@mpFillOn             = False
   res@mpGridAndLimbOn   = False           ; turn on lat/lon lines
   ;res@mpGridLatSpacingF = 10.
   ;res@mpGridLonSpacingF = 30.
   ;res@mpGridLineColor      = -1
   res@mpPerimOn         = False               ; turn off perimeter
   res@mpFillOn         = False
   res@mpOutlineBoundarySets     = "NoBoundaries"
   ;res@mpProjection = "Mollweide"

;Set Position and Sizes

   ;res@vpXF             = 0.12
   ;res@vpYF             = 0.94   
   ;res@vpWidthF         = 0.50
   ;res@vpHeightF        = 0.40
   ;res@trYMinF          = 0.                   
   ;res@trYMaxF          = 950.         

   ;must have on for exodus grid overlay
   res@mpGreatCircleLinesOn=True
   res@cnMaxLevelCount = 150

   res2 = True
   res2 = res

;************
;Main Loop
;************
 do n = 0,nfiles-1
 
 print("begin case "+n)

if (.not.loadncdf) then

 ;load all files
 files = systemfunc ("ls " + dir + fname(n) + "/run/" + fname(n) + fdate(n))
 nf = dimsizes(files)
 if (onemnth) then
   nstart = nf-3
   nfinish = nf-2
 else
   nfinish = nf-1
 end if

 print("load files...")

 f  = addfiles (files(nstart:nfinish),"r")
 ListSetType(f,"cat")
 delete(files)

 print("Grab var...")
 ntime = dimsizes(f[:]->time)

 if (var3d) then
   if (latlon)
     var = f[:]->$VAR(n)$(:,varlev,:,:)
     attr = var(0,:,:)
   else
     var = f[:]->$VAR(n)$(:,varlev,:)
   end if
 else
   var = f[:]->$VAR(n)$
 end if

 var = factor*var

 lat1d = f[0]->$LAT(n)$
 lon1d = f[0]->$LON(n)$
 delete(f)

 if (regrid) then
   var_regrid = ESMF_regrid_with_weights(var,wgtpath + wgtfile,False)
   delete(var)
   var = var_regrid
   delete(var_regrid)
 end if

 print("dim_avg_0...")
 ;;;huh? 
 ;;;fatal:Conditional statements (if and do while) require SCALAR logical values, see all and any functions
 ;;;rank = tointeger(dimsizes(var))
 if (latlon) then
   rank = 3
 else
   ;;;unstructured
   rank = 2
 end if
 bar = dim_avg_0_lowmem(var,rank) 

 print("dim_variance_0...")
 skk = dim_variance_0_lowmem(var,rank,bar)

 if (latlon) then
  copy_VarMeta(attr,skk)
  copy_VarMeta(attr,bar)
  delete(attr)
 end if
 delete(var)
else
;;;only works for latlon = False
  if (n.eq.0) then
    ncdf = addfile(fname_out,"r")
  end if
  bar = ncdf->$barnams(n)$
  skk = ncdf->$skknams(n)$
  lat1d = ncdf->$latnams(n)$
  lon1d = ncdf->$lonnams(n)$
end if

 print("plotting...")

 if (.not.latlon) then
   res@sfXArray = lon1d
   res@sfYArray = lat1d
   res2@sfXArray = lon1d
   res2@sfYArray = lat1d
 end if

 if (n.eq.nfiles-1) then
   res@lbLabelBarOn         = True
   res@lbTitleString = varNam(0)
   res2@lbLabelBarOn         = True
   res2@lbTitleString = varNam(1)
   res@lbTitlePosition = "Bottom"
   res2@lbTitlePosition = "Bottom"

   res@pmLabelBarOrthogonalPosF = 0.1
   res2@pmLabelBarOrthogonalPosF = 0.1

   res@lbBoxSeparatorLinesOn = False
   res2@lbBoxSeparatorLinesOn = False
 end if

 if (manlevs) then
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF  = cmin(0)
   res@cnMaxLevelValF  = cmax(0)
   res@cnLevelSpacingF = cspc(0)
 end if

 plot(2*n) = gsn_csm_contour_map(wks,bar,res)

 if (seover) then
  overlay_se_grid(wks,plot(2*n)) 
 end if

 if (manlevs) then
   res2@cnLevelSelectionMode = "ManualLevels"
   res2@cnMinLevelValF  = cmin(1)
   res2@cnMaxLevelValF  = cmax(1)
   res2@cnLevelSpacingF = cspc(1)
 end if

 plot(2*n+1) = gsn_csm_contour_map(wks,skk,res2)

 if (seover) then
  overlay_se_grid(wks,plot(2*n+1))
 end if

print("Max bar " + max(bar))
print("Min bar " + min(bar))
print("Max skk " + max(skk))
print("Min skk " + min(skk))

 if (writencdf) then
   if (n.eq.0) then
     system("/bin/rm -f "+fname_out)
     ncdf = addfile(fname_out,"c")
   end if
   ncdf->$barnams(n)$ = bar
   ncdf->$skknams(n)$ = skk
   ncdf->$latnams(n)$ = lat1d
   ncdf->$lonnams(n)$ = lon1d
 end if

delete(bar)
delete(skk)
delete(lat1d)
delete(lon1d)

 if (.not.latlon) then
   delete(res@sfXArray)
   delete(res@sfYArray)
 end if

end do ;nfiles


;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot

  ;;if (plabels) then
    resP@gsnPanelFigureStrings = labels
    resP@gsnPanelFigureStringsFontHeightF = 0.010
    resP@gsnPanelFigureStringsPerimOn     = True
    resP@gsnPanelFigureStringsBackgroundFillColor = "white"
    resP@amJust           = "TopRight"
  ;;end if

  ;;resP@gsnPanelLabelBar = True
  ;;resP@lbTitleString              = varNam
  ;;resP@lbTitlePosition            = "Top"
  ;;resP@lbTitleFontHeightF         = 0.0084
  ;;resP@lbLabelFontHeightF         = 0.008

  resP@pmLabelBarOrthogonalPosF = -0.01
  resP@pmLabelBarParallelPosF = 0.

  ;resP@gsnPanelTop        = 0.97
  resP@gsnPanelBottom     = 0.1
  ;resP@gsnPanelRight     = 0.9007;
  ;resP@gsnPanelLeft     = 0.40        ; position of left most plot
  gsn_panel(wks,plot,(/nfiles,2/),resP)      

frame(wks)

end




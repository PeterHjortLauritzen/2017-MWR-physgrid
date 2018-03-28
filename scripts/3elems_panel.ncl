;**************************************
;lagrange.ncl
;
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
;**************************************
begin
;****************************************
  nplots = 9

  linecolor = "black"
  markid = (/16,4/)
  dtphys = 0.15

;******************************************************
; plot options
;******************************************************
;---Start the graphics
  wks = gsn_open_wks("pdf","temp")
  plot = new( (/nplots/), "graphic")

  res                      = True         ; plot modifications desired
  res@gsnDraw              = False        ; don't draw plot
  res@gsnFrame             = False        ; don't advance frame
  res@gsnMaximize = False
  res@vpWidthF = 0.6
  res@vpHeightF = 0.4
  res@trYMaxF                = 1.
  res@trYMinF                = 0.2;0.3
  res@trXMinF                = 0.9
  res@trXMaxF                = 4.1

  res@tmBorderThicknessF = 2 ;axes thickness
  res@tmXTOn = True
  res@tmXBOn = False
  res@tmYLOn = True
  res@tmYROn = False
  ;res@tmXBMajorOutwardLengthF = -1.;0.
  ;res@tmYLMajorOutwardLengthF = -1.;0.
  ;res@tmXBMinorOutwardLengthF = -1.
  ;res@tmYLMinorOutwardLengthF = -1.
  ;res@tmXTMajorOutwardLengthF = 0.
  ;res@tmXTMajorLengthF = 0.
  ;res@tmYRMajorOutwardLengthF = -1.;0.
  ;res@tmXTMinorOutwardLengthF = -1.
  ;res@tmYRMinorOutwardLengthF = -1.

  res@xyMonoLineThickness = True
  res@xyLineThicknessF   = 3.;5.0

  ;res@tmXTMode        = "Manual"
  ;res@tmXTTickStartF = 100.  
  res@tmXBMode        = "Explicit"
  res@tmXBValues      = (/1.,2.,3.,4./)
  ;res@tmXBLabels      = (/"-1.0","-0.5","0.0","0.5","1.0"/)
  ;res@tmYLMode        = "Explicit"
  ;res@tmYLValues      = (/-0.2,0.,0.2,0.4,0.6,0.8,1.0,1.1/)
  ;res@tmYLLabels      = (/"-0.2","0.0","0.2","0.4","0.6","0.8","1.0",""/)

  res@tmXMajorGrid = True
  res@tmXMajorGridLineColor = "grey"
  ;res@tmYMajorGrid = True
  ;res@tmYMajorGridLineColor = "grey"
  res@tmGridDrawOrder = "PreDraw"

  resmkr = True

  rescols = True
  resmkr@tfPolyDrawOrder = "PostDraw"

  restxt = True
  restxt@txFontThicknessF = 5.
  restxt@txFontColor = 1.
  restxt@txFontHeightF = 0.03
;--------------------------------
do n = 0,nplots-1
  print("begin case"+n)
  plottype = n
  ;             0 = init
  ;             1 = init + RK1
  ;             2 = RK1C0
  ;             3 = RK1C0 + phys (bc)
  ;             4 = RK1C0 + phys (ac)
  if (plottype.eq.0) then
    res@tiYAxisString          = "State"
    dir0 = "/home/aherring/lagrange-basis-src/src-basis-fct/init/"
    elemdatNam0 = "elem.dat"
    glldatNam0 =  "gll.dat"
    color0 = (/"red","red4"/)
    npts = 600
    npts0 = 200
  else if (plottype.eq.1) then
    delete(res@tiYAxisString)
    dir0 = "/home/aherring/lagrange-basis-src/src-basis-fct/init/"
    elemdatNam0 = "elem.dat"
    glldatNam0 =  "gll.dat"
    color0 = (/"red","red4"/)
    dir1 = "/home/aherring/lagrange-basis-src/src-basis-fct/t1/"
    elemdatNam1 = "elem.dat"
    glldatNam1 =  "gll.dat"
    color1 = (/"dodgerblue","dodgerblue4"/)
    npts = 600
    npts0 = 200
  else if (plottype.eq.2) then
    dir0 = "/home/aherring/lagrange-basis-src/src-basis-fct/t2my/"
    elemdatNam0 = "elem.dat"
    glldatNam0 =  "gll.dat"
    color0 = (/"dodgerblue","dodgerblue4"/)
    npts = 1500
    npts0 = 500
  else if (plottype.eq.3) then
    res@tiYAxisString          = "State"
    dir0 = "/home/aherring/lagrange-basis-src/src-basis-fct/t2my/"
    elemdatNam0 = "elem.dat"
    glldatNam0 =  "gll.dat"
    color0 = (/"dodgerblue","dodgerblue4"/)
    color1 = (/"magenta","magenta4"/)
    ;;color1 = (/"green","green4"/)
    npts = 1500
    npts0 = 500
  else if (plottype.eq.4) then
    delete(res@tiYAxisString)
    dir0 = "/home/aherring/lagrange-basis-src/src-basis-fct/t3/"
    elemdatNam0 = "elem.dat"
    glldatNam0 =  "gll.dat"
    color0 = (/"magenta","magenta4"/)
    npts = 1500
    npts0 = 500
  else if (plottype.eq.5) then
    dir0 = "/home/aherring/lagrange-basis-src/src-basis-fct/t3/"
    elemdatNam0 = "elem.dat"
    glldatNam0 =  "gll.dat"
    color0 = (/"magenta","magenta4"/)
    npts = 1500
    npts0 = 500
    nc0 = "nc_cell_ave1.dat"
  else if (plottype.eq.6) then
    res@tiYAxisString          = "State"
    res@tiXAxisString          = "x-coordinate"
    dir0 = "/home/aherring/lagrange-basis-src/src-basis-fct/t2my/"
    elemdatNam0 = "elem.dat"
    glldatNam0 =  "gll.dat"
    color0 = (/"dodgerblue","dodgerblue4"/)
    color1 = (/"green","green4"/)
    npts = 1500
    npts0 = 500
  else if (plottype.eq.7) then
    delete(res@tiYAxisString)
    dir0 = "/home/aherring/lagrange-basis-src/src-basis-fct/t3_int/"
    elemdatNam0 = "elem.dat"
    glldatNam0 =  "gll.dat"
    color0 = (/"green","green4"/)
    npts = 1500
    npts0 = 500
  else if (plottype.eq.8) then
    dir0 = "/home/aherring/lagrange-basis-src/src-basis-fct/t3_int/"
    elemdatNam0 = "elem.dat"
    glldatNam0 =  "gll.dat"
    color0 = (/"green","green4"/)
    npts = 1500
    npts0 = 500
    nc0 = "nc_cell_ave1.dat"
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
;--------------------------------
  nx = npts
  ny = 2

  data = asciiread(dir0+elemdatNam0,(/nx,ny/),"float")
  nx = npts0
  elem1 = data(0:nx-1,:)
  elem2 = data(nx:2*nx-1,:)
  elem3 = data(2*nx:3*nx-1,:)
  delete(data)

  res@xyLineColors       = linecolor
  plot(n)  = gsn_csm_xy(wks,elem1(:,0),elem1(:,1),res)
  tmp1 = gsn_csm_xy(wks,elem2(:,0),elem2(:,1),res)
  tmp2 = gsn_csm_xy(wks,elem3(:,0),elem3(:,1),res)
  overlay(plot(n),tmp1)
  overlay(plot(n),tmp2)
  delete(tmp1)
  delete(tmp2)

  nx = 12
  data = asciiread(dir0+glldatNam0,(/nx,ny/),"float")
  gll1 = data(0:3,:)
  gll2 = data(4:7,:)
  gll3 = data(8:11,:)
  delete(data)

  resmkr@gsMarkerSizeF = 0.01;0.02;0.015
  resmkr@gsMarkerThicknessF = 3;5;2;3

do m = 0,1

  resmkr@gsMarkerIndex = markid(m)
  resmkr@gsMarkerColor = color0(m)
  mstr = unique_string("dum")
  plot@$mstr$(n) = gsn_add_polymarker(wks,plot(n),gll1(:,0),gll1(:,1),resmkr)
  mstr = unique_string("dum")
  plot@$mstr$(n) = gsn_add_polymarker(wks,plot(n),gll2(:,0),gll2(:,1),resmkr)
  mstr = unique_string("dum")
  plot@$mstr$(n) = gsn_add_polymarker(wks,plot(n),gll3(:,0),gll3(:,1),resmkr)

end do

  if (plottype.eq.1) then
	  nx = npts
	  ny = 2

	  data = asciiread(dir1+elemdatNam1,(/nx,ny/),"float")
	  nx = npts0
	  elem1 = data(0:nx-1,:)
	  elem2 = data(nx:2*nx-1,:)
	  elem3 = data(2*nx:3*nx-1,:)
	  delete(data)

	  res@xyLineColors       = linecolor
	  tmp0  = gsn_csm_xy(wks,elem1(:,0),elem1(:,1),res)
	  tmp1 = gsn_csm_xy(wks,elem2(:,0),elem2(:,1),res)
	  tmp2 = gsn_csm_xy(wks,elem3(:,0),elem3(:,1),res)
	  overlay(plot(n),tmp0)
	  overlay(plot(n),tmp1)
	  overlay(plot(n),tmp2)
	  delete(tmp0)
	  delete(tmp1)
	  delete(tmp2)

	  nx = 12
	  data = asciiread(dir1+glldatNam1,(/nx,ny/),"float")
	  gll1 = data(0:3,:)
	  gll2 = data(4:7,:)
	  gll3 = data(8:11,:)
	  delete(data)
 
	do m = 0,1 
	  resmkr@gsMarkerIndex = markid(m)
	  resmkr@gsMarkerColor = color1(m)
	  mstr = unique_string("dum")
	  plot@$mstr$(n) = gsn_add_polymarker(wks,plot(n),gll1(:,0),gll1(:,1),resmkr)
	  mstr = unique_string("dum")
	  plot@$mstr$(n) = gsn_add_polymarker(wks,plot(n),gll2(:,0),gll2(:,1),resmkr)
	  mstr = unique_string("dum")
	  plot@$mstr$(n) = gsn_add_polymarker(wks,plot(n),gll3(:,0),gll3(:,1),resmkr)
	end do
  else if (plottype.eq.3 .or. plottype.eq.6) then
	xvals = gll2(3,0)
	yvals = gll2(3,1)+dtphys
	if (plottype.eq.6) then
          xvals = gll2(2,0)
          yvals = gll2(2,1)+dtphys
  	end if
        do m = 0,1
          resmkr@gsMarkerIndex = markid(m)
          resmkr@gsMarkerColor = color1(m)
          mstr = unique_string("dum")
          plot@$mstr$(n) = gsn_add_polymarker(wks,plot(n),xvals,yvals,resmkr)
        end do
	;add arrows
	arrow = "~F34~-~F21~"
	mstr = unique_string("dum")
        plot@$mstr$(n) = gsn_add_text(wks,plot(n),arrow,xvals,yvals-(dtphys/2.),restxt)
  else if (plottype.eq.5 .or. plottype.eq.8) then
        nx = 36
        data = asciiread(dir0+nc0,(/nx,ny/),"float")
        mstr = unique_string("dum")
        plot@$mstr$(n) = gsn_add_polyline(wks,plot(n),data(:,0),data(:,1),rescols)
	delete(data)
  end if
  end if
  end if

  delete(elem1)
  delete(elem2)
  delete(elem3)

end do ;;plottype

  ;;X-label
  txres = True
  ;;;drawNDCGrid(wks)

  txres@txFontHeightF = 0.010
  gsn_text_ndc(wks,"Element 1",0.103,0.875,txres)
  gsn_text_ndc(wks,"Element 2",0.19,0.875,txres)
  gsn_text_ndc(wks,"Element 3",0.28,0.875,txres)

  gsn_text_ndc(wks,"Element 1",0.435,0.875,txres)
  gsn_text_ndc(wks,"Element 2",0.525,0.875,txres)
  gsn_text_ndc(wks,"Element 3",0.612,0.875,txres)

  gsn_text_ndc(wks,"Element 1",0.77,0.875,txres)
  gsn_text_ndc(wks,"Element 2",0.858,0.875,txres)
  gsn_text_ndc(wks,"Element 3",0.945,0.875,txres)

;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot

  resP@gsnPanelFigureStrings = (/"a.","b.","c.","d.","e.","f.","g.","h.","i."/)
  resP@gsnPanelFigureStringsFontHeightF = 0.010
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "BottomLeft";"TopRight"

  ;resP@gsnPanelTop        = 0.97
  resP@gsnPanelBottom     = 0.1
  ;resP@gsnPanelRight     = 0.9007;
  ;resP@gsnPanelLeft     = 0.40        ; position of left most plot
  gsn_panel(wks,plot,(/3,3/),resP)
  frame(wks)
end


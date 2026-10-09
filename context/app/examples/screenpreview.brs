00010 ! screenpreview.brs - reads a ScreenIO screen's raw screenio.dat/screenfld.dat records and
00020 ! renders an ASCII-grid sketch of its control layout to a plain text file, plus an overlap
00030 ! check. Pure FileIO reads - no GUI, no Designer, no design.brs changes needed.
00040 ! Usage: RUN PROC (feed 2 lines: <SCREENCODE> then <output text file path>)
00050 !
00060 ! NOTE: LISTCHLD controls are NOT drawn individually - every LISTCHLD sibling of the same
00070 ! listview shares an identical placeholder VPOSITION=1,HPOSITION=0 (confirmed empirically,
00080 ! not a real coordinate - see context/dev/screenio-guide.md §9), so they're listed as a
00090 ! "Listview columns:" annotation grouped under their parent LISTVIEW's PARENT$ instead.
00100 !
00110    library "fileio" : fnOpenFile, fnGetFileNumber, fnKey$
00120    dim Screenio$(0)*1023, Screenio(0), Screenfld$(0)*1023, Screenfld(0), Form$(0)*2000
00130    dim ScreenCode$*18, OutFile$*255, Grid$(100)*250
00140    dim BoxType$(200)*20, BoxLabel$(200)*255, BoxParent$(200)*20, BoxFieldName$(200)*50
00150    dim BoxR1(200), BoxC1(200), BoxR2(200), BoxC2(200)
00160    dim ColParent$(200)*20, ColLabel$(200)*255
00165    dim Label$*255, Tag$*255, Line$*2000
00170 !
00180    linput ScreenCode$
00190    linput OutFile$
00200    let ScreenCode$=Uprc$(Trim$(ScreenCode$))
00210 !
00220    let Screenio=Fnopen("screenio", mat Screenio$, mat Screenio, mat Form$)
00230    let Screenfld=Fnopen("screenfld", mat Screenfld$, mat Screenfld, mat Form$)
00240 !
00250    read #Screenio, using form$(Screenio), key=Fnkey$(Screenio,ScreenCode$): mat Screenio$, mat Screenio nokey NOTFOUND
00260 !
00270    let Vsize=Screenio(si_vsize)
00280    let Hsize=Screenio(si_hsize)
00290    if Vsize<1 then let Vsize=24
00300    if Hsize<1 then let Hsize=80
00310    if Vsize>100 then let Vsize=100
00320    if Hsize>250 then let Hsize=250
00330 !
00340    for Row=1 to Vsize
00350       let Grid$(Row)=Rpt$(" ",Hsize)
00360    next Row
00370 !
00380    let Boxcount=0
00390    let Colcount=0
00400 !
00410    restore #Screenfld, key=Fnkey$(Screenfld,ScreenCode$): nokey DONESCAN
00420 SCANLOOP: !
00430    read #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld eof DONESCAN
00440    if Uprc$(Trim$(Screenfld$(sf_screencode)))<>ScreenCode$ then goto DONESCAN
00450 !
00460    if Lwrc$(Trim$(Screenfld$(sf_fieldtype)))="listchld" then
00470       let Colcount=Colcount+1
00480       let ColParent$(Colcount)=Trim$(Screenfld$(sf_parent))
00490       let ColLabel$(Colcount)=Trim$(Screenfld$(sf_fieldname))
00500       if ColLabel$(Colcount)="" then let ColLabel$(Colcount)=Trim$(Screenfld$(sf_controlname))
00510       goto SCANLOOP
00520    end if
00530 !
00540    let Boxcount=Boxcount+1
00550    let BoxType$(Boxcount)=Trim$(Screenfld$(sf_fieldtype))
00560    let BoxParent$(Boxcount)=Trim$(Screenfld$(sf_parent))
00565    let BoxFieldName$(Boxcount)=Trim$(Screenfld$(sf_fieldname))
00570    let Label$=Trim$(Screenfld$(sf_description))
00575    if Label$="" then let Label$=Trim$(Screenfld$(sf_controlname))
00580    if Label$="" then let Label$=Trim$(Screenfld$(sf_fieldname))
00590    if Label$="" then let Label$=Trim$(Screenfld$(sf_parent))
00600    if Label$="" then let Label$="?"
00610    let BoxLabel$(Boxcount)=Label$
00620    let BoxR1(Boxcount)=Screenfld(sf_vposition)
00630    let BoxC1(Boxcount)=Screenfld(sf_hposition)
00640    let BoxR2(Boxcount)=BoxR1(Boxcount)+max(Screenfld(sf_height),1)-1
00650    let BoxC2(Boxcount)=BoxC1(Boxcount)+max(Screenfld(sf_width),1)-1
00660    if BoxR1(Boxcount)<1 then let BoxR1(Boxcount)=1
00670    if BoxC1(Boxcount)<1 then let BoxC1(Boxcount)=1
00680    if BoxR2(Boxcount)>Vsize then let BoxR2(Boxcount)=Vsize
00690    if BoxC2(Boxcount)>Hsize then let BoxC2(Boxcount)=Hsize
00700    goto SCANLOOP
00710 !
00720 DONESCAN: !
00730 ! ----- draw each box into the grid -----
00740    for Index=1 to Boxcount
00750       let R1=BoxR1(Index) : let R2=BoxR2(Index) : let C1=BoxC1(Index) : let C2=BoxC2(Index)
00760       if R2>=R1 and C2>=C1 then
00770          if R2=R1 then
00772             if Lwrc$(BoxType$(Index))="caption" then
00773                let Tag$=BoxLabel$(Index)
00774             else if Lwrc$(BoxType$(Index))="button" then
00775                let Tag$="["&BoxLabel$(Index)&"]"
00776             else if Trim$(BoxFieldName$(Index))<>"" then
00777                let Tag$="["&BoxFieldName$(Index)&"]"
00778             else
00779                let Tag$="["&BoxType$(Index)&":"&BoxLabel$(Index)&"]"
00780             end if
00790             let Tag$=Tag$(1:min(Len(Tag$),C2-C1+1))
00800             let Grid$(R1)(C1:C1+Len(Tag$)-1)=Tag$
00810          else
00820             let Grid$(R1)(C1:C1)="+" : let Grid$(R1)(C2:C2)="+"
00830             let Grid$(R2)(C1:C1)="+" : let Grid$(R2)(C2:C2)="+"
00840             if C2>C1+1 then
00850                let Grid$(R1)(C1+1:C2-1)=Rpt$("-",C2-C1-1)
00860                let Grid$(R2)(C1+1:C2-1)=Rpt$("-",C2-C1-1)
00870             end if
00880             for Row=R1+1 to R2-1
00890                let Grid$(Row)(C1:C1)="|"
00900                let Grid$(Row)(C2:C2)="|"
00910             next Row
00920             let Tag$=BoxType$(Index)&":"&BoxLabel$(Index)
00930             let Tag$=Tag$(1:min(Len(Tag$),C2-C1-1))
00940             if R1+1<=R2-1 and Len(Tag$)>0 then
00950                let Grid$(R1+1)(C1+1:C1+Len(Tag$))=Tag$
00960             end if
00970          end if
00980       end if
00990    next Index
01000 !
01010 ! ----- write output file -----
01020    open #(Outchan:=fngetfilenumber): "name="&OutFile$&",replace,recl=300",display,output
01030    print #Outchan: "Screen: "&ScreenCode$&"  ("&Trim$(Screenio$(si_windcap))&")  "&str$(Vsize)&" rows x "&str$(Hsize)&" cols"
01040    print #Outchan: Rpt$("=",Hsize+2)
01050    for Row=1 to Vsize
01060       print #Outchan: Grid$(Row)
01070    next Row
01080    print #Outchan: Rpt$("=",Hsize+2)
01090 !
01100    print #Outchan: ""
01110    print #Outchan: "Listview columns (write order = display order, NOT to scale here):"
01120    for Index=1 to Boxcount
01130       if Lwrc$(BoxType$(Index))="listview" then
01140          let Line$="  "&BoxType$(Index)&" ("&BoxParent$(Index)&"): "
01150          let Any=0
01160          for Jndex=1 to Colcount
01170             if Uprc$(ColParent$(Jndex))=Uprc$(BoxParent$(Index)) then
01180                if Any then let Line$=Line$&", "
01190                let Line$=Line$&ColLabel$(Jndex)
01200                let Any=1
01210             end if
01220          next Jndex
01230          if ~Any then let Line$=Line$&"(none)"
01240          print #Outchan: Line$
01250       end if
01260    next Index
01270 !
01280    print #Outchan: ""
01290    print #Outchan: "Overlap check:"
01300    let Anyoverlap=0
01310    for Index=1 to Boxcount-1
01320       for Jndex=Index+1 to Boxcount
01330          if BoxR1(Index)<=BoxR2(Jndex) and BoxR2(Index)>=BoxR1(Jndex) and BoxC1(Index)<=BoxC2(Jndex) and BoxC2(Index)>=BoxC1(Jndex) then
01340             print #Outchan: "  OVERLAP: "&BoxType$(Index)&":"&BoxLabel$(Index)&"  <->  "&BoxType$(Jndex)&":"&BoxLabel$(Jndex)
01350             let Anyoverlap=1
01360          end if
01370       next Jndex
01380    next Index
01390    if ~Anyoverlap then print #Outchan: "  none found"
01400 !
01410    close #Outchan:
01420    close #Screenio:
01430    close #Screenfld:
01440    print "Wrote preview to "&OutFile$
01450    stop
01460 !
01470 NOTFOUND: !
01480    print "Screen "&ScreenCode$&" not found in screenio.dat."
01490    stop
01500 !
01510 ! ----- local Fnopen wrapper - copied verbatim from the bottom of fileio.brs -----
01520 ! #Autonumber# 99000,10
99000 OPEN: ! ***** Function To Call Library Openfile And Proc Subs
99010    def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)
99020       dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
99030       let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)
99040       if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
99050    fnend

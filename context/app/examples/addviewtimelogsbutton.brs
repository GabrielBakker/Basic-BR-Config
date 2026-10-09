00010 ! addviewtimelogsbutton.brs - one-time utility, adds a "View Timelogs" button to the
00020 ! EXISTING CLAUDECUSTOMERTEST screen (screenio.dat header untouched), calling the custom
00030 ! function {viewtimelogsforcustomer} (function/viewtimelogsforcustomer.brs), which opens
00040 ! CLAUDEVIEWTIMELOGS with the selected row's customer code as Parent_Key$.
00050 !
00060    library "fileio" : fnOpenFile, fnKey$
00070    dim Screenfld$(0)*1023, Screenfld(0), Form$(0)*2000
00080 !
00090    let Screenfld=Fnopen("screenfld", mat Screenfld$, mat Screenfld, mat Form$)
00100 !
00110 ! ----- guard: don't add this twice - scan by primary key, same proven pattern as -----
00120 ! ----- addbuttons_claudecustomertest.brs                                        -----
00130    restore #Screenfld, key=Fnkey$(Screenfld,"CLAUDECUSTOMERTEST"): nokey ADDBUTTON
00140 GUARDSCAN: !
00150    read #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld eof ADDBUTTON
00160    if Uprc$(Trim$(Screenfld$(sf_screencode)))<>"CLAUDECUSTOMERTEST" then goto ADDBUTTON
00170    if Uprc$(Trim$(Screenfld$(sf_controlname)))="VIEWTIMELOGS_BUTTON" then goto ALREADYDONE
00180    goto GUARDSCAN
00190 !
00200 ALREADYDONE: !
00210    print "ViewTimelogs_Button already exists on CLAUDECUSTOMERTEST - skipping write, will still compile."
00220    goto COMPILE
00230 !
00240 ADDBUTTON: !
00250    mat Screenfld$=("") : mat Screenfld=(0)
00260    let Screenfld$(sf_screencode)="CLAUDECUSTOMERTEST"
00270    let Screenfld$(sf_controlname)="ViewTimelogs_Button"
00280    let Screenfld$(sf_description)="View Timelogs"
00290    let Screenfld$(sf_fieldtype)="button"
00300    let Screenfld$(sf_function)="{viewtimelogsforcustomer}"
00310    let Screenfld$(sf_parent)="Button3"
00320    let Screenfld$(sf_fgcolor)="W     "
00330    let Screenfld$(sf_bgcolor)="W     "
00340    let Screenfld(sf_vposition)=22
00350    let Screenfld(sf_hposition)=34
00360    let Screenfld(sf_specwidth)=13
00370    let Screenfld(sf_width)=16
00380    let Screenfld(sf_height)=1
00390    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00400 !
00410 COMPILE: !
00420    close #Screenfld:
00430    library "screenio" : fnCompileScreen
00440    if fnCompileScreen("CLAUDECUSTOMERTEST",1) then
00450       print "Recompiled CLAUDECUSTOMERTEST successfully."
00460    else
00470       print "fnCompileScreen could not find CLAUDECUSTOMERTEST - nothing compiled."
00480    end if
00490    stop
00500 !
00510 ! ----- local Fnopen wrapper - copied verbatim from the bottom of fileio.brs -----
00520 ! #Autonumber# 99000,10
99000 OPEN: ! ***** Function To Call Library Openfile And Proc Subs
99010    def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)
99020       dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
99030       let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)
99040       if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
99050    fnend

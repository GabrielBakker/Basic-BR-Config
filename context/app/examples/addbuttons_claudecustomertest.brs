00010 ! addbuttons_claudecustomertest.brs - one-time utility, adds Add_Button/Edit_Button
00020 ! control records to the EXISTING CLAUDECUSTOMERTEST screen (screenio.dat header untouched),
00030 ! then recompiles it via fnCompileScreen. Add opens CLAUDECUSTOMEREDIT for a new record;
00040 ! Edit opens it against the selected listview row's key - same convention confirmed on the
00050 ! real TABLEADS screen ([LEADSEDIT]Key$=CurrentKey$ for Edit_Button, [LEADSEDIT] for Add_Button).
00060 !
00070    library "fileio" : fnOpenFile, fnKey$
00080    dim Screenfld$(0)*1023, Screenfld(0), Form$(0)*2000
00090 !
00100    let Screenfld=Fnopen("screenfld", mat Screenfld$, mat Screenfld, mat Form$)
00110 !
00120 ! ----- guard: don't add these twice - scan by primary key (proven pattern, same as -----
00121 ! ----- screenpreview.brs) rather than a naive concatenated ky2 composite key       -----
00130    restore #Screenfld, key=Fnkey$(Screenfld,"CLAUDECUSTOMERTEST"): nokey ADDBUTTON
00131 GUARDSCAN: !
00132    read #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld eof ADDBUTTON
00133    if Uprc$(Trim$(Screenfld$(sf_screencode)))<>"CLAUDECUSTOMERTEST" then goto ADDBUTTON
00134    if Uprc$(Trim$(Screenfld$(sf_controlname)))="ADD_BUTTON" then goto ALREADYDONE
00135    goto GUARDSCAN
00136 !
00137 ALREADYDONE: !
00140    print "Add_Button already exists on CLAUDECUSTOMERTEST - skipping write, will still compile."
00150    goto COMPILE
00160 !
00170 ADDBUTTON: !
00180    mat Screenfld$=("") : mat Screenfld=(0)
00190    let Screenfld$(sf_screencode)="CLAUDECUSTOMERTEST"
00200    let Screenfld$(sf_controlname)="Add_Button"
00210    let Screenfld$(sf_description)="Add"
00220    let Screenfld$(sf_fieldtype)="button"
00230    let Screenfld$(sf_function)="[CLAUDECUSTOMEREDIT]"
00240    let Screenfld$(sf_parent)="Button1"
00245    let Screenfld$(sf_fgcolor)="W     "
00246    let Screenfld$(sf_bgcolor)="W     "
00250    let Screenfld(sf_vposition)=22
00260    let Screenfld(sf_hposition)=10
00270    let Screenfld(sf_specwidth)=3
00280    let Screenfld(sf_width)=10
00290    let Screenfld(sf_height)=1
00300    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00310 !
00320 EDITBUTTON: !
00330    mat Screenfld$=("") : mat Screenfld=(0)
00340    let Screenfld$(sf_screencode)="CLAUDECUSTOMERTEST"
00350    let Screenfld$(sf_controlname)="Edit_Button"
00360    let Screenfld$(sf_description)="Edit"
00370    let Screenfld$(sf_fieldtype)="button"
00380    let Screenfld$(sf_function)="[CLAUDECUSTOMEREDIT]Key$=CurrentKey$"
00390    let Screenfld$(sf_parent)="Button2"
00395    let Screenfld$(sf_fgcolor)="W     "
00396    let Screenfld$(sf_bgcolor)="W     "
00400    let Screenfld(sf_vposition)=22
00410    let Screenfld(sf_hposition)=22
00420    let Screenfld(sf_specwidth)=4
00430    let Screenfld(sf_width)=10
00440    let Screenfld(sf_height)=1
00450    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00460 !
00470 COMPILE: !
00480    close #Screenfld:
00490    library "screenio" : fnCompileScreen
00500    if fnCompileScreen("CLAUDECUSTOMERTEST",1) then
00510       print "Recompiled CLAUDECUSTOMERTEST successfully."
00520    else
00530       print "fnCompileScreen could not find CLAUDECUSTOMERTEST - nothing compiled."
00540    end if
00550    stop
00560 !
00570 ! ----- local Fnopen wrapper - copied verbatim from the bottom of fileio.brs -----
00580 ! #Autonumber# 99000,10
99000 OPEN: ! ***** Function To Call Library Openfile And Proc Subs
99010    def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)
99020       dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
99030       let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)
99040       if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
99050    fnend

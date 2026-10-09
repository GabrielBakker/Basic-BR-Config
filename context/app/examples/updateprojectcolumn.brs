00010 ! updateprojectcolumn.brs - one-time utility, changes CLAUDEVIEWTIMELOGS's "Project" listview
00020 ! column from a bound field (FIELDNAME$="PROJECT", showing the raw 4-char project code) to a
00030 ! free-floating S$ field (FIELDNAME$="", CONTROLNAME$="ProjectName", reachable in code as
00040 ! s$(sio_projectname)) - now populated with the real project NAME by the updated
00050 ! function/claudetimelogfilter.brs. Recompiles CLAUDEVIEWTIMELOGS afterward.
00060 !
00070    library "fileio" : fnOpenFile, fnKey$
00080    dim Screenfld$(0)*1023, Screenfld(0), Form$(0)*2000
00090 !
00100    let Screenfld=Fnopen("screenfld", mat Screenfld$, mat Screenfld, mat Form$)
00110 !
00120    restore #Screenfld, key=Fnkey$(Screenfld,"CLAUDEVIEWTIMELOGS"): nokey NOTFOUND
00130 SCANLOOP: !
00140    read #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld eof NOTFOUND
00150    if Uprc$(Trim$(Screenfld$(sf_screencode)))<>"CLAUDEVIEWTIMELOGS" then goto NOTFOUND
00160    if Uprc$(Trim$(Screenfld$(sf_controlname)))="FIELD_PROJECT" then goto FOUNDIT
00170    goto SCANLOOP
00180 !
00190 FOUNDIT: !
00200    let Screenfld$(sf_controlname)="ProjectName"
00210    let Screenfld$(sf_fieldname)=""
00215    let Screenfld(sf_specwidth)=64
00216    let Screenfld(sf_width)=30
00220    rewrite #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00230    print "Updated the Project column to a free-floating field."
00240    goto COMPILE
00250 !
00260 NOTFOUND: !
00270    print "Field_PROJECT control not found on CLAUDEVIEWTIMELOGS - nothing changed."
00280 !
00290 COMPILE: !
00300    close #Screenfld:
00310    library "screenio" : fnCompileScreen
00320    if fnCompileScreen("CLAUDEVIEWTIMELOGS",1) then
00330       print "Recompiled CLAUDEVIEWTIMELOGS successfully."
00340    end if
00350    stop
00360 !
00370 ! ----- local Fnopen wrapper - copied verbatim from the bottom of fileio.brs -----
00380 ! #Autonumber# 99000,10
99000 OPEN: ! ***** Function To Call Library Openfile And Proc Subs
99010    def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)
99020       dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
99030       let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)
99040       if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
99050    fnend

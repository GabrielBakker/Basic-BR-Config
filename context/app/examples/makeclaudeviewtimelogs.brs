00010 ! makeclaudeviewtimelogs.brs - one-time utility, writes new screenio.dat/screenfld.dat
00020 ! records defining CLAUDEVIEWTIMELOGS: a read-only listview bound to timelogs.dat, showing
00030 ! only the timelogs belonging to one customer (passed in as ParentKey$). Uses a real custom
00040 ! Filter function (function/claudetimelogfilter.brs, fnClaudeTimelogFilter$) - a direct,
00050 ! single-screen-only per-record CUSTOMER$=ParentKey$ test, not a shared/generic filter and
00060 ! not the keyed-skip-ahead optimization - per the owner's explicit request, 2026-09-18.
00062 ! The "Project" column shows the real project NAME (looked up from project.dat), not the raw
00064 ! code - see updateprojectcolumn.brs's own header for this as a separate worked technique
00066 ! (converting an already-bound column into a free-floating S$ lookup on an existing screen).
00067 !
00068 ! Corrected 2026-09-19 (owner, twice): header FGCOLOR/BGCOLOR now matches CLAUDECUSTOMEREDIT's
00069 ! moderately-darker pair instead of reusing CLAUDECUSTOMERTEST's unchanged - this app has a house
00070 ! convention about caller-vs-called screen coloring, see app/conventions.md §9 for the     
00071 ! evidence and the readability calibration lesson (the owner's house style, not a general     
00072 ! BR/ScreenIO rule, so it isn't documented in this kit-level dev/ folder).
00073 !
00080    library "fileio" : fnOpenFile, fnKey$
00090    dim Screenio$(0)*1023, Screenio(0), Screenfld$(0)*1023, Screenfld(0), Form$(0)*2000
00100 !
00110 Main: !
00120    let Screenio=Fnopen("screenio", mat Screenio$, mat Screenio, mat Form$)
00130    let Screenfld=Fnopen("screenfld", mat Screenfld$, mat Screenfld, mat Form$)
00140 !
00150 ! ----- guard: don't clobber an existing CLAUDEVIEWTIMELOGS -----
00160    read #Screenio, using form$(Screenio), key=Fnkey$(Screenio,"CLAUDEVIEWTIMELOGS"): mat Screenio$, mat Screenio nokey NEWSCREEN
00170    print "CLAUDEVIEWTIMELOGS already exists in screenio.dat - skipping write, will still compile."
00180    goto COMPILE
00190 !
00200 NEWSCREEN: !
00210 ! ----- screenio.dat header record -----
00220    mat Screenio$=("") : mat Screenio=(0)
00230    let Screenio$(si_screencode)="CLAUDEVIEWTIMELOGS"
00240    let Screenio$(si_fgcolor)="W     "
00250    let Screenio$(si_bgcolor)="994D00"
00260    let Screenio$(si_filelay)="timelogs"
00270    let Screenio$(si_notes)="One-time test screen created by Claude to learn custom Filter functions. Safe to delete."
00280    let Screenio$(si_windcap)="Claude View Timelogs"
00290    let Screenio$(si_createuser)="Claude"
00300    let Screenio$(si_modifyuser)="Claude"
00310    let Screenio(si_vsize)=20
00320    let Screenio(si_hsize)=90
00330    let Screenio(si_border)=1
00340    let Screenio(si_createdate)=days(date$)
00350    let Screenio(si_modifydate)=days(date$)
00360    let Screenio(si_version)=0
00370    write #Screenio, using form$(Screenio): mat Screenio$, mat Screenio
00380 !
00390 ! ----- screenfld.dat control records -----
00400 ! Row 1: Title caption
00410    mat Screenfld$=("") : mat Screenfld=(0)
00420    let Screenfld$(sf_screencode)="CLAUDEVIEWTIMELOGS"
00430    let Screenfld$(sf_controlname)="Title"
00440    let Screenfld$(sf_description)="Timelogs for Customer"
00450    let Screenfld$(sf_fieldtype)="caption"
00460    let Screenfld$(sf_parent)="Caption1"
00470    let Screenfld$(sf_fgcolor)="W     "
00480    let Screenfld$(sf_bgcolor)="W     "
00490    let Screenfld$(sf_justify)="C"
00500    let Screenfld(sf_vposition)=2
00510    let Screenfld(sf_hposition)=25
00520    let Screenfld(sf_specwidth)=8
00530    let Screenfld(sf_width)=40
00540    let Screenfld(sf_height)=1
00550    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00560 !
00570 ! Row 2: the LISTVIEW - FUNCTION$ is the real custom filter, {claudetimelogfilter}
00580    mat Screenfld$=("") : mat Screenfld=(0)
00590    let Screenfld$(sf_screencode)="CLAUDEVIEWTIMELOGS"
00600    let Screenfld$(sf_fieldtype)="LISTVIEW"
00610    let Screenfld$(sf_function)="{claudetimelogfilter}"
00620    let Screenfld$(sf_parent)="LV1"
00630    let Screenfld$(sf_fgcolor)="W     "
00640    let Screenfld$(sf_bgcolor)="W     "
00650    let Screenfld(sf_vposition)=4
00660    let Screenfld(sf_hposition)=5
00670    let Screenfld(sf_specwidth)=1
00680    let Screenfld(sf_width)=80
00690    let Screenfld(sf_height)=14
00700    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00710 !
00720 ! ----- listview columns: DATE, HOURS, PROJECT, Description - write order = display order -----
00730    mat Screenfld$=("") : mat Screenfld=(0)
00740    let Screenfld$(sf_screencode)="CLAUDEVIEWTIMELOGS"
00750    let Screenfld$(sf_controlname)="Field_DATE"
00760    let Screenfld$(sf_fieldname)="DATE"
00770    let Screenfld$(sf_description)="Date"
00780    let Screenfld$(sf_fieldtype)="LISTCHLD"
00790    let Screenfld$(sf_parent)="LV1"
00800    let Screenfld$(sf_cnvrtin)="DATE(mm/dd/ccyy)"
00810    let Screenfld(sf_vposition)=1
00820    let Screenfld(sf_specwidth)=10
00830    let Screenfld(sf_width)=10
00840    let Screenfld(sf_height)=1
00850    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00860 !
00870    mat Screenfld$=("") : mat Screenfld=(0)
00880    let Screenfld$(sf_screencode)="CLAUDEVIEWTIMELOGS"
00890    let Screenfld$(sf_controlname)="Field_HOURS"
00900    let Screenfld$(sf_fieldname)="HOURS"
00910    let Screenfld$(sf_description)="Hours"
00920    let Screenfld$(sf_fieldtype)="LISTCHLD"
00930    let Screenfld$(sf_parent)="LV1"
00940    let Screenfld(sf_vposition)=1
00950    let Screenfld(sf_specwidth)=5
00960    let Screenfld(sf_width)=8
00970    let Screenfld(sf_height)=1
00980    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00990 !
01000 ! "Project" is a free-floating S$ field (blank FIELDNAME$), not bound to timelogs.dat's own
01001 ! PROJECT$ (the raw 4-char code) - reachable in code as s$(sio_projectname). Populated with the
01002 ! real project NAME (looked up from project.dat) by fnClaudeTimelogFilter$'s fnInit_/fnFinal_
01003 ! companions - see function/claudetimelogfilter.brs. SPECWIDTH/WIDTH sized for a real name
01004 ! (project.dat's NAME$ is V64), not the 4-char code this column would need if it were bound.
01005    mat Screenfld$=("") : mat Screenfld=(0)
01010    let Screenfld$(sf_screencode)="CLAUDEVIEWTIMELOGS"
01020    let Screenfld$(sf_controlname)="ProjectName"
01040    let Screenfld$(sf_description)="Project"
01050    let Screenfld$(sf_fieldtype)="LISTCHLD"
01060    let Screenfld$(sf_parent)="LV1"
01070    let Screenfld(sf_vposition)=1
01080    let Screenfld(sf_specwidth)=64
01090    let Screenfld(sf_width)=30
01100    let Screenfld(sf_height)=1
01110    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01120 !
01130    mat Screenfld$=("") : mat Screenfld=(0)
01140    let Screenfld$(sf_screencode)="CLAUDEVIEWTIMELOGS"
01150    let Screenfld$(sf_controlname)="Field_Description"
01160    let Screenfld$(sf_fieldname)="Description"
01170    let Screenfld$(sf_description)="Description"
01180    let Screenfld$(sf_fieldtype)="LISTCHLD"
01190    let Screenfld$(sf_parent)="LV1"
01200    let Screenfld(sf_vposition)=1
01210    let Screenfld(sf_specwidth)=999
01220    let Screenfld(sf_width)=50
01230    let Screenfld(sf_height)=1
01240    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01250 !
01260 ! ----- compile it -----
01270 COMPILE: !
01280    close #Screenio:
01290    close #Screenfld:
01300    library "screenio" : fnCompileScreen
01310    if fnCompileScreen("CLAUDEVIEWTIMELOGS",1) then
01320       print "Compiled CLAUDEVIEWTIMELOGS successfully."
01330    else
01340       print "fnCompileScreen could not find CLAUDEVIEWTIMELOGS - nothing compiled."
01350    end if
01360    stop
01370 !
01380 ! ----- local Fnopen wrapper - copied verbatim from the bottom of fileio.brs -----
01390 ! #Autonumber# 99000,10
99000 OPEN: ! ***** Function To Call Library Openfile And Proc Subs
99010    def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)
99020       dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
99030       let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)
99040       if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
99050    fnend

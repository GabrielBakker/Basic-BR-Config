00010 ! makeclaudecustomeredit.brs - one-time utility, writes new screenio.dat/screenfld.dat
00020 ! records defining CLAUDECUSTOMEREDIT, an Add/Edit form bound to customer.dat (CODE, NAME,
00030 ! CITY, STATE, PHONENUM), with Save/Cancel buttons. Zero custom event functions - matches the
00040 ! real AIRLINESEDIT screen's minimal pattern (confirmed via CSV dump, 2026-09-18): blank
00050 ! INITFN$/READFN$/WRITEFN$, just field/caption pairs plus "let ExitMode=SaveAndQuit"/
00060 ! "let ExitMode=QuitOnly" buttons. ScreenIO's own generic bind-by-FIELDNAME$ read/write
00070 ! handles the rest - no custom code needed for a basic edit form.
00080 !
00090 ! Corrected 2026-09-18 per owner review of the first draft - three real mistakes worth
00100 ! noting for the next screen:
00110 !   1. Field_PHONENUM's SPECWIDTH must match its CNVRTIN$ FORMATTED width (12, for
00120 !      PIC(ZZZDZZZDZZZZ)), not customer.dat's raw storage width (10) - a mismatch here is
00130 !      ERR 58 string overflow at display time. Confirmed against TABLEADS's own real
00140 !      PHONENUM LISTCHLD column, which already used SPECWIDTH=12 for the identical PIC spec
00150 !      (the same lesson was sitting in already-seen data and got missed the first time).
00160 !   2. Every text control/button needs an explicit FGCOLOR$/BGCOLOR$ of "W" (padded to the
00170 !      6-char field width) - leaving it blank lets the screen's own background color (set on
00180 !      the header, often a saturated accent color) show through every control, looking flat.
00190 !      "W" is BR's own-system "Window" color code, not literal white - it's what every real
00200 !      confirmed screen (AIRLINESLIST, TABLEADS, CUSTEDIT) actually uses for standard,
00210 !      readable text controls and buttons.
00220 !   3. WINDCAP$ (Window Caption) only actually displays when BORDER=1 - a border is what
00230 !      gives BR a place to print it. Setting WINDCAP$ with BORDER left at its default (0)
00240 !      silently does nothing visible.
00250 !
00252 ! Corrected again 2026-09-19 (owner, twice): header FGCOLOR/BGCOLOR now a moderately darker
00254 ! shade of CLAUDECUSTOMERTEST's own color, not an unchanged copy - this app has a house
00256 ! convention about caller-vs-called screen coloring, see app/conventions.md §9 for the     
00258 ! evidence and the readability calibration lesson (the owner's house style, not a general     
00260 ! BR/ScreenIO rule, so it isn't documented in this kit-level dev/ folder).
00262 !
00270 ! Then compiles it via fnCompileScreen (ScreenIO v2.93+, WaitForComplete param added v2.95)
00272 ! - no Designer UI needed.
00280 !
00290    library "fileio" : fnOpenFile, fnKey$
00300    dim Screenio$(0)*1023, Screenio(0), Screenfld$(0)*1023, Screenfld(0), Form$(0)*2000
00310 !
00320 Main: !
00330    let Screenio=Fnopen("screenio", mat Screenio$, mat Screenio, mat Form$)
00340    let Screenfld=Fnopen("screenfld", mat Screenfld$, mat Screenfld, mat Form$)
00350 !
00360 ! ----- guard: don't clobber an existing CLAUDECUSTOMEREDIT -----
00370    read #Screenio, using form$(Screenio), key=Fnkey$(Screenio,"CLAUDECUSTOMEREDIT"): mat Screenio$, mat Screenio nokey NEWSCREEN
00380    print "CLAUDECUSTOMEREDIT already exists in screenio.dat - skipping write, will still compile."
00390    goto COMPILE
00400 !
00410 NEWSCREEN: !
00420 ! ----- screenio.dat header record -----
00430    mat Screenio$=("") : mat Screenio=(0)
00440    let Screenio$(si_screencode)="CLAUDECUSTOMEREDIT"
00450    let Screenio$(si_fgcolor)="W     "
00460    let Screenio$(si_bgcolor)="994D00"
00470    let Screenio$(si_filelay)="customer"
00480    let Screenio$(si_notes)="One-time test screen created by Claude to learn Add/Edit screen conventions. Safe to delete."
00490    let Screenio$(si_windcap)="Claude Customer Edit"
00500    let Screenio$(si_createuser)="Claude"
00510    let Screenio$(si_modifyuser)="Claude"
00520    let Screenio(si_vsize)=16
00530    let Screenio(si_hsize)=60
00540    let Screenio(si_border)=1
00550    let Screenio(si_createdate)=days(date$)
00560    let Screenio(si_modifydate)=days(date$)
00570    let Screenio(si_version)=0
00580    write #Screenio, using form$(Screenio): mat Screenio$, mat Screenio
00590 !
00600 ! ----- screenfld.dat control records -----
00610 ! Row 1: Title caption
00620    mat Screenfld$=("") : mat Screenfld=(0)
00630    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
00640    let Screenfld$(sf_controlname)="Title"
00650    let Screenfld$(sf_description)="Claude Customer Edit"
00660    let Screenfld$(sf_fieldtype)="caption"
00670    let Screenfld$(sf_parent)="Caption1"
00680    let Screenfld$(sf_fgcolor)="W     "
00690    let Screenfld$(sf_bgcolor)="W     "
00700    let Screenfld$(sf_justify)="C"
00710    let Screenfld(sf_vposition)=2
00720    let Screenfld(sf_hposition)=15
00730    let Screenfld(sf_specwidth)=8
00740    let Screenfld(sf_width)=30
00750    let Screenfld(sf_height)=1
00760    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00770 !
00780 ! ----- CODE: caption + field, row 4 -----
00790    mat Screenfld$=("") : mat Screenfld=(0)
00800    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
00810    let Screenfld$(sf_controlname)="Caption_CODE"
00820    let Screenfld$(sf_description)="Code:"
00830    let Screenfld$(sf_fieldtype)="caption"
00840    let Screenfld$(sf_parent)="Caption2"
00850    let Screenfld$(sf_fgcolor)="W     "
00860    let Screenfld$(sf_bgcolor)="W     "
00870    let Screenfld$(sf_justify)="R"
00880    let Screenfld(sf_vposition)=4
00890    let Screenfld(sf_hposition)=5
00900    let Screenfld(sf_specwidth)=8
00910    let Screenfld(sf_width)=8
00920    let Screenfld(sf_height)=1
00930    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00940 !
00950    mat Screenfld$=("") : mat Screenfld=(0)
00960    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
00970    let Screenfld$(sf_controlname)="Field_CODE"
00980    let Screenfld$(sf_fieldname)="CODE"
00990    let Screenfld$(sf_description)="Caption_CODE"
01000    let Screenfld$(sf_fieldtype)="C"
01010    let Screenfld$(sf_parent)="F1"
01020    let Screenfld$(sf_fgcolor)="W     "
01030    let Screenfld$(sf_bgcolor)="W     "
01040    let Screenfld(sf_vposition)=4
01050    let Screenfld(sf_hposition)=14
01060    let Screenfld(sf_specwidth)=4
01070    let Screenfld(sf_width)=6
01080    let Screenfld(sf_height)=1
01090    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01100 !
01110 ! ----- NAME: caption + field, row 6 -----
01120    mat Screenfld$=("") : mat Screenfld=(0)
01130    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
01140    let Screenfld$(sf_controlname)="Caption_NAME"
01150    let Screenfld$(sf_description)="Customer Name:"
01160    let Screenfld$(sf_fieldtype)="caption"
01170    let Screenfld$(sf_parent)="Caption3"
01180    let Screenfld$(sf_fgcolor)="W     "
01190    let Screenfld$(sf_bgcolor)="W     "
01200    let Screenfld$(sf_justify)="R"
01210    let Screenfld(sf_vposition)=6
01220    let Screenfld(sf_hposition)=5
01230    let Screenfld(sf_specwidth)=15
01240    let Screenfld(sf_width)=15
01250    let Screenfld(sf_height)=1
01260    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01270 !
01280    mat Screenfld$=("") : mat Screenfld=(0)
01290    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
01300    let Screenfld$(sf_controlname)="Field_NAME"
01310    let Screenfld$(sf_fieldname)="NAME"
01320    let Screenfld$(sf_description)="Caption_NAME"
01330    let Screenfld$(sf_fieldtype)="C"
01340    let Screenfld$(sf_parent)="F2"
01350    let Screenfld$(sf_fgcolor)="W     "
01360    let Screenfld$(sf_bgcolor)="W     "
01370    let Screenfld(sf_vposition)=6
01380    let Screenfld(sf_hposition)=21
01390    let Screenfld(sf_specwidth)=64
01400    let Screenfld(sf_width)=30
01410    let Screenfld(sf_height)=1
01420    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01430 !
01440 ! ----- CITY: caption + field, row 8 -----
01450    mat Screenfld$=("") : mat Screenfld=(0)
01460    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
01470    let Screenfld$(sf_controlname)="Caption_CITY"
01480    let Screenfld$(sf_description)="City:"
01490    let Screenfld$(sf_fieldtype)="caption"
01500    let Screenfld$(sf_parent)="Caption4"
01510    let Screenfld$(sf_fgcolor)="W     "
01520    let Screenfld$(sf_bgcolor)="W     "
01530    let Screenfld$(sf_justify)="R"
01540    let Screenfld(sf_vposition)=8
01550    let Screenfld(sf_hposition)=5
01560    let Screenfld(sf_specwidth)=8
01570    let Screenfld(sf_width)=8
01580    let Screenfld(sf_height)=1
01590    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01600 !
01610    mat Screenfld$=("") : mat Screenfld=(0)
01620    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
01630    let Screenfld$(sf_controlname)="Field_CITY"
01640    let Screenfld$(sf_fieldname)="CITY"
01650    let Screenfld$(sf_description)="Caption_CITY"
01660    let Screenfld$(sf_fieldtype)="C"
01670    let Screenfld$(sf_parent)="F3"
01680    let Screenfld$(sf_fgcolor)="W     "
01690    let Screenfld$(sf_bgcolor)="W     "
01700    let Screenfld(sf_vposition)=8
01710    let Screenfld(sf_hposition)=14
01720    let Screenfld(sf_specwidth)=30
01730    let Screenfld(sf_width)=25
01740    let Screenfld(sf_height)=1
01750    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01760 !
01770 ! ----- STATE: caption + field, row 10 -----
01780    mat Screenfld$=("") : mat Screenfld=(0)
01790    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
01800    let Screenfld$(sf_controlname)="Caption_STATE"
01810    let Screenfld$(sf_description)="State:"
01820    let Screenfld$(sf_fieldtype)="caption"
01830    let Screenfld$(sf_parent)="Caption5"
01840    let Screenfld$(sf_fgcolor)="W     "
01850    let Screenfld$(sf_bgcolor)="W     "
01860    let Screenfld$(sf_justify)="R"
01870    let Screenfld(sf_vposition)=10
01880    let Screenfld(sf_hposition)=5
01890    let Screenfld(sf_specwidth)=8
01900    let Screenfld(sf_width)=8
01910    let Screenfld(sf_height)=1
01920    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01930 !
01940    mat Screenfld$=("") : mat Screenfld=(0)
01950    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
01960    let Screenfld$(sf_controlname)="Field_STATE"
01970    let Screenfld$(sf_fieldname)="STATE"
01980    let Screenfld$(sf_description)="Caption_STATE"
01990    let Screenfld$(sf_fieldtype)="C"
02000    let Screenfld$(sf_parent)="F4"
02010    let Screenfld$(sf_fgcolor)="W     "
02020    let Screenfld$(sf_bgcolor)="W     "
02030    let Screenfld$(sf_justify)="U"
02040    let Screenfld(sf_vposition)=10
02050    let Screenfld(sf_hposition)=14
02060    let Screenfld(sf_specwidth)=2
02070    let Screenfld(sf_width)=4
02080    let Screenfld(sf_height)=1
02090    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
02100 !
02110 ! ----- PHONENUM: caption + field, row 12 -----
02120    mat Screenfld$=("") : mat Screenfld=(0)
02130    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
02140    let Screenfld$(sf_controlname)="Caption_PHONENUM"
02150    let Screenfld$(sf_description)="Phone:"
02160    let Screenfld$(sf_fieldtype)="caption"
02170    let Screenfld$(sf_parent)="Caption6"
02180    let Screenfld$(sf_fgcolor)="W     "
02190    let Screenfld$(sf_bgcolor)="W     "
02200    let Screenfld$(sf_justify)="R"
02210    let Screenfld(sf_vposition)=12
02220    let Screenfld(sf_hposition)=5
02230    let Screenfld(sf_specwidth)=8
02240    let Screenfld(sf_width)=8
02250    let Screenfld(sf_height)=1
02260    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
02270 !
02280    mat Screenfld$=("") : mat Screenfld=(0)
02290    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
02300    let Screenfld$(sf_controlname)="Field_PHONENUM"
02310    let Screenfld$(sf_fieldname)="PHONENUM"
02320    let Screenfld$(sf_description)="Caption_PHONENUM"
02330    let Screenfld$(sf_fieldtype)="C"
02340    let Screenfld$(sf_parent)="F5"
02350    let Screenfld$(sf_fgcolor)="W     "
02360    let Screenfld$(sf_bgcolor)="W     "
02370    let Screenfld$(sf_cnvrtin)="PIC(ZZZDZZZDZZZZ)"
02380    let Screenfld(sf_vposition)=12
02390    let Screenfld(sf_hposition)=14
02400 ! SPECWIDTH must match the FORMATTED width (12 for this PIC spec), not the raw C10 storage
02410 ! width - see the header note.
02420    let Screenfld(sf_specwidth)=12
02430    let Screenfld(sf_width)=12
02440    let Screenfld(sf_height)=1
02450    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
02460 !
02470 ! ----- Save / Cancel buttons, row 14 -----
02480    mat Screenfld$=("") : mat Screenfld=(0)
02490    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
02500    let Screenfld$(sf_controlname)="SaveButton"
02510    let Screenfld$(sf_description)="Save"
02520    let Screenfld$(sf_fieldtype)="button"
02530    let Screenfld$(sf_function)="let ExitMode=SaveAndQuit"
02540    let Screenfld$(sf_parent)="Button1"
02550    let Screenfld$(sf_fgcolor)="W     "
02560    let Screenfld$(sf_bgcolor)="W     "
02570    let Screenfld(sf_vposition)=14
02580    let Screenfld(sf_hposition)=20
02590    let Screenfld(sf_specwidth)=4
02600    let Screenfld(sf_width)=8
02610    let Screenfld(sf_height)=1
02620    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
02630 !
02640    mat Screenfld$=("") : mat Screenfld=(0)
02650    let Screenfld$(sf_screencode)="CLAUDECUSTOMEREDIT"
02660    let Screenfld$(sf_controlname)="CancelButton"
02670    let Screenfld$(sf_description)="Cancel"
02680    let Screenfld$(sf_fieldtype)="button"
02690    let Screenfld$(sf_function)="let ExitMode=QuitOnly"
02700    let Screenfld$(sf_parent)="Button2"
02710    let Screenfld$(sf_fgcolor)="W     "
02720    let Screenfld$(sf_bgcolor)="W     "
02730    let Screenfld(sf_vposition)=14
02740    let Screenfld(sf_hposition)=32
02750    let Screenfld(sf_specwidth)=6
02760    let Screenfld(sf_width)=8
02770    let Screenfld(sf_height)=1
02780    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
02790 !
02800 ! ----- compile it -----
02810 COMPILE: !
02820    close #Screenio:
02830    close #Screenfld:
02840    library "screenio" : fnCompileScreen
02850    if fnCompileScreen("CLAUDECUSTOMEREDIT",1) then
02860       print "Compiled CLAUDECUSTOMEREDIT successfully."
02870    else
02880       print "fnCompileScreen could not find CLAUDECUSTOMEREDIT - nothing compiled."
02890    end if
02900    stop
02910 !
02920 ! ----- local Fnopen wrapper - copied verbatim from the bottom of fileio.brs -----
02930 ! #Autonumber# 99000,10
99000 OPEN: ! ***** Function To Call Library Openfile And Proc Subs
99010    def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)
99020       dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
99030       let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)
99040       if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
99050    fnend

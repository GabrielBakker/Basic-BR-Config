00010 ! makeclaudecustomertest.brs
00020 ! ONE-TIME UTILITY (kept as an exemplar) - writes new screenio.dat/screenfld.dat records
00030 ! defining a minimal listview screen, SCREENCODE "CLAUDECUSTOMERTEST", bound to customer.dat
00040 ! (FILELAY "customer"), showing CODE/NAME/CITY/STATE/PHONENUM columns. Zero custom event
00050 ! functions - the "bare listview" shape confirmed against the real AIRLINESLIST screen
00060 ! (screenio.dat/screenfld.dat records read directly via csvdump.brs, 2026-09-18).
00070 !
00080 ! IMPORTANT: writing these records is NOT enough to make the screen runnable. Even a
00090 ! zero-custom-function screen still needs a compile pass to produce its compiled
00100 ! screenio\<name>.brs Helper Library before fnfm() will run it - always compile, even for a
00110 ! screen with no custom functions at all (owner, 2026-09-18). As of ScreenIO v2.93 this no
00120 ! longer requires the Designer UI - library "screenio" : fnCompileScreen does the same
00130 ! Load-then-Save-and-Compile sequence from code, called at the end of this program.
00140 !
00142 ! Corrected 2026-09-18 (owner review): the header needs BORDER=1 for WINDCAP$ to actually
00144 ! display (a border is what gives BR a place to print it), and every text control/button
00146 ! needs an explicit FGCOLOR$/BGCOLOR$ of "W" (padded to 6 chars) or it shows through as the
00148 ! screen's own background color - see makeclaudecustomeredit.brs's header for the fuller note.
00150    library "fileio" : fnOpenFile, fnKey$
00160    dim Screenio$(0)*1023, Screenio(0), Screenfld$(0)*1023, Screenfld(0), Form$(0)*2000
00170 !
00180 Main: !
00190    let Screenio=Fnopen("screenio", mat Screenio$, mat Screenio, mat Form$)
00200    let Screenfld=Fnopen("screenfld", mat Screenfld$, mat Screenfld, mat Form$)
00210 !
00220 ! ----- guard: don't clobber an existing CLAUDECUSTOMERTEST -----
00230    read #Screenio, using form$(Screenio), key=Fnkey$(Screenio,"CLAUDECUSTOMERTEST"): mat Screenio$, mat Screenio nokey NEWSCREEN
00240    print "CLAUDECUSTOMERTEST already exists in screenio.dat - skipping write, will still compile."
00250    goto COMPILE
00260 !
00270 NEWSCREEN: !
00280 ! ----- screenio.dat header record -----
00290    mat Screenio$=("") : mat Screenio=(0)
00300    let Screenio$(si_screencode)="CLAUDECUSTOMERTEST"
00310    let Screenio$(si_fgcolor)="000000"
00320    let Screenio$(si_bgcolor)="CC6600"
00330    let Screenio$(si_filelay)="customer"
00340    let Screenio$(si_notes)="One-time test screen created by Claude to learn the ScreenIO record format. Safe to delete."
00350    let Screenio$(si_windcap)="Claude Customer Test"
00360    let Screenio$(si_createuser)="Claude"
00370    let Screenio$(si_modifyuser)="Claude"
00380    let Screenio(si_vsize)=24
00390    let Screenio(si_hsize)=80
00395    let Screenio(si_border)=1
00400    let Screenio(si_createdate)=days(date$)
00410    let Screenio(si_modifydate)=days(date$)
00420    let Screenio(si_version)=0
00430    write #Screenio, using form$(Screenio): mat Screenio$, mat Screenio
00440 !
00450 ! ----- screenfld.dat control records -----
00460 ! Row 1: Title caption
00470    mat Screenfld$=("") : mat Screenfld=(0)
00480    let Screenfld$(sf_screencode)="CLAUDECUSTOMERTEST"
00490    let Screenfld$(sf_controlname)="Title"
00500    let Screenfld$(sf_description)="Claude Customer Test"
00510    let Screenfld$(sf_fieldtype)="caption"
00520    let Screenfld$(sf_parent)="Caption1"
00525    let Screenfld$(sf_fgcolor)="W     "
00526    let Screenfld$(sf_bgcolor)="W     "
00530    let Screenfld$(sf_justify)="C"
00540    let Screenfld(sf_vposition)=2
00550    let Screenfld(sf_hposition)=10
00560    let Screenfld(sf_specwidth)=8
00570    let Screenfld(sf_width)=62
00580    let Screenfld(sf_height)=1
00590    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00600 !
00610 ! Row 2: the LISTVIEW itself - blank FUNCTION$ means no Filter function, all rows show
00620    mat Screenfld$=("") : mat Screenfld=(0)
00630    let Screenfld$(sf_screencode)="CLAUDECUSTOMERTEST"
00640    let Screenfld$(sf_fieldtype)="LISTVIEW"
00650    let Screenfld$(sf_parent)="LV1"
00660    let Screenfld$(sf_fgcolor)="W     "
00670    let Screenfld$(sf_bgcolor)="W     "
00680    let Screenfld$(sf_justify)=" "
00690    let Screenfld(sf_vposition)=4
00700    let Screenfld(sf_hposition)=10
00710    let Screenfld(sf_specwidth)=1
00720    let Screenfld(sf_width)=62
00730    let Screenfld(sf_height)=17
00740    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00750 !
00760 ! Rows 3-7: LISTCHLD columns, one per customer.dat field - write order IS display order
00770    mat Screenfld$=("") : mat Screenfld=(0)
00780    let Screenfld$(sf_screencode)="CLAUDECUSTOMERTEST"
00790    let Screenfld$(sf_controlname)="Field_CODE"
00800    let Screenfld$(sf_fieldname)="CODE"
00810    let Screenfld$(sf_description)="Code"
00820    let Screenfld$(sf_fieldtype)="LISTCHLD"
00830    let Screenfld$(sf_parent)="LV1"
00840    let Screenfld$(sf_justify)=" "
00850    let Screenfld(sf_vposition)=1
00860    let Screenfld(sf_specwidth)=4
00870    let Screenfld(sf_width)=6
00880    let Screenfld(sf_height)=1
00890    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
00900 !
00910    mat Screenfld$=("") : mat Screenfld=(0)
00920    let Screenfld$(sf_screencode)="CLAUDECUSTOMERTEST"
00930    let Screenfld$(sf_controlname)="Field_NAME"
00940    let Screenfld$(sf_fieldname)="NAME"
00950    let Screenfld$(sf_description)="Customer Name"
00960    let Screenfld$(sf_fieldtype)="LISTCHLD"
00970    let Screenfld$(sf_parent)="LV1"
00980    let Screenfld$(sf_justify)=" "
00990    let Screenfld(sf_vposition)=1
01000    let Screenfld(sf_specwidth)=64
01010    let Screenfld(sf_width)=25
01020    let Screenfld(sf_height)=1
01030    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01040 !
01050    mat Screenfld$=("") : mat Screenfld=(0)
01060    let Screenfld$(sf_screencode)="CLAUDECUSTOMERTEST"
01070    let Screenfld$(sf_controlname)="Field_CITY"
01080    let Screenfld$(sf_fieldname)="CITY"
01090    let Screenfld$(sf_description)="City"
01100    let Screenfld$(sf_fieldtype)="LISTCHLD"
01110    let Screenfld$(sf_parent)="LV1"
01120    let Screenfld$(sf_justify)=" "
01130    let Screenfld(sf_vposition)=1
01140    let Screenfld(sf_specwidth)=30
01150    let Screenfld(sf_width)=15
01160    let Screenfld(sf_height)=1
01170    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01180 !
01190    mat Screenfld$=("") : mat Screenfld=(0)
01200    let Screenfld$(sf_screencode)="CLAUDECUSTOMERTEST"
01210    let Screenfld$(sf_controlname)="Field_STATE"
01220    let Screenfld$(sf_fieldname)="STATE"
01230    let Screenfld$(sf_description)="ST"
01240    let Screenfld$(sf_fieldtype)="LISTCHLD"
01250    let Screenfld$(sf_parent)="LV1"
01260    let Screenfld$(sf_justify)=" "
01270    let Screenfld(sf_vposition)=1
01280    let Screenfld(sf_specwidth)=2
01290    let Screenfld(sf_width)=4
01300    let Screenfld(sf_height)=1
01310    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01320 !
01330    mat Screenfld$=("") : mat Screenfld=(0)
01340    let Screenfld$(sf_screencode)="CLAUDECUSTOMERTEST"
01350    let Screenfld$(sf_controlname)="Field_PHONENUM"
01360    let Screenfld$(sf_fieldname)="PHONENUM"
01370    let Screenfld$(sf_description)="Phone"
01380    let Screenfld$(sf_fieldtype)="LISTCHLD"
01390    let Screenfld$(sf_parent)="LV1"
01400    let Screenfld$(sf_justify)=" "
01410    let Screenfld(sf_vposition)=1
01420    let Screenfld(sf_specwidth)=10
01430    let Screenfld(sf_width)=12
01440    let Screenfld(sf_height)=1
01450    write #Screenfld, using form$(Screenfld): mat Screenfld$, mat Screenfld
01460 !
01470 ! ----- compile it - the same Load-then-Save-and-Compile sequence the Designer's own -----
01480 ! ----- menu options run, exposed as a library call since ScreenIO v2.93            -----
01490 COMPILE: !
01500    close #Screenio:
01510    close #Screenfld:
01520    library "screenio" : fnCompileScreen
01530    if fnCompileScreen("CLAUDECUSTOMERTEST",1) then
01540       print "Compiled CLAUDECUSTOMERTEST - screenio\claudecustomertest.brs/.br now exist and fnfm() will run it."
01550    else
01560       print "fnCompileScreen could not find CLAUDECUSTOMERTEST - nothing was compiled."
01570    end if
01580    stop
01590 !
01600 ! ----- local Fnopen wrapper - copied verbatim from the bottom of fileio.brs (house -----
01610 ! ----- convention: this wrapper lives at the END of the program, not the top)     -----
01620 ! #Autonumber# 99000,10
99000 OPEN: ! ***** Function To Call Library Openfile And Proc Subs
99010    def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)
99020       dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
99030       let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)
99040       if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
99050    fnend

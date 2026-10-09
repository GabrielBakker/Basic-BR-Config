00010 ! runscreen.brs - links to ScreenIO's fnfm$ and runs any screen by name interactively, so a
00020 ! human can click through it visually - the interactive complement to screenpreview.brs's
00030 ! static ASCII preview. RUN PROC (feed 1 line: <SCREENCODE>).
00040 !
00050 ! Use via $BR_AI_USER (interactive), not $BR_AI_UTIL - this opens a real GUI window and waits
00060 ! for the user, so it should not be run headless or waited-on by an automated caller.
00070 !
00080 ! For a FIRST BR session with nobody present to click through the ~20s splash screen, run
00090 ! tools/LexiTip.exe immediately before this (see BR_launch.md) - unneeded if another BR
00100 ! session is already open, since the splash is skipped automatically in that case.
00110 !
00120    dim Ret$*255, ScreenCode$*18
00130    linput ScreenCode$
00140    library "screenio" : fnfm$
00150    let Ret$=fnfm$(trim$(ScreenCode$))
00160    print Ret$
00170    stop

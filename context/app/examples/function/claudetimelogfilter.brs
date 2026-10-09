! function\claudetimelogfilter.brs
! Custom Filter function for CLAUDEVIEWTIMELOGS - deliberately simple and specific to this one
! screen (not a shared/generic filter): includes a timelogs.dat record only if its own CUSTOMER$
! field matches ParentKey$ (the customer code passed in by the caller). Direct per-record test,
! no keyed skip-ahead optimization - matches the owner's explicit request, 2026-09-18.
!
! Updated 2026-09-18: the "Project" column now shows the project's real NAME (looked up from
! project.dat by PROJECT$) instead of the raw 4-char project code - the free-floating S$ field
! mechanism (screenio-guide.md §4), populated here via the confirmed fnInit_/fnFinal_ companion
! pattern (real example: function/filtersubscriptioncharges.brs) so project.dat is opened once,
! not once per record.
!
dim project, project$(0)*1024, project(0)
!
def fnClaudeTimelogFilter$
   if trim$(f$(tl_customer))=trim$(ParentKey$) then
      mat Project$=("") : mat Project=(0)
      read #project, using form$(project), key=f$(tl_project) : mat Project$, mat Project nokey Ignore
      let s$(sio_projectname)=Project$(pj_name)
      let fnClaudeTimelogFilter$="1"
   else
      let fnClaudeTimelogFilter$=""
   end if
fnend
!
! This function is run before the listview starts loading.
def fnInit_ClaudeTimelogFilter
   let project=fnOpen("project",mat project$,mat project,mat form$,1)
fnend
!
! This function is run after the listview has finished loading.
def fnFinal_ClaudeTimelogFilter
   close #project:
fnend

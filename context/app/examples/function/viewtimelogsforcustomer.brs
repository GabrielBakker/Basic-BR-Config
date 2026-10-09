! function\viewtimelogsforcustomer.brs
! Button action for CLAUDECUSTOMERTEST's "View Timelogs" button - opens CLAUDEVIEWTIMELOGS,
! passing the selected listview row's customer code as Parent_Key$ (fnfm$'s 5th positional
! argument), so CLAUDEVIEWTIMELOGS's own fnClaudeTimelogFilter$ sees it as ParentKey$.
!
def fnViewTimelogsForCustomer
   library : fnfm$
   let fnfm$("claudeviewtimelogs","",0,0,CurrentKey$)
fnend

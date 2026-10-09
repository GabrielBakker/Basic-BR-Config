! ===== BLESSED EXEMPLAR (context/app/exemplars) =====
! Archetype: single-function library unit (see function_addanemail.brs's header for the
! pattern) — this is the actual hand-written source for screenio_reportpl.brs's report
! button. Note the user-facing validation idiom: check the inputs (two valid dates) before
! doing any work, and use Msgbox with a conversational error message rather than an error
! trap when they're missing/invalid.
! =====================================================
! function\printprofitandloss.brs
! Created on 04/28/2009
!
! fnPrintProfitAndLoss - This Function Prints the Profit and Loss Report
!
!
def fnPrintProfitAndLoss(mat s$,&ExitMode;___,StartDate,EndDate,StatusWindow)
   library "report" : fnProfitAndLoss

   let StartDate=val(s$(sio_startdate))
   let EndDate=val(s$(sio_enddate))

   if StartDate and EndDate then
      open #(StatusWindow:=fnGetFileNumber): "srow=14,scol=31,rows=1,cols=20,BORDER=S",display,outin
      print #StatusWindow, fields "1,1,CC 20" : "Now Printing..."
      let fnProfitAndLoss(StartDate,EndDate)
      close #StatusWindow:

      let ExitMode=QuitOnly
   else
      let msgbox("Please enter two Valid Dates. If you did enter valid dates and I didn't recognise them, I'm sorry. Try entering the date in the format mm/dd/ccyy. I'm a little daft sometimes. I am only a machine, after all.","Date Error")
   end if
fnend

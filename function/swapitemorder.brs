! function\swapitemorder.brs
! Created on 07/18/2022
!
! fnSwapItemOrder - This function works on a listview to swap the order of
!  two items by reversing their entries on disk.
!
dim D$(1)*1024,D(1)

def fnSwapItemOrder(;___,F)
   if udim(mat SelectedRecords)><2 then
      let msgbox("You must select to lines to swap before clicking this button. Use Ctrl or Shift for Multiselect.","ID-10-T Error")
   else
      let F=fnopen(ScreenIO$(si_filelay),mat F$,mat F,mat form$)
      mat D$(udim(mat F$)) : mat D(udim(mat F))
      read #F, using Form$(F), rec=SelectedRecords(1) : mat F$, mat F
      read #F, using Form$(F), rec=SelectedRecords(2) : mat D$, mat D
      rewrite #F, using Form$(F) : mat F$, mat F
      read #F, using Form$(F), rec=SelectedRecords(1) : mat F$, mat F
      rewrite #F, using Form$(F) : mat D$, mat D
      let fnCloseFile(F,ScreenIO$(si_filelay))
      let RepopulateListviews=1
   end if
fnend

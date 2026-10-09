! function\exportlistviewcsv.brs
! Created on 07/03/2014
!
! fnExportListview - This function exports a Listview in its current
!  form to a CSV file, using a new function in FileIO.
!
! You must add a control Name for the listview, and then put that listview name in the CSV button's Userdata field.
!
def fnExportListview(;___,ListviewSubscript)
   let ListviewSubscript=fnFindSubscript(mat Subscripts$,"ctl_",UserData$(ControlIndex))
   if ListviewSubscript then
      let fnExportListviewCSV(Window,fnListSpec$(ControlSpec$(ListviewSubscript)),1)
   else
      let msgbox("Couldn't find the target listview. Please ensure a valid listview is selected for the Print button, or contact the programmer who worked on your system to fix this error.")
   end if
fnend

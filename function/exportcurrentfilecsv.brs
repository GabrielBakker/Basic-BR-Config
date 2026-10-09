 ! function\exportcurrentfilecsv.brs
 ! Created on 11/09/2017
 !
 ! fnExportCurrentFileCSV - This function calls FileIO's CSV Export Dialog
 !  with Column Select automatically for the file that is the subject of the
 !  current listview. It passes in the currently selected records.
 !
 ! Specify an alternate layout if you like (with fewer fields (replace fields you don't want with Xs)) in UserData
 !
 dim SelRecs(1)
 !
 def fnExportCurrentFileCSV
    mat SelRecs(udim(mat SelectedRecords))=SelectedRecords
    if udim(mat SelRecs)=1 then mat SelRecs(udim(mat VisibleRecords))=VisibleRecords
    if trim$(UserData$(ControlIndex))="" then let UserData$(ControlIndex)=ScreenIO$(si_filelay)
    let fnCSVExport(UserData$(ControlIndex),3,"",0,0,"","",0,mat SelRecs,"",1)
 fnend

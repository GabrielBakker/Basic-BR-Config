 ! ===== BLESSED EXEMPLAR (context/app/exemplars) =====
 ! Archetype: single-function library unit — the app's real, hand-authored source layer for
 ! ScreenIO event code (see the function_*.brs files and the "Imported From" note in the
 ! screenio_*.brs exemplars). One function per file, named after the function, filed under
 ! function/. This one is about as small as this archetype gets: a single call-out that
 ! opens another screen (fnfm) and passes the current record's key along as ParentKey$.
 ! =====================================================
 ! function\addanemail.brs
 ! Created on 07/26/2014
 !
 ! fnAddAnEmail - This function calls the Add Email screen
 !   passing in ParentKey$
 !
 !
 def fnAddAnEmail
    let fnfm("emails2edit","",0,0,ParentKey$)
 fnend

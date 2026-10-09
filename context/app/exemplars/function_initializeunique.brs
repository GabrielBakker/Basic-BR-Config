 ! ===== BLESSED EXEMPLAR (context/app/exemplars) =====
 ! Archetype: single-function library unit (see function_addanemail.brs's header for the
 ! pattern). This one shows the auto-key-generation idiom: fnMakeUniqueKey$ fills a record's
 ! ID field the first time it's needed, found here by name via fnFindSubscript rather than a
 ! hardcoded subscript constant.
 ! =====================================================
 ! function\initializeunique.brs
 !
 ! Created on 01/11/2009
 !
 ! This function will initialize any key to unique
 !
 def fnInitializeUnique(mat Subscripts$,mat f$,prefix$,DataFile;___,Subscript)
    let Subscript=fnFindSubscript(mat Subscripts$,prefix$,"id")
    if Subscript then
       let f$(Subscript)=fnMakeUniqueKey$(DataFile)
    end if
 fnend
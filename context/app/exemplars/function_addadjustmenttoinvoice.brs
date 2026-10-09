 ! ===== BLESSED EXEMPLAR (context/app/exemplars) =====
 ! Archetype: single-function library unit (see function_addanemail.brs's header for the
 ! pattern). This one shows the cross-library-call idiom: pulling one function
 ! (fnInvoiceAdjustment) from another module's library ("invclib") for a single call, done
 ! inline in the function body rather than in a one-time linkage block.
 ! =====================================================
 ! function\addadjustmenttoinvoice.brs
 ! Created on 03/30/2009
 !
 ! fnAddAdjustmentToInvoice - This Function ...
 !
 !
 def fnAddAdjustmentToInvoice(mat f$,mat f,mat s$)

    library "invclib" : fnInvoiceAdjustment
    let fnInvoiceAdjustment(f$(ih_id))

    let fnReadInvoice(mat f$,mat f,mat s$,Window)

 fnend
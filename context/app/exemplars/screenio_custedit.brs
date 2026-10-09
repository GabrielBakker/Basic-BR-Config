00001 ! ===== BLESSED EXEMPLAR (context/app/exemplars) =====
00002 ! Archetype: file-maintenance edit form (ScreenIO), full-scale real business entity
00003 ! (Customer) — kept alongside the tiny screenio_airlinesedit.brs so both the minimal and
00004 ! realistic scale of this archetype are represented.
00005 ! Note: GENERATED file — do not hand-edit; see screenio_airlinesedit.brs's header for why,
00006 ! and edit the underlying function/<name>.brs pieces instead, then recompile the screen.
00007 ! =====================================================
00010 ! screenio\custedit.br
00020 ! ScreenIO Generated Helper Library for CUSTEDIT screen
00030 ! Copyright 2008 by Sage AX
00040 !
00050 ! Compiled On: 02/25/2025
00060 ! Version: 26
00070 !
00080 !
00090 !
00300 !
00310    option retain
00320    dim FileIOLinkageSet
00330    dim Ret$*255
00340    dim PassedData$(1)*255
00350    mat PassedData$(0)
00600 !
01000 Main: ! If you run me as a program, I run the custedit screen
01010    library "screenio" : fnfm$
01020    let Ret$=fnfm$("custedit","",0,0,"",0,0,0,0,mat PassedData$)
01030    if len(trim$(Ret$)) then
01040       print Ret$
01050    end if
01060    if fkey=93 then execute "system"
01070    stop
01080 !
05000 CustomFunctions: ! Lines 5000 - 70000 are Custom Functions
05001 ! ============================================================
05002 ! Imported From "function\stripcommas.brs"
05003  ! function\stripcommas.brs
05004  ! Created on 06/15/2013
05005  !
05006  ! fnStripCommas - This Function strips the commas from the target thing
05007  !
05008  !
05009  def fnStripCommas
05010     let FieldText$=srep$(FieldText$,",","")
05011     let fnStripCommas=1
05012  fnend
05013 !
05014 ! Imported From "function\scanreciept.brs"
05015  ! function\scanreciept.brs
05016  ! Created on 01/16/2009
05017  !
05018  ! fnScanReciept - This Function calls the library ScanReciept routine in
05019  !  "recieptl" and assigns its key to the given data file
05020  !
05021  ! If you specify a control name in UserData
05022  !  in the form: "RecieptKeyField|ReceiptImageDisplay"
05023  !
05024  ! Alternately you can specify "FAST" to do a fast scan.
05025  !
05026  dim Parameters$(1)*64, ScanOptions$*255
05027  !
05028  def fnScanReciept(mat f$, mat s$,mat Subscripts$,prefix$;___,TargetName$,FileSubscript,ScreenSubscript,key$,TargetPicture$,UseScreenForFile,FastScan,ImportReciept,CutePDFIt)
05029     library "recieptl" : fnScanReciept$, fnImportReciept$, fnGetRecieptFromPrinter$
05030 !
05031  ! .! Read Parameters, Determine FastScan, ImportReceipt, TargetName$,TargetPicture$
05032     let TargetName$=TargetPicture$="reciept" ! Default to reciept (misspelling that is in SageLive unfortunately)
05033     let FastScan=ImportReciept=0 ! Default to false
05034 !
05035     let ScanOptions$=Trim$(UserData$(ControlIndex)) ! We work on a copy so we don't destroy the original for subsequent clicks.
05036 !
05037     if len(ScanOptions$) then ! Parse Options
05038        let FastScan=fnParseOut(ScanOptions$,"fast")
05039        let ImportReciept=fnParseOut(ScanOptions$,"import")
05040        let CutePDFIt=fnParseOut(ScanOptions$,"cutepdf")
05041 !
05042        if len(Trim$(ScanOptions$)) then ! If anything else
05043           str2mat(trim$(ScanOptions$),mat Parameters$,"|") ! Use specified in UserData
05044           let TargetName$=TargetPicture$=Parameters$(1)
05045           if udim(Parameters$)>=2 and len(trim$(Parameters$(2))) then let TargetPicture$=Parameters$(2) ! Parse out TArget Picture if given.
05046        end if
05047     end if
05048 !
05049  ! .! Find Subscripts for TargetName$ and TargetPicture$
05050     let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,TargetName$)
05051     if ~FileSubscript then
05052        let UseScreenForFile=1
05053        let FileSubscript=fnFindSubscript(mat Subscripts$,"sio_",TargetName$) ! If there's nothing in mat F$ that matches, check mat S$
05054     end if
05055     let ScreenSubscript=fnFindSubscript(mat Subscripts$,"sio_",TargetPicture$) ! Try to find Display Picture Element target.
05056 !
05057  ! .! If we found somewhere to save the results, then:
05058     if FileSubscript or ScreenSubscript then
05059        if ImportReciept then
05060           let key$=fnImportReciept$
05061        else if CutePDFIt then
05062           let Key$=fnGetRecieptFromPrinter$
05063        else
05064           let key$=fnScanReciept$(FastScan,1)
05065        end if
05066 !
05067        if trim$(key$)<>"" then
05068           if FileSubscript then
05069              if UseScreenForFile then
05070                 let s$(FileSubscript)=key$
05071              else
05072                 let f$(FileSubscript)=key$
05073              end if
05074           end if
05075           if ScreenSubscript then let s$(ScreenSubscript)=fnReadUnopenedDescription$("reciept",key$)
05076        end if
05077     end if
05078  fnend
05079 !
05080  def fnParseOut(&String$,Option$;___,FoundIt)
05081     let String$=lwrc$(String$) : let Option$=lwrc$(Option$) ! Make Case Insensitive
05082     if pos(String$,Option$) then
05083        let FoundIt=1
05084        let String$=srep$(String$,Option$&"|","")   ! Pull out the option from wherever it was.
05085        let String$=srep$(String$,"|"&Option$,"")   ! No matter which side the | it is
05086        let String$=srep$(String$,Option$,"")       ! Or even if its neither side.
05087     end if
05088     let fnParseOut=FoundIt
05089  fnend
05090 !
05091 ! Imported From "function\importreciept.brs"
05092  ! function\importreciept.brs
05093  ! Created on 01/16/2009
05094  !
05095  ! fnImportReciept - This Function calls the "recieptl" library to
05096  !  import a reciept into the reciepts file and write its key in this file
05097  !
05098  !
05099  def fnImportReciept(mat f$, mat s$,mat Subscripts$,prefix$;___,FileSubscript,key$,folder$*80,DeleteAfterImport,DescriptionSubscript)
05100     library "recieptl" : fnImportReciept$
05101 !
05102     let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,"reciept")
05103     if FileSubscript then
05104  ! .!   if lwrc$(trim$(prefix$))="ih_" then    ! Disabled 9/16/2009 by GSB
05105  ! .!      let folder$="Import\Invoices\*.pdf"
05106  ! .!      let DeleteAfterImport=1
05107  ! .!   else if lwrc$(trim$(prefix$))="ex_" then
05108  ! .!      let folder$="Import\Expenses\*.pdf"
05109  ! .!      let DeleteAfterImport=1
05110  ! .!   else if lwrc$(trim$(prefix$))="po_" or lwrc$(trim$(prefix$))="pi_" then
05111  ! .!      let DeleteAfterImport=1
05112  ! .!   end if
05113 !
05114        let key$=fnImportReciept$("",folder$,DeleteAfterImport)
05115 !
05116        if trim$(key$)<>"" then
05117           let f$(FileSubscript)=key$
05118           if sio_reciept then let s$(sio_reciept)=fnReadUnopenedDescription$("reciept",f$(FileSubscript))
05119 !
05120           let DescriptionSubscript=fnFindSubscript(mat Subscripts$,prefix$,"description")
05121           if DescriptionSubscript then
05122              if trim$(f$(DescriptionSubscript))="" then
05123                 let f$(DescriptionSubscript)=s$(sio_reciept)(pos(s$(sio_reciept),"\",-1)+1:pos(s$(sio_reciept),".",-1)-1)
05124              end if
05125           end if
05126        end if
05127     end if
05128  fnend
05129 !
05130 ! Imported From "function\scanrecieptfast.brs"
05131  ! function\scanrecieptfast.brs
05132  ! Created on 01/16/2009
05133  !
05134  ! fnscanrecieptfast - This Function ...
05135  !
05136  !
05137  def fnscanrecieptfast(mat f$, mat s$,mat Subscripts$,prefix$;___,FileSubscript,key$)
05138     library "recieptl" : fnScanReciept$
05139 !
05140     let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,"reciept")
05141 !
05142     if FileSubscript then
05143        let key$=fnScanReciept$(1,1)
05144 !
05145        if trim$(key$)<>"" then
05146           let f$(FileSubscript)=key$
05147           let s$(sio_reciept)=fnReadUnopenedDescription$("reciept",f$(FileSubscript))
05148        end if
05149     end if
05150  fnend
05151 !
05152 ! Imported From "function\getrecieptfromprinter.brs"
05153  ! function\getrecieptfromprinter.brs
05154  ! Created on 02/24/2010
05155  !
05156  ! fnGetRecieptFromPrinter - This Function grabs a reciept from the printer.
05157  !
05158  !
05159  def fnGetRecieptFromPrinter(mat f$, mat s$,mat Subscripts$,prefix$;___,FileSubscript,key$)
05160     library "recieptl" : fnGetRecieptFromPrinter$
05161 !
05162     let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,"reciept")
05163     if FileSubscript then
05164        let key$=fnGetRecieptFromPrinter$
05165 !
05166        if trim$(key$)<>"" then
05167           let f$(FileSubscript)=key$
05168           if sio_reciept then let s$(sio_reciept)=fnReadUnopenedDescription$("reciept",f$(FileSubscript))
05169        end if
05170     end if
05171  fnend
05172 !
05173 ! Imported From "function\initcustomer.brs"
05174  ! function\initcustomer.brs
05175  !
05176  !
05177  ! Created on 01/07/2009
05178  !
05179  def fninitcustomer(mat f$,mat f,Datafile)
05180     let f$(cu_code)=Fnmakeuniquekey$(DataFile)
05181     let f(cu_rate)=115
05182     let f$(cu_terms)="Net Due Upon Receipt"
05183     let f(cu_latefee)=0.025
05184     let f(cu_latemin)=9.95
05185     let f(cu_latestart)=1
05186     let f(cu_latefrequency)=1
05187     let f(cu_timelogRep)=1
05188     let f$(cu_delivery)="Internet"
05189     let f(cu_muteMoveMsg)=1
05190  fnend
05191 !
05192 ! Imported From "function\readany.brs"
05193 ! function\readany.brs
05194 ! Created on 01/16/2009
05195 !
05196 ! fnReadAny$ - This Function Unpacks Any SageLive data file for Any SageLive
05197 !  screen.
05198 !
05199 ! #Include {adjustpicturesizes}
05200 ! #Include {expensealtparmsubs}
05201 ! #Include {updatecustomerratetooltip}
05202 !
05203 dim filterfields$(1)*255
05204 dim filtervalue$(1)*255
05205 dim LastParentKey$*255
05206 !
05207 def fnReadAny$(mat f$,mat f,mat s$,mat subscripts$,mat Form$,Prefix$,ParentKey$*255;___,FilterSub,PassedFilter,Index,StartField,EndField,tmp$*63,Qndex,Endex,i,QCnt,Employee,TripPlan)
05208    if ~Initialized then
05209       let fnInit_ReadAny
05210       let NeedsClosing=1
05211    end if
05212 !
05213    let fnExpenseAltParmSubs
05214 !
05215  ! .! Apply Filters if they apply
05216    let PassedFilter=1
05217 !
05218    if len(trim$(ParentKey$)) then
05219       if LastParentKey$<>ParentKey$ then
05220          let LastParentKey$=ParentKey$
05221 !
05222          mat filterfields$(0)
05223          mat filtervalue$(0)
05224 !
05225  ! .     ! First determine what the filters are
05226          if ParentKey$(1:1)="^" then
05227 !
05228             do while len(ParentKey$)>0
05229                Index=udim(Mat FilterFields$)+1
05230                mat filterfields$(Index)
05231                mat filtervalue$(Index)
05232 !
05233                let filterfields$(Index)=fnSwipe$(ParentKey$,"^","=")
05234                let filtervalue$(Index)=fnSwipe$(ParentKey$,"=","^")
05235             loop
05236          else
05237             if len(ParentKey$)=4 then
05238                mat filterfields$(2)
05239                mat filtervalue$(2)
05240                let filterfields$(1)="customer"
05241                let filtervalue$(1)=ParentKey$
05242                let filterfields$(2)="invoice"
05243                let filtervalue$(2)=""
05244             end if
05245          end if
05246       end if
05247 !
05248       for i=1 to udim(mat filterfields$)
05249          if filterfields$(i)(1:1)="(" then ! Set of consecutive fields
05250             if (StartField:=fnFindSubscript(mat Subscripts$,prefix$,filterfields$(i)(2:pos(filterfields$(i),":")-1))) then
05251                if (EndField:=fnFindSubscript(mat Subscripts$,prefix$,filterfields$(i)(pos(filterfields$(i),":")+1:len(filterfields$(i))-1))) then
05252                   if srch(mat f$(StartField:EndField),filtervalue$(i))=-1 then
05253                      let PassedFilter=0
05254                   end if
05255                end if
05256             end if
05257          else ! Single Field
05258             if (FilterSub:=fnFindSubscript(mat Subscripts$,prefix$,filterfields$(i))) then
05259                if filtervalue$(i)<>trim$(f$(FilterSub)) then
05260                   let PassedFilter=0
05261                end if
05262             end if
05263          end if
05264       next i
05265    else
05266       if al_date and f(al_date)=0 then ! Special case for  Scheduled Tasks
05267          let PassedFilter=0  ! Refactor this to work the proper way later.
05268       end if
05269    end if
05270 !
05271    if uprc$(trim$(Screenio$(si_screencode)))="TABWORK" and ScreenIO(si_readIndex)=2 and f$(pj_status)="P" then
05272       let PassedFilter=0
05273       let fnReadAny$="STOP"
05274    end if
05275 !
05276 !
05277 !
05278    if PassedFilter then
05279 !
05280       if sio_customer then let s$(sio_customer)=fnReadThis$("customer",CustomerFile,mat Customer$,mat Customer,mat f$,Prefix$,mat Subscripts$,mat Form$)
05281       if sio_employee then let s$(sio_employee)=fnReadThis$("employee",EmployeeFile,mat Employee$,mat Employee,mat f$,prefix$,mat Subscripts$,mat Form$)
05282       if sio_invent then let s$(sio_invent)=fnreadThis$    ("invent"  ,InventFile  ,mat Invent$,mat Invent,mat f$,prefix$,mat Subscripts$,mat Form$)
05283       if sio_payin then let s$(sio_payin)=fnReadThis$      ("payin"   ,PayInFile   ,mat PayIn$,mat PayIn,mat f$,prefix$,mat Subscripts$,mat Form$,"payment")
05284       if sio_payout then let s$(sio_payout)=fnReadThis$    ("payout"  ,PayOutFile  ,mat PayOut$,mat PayOut,mat f$,prefix$,mat Subscripts$,mat Form$,"payment")
05285       if sio_emplinvc then let s$(sio_emplinvc)=fnReadThis$("emplinvc",EmplInvcFile,mat EmplInvc$,mat EmplInvc,mat f$,prefix$,mat Subscripts$,mat Form$)
05286       if sio_reciept then let s$(sio_reciept)=fnReadThis$  ("reciept" ,RecieptFile ,mat Reciept$,mat Reciept,mat f$,Prefix$,mat Subscripts$,mat Form$,"",1)
05287       if sio_images then let s$(sio_images)=fnReadThis$    ("images"  ,ImagesFile  ,mat Images$,mat Images,mat f$,prefix$,mat Subscripts$,mat Form$)
05288       if sio_project then let s$(sio_project)=fnReadThis$  ("project" ,ProjectFile ,mat Project$,mat Project,mat f$,prefix$,mat Subscripts$,mat Form$)
05289       if sio_subtype then let s$(sio_subtype)=fnReadThis$  ("subtype" ,subtypeFile ,mat subtype$,mat subtype,mat f$,prefix$,mat Subscripts$,mat Form$)
05290 !
05291       if sio_expncat then let s$(sio_expncat)=fnReadThis$  ("expncat" ,ExpnCatFile ,mat ExpnCat$,mat ExpnCat,mat f$,prefix$,mat Subscripts$,mat Form$)
05292       if sio_expndesc then let s$(sio_expndesc)=fnReadThis$("expndesc" ,ExpnDescFile ,mat ExpnDesc$,mat ExpnDesc,mat f$,prefix$,mat Subscripts$,mat Form$)
05293       if sio_expense then let s$(sio_expense)=fnReadThis$  ("expense" ,ExpenseFile ,mat Expense$,mat Expense,mat f$,prefix$,mat subscripts$,mat form$)
05294       if sio_projstep then let s$(sio_projstep)=fnReadThis$  ("projstep",ProjStepFile,mat ProjStep$,mat ProjStep,mat f$,prefix$,mat subscripts$,mat form$,"",0,ps_name)
05295       if sio_programmer then let s$(sio_programmer)=fnReadThis$("employee",EmployeeFile,mat Employee$,mat Employee,mat f$,Prefix$,mat Subscripts$,mat Form$,"programmer")
05296       if sio_stepcat then let s$(sio_stepcat)=fnReadThis$    ("stepcat", StepCatFile  ,mat StepCat$,mat StepCat,mat F$,prefix$,mat Subscripts$,mat Form$)
05297       if sio_airlines then let s$(sio_airlines)=fnReadThis$("airlines",AirlinesFile,mat Airlines$,mat Airlines,mat f$,prefix$,mat Subscripts$,mat Form$)
05298       if sio_typeout then let s$(sio_typeout)=fnReadThis$  ("bctypes", BCTypesFile, mat BCTypes$,mat BCTypes,mat F$,prefix$,mat Subscripts$,mat Form$,"typeout")
05299       if sio_typein then let s$(sio_typein)=fnReadThis$    ("bctypes", BCTypesFile, mat BCTypes$,mat BCTypes,mat F$,prefix$,mat Subscripts$,mat Form$,"typein")
05300       if sio_feetype1 then let s$(sio_feetype1)=fnReadThis$("bctypes", BCTypesFile, mat BCTypes$,mat BCTypes,mat F$,prefix$,mat Subscripts$,mat Form$,"feetype1")
05301       if sio_feetype2 then let s$(sio_feetype2)=fnReadThis$("bctypes", BCTypesFile, mat BCTypes$,mat BCTypes,mat F$,prefix$,mat Subscripts$,mat Form$,"feetype2")
05302       if sio_exchange then let s$(sio_exchange)=fnReadThis$("exchange",ExchangeFile,mat Exchange$,mat Exchange,mat F$,prefix$,mat Subscripts$,mat Form$)
05303       if sio_wallets then let s$(sio_Wallets)=fnReadThis$("wallets",WalletsFile,mat Wallets$,mat Wallets,mat F$,prefix$,mat Subscripts$,mat Form$)
05304 !
05305       if sio_icon then let s$(sio_icon)=fnReadImage$("icon",mat f$,prefix$,mat subscripts$)
05306 !
05307       if sio_startdate then let s$(sio_startdate)=fnExtractDate$("startdate",mat f,prefix$,mat subscripts$)
05308       if sio_date then let s$(sio_date)=fnExtractDate$("date",mat f,prefix$,mat subscripts$)
05309       if sio_added then let s$(sio_added)=fnExtractDate$("added",mat f,prefix$,mat subscripts$)
05310 !
05311       if sio_recieptflag then let s$(sio_recieptflag)=fnIsItThere$("reciept",mat f$,prefix$,mat subscripts$)
05312       if sio_NotesPresent then let s$(sio_NotesPresent)=fnIsItThere$("notes",mat f$,prefix$,mat subscripts$)
05313 !
05314       if sio_status then let s$(sio_status)=fnThis$("status",mat f$,prefix$,mat Subscripts$)
05315       if sio_phonenum then let s$(sio_phonenum)=fnFormatPhone$("phonenum",mat f$,prefix$,mat subscripts$)
05316       if sio_fromlead then let s$(sio_fromlead)=fnExistsYN$("fromlead",mat f$,prefix$,mat subscripts$)
05317       if sio_contractYN then let s$(sio_contractYN)=fnExistsYN$("reciept",mat f$,prefix$,mat subscripts$)
05318 !
05319  ! .  ! if sio_projfolder then let s$(sio_projfolder)=fnThis$("projfolder",mat f$,prefix$,mat Subscripts$)
05320  ! .  ! if sio_notefile then let s$(sio_notefile)=fnThis$("notefile",mat f$,prefix$,mat Subscripts$)
05321 !
05322       if sio_timein then let s$(sio_timein)=fnThis$("logintime",mat f$,prefix$,mat Subscripts$)
05323 !
05324       if sio_sentyn then let s$(sio_sentyn)=fnYesNo$("sent",mat f,prefix$,mat subscripts$)
05325 !
05326       if sio_activeyn then let s$(sio_activeyn)=fnYesNo$("active",mat f,prefix$,mat subscripts$)
05327 !
05328       if sio_amount then let s$(sio_amount)=fnFormatAmount$("total",mat f,prefix$,mat subscripts$)
05329 !
05330       if sio_sortcolumn and ex_description and ex_date then let s$(sio_sortcolumn)=lwrc$(f$(ex_description)(1:3))&" "&str$(f(ex_date))
05331 !
05332       if sio_lock and em_lock and em_lock<=udim(mat f) then
05333          if f(em_lock) then
05334             let s$(sio_lock)="Locked"
05335          else
05336             let s$(sio_lock)=""
05337          end if
05338       end if
05339 !
05340       if sio_projectStatus and pj_billed and pj_approved and pj_emailed then
05341          if f(pj_QuotedCust) then
05342             if f(pj_billed) then
05343                let s$(sio_projectStatus)="Done"
05344             else if f(pj_approved) then
05345                let s$(sio_projectStatus)="Aprv"
05346             else if f(pj_emailed) then
05347                let s$(sio_projectStatus)="Cust"
05348             else
05349                let s$(sio_projectStatus)="Plan"
05350             end if
05351          else
05352             let s$(sio_projectStatus)=""
05353          end if
05354       end if
05355 !
05356       if uprc$(trim$(screenio$(si_screencode)))="SCHEDULE" and al_description and ~len(trim$(f$(al_description))) then let f$(al_description)="{"&f$(al_function)&"}"
05357 !
05358       if sio_invoice then
05359          if ~tl_customer or (trim$(f$(tl_customer))<>"" and f(tl_DontBillCustomer)=0) then
05360             let s$(sio_invoice)=fnReadThis$("invoice" ,InvoiceFile ,mat Invoice$,mat Invoice,mat f$,prefix$,mat Subscripts$,mat Form$)
05361          else
05362             let s$(sio_invoice)=fnReadThis$("emplinvc",EmplInvcFile,mat EmplInvc$,mat EmplInvc,mat f$,prefix$,mat Subscripts$,mat Form$)
05363          end if
05364       end if
05365 !
05366       if sio_roundhours and tl_hours then
05367          let s$(sio_roundhours)="( "&str$(fnRoundHours(f(tl_hours)))&" )"
05368       end if
05369 !
05370       if sio_invoice_total and ih_id then
05371          let s$(sio_invoice_total)=cnvrt$("PIC($$$,$$#.##)",fnReadInvoiceTotal(f$(ih_id),InvoiceLFile,mat form$)-fnSumPaymentsOnInvoice(f$(ih_id),"",InvcPmtsFile,mat form$))
05372       end if
05373 !
05374       if sio_expense_total and ex_id and ex_total then
05375          let s$(sio_expense_total)=cnvrt$("PIC($$$,$$#.##)",f(ex_total)-fnSumPaymentsOnExpense(f$(ex_id),"",ExpnPmtsFile,mat form$))
05376       end if
05377 !
05378       if sio_QuotedCount then let s$(sio_QuotedCount)=fnCountQuote$(mat f$,mat f)
05379       if sio_QuoteTotal then let s$(sio_QuoteTotal)=fnQuoteTotal$(mat f$,mat f)
05380 !
05381  ! .  ! ********************************************** CUSTOM BITS:
05382  !          This next part of the function are custom bits
05383  !          for various specific screens.
05384   !       **********************************************
05385  ! .  ! This custom bit is for the EXPNEDIT screen, to
05386  ! .  !   disallow editing of expenses by subcontractors once they've been paid.
05387       if Screenio$(si_screencode)="EXPNEDIT" then
05388          if ~fnIsAdmin and ~CurrentEmployee$=f$(ex_enteredby) then ! Failsafe to make sure they don't see something they shouldn't.
05389             let msgbox('You do not have access to view this expense record.','Access Denied')
05390             let ExitMode=QuitOnly
05391          else if fnIsAdmin or f$(ex_status)="E" then ! if its admin, or if its unpaid, they can still edit it.
05392             let Invisible(ctl_BackButton)=1
05393             let Invisible(ctl_CancelButton)=0
05394             let Invisible(ctl_SaveButton)=0
05395             let Invisible(ctl_CutePDFButton)=0
05396             let Invisible(ctl_ImportButton)=0
05397             let Invisible(ctl_ScanButton)=0
05398             let Invisible(ctl_QuickScanButton)=0
05399             let Invisible(ctl_AddPageButton)=0
05400          end if
05401       end if
05402 !
05403  ! .  ! This custom bit is for the Todo list (TabTodo)
05404       if todo_color and ctl_TaskDescription then
05405          let FgColor$(ctl_TaskDescription)="FFFFFF"
05406          let BgColor$(ctl_TaskDescription)=f$(todo_color)
05407       end if
05408 !
05409  ! .  ! This custom bit is for the Work Tab (TabWork) to show Employee Names but only if its me.
05410       if pj_employee and pj_employee2 and sio_ProjectEmployee and ctl_ProjectEmployee and ~Invisible(ctl_ProjectEmployee) then
05411          let s$(sio_ProjectEmployee)=""
05412          let AltSpec=4 : if em_ShortName then let AltSpec=em_shortName
05413          if f$(pj_employee)="0000" and trim$(f$(pj_employee2))><"" then
05414             let s$(sio_ProjectEmployee)=fnReadThis$("employee",EmployeeFile,mat Employee$,mat Employee,mat f$,prefix$,mat Subscripts$,mat Form$,"employee2",0,AltSpec)
05415          else
05416             let s$(sio_ProjectEmployee)=fnReadThis$("employee",EmployeeFile,mat Employee$,mat Employee,mat f$,prefix$,mat Subscripts$,mat Form$,"",0,AltSpec)
05417          end if
05418       end if
05419 !
05420  ! .  ! This custom bit is for the Subscription Listview, for the Current tab
05421       if sio_SubscriptionCurrent and sub_id then
05422          if fnCheckIfCurrent(f$(sub_id)) then
05423             let s$(sio_SubscriptionCurrent)="Yes"
05424          else
05425             let s$(sio_SubscriptionCurrent)="No"
05426          end if
05427       end if
05428 !
05429  ! .  ! This custom bit is for the Project Edit screen.
05430       if ScreenIO$(si_screencode)="PROJEDIT" then
05431          if ctl_field_priceadjust then
05432             let Tooltip$(ctl_field_priceadjust)=fnCustomerRateTooltip$(f$(pj_customer),f(pj_priceadjust))
05433          end if
05434       end if
05435 !
05436  ! .  ! This custom bit is for Project Steps screens.
05437       if ScreenIO$(si_screencode)="PROJSTEPEDIT" then
05438  ! .     ! If it has been assigned, make those fields visible. (but leave them protected)
05439          if len(trim$(F$(ps_AssignedTo))) then
05440             let Invisible(ctl_Caption_AssignedTo)=0
05441             let Invisible(ctl_Field_AssignedTo)=0
05442          end if
05443  ! .     ! If we're editing then make the EDITING caption show the title instead.
05444          if ParentKey$="view" then let s$(sio_Title)=f$(ps_name)
05445       end if
05446 !
05447  ! .  ! This final part is for the Expense Wizard.
05448       if ctl_Show2Receipts then
05449          let fnAdjustPictureSizes
05450       end if
05451 !
05452       dim Trips$(1)
05453       mat Trips$(0)
05454       if ctl_travelprefs then                                                                                       ! If we're in Expense Wizard
05455          if ex_tripplan and ex_tripplan<=udim(mat f$) and lwrc$(ScreenIO$(si_screencode))="expensewiz" then         ! If we're in Expense Wizard
05456             if eWiz_Search1 and udim(mat PassedData$)>eWiz_Search1 and len(trim$(PassedData$(eWiz_Search1))) then
05457                if ctl_SearchInternetButton then let Invisible(ctl_SearchInternetButton)=0
05458             end if
05459 !
05460             if len(trim$(f$(ex_tripPlan))) then
05461                library "triplib" : fnReadSimilarTrips, fnReadSameTimeTrips
05462                if lwrc$(trim$(TravelType$)) = "plane" then  ! #Select# lwrc$(trim$(TravelType$)) #Case# "plane"
05463                   let fnReadSimilarTrips(mat Trips$,f$(ex_tripplan))
05464                else  ! #Case Else#
05465                   let fnReadSameTimeTrips(mat Trips$,f$(ex_tripplan))
05466                end if  ! #End Select#
05467 !
05468                if lwrc$(trim$(TravelType$))="plane" then
05469 !
05470  ! .              ! Here, if its a plane ticket, then instead show all details for all employees.
05471  ! .              !  I believe we just need to open the tab windows and then do nothing else, they should
05472  ! .              !  all work even though the screen can handle it. We may need to put a mainloop to disable exiting
05473  ! .              !   on fkey=92 though.
05474 !
05475  ! .              ! Kind of hacky.
05476  ! .              ! First, find all similar travel records.
05477                   dim TabWindows(1),TabChildWindows(1)
05478                   dim EmployeeName$*255
05479 !
05480                   mat TabWindows(udim(mat Trips$))
05481                   mat TabChildWindows(udim(mat Trips$))
05482 !
05483                   let fnPrepReadEmployee
05484 !
05485                   for Index=1 to udim(mat Trips$)
05486                      mat TripPlan$=("") : mat TripPlan=(0)
05487                      mat Employee$=("") : Mat Employee=(0)
05488 !
05489                      let EmployeeName$=fnReadEmployee$(Trips$(Index))
05490 !
05491  ! .                 ! Open a tab for each one
05492  ! .                 ! Display the ViewTravelPrefsNB screen on that tab, in display only, for each employee.
05493                      open #(TabWindows(Index):=fnGetFileNumber): "srow="&str$(VPosition(ctl_travelprefs))&",scol="&str$(HPosition(ctl_travelprefs))&",rows="&str$(Height(ctl_TravelPrefs))&",cols="&str$(Width(ctl_TravelPrefs))&",parent="&str$(Window)&",n=/#00AAFF:#550000,tab="&EmployeeName$,display,outin
05494                      let TabChildWindows(Index)=fnfm("viewtravelprefsnb",Trips$(Index),1,1,"",TabWindows(Index),1,1)
05495                   next Index
05496                   let fnDoneReadEmployee
05497                else
05498                   let Invisible(ctl_travelprefs)=0 ! Display the Travel Preferences child screen for current person only
05499                end if
05500                let Invisible(ctl_ViewTPrefsButton)=0
05501             else
05502  ! .           ! Move screen controls down.
05503                let VPosition(ctl_Title)+=4
05504                let VPosition(ctl_DescriptionPreview)+=5
05505 !
05506                let VPosition(ctl_Caption_Date)+=6
05507                let VPosition(ctl_Date)+=6
05508                let VPosition(ctl_DateDisplay)+=6
05509 !
05510                let VPosition(ctl_Caption_Description)+=7
05511                let VPosition(ctl_Description)+=7
05512                let VPosition(ctl_TypeCaption)+=7
05513                let VPosition(ctl_expndesc)+=7
05514 !
05515                let VPosition(ctl_Field_Total)+=7
05516                let VPosition(ctl_Caption_Total)+=7
05517 !
05518                let VPosition(ctl_Method)+=7
05519                let VPosition(ctl_MethodCaption)+=7
05520                let VPosition(ctl_PaymentDate)+=7
05521                let VPosition(ctl_PaymentDateCaption)+=7
05522                let VPosition(ctl_CopyDate)+=7
05523                let VPosition(ctl_SetDateToday)+=7
05524                let VPosition(ctl_ReferenceNum)+=7
05525                let VPosition(ctl_ReferenceNumCaption)+=7
05526 !
05527                let VPosition(ctl_expnCat)+=7
05528                let VPosition(Ctl_Caption_ExpnCat)+=7
05529 !
05530                let VPosition(ctl_Customer)+=8
05531                let VPosition(ctl_CustomerCaption)+=8
05532                let VPosition(ctl_Check_Billable)+=8
05533 !
05534                let VPosition(ctl_Caption_Notes)+=8
05535                let VPosition(ctl_Field_Notes)+=8
05536                let Height(ctl_Field_Notes)+=1
05537 !
05538                let VPosition(ctl_Save_Button)-=5
05539                let VPosition(ctl_Cancel_Button)-=5
05540 !
05541             end if
05542          end if
05543       end if
05544    End if
05545 !
05546    if PassedFilter then
05547       if uprc$(trim$(ScreenIO$(si_screenCode)))="PAYIN" or uprc$(trim$(ScreenIO$(si_screenCode)))="PAYOUT" then
05548          let StatusSubscript=fnFindSubscript(mat Subscripts$,Prefix$,"status")
05549          let DateSubscript=fnFindSubscript(mat Subscripts$,Prefix$,"date")
05550          if sio_SortColumn and StatusSubscript and DateSubscript and StatusSubscript<=udim(mat f$) and DateSubscript<=udim(mat f) then
05551             let s$(sio_sortcolumn)=f$(StatusSubscript)&str$(99999-f(DateSubscript))
05552          end if
05553          if StatusSubscript and StatusSubscript<=udim(mat f$) and f$(StatusSubscript)="P" then
05554             let fnReadAny$="/#808080:#000000"
05555          else
05556             let DepositSubscript=fnFindSubscript(mat Subscripts$,Prefix$,"deposit")
05557             if DepositSubscript and DepositSubscript<=udim(mat f) and f(DepositSubscript)=1 then
05558  ! .           ! Payment from Customer is a Deposit. Use Purple.
05559                let fnReadAny$="/#8080FF:#000000"
05560             else
05561  ! .           ! Payment is not a Deposit, could be payout or a regular customer payment. White and Grey.
05562                let fnReadAny$="/#FFFFFF:#000000"
05563             end if
05564          end if
05565       else if lwrc$(trim$(ScreenIO$(si_filelay)))="employee" then
05566          if ~f(em_hide) then
05567             if f(em_lock) then
05568                let fnReadAny$="/#660000:#000000"
05569             else
05570                let fnReadAny$="/#0099CC:#000000"
05571             end if
05572          end if
05573       else
05574          let fnReadAny$="1"
05575       end if
05576    end if
05577 !
05578    if NeedsClosing then
05579       let fnFinal_ReadAny
05580    end if
05581 fnend
05582 !
05583 def fnReadAny(mat f$,mat f,mat s$,mat subscripts$,mat Form$,Prefix$,ParentKey$*255)
05584    if fnReadAny$(mat f$,mat f,mat s$,mat subscripts$,mat Form$,Prefix$,ParentKey$)=="1" then
05585       let fnReadAny=1
05586    end if
05587 fnend
05588 !
05589 dim Customer$(1)*1023,Customer(1),CustomerFile,CloseCustomerFile
05590 dim Employee$(1)*1023,Employee(1),EmployeeFile,CloseEmployeeFile
05591 !
05592 dim Initialized
05593 dim NeedsClosing
05594 !
05595 def fnInit_ReadAny
05596    library "timelib" : fnRoundHours, fnSwipe$
05597    library "invclib" : fnReadInvoiceTotal
05598    library "paymentl" : fnSumPaymentsOnInvoice, fnSumPaymentsOnExpense
05599    library "sublib" : fnCheckIfCurrent, fnCloseCheckCurrentFiles
05600 !
05601    let Initialized=1
05602    let LibraryLinkage=1
05603 !
05604 !
05605  ! .! Open files if this is called as a filter function and it uses the fields in them.
05606  ! .! If opened, close them again in Final_ below.
05607 !
05608    if sio_Customer then                                                    ! Customer File
05609       if ~CustomerFile or file(CustomerFile)=-1 or ~pos(lwrc$(file$(CustomerFile)),"customer") then
05610          let CustomerFile=fnOpen("customer",mat Customer$,mat Customer,mat Form$,1)
05611          let CloseCustomerFile=1
05612       end if
05613    end if
05614    if sio_ProjectEmployee or sio_Employee then                             ! Employee File
05615       if ~EmployeeFile or file(EmployeeFile)=-1 or ~pos(lwrc$(file$(EmployeeFile)),"employee") then
05616          let EmployeeFile=fnOpen("employee",mat Employee$,mat Employee,mat Form$,1)
05617          let CloseEmployeeFile=1
05618       end if
05619    end if
05620 !
05621    if uprc$(trim$(Screenio$(si_screencode)))="TABWORK" and ScreenIO(si_readIndex)=2 then
05622       restore #DataFile, key>="E": nokey Ignore
05623    end if
05624 fnend
05625 !
05626 def fnFinal_ReadAny
05627    if CloseCustomerFile then close #CustomerFile: : let CustomerFile=0
05628    if CloseEmployeeFile then close #EmployeeFile: : let EmployeeFile=0
05629 !
05630    if sio_SubscriptionCurrent then let fnCloseCheckCurrentFiles
05631 fnend
05632 !
05633 dim Employee$(1)*1024,Employee(1)
05634 dim TripPlan$(1)*1024,TripPlan(1)
05635 dim EmployeeName$*128
05636 !
05637 def fnPrepReadEmployee(;TripPlanOutput)
05638    let Employee=fnOpen("employee",mat Employee$,mat Employee,mat Form$,1)
05639    if TripPlanOutput then
05640       let TripPlan=fnOpen("tripplan",mat TripPlan$,mat TripPlan,mat Form$)
05641    else
05642       let TripPlan=fnOpen("tripplan",mat TripPlan$,mat TripPlan,mat Form$,1)
05643    end if
05644 fnend
05645 !
05646 def fnDoneReadEmployee(;TripPlanOutput)
05647    close #Employee:
05648    if TripPlanOutput then
05649       let fnCloseFile(TripPlan,"tripplan")
05650    else
05651       Close #TripPlan:
05652    end if
05653 fnend
05654 !
05655 def fnReadEmployee$*64(TripID$;FirstnameOnly)
05656    read #TripPlan, using form$(TripPlan), key=TripID$ : mat TripPlan$,mat TripPlan nokey Ignore
05657    if len(trim$(TripPlan$(tp_employee))) then
05658       read #Employee, using form$(Employee), key=TripPlan$(tp_Employee) : mat Employee$, mat Employee nokey Ignore
05659    end if
05660    if FirstNameOnly and pos(Employee$(em_name)," ") then
05661       let fnReadEmployee$=Employee$(em_name)(1:pos(Employee$(em_name)," ")-1)
05662    else
05663       let fnReadEmployee$=Employee$(em_name)
05664    end if
05665 fnend
05666 !
05667 def fnThis$*255(thing$,mat f$,prefix$,mat Subscripts$;___,FileSubscript)
05668    let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,Thing$)
05669    if FileSubscript then let fnThis$=f$(FileSubscript)
05670 fnend
05671 !
05672 def fnIsItThere$(thing$,mat f$,mat prefix$,mat subscripts$;___,FileSubscript)
05673    let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,Thing$)
05674    if FileSubscript and trim$(f$(FileSubscript))<>"" then let fnIsItThere$="X"
05675 fnend
05676 !
05677 def fnReadImage$*255(Thing$,mat f$,prefix$,mat subscripts$;___,FileSubscript)
05678    let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,Thing$)
05679    if FileSubscript then let fnReadImage$=fnReadUnopenedDescription$("images",f$(FileSubscript))
05680 fnend
05681 !
05682 def fnExtractNotes$*100(Thing$,Index,mat f$,prefix$,mat subscripts$;___,FileSubscript)
05683    let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,Thing$)
05684    if FileSubscript then let fnExtractNotes$=f$(FileSubscript)(((index-1)*100)+1:(Index*100))
05685 fnend
05686 !
05687 def fnExtractDate$(Thing$,mat f,prefix$,mat subscripts$;___,FileSubscript)
05688    let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,Thing$)
05689    if FileSubscript then
05690       if PutDatesInSortableOrder then
05691          let fnExtractDate$=Date$(f(FileSubscript),"ccyy/mm/dd")
05692       else
05693          let fnExtractDate$=Date$(f(FileSubscript),"mm/dd/ccyy")
05694       end if
05695    end if
05696 fnend
05697 !
05698 def fnFormatAmount$(Thing$,mat f,prefix$,mat subscripts$;___,FileSubscript)
05699    let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,Thing$)
05700    if FileSubscript then let fnFormatAmount$="$"&trim$(cnvrt$("N 8.2",f(FileSubscript)))
05701 fnend
05702 !
05703 def fnFormatPhone$(Thing$,mat f$,prefix$,mat subscripts$;___,FileSubscript)
05704    let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,Thing$)
05705    if FileSubscript then let fnFormatPhone$="("&F$(FileSubscript)(1:3)&") "&F$(FileSubscript)(4:6)&"-"&F$(FileSubscript)(7:10)
05706 fnend
05707 !
05708 def fnExistsYN$(Thing$,mat f$,prefix$,mat Subscripts$;___,FileSubscript)
05709    let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,Thing$)
05710    if FileSubscript then
05711       if len(trim$(f$(FileSubscript))) then
05712          let fnExistsYN$="Yes"
05713       else
05714          let fnExistsYN$=""
05715       end if
05716    end if
05717 fnend
05718 !
05719 def fnYesNo$(Thing$,mat f,prefix$,mat subscripts$;___,FileSubscript)
05720    let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,Thing$)
05721    if FileSubscript then
05722       if f(FileSubscript) then
05723          let fnYesNo$="Yes"
05724       else
05725          let fnYesNo$="No"
05726       end if
05727    end if
05728 fnend
05729 !
05730 def fnReadThis$*255(Thing$,&FileNumber,mat ReadThing$,mat ReadThing,mat f$,Prefix$,mat Subscripts$,mat Form$;FileThing$,Picture,AltSub,___,FileSubscript)
05731    if ~AltSub then let AltSub=2
05732    if FileThing$="" then let FileThing$=Thing$
05733    let FileSubscript=fnFindSubscript(mat Subscripts$,prefix$,FileThing$)
05734    if FileSubscript and trim$(f$(FileSubscript))<>"" then
05735       if FileNumber then
05736          let fnReadThis$=fnReadDescription$(FileNumber,AltSub,f$(FileSubscript),mat ReadThing$,mat ReadThing,mat Form$)
05737       else
05738          let fnReadThis$=fnReadUnopenedDescription$(Thing$,f$(FileSubscript),AltSub)
05739       end if
05740    else
05741       if ~(fnBR42 and Picture) then
05742          let fnReadThis$="No "&Thing$
05743       end if
05744    end if
05745 fnend
05746 !
05747 def fnQuoteTotal$(mat f$,mat f)
05748    if f(pj_QuotedCust) then
05749       library "timelib" : fnIsAdmin
05750       if fnIsAdmin then
05751          library "quotelib" : fnQuoteTotal
05752          let fnQuoteTotal$="$"&str$(fnQuoteTotal(f$(pj_id),f$(pj_customer),f(pj_PriceAdjust)))
05753       end if
05754    end if
05755 fnend
05756 !
05757 def fnCountQuote$*21(mat f$,mat f;___,Endex,Qndex,Qcnt,String$*21)
05758    if pj_quotedcust and pj_quotedemp and pj_quotedempl and pj_employee and pj_employeel then
05759       let Qcnt=0
05760       if f(pj_QuotedCust) then
05761          let string$="C"
05762          let Qcnt+=1
05763       else
05764          let string$="_"
05765       end if
05766       for Endex=pj_Employee to pj_EmployeeL
05767          if trim$(f$(Endex))><"" then
05768             let Qndex=Endex-pj_Employee+pj_QuotedEmp
05769             if f(Qndex) then
05770                let string$=string$&"E"
05771                let Qcnt+=1
05772             else
05773                let string$=string$&"_"
05774             end if
05775          else
05776             let string$=string$&" "
05777          end if
05778       next Endex
05779       if Qcnt then
05780          let fnCountQuote$=trim$(string$)
05781       end if
05782    end if
05783 fnend
05784 !
05785 ! Imported From "function\customervalidation.brs"
05786  ! function\customervalidation.brs
05787  !
05788  !
05789  ! Created on 01/09/2009
05790  !
05791  ! This function validates a record for the Customer file
05792  ! It is intended to be called from the Prewrite Event
05793  ! If anything is found to be amiss, the SaveAndQuit is cancelled.
05794  def fncustomervalidation(mat f$, mat f, &ExitMode, &CurrentField)
05795     if ~len(trim$(f$(cu_Name))) then
05796        let msgbox("The Customer Name cannot be blank.","Validation")
05797        let ExitMode=0 ! Cancel Exit
05798        let CurrentField=1
05799     end if
05800  fnend
05801 !
05802 ! Imported From "function\adjustpicturesizes.brs"
05803  ! function\adjustpicturesizes.brs
05804  ! Created on 10/05/2016
05805  !
05806  ! fnAdjustPictureSizes - This function detects if we should change picture sizes or not.
05807  !
05808  !
05809  def fnAdjustPictureSizes
05810     if sio_Show2Receipts then
05811        if val(s$(sio_Show2Receipts)) or len(trim$(s$(sio_payrecieptkey))) then
05812           let Invisible(ctl_payreciept)=0
05813           let Invisible(ctl_paycutepdfButton)=0
05814           let Invisible(ctl_payselectfile)=0
05815           let Invisible(ctl_payScan)=0
05816           let Invisible(ctl_payQuickScan)=0
05817           let Invisible(ctl_payrecieptkey)=0
05818           let Invisible(ctl_PayOpenButton)=0
05819 !
05820           let Height(ctl_reciept)=15
05821           let Vposition(ctl_cutepdfButton)=17
05822           let Vposition(ctl_selectfile)=17
05823           let Vposition(ctl_Scan)=17
05824           let Vposition(ctl_QuickScan)=17
05825           let Vposition(ctl_field_reciept)=17
05826           let Vposition(ctl_OpenButton)=17
05827        else
05828           let Invisible(ctl_payreciept)=1
05829           let Invisible(ctl_paycutepdfButton)=1
05830           let Invisible(ctl_payselectfile)=1
05831           let Invisible(ctl_payScan)=1
05832           let Invisible(ctl_payQuickScan)=1
05833           let Invisible(ctl_payrecieptkey)=1
05834           let Invisible(ctl_PayOpenButton)=1
05835 !
05836           let Height(ctl_reciept)=32
05837           let Vposition(ctl_cutepdfButton)=34
05838           let Vposition(ctl_selectfile)=34
05839           let Vposition(ctl_Scan)=34
05840           let Vposition(ctl_QuickScan)=34
05841           let Vposition(ctl_field_reciept)=34
05842           let Vposition(ctl_OpenButton)=34
05843        end if
05844     end if
05845     if fkey=92 then let ExitMode=0 : let fkey(-1) ! Suppress exit on Tab Click
05846  fnend
05847 !
05848 ! Imported From "function\expensealtparmsubs.brs"
05849  ! function\expensealtparmsubs.brs
05850  ! Created on 03/31/2018
05851  !
05852  ! fnExpenseAltParmSubs - This function sets the subscripts used for
05853  !   passing Alternate Extended parameters into the Expense Wizard using mat PassedData$.
05854  !
05855 !
05856  def fnExpenseAltParmSubs
05857     let eWiz_LDepTime=1
05858     let eWiz_LArvTime=2
05859     let eWiz_LFlightNo=3
05860     let eWiz_LConfirmation=4
05861 !
05862     let eWiz_RDepTime=5
05863     let eWiz_RArvTime=6
05864     let eWiz_RFlightNo=7
05865     let eWiz_RConfirmation=8
05866 !
05867     let eWiz_Search1=9
05868     let eWiz_Search2=10
05869     let eWiz_SearchL=11
05870 !
05871     let eWiz_FromAirport=12
05872     let eWiz_ToAirport=13
05873     let eWiz_SecondAirport=14
05874 !
05875     let eWiz_MarkDone=15
05876 !
05877     let eWiz_ArraySize=15   ! Top Element, used for sizing array.
05878  fnend
05879 !
05880  ! Function to aid in reading these values.
05881  def fnP$*255(Sub)
05882     if Sub<=udim(mat PassedData$) then let fnP$=trim$(PassedData$(Sub))
05883  fnend
05884 !
05885  def fnSP$(Sub,Data$*255)
05886     if Sub<=udim(mat PassedData$) then let PassedData$(Sub)=trim$(Data$)
05887  fnend
05888 !
05889 ! Imported From "function\updatecustomerratetooltip.brs"
05890 ! function\updatecustomerratetooltip.brs
05891 ! Created on 04/07/2022
05892 !
05893 ! fnUpdateCustomerRateTooltip - This function updates the customer rate tooltip
05894 !  for the customer rate.
05895 !
05896 !
05897 def fnUpdateCustomerRateTooltip(;___,NewPriceAdjust)
05898  ! .! Add a tooltip to the Edit Project screen if you hover over the "Price Adjustment" field,
05899  ! .!  so that it shows the actual price
05900    let NewPriceAdjust=val(FieldText$) conv BadPriceAdjustData
05901 !
05902       let Tooltip$(ControlIndex)=fnCustomerRateTooltip$(f$(pj_customer),NewPriceAdjust)
05903       let fnUpdateCustomerRateTooltip=1
05904 !
05905    BadPriceAdjustData: ! Continue from here if bad data, don't update price or tooltip if there's letters in the field.
05906 fnend
05907 !
05908 let Project=fnOpen("Project",mat Project$,mat Project,mat form$)
05909 let Customer=fnOpen("Customer",mat Customer$,mat Customer,mat form$)
05910 !
05911 dim CustomerRate,SelectedCustomer$
05912 !
05913 def fnCustomerRateTooltip$*80(Customer$, PriceAdjust;___,ProjectRateAdjust$*60)
05914    if len(trim$(Customer$)) then
05915       if SelectedCustomer$><Customer$ then
05916          let SelectedCustomer$=Customer$
05917          let CustomerRate=fnReadUnOpenedNumber("Customer",Customer$,cu_rate)
05918       end if
05919 !
05920       if PriceAdjust then
05921          let ProjectRateAdjust$=trim$(cnvrt$("pic(-$$$$$$$.##)",CustomerRate))
05922          if PriceAdjust>0 then
05923             let ProjectRateAdjust$(inf:0)=" + "
05924          else if PriceAdjust<0 then
05925             let ProjectRateAdjust$(inf:0)=" - "
05926          end if
05927          let ProjectRateAdjust$(inf:0)=trim$(cnvrt$("pic($$$$$$$.##)",abs(PriceAdjust)))&" = "
05928       end if
05929 !
05930       let fnCustomerRateTooltip$="Price: "&ProjectRateAdjust$&""&trim$(cnvrt$("pic($$$$$$$.##)",CustomerRate+PriceAdjust))&""
05931    else
05932       let fnCustomerRateTooltip$="No Customer Selected"
05933    end if
05934 fnend
05935 !
05936 !
05937 !
85000    def library fnCheckStringFunction(Function$*255)
85001    if Function$ = "{stripcommas}" then
85002       let fnCheckStringFunction = 0
85003    else if Function$ = "{scanreciept}" then
85004       let fnCheckStringFunction = 0
85005    else if Function$ = "{importreciept}" then
85006       let fnCheckStringFunction = 0
85007    else if Function$ = "{scanrecieptfast}" then
85008       let fnCheckStringFunction = 0
85009    else if Function$ = "{getrecieptfromprinter}" then
85010       let fnCheckStringFunction = 0
85011       else if Function$ = "{initcustomer}" then
85012          let fnCheckStringFunction = 0
85013       else if Function$ = "{readany}" then
85014          let fnCheckStringFunction = 10
85015       else if Function$ = "{customervalidation}" then
85016          let fnCheckStringFunction = 0
85017       else
85018          if Function$<>"{{GetData}}" and Function$<>"{{SetData}}" then
85019             print "Function ("&function$&") on screen CUSTEDIT is not Supported: The library is out of date or fn not found."
85020          end if
85021       end if
85022    fnend
85023 !
85024 !
89000    def library fnFunctionSwitch(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89010       let fnFunctionSwitch = fnFS(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89020    fnend
89030    def library fnFunctionSwitch$*255(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89040       let fnFunctionSwitch$ = fnFS$(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89050    fnend
89060    def library fnFunctionSwitch1(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89070       let fnFunctionSwitch1 = fnFS(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89080    fnend
89090    def library fnFunctionSwitch1$*255(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89100       let fnFunctionSwitch1$ = fnFS$(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89110    fnend
89120    def library fnFunctionSwitch2(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89130       let fnFunctionSwitch2 = fnFS(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89140    fnend
89150    def library fnFunctionSwitch2$*255(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89160       let fnFunctionSwitch2$ = fnFS$(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89170    fnend
89180    def library fnFunctionSwitch3(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89190       let fnFunctionSwitch3 = fnFS(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89200    fnend
89210    def library fnFunctionSwitch3$*255(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89220       let fnFunctionSwitch3$ = fnFS$(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89230    fnend
89240    def library fnFunctionSwitch4(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89250       let fnFunctionSwitch4 = fnFS(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89260    fnend
89270    def library fnFunctionSwitch4$*255(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89280       let fnFunctionSwitch4$ = fnFS$(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89290    fnend
89300    def library fnFunctionSwitch5(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89310       let fnFunctionSwitch5 = fnFS(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89320    fnend
89330    def library fnFunctionSwitch5$*255(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89340       let fnFunctionSwitch5$ = fnFS$(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89350    fnend
89360    def library fnFunctionSwitch6(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89370       let fnFunctionSwitch6 = fnFS(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89380    fnend
89390    def library fnFunctionSwitch6$*255(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89400       let fnFunctionSwitch6$ = fnFS$(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89410    fnend
89420    def library fnFunctionSwitch7(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89430       let fnFunctionSwitch7 = fnFS(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89440    fnend
89450    def library fnFunctionSwitch7$*255(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89460       let fnFunctionSwitch7$ = fnFS$(Function$,mat Subscripts$,mat PassedData$,FieldIndex,FieldText$,ControlIndex,Key$,ExitMode,RepopulateListviews,RedrawListviews,CurrentField,CurrentField$,Prefix$,CurrentKey$,CurrentRec,ParentKey$,DataFile,Window,CurrentRow,LockUser$,Path$,Selecting,mat Disk_F$,mat Disk_F,OnRead,TryToContinue,DisplayOnly,Active,RedrawFrames,RedrawScreens,RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$)
89470    fnend
89480 !
89490  dim DataIsInside
89500 !
89510    def fnFS(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$;___,ReturnValue,ReturnValue$*255,Index)
89520       gosub FunctionSwitch
89530       let fnFS=ReturnValue
89540    fnend
89550    def fnFS$*255(Function$*255,mat Subscripts$,mat PassedData$,&FieldIndex,&FieldText$,&ControlIndex,&Key$,&ExitMode,&RepopulateListviews,&RedrawListviews,&CurrentField,&CurrentField$,&Prefix$,&CurrentKey$,&CurrentRec,&ParentKey$,&DataFile,Window,&CurrentRow,LockUser$,&Path$,&Selecting,mat Disk_F$,mat Disk_F,&OnRead,&TryToContinue,&DisplayOnly,&Active,&RedrawFrames,&RedrawScreens,&RepopulateCombo,mat F$,mat F, mat S$,mat CnvrtIn$,mat FieldsSSubs$,mat FieldsNSubs$,mat FieldName$,mat ControlName$,mat ScreenSubs$,mat Function$,mat SpecWidth,mat Form$,mat ScreenData$,mat ScreenLongData$,mat ScreenData,mat ReturnData$,mat ControlSpec$;___,ReturnValue,ReturnValue$*255,Index)
89560       gosub FunctionSwitch
89570       let fnFS$ = ReturnValue$
89580    fnend
89590 !
89600 !
92000 FunctionSwitch: ! Routine to call custom function
92001 !
92002    if ~DataIsInside then
92003       let fnPopData(2)
92004       if Function$="{{SetData}}" then let DataIsInside=1
92005    end if
92006 !
92007    if ~FileIOLinkageSet then
92008       library "fileio" : fnOpenFile,Fnclosefile,Fngetfilenumber,Fnkey$,FnBuildKey$,Fnreadlayoutarrays,Fndoeslayoutexist,Fnreadallkeys,fnReadRelativeDescription$,fnReadRelUnopenedDescription$,fnReadRelUnopenedNumber,fnUpdateFile,fnLog,fnLogArray,fnSetLogChanges,fnLogChanges,fnErrLog,fnReadLayouts,Fnmakeuniquekey$,FnDisplayLength,FnLength,FnReadDescription$,FnReadUnopenedDescription$,fnReadRecordWhere$,fnUniqueKey,fnReadNumber,fnReadUnopenedNumber,fnReadRelativeNumber,fnNotInFile,fnDataCrawler,fnDataEdit,fnShowData,fnCopyfile
92009       library "fileio" : fnMakeSubProc,fnReadMatchingKeys,fnReadAllNewKeys,fnReadFilterKeys,fnReadEntireLayout,fnReadLayoutHeader,fnReadSubs,fnReadLayoutPath$,fnReadKeyFiles,fnAskCombo$,fnRunProcFile,fnBuildProcFile,fnReadLockedUsers,fnShowMessage,fnExportListviewCSV,fnCsvExport,fnCsvImport
92010       library "screenio" : fnCallScreen$,fnFindSubscript,fnFm$,fnfm,fnDisplayScreen,fnGetUniqueName$,fnIsInputSpec,fnIsOutputSpec,fnDays,fnBR42,fnBR43,fnAnimate,fnPrepareAnimation,fnCloseAnimation,fnFunctionBase,fnListSpec$
92011       let FileIOLinkageSet=1
92012       for Index=1 to udim(mat Subscripts$) : execute (Subscripts$(Index)) : next Index
92013    end if
92014 !
92015    if Function$ = "{stripcommas}" then
92016       let ReturnValue = fnStripCommas
92017    else if Function$ = "{scanreciept}" then
92018       let ReturnValue = fnScanReciept(mat f$, mat s$,mat Subscripts$,prefix$)
92019    else if Function$ = "{importreciept}" then
92020       let ReturnValue = fnImportReciept(mat f$, mat s$,mat Subscripts$,prefix$)
92021    else if Function$ = "#recieptl:fnPrintFile(f$(cu_reciept))" then
92022       library "recieptl" : fnPrintFile
92023       let ReturnValue = fnPrintFile(f$(cu_reciept))
92024    else if Function$ = "{scanrecieptfast}" then
92025       let ReturnValue = fnscanrecieptfast(mat f$, mat s$,mat Subscripts$,prefix$)
92026    else if Function$ = "#recieptl:fnPrintFile(f$(cu_reciept),1)" then
92027       library "recieptl" : fnPrintFile
92028       let ReturnValue = fnPrintFile(f$(cu_reciept),1)
92029    else if Function$ = "{getrecieptfromprinter}" then
92030       let ReturnValue = fnGetRecieptFromPrinter(mat f$, mat s$,mat Subscripts$,prefix$)
92031    else if Function$ = "{initcustomer}" then
92032       let ReturnValue = fninitcustomer(mat f$,mat f,Datafile)
92033    else if Function$ = "{readany}" then
92034       let ReturnValue$ = fnReadAny$(mat f$,mat f,mat s$,mat subscripts$,mat Form$,Prefix$,ParentKey$)
92035    else if Function$ = "{customervalidation}" then
92036       let ReturnValue = fncustomervalidation(mat f$, mat f, ExitMode, CurrentField)
92037    else
92038       if Function$<>"{{GetData}}" and Function$<>"{{SetData}}" then
92039          print "Function ("&function$&") on screen CUSTEDIT is not Supported: The library is out of date or fn not found."
92040       end if
92041    end if
92042 !
92043    if ~DataIsInside or Function$="{{GetData}}" then
92044       let fnPushData(2)
92045       let DataIsInside=0
92046    end if
92047 return
92048 !
99000 OPEN: !   ***** Function  To Call Library Openfile And Proc Subs
99010    def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,Suppress_Log,mat DateFmt$,___,Index)
99020       dim _FileIOSubs$(1)*800, _loadedsubs$(1)*32
99030       let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$,Suppress_Log,mat DateFmt$)
99040       if srch(_loadedsubs$,uprc$(Filename$))<=0 then : mat _loadedsubs$(UDIM(_loadedsubs$)+1) : _loadedsubs$(UDIM(_loadedsubs$))=uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
99050    fnend
99060 !
99980 IGNORE: continue
99990 REPEAT: retry

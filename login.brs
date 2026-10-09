!--------------------------------------------------
dim Form$(0)*255
dim webusers$(0)*1023,webusers(0)
dim usersession$(0)*1023,usersession(0)
dim Form$(1)*255
dim email$*40,Password$*40,Stored_Password$*200
!--------------------------------------------------
def library fnlogin (mat keys$,mat values$;___,user_name$*255,usersession$*255,storeduseremail$*255)
   fnlinklibraries
   email$ = Fnget_Value$('user_name',mat keys$,mat values$) ! this is the user EMAIL, but built-in browser login popup uses "user_name"
   Password$ = Fnget_Value$('password',mat keys$,mat values$)
   usersession$ = Fnget_Value$('session',mat keys$,mat values$)
   storeduseremail$ = fnreadsessionuser$(usersession$)

   if email$='' or email$='notfound' or password$='' or password$='notfound' or usersession$='' or usersession$='notfound' then
      fnauthenticate('Log in','.\challenge.bootstrap.html')
   else if storeduseremail$<>'' then
      fnallowlogin
   else if srch(keys$,'^user_name') < 1 then ! if not already authenticated
      fnauthenticate('Log in','.\challenge.bootstrap.html')
   else if password$ = fnreadpassword$(email$) then
      fnallowlogin
   end if
fnend
!--------------------------------------------------
dim lastUsedPage$*1000
def fnallowlogin
   pagetimeout = 20
!  env$ are environment variables defined in BRconfig.sys file
   minute_days_value = .00069445
   fnauthorize(-pagetimeout*minute_days_value)
   fnstoresessionuser(usersession$,email$)

   lastUsedPage$ = Fnget_Value$('lastUsedPage',mat keys$,mat values$)
   if lastUsedPage$<>'' then
      if lastusedpage$(1:7)='http://' then
         lastusedpage$ = lastusedpage$(pos(lastusedpage$,'/',8):len(lastusedpage$))
      end if
      if lastusedpage$(1:8)='https://' then
         lastusedpage$ = lastusedpage$(pos(lastusedpage$,'/',9):len(lastusedpage$))
      end if
      fnsend_Page(lastUsedPage$)
   else
      fnsend_Page('/html/examples/json.html')
  end if
fnend
!--------------------------------------------------
def library fnlogout (mat keys$,mat values$;___,user_name$*255,usersession$*255,Resp_Data$*255)
   fnlinklibraries
   usersession$ = Fnget_Value$('session',mat keys$,mat values$)
   if usersession$<>'notfound' then
      usersession=Fnopen('session',Mat usersession$,Mat usersession,Mat Form$)
      read #usersession, using Form$(usersession), key=usersession$: Mat usersession$, Mat usersession nokey Ignore
      if File(usersession)=0 then
         delete #usersession:!  Delete Old Session Data
      end if
      Fnclosefile(usersession,'session')
!     this is the response the page needs before redirecting to the login page
      Resp_Data$ = 'loggedout'
   else
      Resp_Data$ = 'session_not_found'
   end if
   library : Fnput_Json, Fnsend_Object
   Fnput_Json('LogoutResponse', Resp_Data$)
   Fnsend_Object('LogoutResponse')
fnend
!--------------------------------------------------
dim linkestablished
def fnlinklibraries
   if ~linkestablished then
      library 'fileio' : Fnopenfile, Fnbuildkey$, Fnclosefile
      library 'util' : Fnget_Value$, fnreadsessionuser$
      library : fnauthenticate, fnsend_page, fnauthorize
      linkestablished=1
   end if
fnend
!--------------------------------------------------
def Fnstoresessionuser(usersession$,email$*40;___,usersession)
   usersession=Fnopen('session',Mat usersession$,Mat usersession,Mat Form$)
   read #usersession, using Form$(usersession), key=rpad$(usersession$,kln(usersession)): Mat usersession$, Mat usersession nokey Ignore
   if File(usersession)<>0 then
      usersession$(sn_usersession)=usersession$
      usersession$(sn_email)=email$
      usersession(sn_days_date)=days(date$)
      usersession(sn_time)=val(srep$(time$,':','')(1:4))
      write #usersession, using Form$(usersession) : Mat usersession$, Mat usersession
   end if
   Fnclosefile(usersession,'session')
   Fnstoresessionuser=1
fnend
!--------------------------------------------------
dim Resp_Data$*50000
def library fnuserinfo (mat keys$,mat values$;___,level,storeduseremail$*255,usersession$*255,webuserskey$*255,name$*255)
   fnlinklibraries
   usersession$ = Fnget_Value$('session',mat keys$,mat values$)
   storeduseremail$= fnreadsessionuser$(usersession$)
   if storeduseremail$<>'' and storeduseremail$<>'notfound' then
      webusers=Fnopen('webusers',Mat webusers$,Mat webusers,Mat Form$,1,1)
      read #webusers, using Form$(webusers), key=rpad$(storeduseremail$,kln(webusers)): Mat webusers$, Mat webusers nokey Ignore
      if File(webusers)=0 then
         Resp_Data$ = '{"level":"'&webusers$(wusr_level)&'","oper":"'&webusers$(wusr_oper)&'","opername":"'&webusers$(wusr_opername)&'","email":"'&webusers$(wusr_email)&'"}'
      else
         Resp_Data$ = '{"err":"user_not_found"}'
      end if
      close #webusers:
   else
      Resp_Data$ = '{"err":"user_not_found"}'
   end if
   library : Fnput_Json, Fnsend_Object
   Fnput_Json('userinfo', Resp_Data$)
   Fnsend_Object('userinfo')
fnend
!--------------------------------------------------
dim resourcedates$*50000,Rec_Data$*200
dim resourcedate$(0)*500, resourcedate(0), form$(0)*255
def fnresourcedates$*50000
   resourcedate = fnopen('resourcedate', mat resourcedate$, mat resourcedate, mat form$,1)
   library :Fncompile_Json
   library 'util': fnwrapjsonarray
   library 'fileio': Fnreadsubs
   Fnreadsubs('resourcedate',Mat Ssubs$,Mat Nsubs$,Prefix$)
   resourcedates$ = ''
   do
      read #resourcedate,using form$(resourcedate): mat resourcedate$, mat resourcedate eof ignore
      if file(resourcedate)<>0 then exit do
      Fncompile_Json('{',NULL$,Mat Ssubs$, Mat resourcedate$, Rec_Data$)
      resourcedates$(inf:inf) = Rec_Data$&','
   loop
   fnwrapjsonarray(resourcedates$)
   close #resourcedate:
   fnresourcedates$ = resourcedates$
fnend
!--------------------------------------------------
def Fnreadpassword$*40(email$*40;___,webusers)
   webusers=Fnopen('webusers',Mat webusers$,Mat webusers,Mat Form$,1,1)
   read #webusers, using Form$(webusers), key=rpad$(email$,kln(webusers)) : Mat webusers$, Mat webusers nokey Ignore
   if File(webusers)=0 then
      Fnreadpassword$=webusers$(wusr_password)
   end if
   close #webusers:
fnend
!--------------------------------------------------
def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,___,Index)
   dim _Fileiosubs$(1)*800, _Loadedsubs$(1)*80
   Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _Fileiosubs$, Supress_Prompt,Ignore_Errors,Program$)
   if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
fnend
!--------------------------------------------------
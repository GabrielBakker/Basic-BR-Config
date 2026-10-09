! FileIO Library Basic Addon Template by Gabriel Bakker
! Copyright 2012 Gabriel Bakker, Sage AX
! Created: 2/6/2012
!
! Use this template library as an example of how
! to construct other template libraries.
!
! Every Template must have two library functions,
!  fnTemplateList and fnRunTemplate.
!
!  fnTemplateList(mat TemplateDesc$)
!  takes an array of descriptions and returns a list of
!  the available functions in this template library.
!
!  fnRunTemplate(Template,FileLay$)
!  this function takes the given template Index and
!  file layout and calls your template function.
!
!  A template function should read the file layout
!  and then build a string of code and return it
!  in the clip board so that a programmer can
!  paste it into his editor of choice later.
!
!
! To add to this template library, add your
!  template description and template label
!  to the list and gosub statement at the
!  bottom of this library.
!
!  Then write some template code at that label
!  in a subroutine that sets the code to return
!  in the "ReturnCode$" variable, or use the
!  fnReturnCode function.

dim Keys$(1)*255,KeyDescription$(1)*255,Ssubs$(1),Nsubs$(1),Sspec$(1),Nspec$(1)
dim Sdescription$(1)*255,Ndescription$(1)*255,Spos(1),Npos(1)
dim FileName$*255,Prefix$
dim LongestElement

dim NumberList$
dim KeyFields$(1)
dim KeyGiven
dim KeyLength, Length, Sub

dim CodeLine$*400

! *******************************************
!                Objects
! *******************************************
SetAttr: ! Creates the SetAttr Attributes that Mike Miller uses for his BR Object implementation
   for Index=1 to udim(mat SSubs$)
      let fnReturnCode('        let FnSetAttr$(Self$, "'&SDescription$(Index)&'",'&FileLay$&'$('&Prefix$&Ssubs$(Index)&'))')
   next Index
   for Index=1 to udim(mat NSubs$)
      let fnReturnCode('        let FnSetAttr(Self$, "'&NDescription$(Index)&'",'&FileLay$&'('&Prefix$&Nsubs$(Index)&'))')
   next Index
return

GetAttr: ! Creates the GetAttr Attributes that Mike Miller uses for his BR Object implementation
   for Index=1 to udim(mat SSubs$)
      let fnReturnCode('        let '&FileLay$&'$('&Prefix$&Ssubs$(Index)&')=FnGetAttr$(Obj$, "'&SDescription$(Index)&'")')
   next Index
   for Index=1 to udim(mat NSubs$)
      let fnReturnCode('        let '&FileLay$&'('&Prefix$&Ssubs$(Index)&')=FnGetAttr(Obj$, "'&SDescription$(Index)&'")')
   next Index
return


dim ReturnCode$*20000
def fnReturnCode(String$*512)
   let ReturnCode$=ReturnCode$&String$&chr$(13)&chr$(10)
fnend

dim RawForm$*10000

def library fnRunTemplate(Template,FileLay$;___,Index)
   let fnEstablishLinkage
   let ReturnCode$=""
   let fnReadEntireLayout(FileLay$,Filename$,Prefix$,Mat Keys$,Mat KeyDescription$,Mat Ssubs$,Mat Nsubs$,Mat Sspec$,Mat Nspec$,Mat Sdescription$,Mat Ndescription$,Mat Spos,Mat Npos)
   let RawForm$=fnReadForm$(FileLay$)
   let LongestElement=0
   for Index=1 to udim(mat SSpec$)
      let LongestElement=max(LongestElement,fnLength(SSpec$(Index)))
   next Index
   for Index=1 to udim(mat NSpec$)
      let LongestElement=max(LongestElement,fnLength(NSpec$(Index)))
   next Index
   for Index=1 to udim(mat SSubs$)
      let SSubs$(Index)=lwrc$(SSubs$(Index))
   next Index
   for Index=1 to udim(mat NSubs$)
      let NSubs$(Index)=lwrc$(NSubs$(Index))
   next Index
   let Prefix$=trim$(Prefix$)
   gosub RunTemplate

   if len(ReturnCode$) then let SetEnv("CLIPBOARD",ReturnCode$)
fnend

RunTemplate: ! Template List gosub statement:
   on Template gosub SetAttr, GetAttr
return

TemplateList: ! Dictionary listing of available functions
   data "SetAttr"
   data "GetAttr"

def library fnTemplateList(mat TemplateDesc$)
   restore TemplateList
   mat TemplateDesc$(2)
   read mat TemplateDesc$
fnend

dim LinkageEstablished
def fnEstablishLinkage
   if ~LinkageEstablished then
      library "fileio" : fnOpenFile, fnClose, fnReadEntireLayout, fnGetFileNumber, fnGetKeyElements, fnLength, fnAskCombo$, fnReadForm$
      let linkageEstablished=1
   end if
fnend
!
! #Autonumber# 99000,10
OPEN: ! ***** Function To Call Library Openfile And Proc Subs
      def Fnopen(Filename$*255, Mat F$, Mat F, Mat Form$; Inputonly, Keynum, Dont_Sort_Subs, Path$*255, Mat Descr$, Mat Field_Widths,Supress_Prompt,Ignore_Errors,___,Index)
         dim _FileIOSubs$(1)*800, _Loadedsubs$(1)*80
         let Fnopen=Fnopenfile(Filename$, Mat F$, Mat F, Mat Form$, Inputonly, Keynum, Dont_Sort_Subs, Path$, Mat Descr$, Mat Field_Widths, Mat _FileIOSubs$, Supress_Prompt,Ignore_Errors,Program$)
         if Srch(_Loadedsubs$,Uprc$(Filename$))<=0 then : mat _Loadedsubs$(Udim(_Loadedsubs$)+1) : let _Loadedsubs$(Udim(_Loadedsubs$))=Uprc$(Filename$) : for Index=1 to Udim(Mat _Fileiosubs$) : execute (_Fileiosubs$(Index)) : next Index
      fnend

Ignore: Continue

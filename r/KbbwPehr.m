KbbwPehr ; VEN/ARC - Patient EHR: RPC 1 ; 2016-04-14 10:27
 ;;1.0;Patient EHR;
 ;;App ver;App name;Patch #s w changes to routine;App release date;KIDS build #?
 ;
 ; Unit tests require that the parameter KBBW PEHR ENABLE exists
 if $t(EN^%ut)'="" do EN^%ut("KbbwPehrRpc",2)
 quit
 ;
STARTUP ; Runs once per routine
 ;
 ; ZEXCEPT: pehrEnabled
 kill pehrEnabled
 new list
 do ENVAL^XPAR(.list,"KBBW PEHR ENABLE",1,.error)
 if list>0 S pehrEnabled=$$PehrEnabled
 else  set pehrEnabled=""
 ;
 quit
 ;
SETUP ; Runs once per test
 ;
 quit
 ;
TEARDOWN ; Runs once per test
 ;
 if pehrEnabled]"" do
 . do CHG^XPAR("PKG","KBBW PEHR ENABLE",1,pehrEnabled,.error)
 ;
 quit
 ;
SHUTDOWN ; Runs once per routine. Probably won't use this.
 ;
 quit
 ;
Status1 ; @TEST Parameter set to "YES"
 ;
 do CHG^XPAR("PKG","KBBW PEHR ENABLE",1,1,.error)
 do CHKTF^%ut($$PehrEnabled)
 ;
 quit
 ;
Status2 ; @TEST Parameter set to "NO"
 ;
 do CHG^XPAR("PKG","KBBW PEHR ENABLE",1,0,.error)
 do CHKTF^%ut('$$PehrEnabled)
 ;
 quit 
 ;
PehrEnabled() ; Is the PEHR enabled?
 ;
 quit $$GET^XPAR("PKG","KBBW PEHR ENABLE",1,"Q")
 ;
UserSettings(requestDuz) ;
 ;ven/arc;test;pseudo-function;messy;silent;non-sac;non-recursive
 ;ven/arc;test/production;procedure/pseudo-function/function;clean/messy;silent/report/dialogue;sac/non-sac;recursive/non-recursive
 ;
 ; UserInfo(.info)
 ; RPC call for basic user/patient info
 ;
 if '$data(U) set U="^"
 ;
 new workingDuz
 set workingDuz=$s($g(requestDuz):requestDuz,$g(DUZ):DUZ,1:0)
 quit:'workingDuz "DUZ not set or specified"
 ;
 ; Supply DUZ and user name
 new info
 set info=$p($g(^VA(200,workingDuz,0)),U)
 ;
 ; Manually check for access to a security key
 ; Pointless in this context
 ; Demonstrated for my benefit
 ;N KEYIEN,SECKEY
 ;S SECKEY=""
 ;S KEYIEN=+$O(^DIC(19.1,"B","KBBWFA",0))
 ; Establish boolean for access to key that allows this RPC
 ;S:KEYIEN SECKEY=$D(^VA(200,workingDuz,51,KEYIEN,0))
 ;
 ; The next question is whether the service is active (boolean)
 set info=info_U_$$PehrEnabled
 ;
 ; If the PEHR service is active, return DFN and name of patient
 ; associated with the user and the default view
 if $p(info,U,2) do
 . set info=info_U_$$UserPatient(workingDuz)
 .;
 . new iens
 . set iens=$o(^KBBW(11345001,"B",workingDuz,0))
 . set info=info_U_$$GET1^DIQ(11345001,iens,.03)
 ;
 quit info
 ;
UserPatient(duz) ;
 ;ven/arc;test;function;clean;silent;non-sac;non-recursive
 ;
 quit:'$g(duz) ""
 ;
 new ien,dfn,ptName
 set ien=+$o(^KBBW(11345001,"B",duz,0))
 ; dfn will be null if user doesn't have a record in KBBW PEHR User Settings
 set dfn=$p(^KBBW(11345001,ien,0),U,2)
 ; Use Fileman call since I don't own this file
 set ptName=$$GET1^DIQ(2,dfn,.01)
 ;
 quit dfn_U_ptName
 ;
 ; The following sub-routines are not intended for use.
 ; They are intended to test and document DBS API calls.
 ;
UserName(iens) ;
 ;
 quit $$GET1^DIQ(11345001,iens,.01)
 ;
FirstAuthUser(ien) ;
 ; Returns the first other user authorized by this user identified with the IEN
 ; to view their patient records
 ;
 new iens
 set iens="1,"_ien_","
 ;
 quit $$GET1^DIQ(11345001.01,iens,.01)
 ;
UserAndPatient(ien)
 ; Returns a user and patient in an FDA
 ;
 new iens
 set iens=ien_","
 ;
 do GETS^DIQ(11345001,iens,.01,,"people")
 do GETS^DIQ(11345001,iens,.02,,"people")
 ;
 quit
 ;
ListAllUsers
 ; Returns a list of all users sorted by name
 do LIST^DIC(11345001,,"@;.01;.02;.03","P",,,,,,,"users","error")
 ;
 quit
 ;
eor ; End of routine KbbwPehr

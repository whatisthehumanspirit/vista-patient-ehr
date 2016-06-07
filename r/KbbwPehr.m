KbbwPehr ; VEN/ARC - Patient EHR: RPC 1 ; 2016-04-14 10:27
 ;;1.0;Patient EHR;
 ;;App ver;App name;Patch #s w changes to routine;App release date;KIDS build #?
 ;
 ; Unit tests require that the parameter KBBW PEHR ENABLE exists
 if $t(EN^%ut)'="" do EN^%ut("KbbwPehr",2)
 quit
 ;
STARTUP ; Runs once per routine
 ;
 ; ZEXCEPT: pehrEnabled
 kill pehrEnabled,error
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
 quit $$GET^XPAR("ALL","KBBW PEHR ENABLE",1,"Q")
 ;
UserSettings(requestDuz) ;
 ;ven/arc;test;function;clean;silent;non-sac;non-recursive
 ;ven/arc;test/production;procedure/pseudo-function/function;clean/messy;silent/report/dialogue;sac/non-sac;recursive/non-recursive
 ;
 if '$data(U) set U="^"
 ;
 new workingDuz
 set workingDuz=$s($g(requestDuz):requestDuz,$g(DUZ):DUZ,1:0)
 quit:'workingDuz "DUZ not set or specified"
 ;
 ; Supply DUZ and user name
 new info
 set info=workingDuz_U_$p($g(^VA(200,workingDuz,0)),U)
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
 if $p(info,U,3) do
 . set info=info_U_$$UserPatient(workingDuz)
 .;
 . new iens
 . set iens=$o(^KBBW(11345001,"B",workingDuz,0))
 . set info=info_U_$$GET1^DIQ(11345001,iens,.03)
 ;
 quit info
 ;
UserPatient(duz) ;
 ;ven/arc;test;pseudo-function;clean;silent;non-sac;non-recursive
 ;
 ; Parameters:
 ; duz : integer
 ;
 ; Outputs:
 ; Returns [DFN]^[patient name]
 ; Sets U
 ;
 quit:'$g(duz) ""
 ;
 if '$data(U) set U="^"
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
AddUser(person,patient) ;
 ;ven/arc;test;pseudo-function;clean;silent;non-sac;non-recursive
 ;
 ; Parameters:
 ; person & patient must be strings -- external values
 ;
 ; Outputs:
 ; Returns a boolean value for success
 ; Sets U
 ; Adds a record to file 11345001
 ;
 ; TODO: Make this an internal call and do the lookups myself on New Person and
 ; patient to avoid problems with duplicate names.
 ;
 set U="^"
 ;
 new record,ien,error
 set record(11345001,"+1,",.01)=person
 set record(11345001,"+1,",.02)=patient
 do UPDATE^DIE("E","record","ien","error")
 ;
 quit:'$d(error) ien(1)
 quit:$d(error) 0
 ;
AddUserDialog() ;
 ;ven/arc;test;pseudo-function;clean;dialogue;non-sac;non-recursive
 ;
 ; Find potential users
 new users,usersError
 do LIST^DIC(200,,"@;.01;","P",,,,,,,"users","usersError")
 quit:'$d(users) 0
 ;
 ; Remove special New Persons from the list
 new i
 set i=0
 for  set i=$o(users("DILIST",i)) quit:'i  do
 . if $p(users("DILIST",i,0),"^",1)<1  do
 .. kill users("DILIST",i)
 ;
 ; Remove existing PEHR users from the list
 set i=0
 for  set i=$o(users("DILIST",i)) quit:'i  do
 . if $d(^KBBW(11345001,"B",$p(users("DILIST",i,0),"^",1)))  do
 .. kill users("DILIST",i)
 ;
 ; List New Persons who can be added
 set i=0
 for  set i=$o(users("DILIST",i)) quit:'i  do
 . write !,$p(users("DILIST",i,0),"^",1),?4,$p(users("DILIST",i,0),"^",2)
 write !!
 ;
 ; Select a New Person
 new userIen
 read !!,"Which user do you wish to add (IEN)? ",userIen:60
 set userIen=+userIen
 quit:'userIen 0
 ;
 new userName
 set userName=$p(users("DILIST",userIen,0),"^",2)
 quit:userName="" 0
 ;
 write !!
 ;
 ; Find potential patients
 new patients,patientsError
 do LIST^DIC(2,,"@;.01;","P",,,,,,,"patients","patientsError")
 quit:'$d(patients) 0
 ;
 ; Remove existing PEHR patients from the list
 set i=0
 for  set i=$o(patients("DILIST",i)) quit:'i  do
 . if $d(^KBBW(11345001,"C",$p(patients("DILIST",i,0),"^",1)))  do
 .. kill patients("DILIST",i)
 ;
 ; Print Patients who can be added
 set i=0
 for  set i=$o(patients("DILIST",i)) quit:'i  do
 . write !,$p(patients("DILIST",i,0),"^",1),?4,$p(patients("DILIST",i,0),"^",2)
 ;
 ; Select a Patient
 new patientIen
 read !!,"Which patient do you wish to add (IEN)? ",patientIen:60
 set patientIen=+patientIen
 quit:'patientIen 0
 ;
 new patientName
 set patientName=$p(patients("DILIST",patientIen,0),"^",2)
 quit:patientName="" 0
 ;
 write !!
 ;
 ;
 quit $$AddUser(userName,patientName)
 ;
AddAuthUser(user,authUser) ;
 ;ven/arc;test;pseudo-function;clean;silent;non-sac;non-recursive
 ;
 ; Parameters:
 ; user & authUser must be strings -- external values
 ;
 ; Outputs:
 ; Returns a boolean value for success
 ; Sets U
 ; Adds a record to subfile 1345001.01
 ;
 if '$data(U) set U="^"
 ;
 new userIen
 set userIen=$$FIND1^DIC(11345001,,"B",user,,,)
 ; Fail if the New Person isn't already a registered PEHR user
 quit:'userIen 0
 ;
 ; Fail if the user to be authorized isn't already a registered PEHR user
 quit:'$$FIND1^DIC(11345001,,"B",authUser,,,) 0
 ;
 new record,ien,error
 set record(11345001.01,"+1,"_userIen_",",.01)=authUser
 do UPDATE^DIE("E","record","ien","error")
 ;
 quit:'$d(error) ien(1)
 quit:$d(error) 0
 ;
DelUser(user) ;
 ;ven/arc;test;pseudo-function;clean;silent;non-sac;non-recursive
 ;
 ; Parameters:
 ; user : string -- user's name, from New Person file
 ;
 ; Outputs:
 ; Returns a boolean value for success
 ; Sets U
 ; Deletes a record from file 11345001
 ;
 if '$data(U) set U="^"
 ;
 new userIen
 set userIen=$$FIND1^DIC(11345001,,"B",user,,,)
 ; Fail if the New Person isn't already a registered PEHR user
 quit:'userIen 0
 ;
 kill error
 new record
 set record(11345001,userIen_",",.01)="@"
 do FILE^DIE(,"record","error")
 ;
 quit:'$d(error) 1
 quit:$d(error) 0
 ;
DelUserDialog() ;
 ;ven/arc;test;pseudo-function;clean;dialogue;non-sac;non-recursive
 ;
 kill error
 do LIST^DIC(11345001,,"@;.01;","P",,,,,,,"users","error")
 ;
 new i
 set i=0
 for  set i=$o(users("DILIST",i)) quit:'i  do
 . write !,i,?2,$p(users("DILIST",i,0),"^",2)
 ;
 new userIndex
 read !!,"Which user do you wish to delete (IEN)? ",userIndex:15
 set userIndex=+userIndex
 quit:'userIndex 0
 ;
 new userName
 set userName=$p(users("DILIST",userIndex,0),"^",2)
 quit:userName="" 0
 quit $$DelUser(userName)
 ;
DelAuthUser(user,authUser) ;
 ;ven/arc;test;pseudo-function;clean;silent;non-sac;non-recursive
 ;
 ; Parameters:
 ; user : string -- user's name, from New Person file
 ; authUser : string -- user's name, from New Person file
 ;
 ; Outputs:
 ; Returns a boolean value for success
 ; Sets U
 ; Deletes a record from subfile 11345001.01
 ;
 if '$data(U) set U="^"
 ;
 new userIen
 set userIen=$$FIND1^DIC(11345001,,"B",user,,,)
 ; Fail if the New Person isn't already a registered PEHR user
 quit:'userIen 0
 ;
 new authUserIen
 set authUserIen=$$FIND1^DIC(11345001.01,","_userIen_",",,authUser,"GS",,)
 ; Fail if the New Person isn't already a registered PEHR user
 quit:'authUserIen 0
 ;
 kill error
 new record
 set record(11345001.01,authUserIen_","_userIen_",",.01)="@"
 do FILE^DIE(,"record","error")
 ;
 quit '$d(error)
 ;
 ;
 ;
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
 kill users,error
 do LIST^DIC(11345001,,"@;.01;.02;.03","P",,,,,,,"users","error")
 ;
 quit
 ;
eor ; End of routine KbbwPehr

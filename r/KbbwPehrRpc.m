KbbwPehrRpc ; VEN/ARC - Patient EHR: RPC 1 ; 2016-04-14 10:27
 ;;1.0;Patient EHR;
 ;;App ver;App name;Patch #s w changes to routine;App release date;KIDS build #?
 ;
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
UserSettings(info) ; UserInfo(.info)
 ;ven/arc;test;pseudo-function;messy;silent;non-sac;non-recursive
 ;
 ; RPC call for basic user/patient info
 ;
 kill info
 quit:'DUZ
 ;
 ; Return DUZ and user name
 set info=DUZ_U_$p($g(^VA(200,DUZ,0)),U)
 ;
 ; Manually check for access to a security key
 ; Pointless in this context
 ; Demonstrated for my benefit
 ;N KEYIEN,SECKEY
 ;S SECKEY=""
 ;S KEYIEN=+$O(^DIC(19.1,"B","KBBWFA",0))
 ; Establish boolean for access to key that allows this RPC
 ;S:KEYIEN SECKEY=$D(^VA(200,DUZ,51,KEYIEN,0))
 ;
 ; The user has already authenticated, so no harm in relaying user name
 ; The next question is whether the service is active (boolean)
 set info=info_U_$$PehrEnabled
 ;
 ; If the PEHR service is active, return DFN and name of patient
 ; associated with the user
 if $p(info,U,3) do
 . set info=info_U_$$UserPatient(DUZ)
 ;
 quit
 ;
UserPatient(duz) ;
 ;ven/arc;test;function;clean;silent;non-sac;non-recursive
 ;
 quit:'$get(duz) ""
 ;
 new ien,dfn,ptName
 set ien=+$o(^KBBW(11345001,"B",duz,0))
 ; dfn will be null if user doesn't have a record in KBBW EHR USER SETTINGS
 set dfn=+$p(^KBBW(11345001,ien,0),U,2)
 ; Use Fileman call since I don't own this file
 set ptName=$$GET1^DIQ(2,dfn,.01,"E")
 ;
 quit dfn_U_ptName
 ;
eor ; End of routine KbbwPehrRpc

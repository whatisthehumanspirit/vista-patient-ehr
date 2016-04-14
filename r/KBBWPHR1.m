KBBWPHR1 ; VEN/ARC - Patient EHR: RPC 1 ; 2016-04-14 10:27
 ;;1.0;PEHR;
 ;;App version;App name;Patch #s w routine changes;App release date;
 ;
 ; Unit tests require that the parameter KBBW PEHR ENABLE exists
 I $T(EN^%ut)'="" D EN^%ut("KBBWPHR1",2)
 Q
 ;
STARTUP ; Runs once per routine
 ; ZEXCEPT: PEHRENBL
 K PEHRENBL
 N list,error
 D ENVAL^XPAR(.list,"KBBW PEHR ENABLE",1,.error)
 I list>0 S PEHRENBL=$$PehrEnabled
 E  S PEHRENBL=""
 Q
 ;
SETUP ; Runs once per test
 Q
 ;
TEARDOWN ; Runs once per test
 I PEHRENBL]"" D
 . D CHG^XPAR("PKG","KBBW PEHR ENABLE",1,PEHRENBL,.ERR)
 Q
 ;
SHUTDOWN ; Runs once per routine. Probably won't use this.
 Q
 ;
ST1 ; @TEST Parameter set to "YES"
 ;
 D CHG^XPAR("PKG","KBBW PEHR ENABLE",1,1,.ERR)
 D CHKTF^%ut($$PehrEnabled)
 Q
 ;
ST2 ; @TEST Parameter set to "NO"
 ;
 D CHG^XPAR("PKG","KBBW PEHR ENABLE",1,0,.ERR)
 D CHKTF^%ut('$$PehrEnabled)
 Q 
 ;
PehrEnabled() ; Is the PEHR enabled?
 ;
 Q $$GET^XPAR("PKG","KBBW PEHR ENABLE",1,"Q")
 ;
UserInfo(INFO) ; RPC call for basic user/patient info (KBBW IDENTIFY USER)
 ;               Pass parameter by reference
 K INFO
 Q:'DUZ
 ;
 ; Return DUZ and user name
 S INFO=DUZ_U_$P($G(^VA(200,DUZ,0)),U)
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
 S INFO=INFO_U_$$PehrEnabled
 ;
 ; If the PEHR service is active, return DFN and name of patient
 ; associated with the user
 I $P(INFO,U,3) D
 S INFO=INFO_U_$$PtInfo(DUZ)
 ;
 Q
 ;
PtInfo(USER) ;
 ;
 Q:'$G(USER) ""
 ;
 N USERIEN,PTDFN,PTNAME
 S USERIEN=+$O(^KBBW(11345001,"B",USER,0))
 ; PTDFN will be null if user doesn't have a record in KBBW EHR USER SETTINGS
 S PTDFN=+$P(^KBBW(11345001,USERIEN,0),U,2)
 ; Use Fileman call since I don't own this file
 S PTNAME=$$GET1^DIQ(2,PTDFN,.01,"E")
 Q PTDFN_U_PTNAME
 ;
EOR ; End of routine KBBWRPC

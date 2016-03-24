KBBWRPC ; VEN/ARC - PATIENT EHR RPC ; 11/5/2015
 ;;1.0;KBBW PEHR;**LOCAL**;NOV 5, 2015
 ;
 I $T(EN^%ut)'="" D EN^%ut("KBBWRPC",2)
 Q
 ;
STARTUP ; Runs once per routine
 Q
 ;
SETUP ; Runs once per test
 Q
 ;
TEARDOWN ; Runs once per test
 Q
 ;
SHUTDOWN ; Runs once per routine. Probably won't use this.
 Q
 ;
ST1 ; @TEST Check existence of parameter
 N list,error
 S list="",error=""
 D ENVAL^XPAR(.list,"KBBW PEHR ENABLE",1,.error)
 N x S x=(list>0) 
 D CHKEQ^%ut(x,1)
 K list,error,x
 Q
 ;
ST2 ;
 ;D CHG^XPAR("PKG","KBBW PEHR ENABLE",1,0,.ERR)
 ;
STATUS() ; Is the PEHR enabled?
 Q $$GET^XPAR("PKG","KBBW PEHR ENABLE",1,"Q")
 ;
PATIENT(PT) ; RPC call for basic user/patient info [RPC broker call name]
 ;            So pass parameter by reference
 K PT
 Q:'DUZ
 S PT=DUZ_U_$P($G(^VA(200,DUZ,0)),U)_U
 N KEYIEN,SECKEY
 S SECKEY=""
 S KEYIEN=+$O(^DIC(19.1,"B","KBBWFA",0))
 S:KEYIEN SECKEY=$D(^VA(200,DUZ,51,KEYIEN,0))
 S PT=PT_SECKEY_U_$$STATUS_U
 Q
 ;
EOR ; End of routine KBBWRPC

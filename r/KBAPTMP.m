KBAPTMP ; VEN/ARC&POO - Cross references ; 2/25/16 3:42pm
 ;;1.0;;
 ;
 ; ENTER
 ;  USRAUTH  = IEN in 200 authorizing person
 ;  USRALLOW = IEN in 11312001 person being 
 ;             allowed to see authorizing's patient
 ; EXIT
 ;  PATIENT added to ALLOWED PATIENTS 
AUTHPT(USRAUTH,USRALLOW) ;
 Q:'$G(USRAUTH)
 Q:'$G(USRALLOW)
 ; Find IEN of authorizing user in 11312001
 S USERIEN=$O(^KBAP(11312001,"B",USRAUTH,0))
 N DIERR,DIE,FDA,PATIENT
 ; Get default patient for the user authorizing
 S PATIENT=$P(^KBAP(11312001,USRALLOW,0),"^",2)
 S FDA(3,11312001.02,"?+2,"_USERIEN_",",.01)=PATIENT
 D UPDATE^DIE("","FDA(3)")
 Q
 ;

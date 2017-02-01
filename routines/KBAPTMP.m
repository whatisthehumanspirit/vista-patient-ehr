KBAPTMP ; VEN/ARC&POO - Cross references ; 2/25/16 3:42pm
 ;;1.0;;
 ;
 ; Refactored to instruct and pass XINDEX
 ; VARIABLES
 ;    SCHDDT  = DateTime to run scheduled event ( $h in seconds)
 ;    TASKIEN = Task Number
 ;    LSTUPDT = Last update to $h for task for today
 ;    TSKDESC =  Task description 
 ;    TSKERTN = Task entry linetag and routine
 ; Enter:
 ;    nothing
 ; Exit:
 ;    array of tasks scheduled for today
 ;   XTASKS(task number,description or entrypoint and routine)=""
TDAYTSK(XTASKS) ; Return array of today's tasks
 K POO
 N SCHDDT,TASKIEN,LSTUPDT,TSKDESC,TSKERTN
 S SCHDDT=0
 F  S SCHDDT=$O(^%ZTSCH(SCHDDT)) Q:'SCHDDT  D
 . S TASKIEN=$O(^%ZTSCH(SCHDDT,""))
 . Q:'$D(^%ZTSK(TASKIEN))
 . S LSTUPDT=$P(^%ZTSK(TASKIEN,.1),"^",2)
 . I +LSTUPDT=+$H D
 .. S TSKDESC=$G(^%ZTSK(TKSIEN,.03))
 .. S TSKERTN=$P(^%ZTSK(TASKIEN,0),"^",1,2)
 .. S XTASKS(TASKIEN,$S(TSKDESC'="":TSKDESC,1:TSKERTN))=""
 Q
 ;
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
 ;
 ; Pull patient lab data
 ; Call as D PTLABS^KBAPTMP(DFN,ARRAY,CNT)
 ; ENTER
 ;    DFN    = IEN of patient in file 2
 ;    ARRAY  = Name of the array
 ;    TOTAL  = Number of tests to return (default = 20)
 ; RETURNS
 ;    ARRAY  = array with information on tests 
 ;             Tests will be in newest to oldest order
PTLABS(DFN,LABSARR,TOTAL) ;
 K @LABSARR
 Q:'$G(DFN)
 S:(+$G(TOTAL)=0) TOTAL=20
 ; Quit if patient has not had any lab tests
 Q:'$G(^DPT(DFN,"LR"))
 N LRDFN S LRDFN=$G(^DPT(DFN,"LR"))
 Q:'$P($G(^LR(LRDFN,0)),"^",3)
 ; Let's return the 10 most recent chemistry tests info
 N CNT,LRIDT,LRUID,NODE,NODE0,LRAA,LRAD,LRAN,LRTSTIEN,LRTSTN,LRTSTD
 S (CNT,LRIDT)=0
 F  S LRIDT=$O(^LR(LRDFN,"CH",LRIDT)) Q:'LRIDT  D  Q:CNT>=TOTAL
 . S LRUID=$P($G(^LR(LRDFN,"CH",LRIDT,"ORU")),"^") 
 . Q:LRUID=""
 . S CNT=CNT+1
 . S NODE0=$G(^LR(LRDFN,"CH",LRIDT,0))
 . S @LABSARR@(CNT,"LRUID")=$G(LRUID)
 . S @LABSARR@(CNT,"DATE/TIME")=$$FMTE^XLFDT(+NODE0)
 . S @LABSARR@(CNT,"SPECIMEN")=$$GET1^DIQ(61,$P(NODE0,"^",5),.01,"E")
 . S NODE=$NA(^LRO(68,"C",LRUID)),NODE=$Q(@NODE)
 . S LRAA=$QS(NODE,4)
 . S LRAD=$QS(NODE,5)
 . S LRAN=$QS(NODE,6)
 . S LRTSTIEN=$O(^LRO(68,LRAA,1,LRAD,1,LRAN,4,0))
 . S LRTSTN=$$GET1^DIQ(60,LRTSTIEN,.01)
 . S LRTSTD=$P($$GET1^DIQ(60,LRTSTIEN,5),";",2)
 . S @LABSARR@(CNT,"TEST")=LRTSTN
 . S @LABSARR@(CNT,"RESULT")=$P($G(^LR(LRDFN,"CH",LRIDT,LRTSTD)),"^")
 Q

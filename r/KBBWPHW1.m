KBBWPHW1 ; VEN/ARC - Patient EHR: Fileman Web 1 ; 2016-04-14 11:22
 ;;1.0;PEHR;
 ;
 ;
UserPt(html,FILTER) ;
 ;ven/arc;test;pseudo-function;messy;silent;sac;non-recursive
 if '$D(html) set html=$NA(^TMP("pehrhtml",$J))
 kill @html
 ;
 new htmlTop,htmlBottom
 do HTMLTB^KBAIWEB(.htmlTop,.htmlBottom,"PEHR Test")
 merge @html=htmlTop
 ;
 new ien
 set ien=$G(FILTER("ien"))
 if ien="" set ien=1
 ;
 new fileArray
 do FMX^KBAIWEB("fileArray",11345001,ien)
 ;
 new tableArray
 set tableArray("HEADER",1)="User"
 set tableArray("HEADER",2)="Patient"
 set tableArray("TITLE")="File 11345001"
 set tableArray(1,1)=fileArray("KBBW_EHR_USER_SETTINGS","User")
 set tableArray(1,2)=fileArray("KBBW_EHR_USER_SETTINGS","Patient")
 ;
 do GENHTML2^KBAIUTIL(html,"tableArray")
 set @html@($O(@html@(""),-1)+1)=htmlBottom
 ;
 kill @html@(0)
 ;
 set HTTPRSP("mime")="text/html"
 ;
 quit
 ;
PTINFO(html,FILTER) ;
 ;ven/arc;test;pseudo-function;messy;silent;sac;non-recursive
 K ^TMP("ALEXIS")
 M ^TMP("ALEXIS")=DUZ
 ;D DUZ^XUP(DUZ)
 I '$D(html) S html=$NA(^TMP("pehrhtml",$J))
 K @html
 N GTOP,GBOT
 D HTMLTB^KBAIWEB(.GTOP,.GBOT,"PEHR Test")
 M @html=GTOP
 ;S DUZ=$G(FILTER("duz"))
 ;I DUZ="" S DUZ=1
 S U="^"
 N INFO
 ;K DUZ("AUTO")
 ;D USERINFO^KBBWRPC(.INFO)
 ;M ^TMP("ALEXIS")=INFO
 ;N DFN S DFN=+$P(INFO,U,4)
 N USERIEN,PTDFN
 S USERIEN=$O(^KBBW(11345001,"B",57,0))
 M ^TMP("ALEXIS")=DUZ
 M ^TMP("ALEXIS")=USERIEN
 S PTDFN=$P(^KBBW(11345001,2,0),U,2)
 N filearray,dataarray
 D FMX^KBAIWEB("filearray",2,PTDFN)
 M ^TMP("ALEXIS")=filearray
 S dataarray("HEADER",1)="Name"
 S dataarray("HEADER",2)="Date Of Birth"
 S dataarray("HEADER",3)="Age"
 S dataarray("TITLE")="User's Patient Info"
 S dataarray(1,1)=filearray("PATIENT","NAME")
 S dataarray(1,2)=filearray("PATIENT","DATE_OF_BIRTH")
 S dataarray(1,3)=filearray("PATIENT","AGE")
 D GENHTML2^KBAIUTIL(html,"dataarray")
 S @html@($O(@html@(""),-1)+1)=GBOT
 K @html@(0)
 S HTTPRSP("mime")="text/html"
 Q
 ;
EOR ; End of routine KBBWPHW1

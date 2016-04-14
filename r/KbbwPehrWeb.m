KbbwPehrWeb ; VEN/ARC - Patient EHR: Fileman Web 1 ; 2016-04-14 11:22
 ;;1.0;Patient EHR;
 ;
 ;
UserPt(html,FILTER) ;
 ;ven/arc;test;pseudo-function;messy;silent;sac;non-recursive
 ;
 if '$d(html) set html=$na(^TMP("pehrhtml",$J))
 kill @html
 ;
 new htmlTop,htmlBottom
 do HTMLTB^KBAIWEB(.htmlTop,.htmlBottom,"PEHR Test")
 merge @html=htmlTop
 ;
 new ien
 set ien=$g(FILTER("ien"))
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
 set @html@($o(@html@(""),-1)+1)=htmlBottom
 ;
 kill @html@(0)
 ;
 set HTTPRSP("mime")="text/html"
 ;
 quit
 ;
PtInfo(html,FILTER) ;
 ;ven/arc;test;pseudo-function;messy;silent;sac;non-recursive
 ;
 if '$d(html) set html=$na(^TMP("pehrhtml",$J))
 kill @html
 ;
 new htmlTop,htmlBottom
 do HTMLTB^KBAIWEB(.htmlTop,.htmlBottom,"PEHR Test")
 merge @html=htmlTop
 ;
 set DUZ=$g(FILTER("duz"))
 if DUZ="" set DUZ=1
 ;
 set U="^"
 new info,dfn
 do UserInfo^KbbwPehrRpc(.info)
 set dfn=+$(info,U,4)
 ;
 new fileArray
 do FMX^KBAIWEB("fileArray",2,dfn)
 ;
 new tableArray
 set tableArray("HEADER",1)="Name"
 set tableArray("HEADER",2)="Date Of Birth"
 set tableArray("HEADER",3)="Age"
 set tableArray("TITLE")="User's Patient Info"
 set tableArray(1,1)=fileArray("PATIENT","NAME")
 set tableArray(1,2)=fileArray("PATIENT","DATE_OF_BIRTH")
 set tableArray(1,3)=fileArray("PATIENT","AGE")
 ;
 do GENHTML2^KBAIUTIL(html,"tableArray")
 set @html@($o(@html@(""),-1)+1)=htmlBottom
 ;
 kill @html@(0)
 ;
 set HTTPRSP("mime")="text/html"
 ;
 quit
 ;
EOR ; End of routine KbbwPehrWeb

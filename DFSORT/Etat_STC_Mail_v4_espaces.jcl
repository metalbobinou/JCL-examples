//GJSDSFE JOB MSGLEVEL=1,CLASS=A,MSGCLASS=Y,NOTIFY=&SYSUID                      
//*******************************************************                       
//*                                                     *                       
//*  JOB INTERROGATION SDSF SUR ETAT E-GEN + ENVOI MAIL *                       
//*                                                     *                       
//*******************************************************                       
// SET FILE1=MON.FILE1
// SET FILE2=MON.FILE2                                                  
//*                                                                             
//*********************                                                         
//* RECUPERATION SDSF *                                                         
//*********************                                                         
//SDSFREQ  EXEC PGM=SDSF                                                        
//SYSOUT   DD SYSOUT=*                                                          
//ISFOUT   DD DSN=&FILE1,                                                       
//            DCB=(RECFM=FB,LRECL=200,BLKSIZE=200),                             
//            SPACE=(TRK,(5,2),RLSE),                                           
//            DISP=(NEW,PASS,DELETE)                                            
//ISFIN    DD *                                                                 
O=                                                                              
PRE NOTHING                                                                     
DA                                                                              
ARR REAL A OWNER                                                                
ARR ECPU-TIME A REAL                                                            
PRE LOL*                                                                        
/*                                                                              
//*                                                                             
//*************************                                                     
//* EXTRACTION DES LIGNES *                                                     
//*************************                                                     
//CATGREP  EXEC PGM=SORT                                                        
//SYSOUT   DD SYSOUT=*                                                          
//SORTOUT  DD DSN=&FILE2,                                                       
//            DCB=(RECFM=FB,LRECL=200,BLKSIZE=200),                             
//            SPACE=(TRK,(1,1),RLSE),                                           
//            DISP=(NEW,PASS,DELETE)                                            
//SORTIN   DD DSN=&FILE1,                                                       
//            DISP=(MOD,DELETE,DELETE)                                          
//SYSIN    DD *                                                                 
 SORT FIELDS=COPY                                                               
 INCLUDE COND=(1,80,SS,EQ,C'LOL')                                               
/*                                                                              
//*                                                                             
//********************************************                                  
//* ENCADREMENT DES LIGNES                   *                                  
//* SI + DE 2500 PAGES (REAL) : OK, SINON KO *                                  
//********************************************                                  
//CUTPASTE EXEC PGM=SORT                                                        
//SYSOUT   DD SYSOUT=*                                                          
//SORTOUT  DD DSN=&FILE1,                                                       
//            DCB=(RECFM=FB,LRECL=200,BLKSIZE=200),                             
//            SPACE=(TRK,(1,1),RLSE),                                           
//            DISP=(NEW,PASS,DELETE)                                            
//SORTIN   DD DSN=&FILE2,                                                       
//            DISP=(MOD,DELETE,DELETE)                                          
//SYSIN    DD *                                                                 
 INREC FIELDS=(1:8,7,                                                           
               9:26,7,                                                          
               17:35,8,                                                         
               26:44,4,                                                         
               31:51,6,                                                         
               38:62,6)                                                         
 OUTREC IFTHEN=(WHEN=(31,6,ZD,GT,2500),                                         
   BUILD=(1,43,44:C' OK',164X)),                                                
   IFTHEN=(WHEN=NONE,                                                           
     BUILD=(1,43,44:C' KO',164X))                                               
 SORT FIELDS=(1,7,CH,A)                                                         
/*                                                                              
//*  1:8,7 => ECRITURE EN SORTIE COL 1 DEPUIS ENTREE COL 8 SUR 7 CHARS          
//*                                                                             
//*****************************                                                 
//* HTMLISATION DES RESULTATS *                                                 
//*****************************                                                 
//TOHTML   EXEC PGM=SORT                                                        
//SYSOUT   DD SYSOUT=*                                                          
//SORTOUT  DD DSN=&FILE2,                                                       
//            DCB=(RECFM=FB,LRECL=200,BLKSIZE=200),                             
//            SPACE=(TRK,(1,1),RLSE),                                           
//            DISP=(NEW,PASS,DELETE)                                            
//SORTIN   DD DSN=&FILE1,                                                       
//            DISP=(MOD,DELETE,DELETE)                                          
//SYSIN    DD *                                                                 
 SORT FIELDS=COPY                                                               
 INREC IFTHEN=(WHEN=(45,2,CH,EQ,C'OK'),                                         
   BUILD=(1,44,45:C'<FONT COLOR="GREEN">OK</FONT></TR>',128X)),                 
   IFTHEN=(WHEN=NONE,                                                           
     BUILD=(1,44,45:C'<FONT COLOR="RED">KO</FONT></TR>',124X))                  
 OUTREC BUILD=(C'<TR><TD>',                                                         
               1,7,C'</TD><TD>',                                                
               9,7,C'</TD><TD>',                                                
               17,8,C'</TD><TD>',                                               
               26,4,C'</TD><TD>',                                               
               31,6,C'</TD><TD>',                                               
               38,6,C'</TD><TD>',                                               
               44,100)                                                          
/*                                                                              
//*                                                                             
//****************************                                                  
//* PREPARATION EN-TETE MAIL *                                                  
//****************************                                                  
//HMAIL1   EXEC PGM=ICEGENER                                                    
//SYSIN    DD  DUMMY                                                            
//SYSPRINT DD  SYSOUT=*                                                         
//SYSUT2   DD  DSN=&&HEADTMP1,                                                  
//             DCB=(RECFM=FB,LRECL=200,BLKSIZE=200),                            
//             SPACE=(TRK,1),                                                   
//             DISP=(NEW,PASS,DELETE)                                           
//SYSOUT   DD  SYSOUT=*                                                         
//SYSUT1   DD *                                                                 
HELO SERVER                                       
MAIL FROM:<fromàserver.com>                 
RCPT TO:<toàserver.com>  
DATA                                                
FROM: MOI<fromàserver.com>                 
TO: <toàserver.com>      
SUBJECT: ETAT STC LOL                        
CONTENT-TYPE: MULTIPART/MIXED; BOUNDARY="SEPARATEUR"                            
MIME-VERSION: 1.0                                                               
                                                                                
--SEPARATEUR                                                                    
CONTENT-TYPE: TEXT/HTML; CHARSET=ISO-8859-1                                     
                                                                                
<HTML>                                                                          
<HEAD>                                                                          
</HEAD>                                                                         
<BODY BGCOLOR="WHITE" TEXT="BLACK">                                             
STC LOL ACTUELLEMENT DEMARREES :    
<BR><BR>                                                                        
<TABLE>                                                                         
<TR>                                                                            
<TD>JOBNAME</TD><TD>PROCSTEP</TD><TD>JOBID</TD>                                 
<TD>OWNER</TD><TD>MEMORY</TD><TD>ECPU</TD><TD>STATE</TD>                        
</TR>                                                                           
/*                                                                              
//*                                                                             
//************************                                                      
//* SUPPRESS POUR BLANCS *                                                      
//************************                                                      
//HMAIL2   EXEC PGM=SORT                                                        
//SYSOUT   DD SYSOUT=*                                                          
//SORTOUT  DD DSN=&&HEADTMP2,                                                   
//            DCB=(RECFM=FB,LRECL=200,BLKSIZE=200),                             
//            SPACE=(TRK,(1,1),RLSE),                                           
//            DISP=(NEW,PASS,DELETE)                                            
//SORTIN   DD DSN=&&HEADTMP1,                                                   
//            DISP=(MOD,DELETE,DELETE)                                          
//SYSIN    DD *                                                                 
 SORT FIELDS=COPY                                                               
 OUTREC BUILD=(1,80,120X)                                                       
/*                                                                              
//*                                                                             
//****************************                                                  
//* PREPARATION EN-PIED MAIL *                                                  
//****************************                                                  
//FMAIL1   EXEC PGM=ICEGENER                                                    
//SYSIN    DD  DUMMY                                                            
//SYSPRINT DD  SYSOUT=*                                                         
//SYSUT2   DD  DSN=&&FOOTTMP1,                                                  
//             DCB=(RECFM=FB,LRECL=200,BLKSIZE=200),                            
//             SPACE=(TRK,1),                                                   
//             DISP=(NEW,PASS,DELETE)                                           
//SYSOUT   DD  SYSOUT=*                                                         
//SYSUT1   DD *                                                                 
</TABLE>                                                                        
</BODY>                                                                         
</HTML>                                                                         
.                                                                               
QUIT                                                                            
/*                                                                              
//*                                                                             
//************************                                                      
//* SUPPRESS POUR BLANCS *                                                      
//************************                                                      
//FMAIL2   EXEC PGM=SORT                                                        
//SYSOUT   DD SYSOUT=*                                                          
//SORTOUT  DD DSN=&&FOOTTMP2,                                                   
//            DCB=(RECFM=FB,LRECL=200,BLKSIZE=200),                             
//            SPACE=(TRK,(1,1),RLSE),                                           
//            DISP=(NEW,PASS,DELETE)                                            
//SORTIN   DD DSN=&&FOOTTMP1,                                                   
//            DISP=(MOD,DELETE,DELETE)                                          
//SYSIN    DD *                                                                 
 SORT FIELDS=COPY                                                               
 OUTREC BUILD=(1,80,120X)                                                       
/*                                                                              
//*                                                                             
//******************                                                            
//* ENVOI PAR MAIL *                                                            
//******************                                                            
//SMAIL    EXEC PGM=ICEGENER                                                    
//SYSIN    DD  DUMMY                                                            
//SYSPRINT DD  SYSOUT=*                                                         
//SYSUT2   DD  SYSOUT=(B,SMTP)                                                  
//SYSOUT   DD  SYSOUT=*                                                         
//SYSUT1   DD  DSN=&&HEADTMP2,                                                  
//             DCB=(RECFM=FB,LRECL=200,BLKSIZE=200),                            
//             DISP=(MOD,DELETE,DELETE)                                         
//         DD  DSN=&FILE2,                                                      
//             DCB=(RECFM=FB,LRECL=200,BLKSIZE=200),                            
//             DISP=(MOD,DELETE,DELETE)                                         
//         DD  DSN=&&FOOTTMP2,                                                  
//             DCB=(RECFM=FB,LRECL=200,BLKSIZE=200),                            
//             DISP=(MOD,DELETE,DELETE)                                         
//*                                                                             

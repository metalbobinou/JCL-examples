//MYRUN    JOB CLASS=A,MSGLEVEL=(1,1),MSGCLASS=A,REGION=0M,   
//         NOTIFY=&SYSUID,TIME=30                             
//* SET FICHIER=HELLOC                                        
//* SET FICHIER=TESTFD                                        
//  SET FICHIER=CHICOU$Z                                      
//RUNPRM   EXEC PGM=&FICHIER,                                 
//             PARM='ADCDA.TEST',                             
//             REGION=0M                                      
//STEPLIB  DD DSN=ADCDA.MALIB.OUT,DISP=SHR                    
//*CONFIG   DD DSN=ADCDA.TEST,DISP=SHR                        
//DEPENS   DD DSN=ADCDA.MALIB.DATA.IN.DEP$JAN,DISP=SHR        
//SORTIE   DD DSN=ADCDA.MALIB.DATA.OUT.TOTAL,DISP=SHR         
//*SYSWORK  DD DSN=&&TEMP,DISP=(NEW,PASS,)                    
//SYSPRINT DD SYSOUT=*                                        
//SYSUDUMP DD SYSOUT=*       
//SYSABEND DD SYSOUT=*       
//SYSCPRTT DD SYSOUT=*       
//SYSOUT   DD SYSOUT=*       
//RUN      JOB CLASS=A,MSGLEVEL=(1,1),MSGCLASS=A,REGION=0M,
//         NOTIFY=&SYSUID,TIME=30                          
//  SET FICHIER=HELLOC                                     
//RUNPRM   EXEC PGM=&FICHIER,REGION=0M                     
//STEPLIB  DD DSN=ADCDA.MALIB.OUT,DISP=SHR                 
//*CONFIG   DD DSN=ADCDA.MALIB..CONFIG,DISP=SHR            
//SYSPRINT DD SYSOUT=*                                     
//SYSUDUMP DD SYSOUT=*                                     
//SYSABEND DD SYSOUT=*                                     
//SYSCPRTT DD SYSOUT=*                                     
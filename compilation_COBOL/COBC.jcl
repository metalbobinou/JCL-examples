//COBCOMP  JOB CLASS=A,MSGLEVEL=(1,1),MSGCLASS=1,REGION=0M,  
//         NOTIFY=&SYSUID,TIME=30                            
//  SET FICHIER=CHICOU$Z                                     
//*                                                          
//* *********************************************************
//* * COMPILE IGYCRCTL 'DYN,DATA(31),LIST,NOOFF,NOFASTSRT'  *
//* *********************************************************
//*                                                          
//COMPILE  EXEC PGM=IGYCRCTL,                                
//         PARM='DYN,DATA(31),LIST,NOOFF,NOFASTSRT'          
//STEPLIB  DD   DSNAME=IGY410.SIGYCOMP,DISP=SHR              
//SYSPRINT DD   SYSOUT=*                                     
//SYSLIN   DD   DSN=ADCDA.MALIB.OBJ(&FICHIER),DISP=SHR       
//SYSUT1   DD   UNIT=3390,SPACE=(CYL,(1,1))                           
//SYSUT2   DD   UNIT=3390,SPACE=(CYL,(1,1))                         
//SYSUT3   DD   UNIT=3390,SPACE=(CYL,(1,1))                         
//SYSUT4   DD   UNIT=3390,SPACE=(CYL,(1,1))                         
//SYSUT5   DD   UNIT=3390,SPACE=(CYL,(1,1))                         
//SYSUT6   DD   UNIT=3390,SPACE=(CYL,(1,1))                         
//SYSUT7   DD   UNIT=3390,SPACE=(CYL,(1,1))                         
//SYSIN    DD   DSN=ADCDA.MALIB.COBOL(&FICHIER),DISP=SHR            
//*                                                                 
//* ************************************************************    
//* * LINK IEWL 'OPTIONS=OPTS'                                 *    
//* ************************************************************    
//*                                                                 
//LINK     EXEC PGM=IEWL,PARM='OPTIONS=OPTS'                        
//OPTS DD *                                               
     AMODE=31,MAP                                         
     NORENT,DYNAM=DLL                                     
     CASE=MIXED                                           
/*                                                        
//*SYSLIB   DD   DSN=SYS1.COB2LIB,DISP=SHR                
//*         DD   DSN=SYS1.COB2COMP,DISP=SHR               
//SYSLIB   DD   DSN=IGY410.SIGYCOMP,DISP=SHR              
//         DD   DSN=IGY410.SIGYPROC,DISP=SHR              
//         DD   DSN=SYS1.LINKLIB,DISP=SHR                 
//         DD   DSN=CEE.SCEELKED,DISP=SHR                 
//SYSLMOD  DD   DSN=ADCDA.MALIB.OUT(&FICHIER),DISP=SHR    
//SYSTERM  DD   SYSOUT=*                                  
//SYSPRINT DD   SYSOUT=*                                  
//SYSLIN   DD   DSN=ADCDA.MALIB.OBJ(&FICHIER),DISP=SHR    
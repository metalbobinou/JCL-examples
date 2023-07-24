//COMPILNK JOB CLASS=A,MSGLEVEL=(1,1),MSGCLASS=X,REGION=0M,         
//         NOTIFY=&SYSUID,TIME=30                                   
// SET FICHIER=HELLOC                                               
//*                                                                 
//***************************************************************** 
//** COMPILE CCNDRVR '/SEARCH(''CEE.SCEEH.+'') NOOPT SO OBJ LIST' * 
//***************************************************************** 
//*                                                                 
//COMPILE EXEC PGM=CCNDRVR,                                         
//        PARM='/SEARCH(''CEE.SCEEH.+'') NOOPT SO OBJ LIST'         
//STEPLIB DD DSNAME=CEE.SCEERUN,DISP=SHR                            
//        DD DSNAME=CEE.SCEERUN2,DISP=SHR                           
//        DD DSNAME=CBC.SCCNCMP,DISP=SHR                            
//SYSPRINT DD SYSOUT=*                                              
//SYSCPRTT DD SYSOUT=*                                           
//*SYSLIB DD DSN=ADCDA.MALIB.C,DISP=SHR                          
//*      DD DISP=SHR,DSN=TCPIP.SEZACMAC                          
//*      DD DISP=SHR,DSN=CEE.SCEEH.H                             
//*USERLIB DD DSN=ADCDA.MALIB.C,DISP=SHR                         
//SYSIN  DD DSN=ADCDA.MALIB.C(&FICHIER),DISP=SHR                 
//SYSLIN DD DSN=ADCDA.MALIB.OBJ(&FICHIER),DISP=SHR               
//*                                                              
//**************************************************             
//**  BIND1  IEWL 'OPTIONS=OPTS'                   *             
//**************************************************             
//*                                                              
//BIND1 EXEC PGM=IEWL,PARM='OPTIONS=OPTS'                        
//OPTS DD *                                                      
     AMODE=31,MAP                                                
     NORENT,DYNAM=DLL                                            
	 CASE=MIXED                                            
/*                                                         
//SYSLIB DD DISP=SHR,DSN=CEE.SCEELKEX                      
//       DD DISP=SHR,DSN=TCPIP.SEZACMTX                    
//       DD DISP=SHR,DSN=CEE.SCEELKED                      
//       DD DISP=SHR,DSN=CEE.SCEECPP                       
//       DD DISP=SHR,DSN=SYS1.CSSLIB                       
//SYSLIN DD DISP=SHR,DSN=ADCDA.MALIB.OBJ(&FICHIER)         
//*      DD DISP=SHR,DSN=SYS1.MDALBIN.PROG.OBJ(EDSATT)     
//*      DD DISP=SHR,DSN=SYS1.MDALBIN.PROG.OBJ(WAIT)       
//*      DD DISP=SHR,DSN=SYS1.MDALBIN.PROG.OBJ(STOP0C1)    
//       DD DISP=SHR,DSN=CBC.SCLBSID(IOSTREAM)             
//SYSLMOD DD DISP=SHR,DSN=ADCDA.MALIB.OUT(&FICHIER)        
//SYSPRINT DD SYSOUT=*       
//*
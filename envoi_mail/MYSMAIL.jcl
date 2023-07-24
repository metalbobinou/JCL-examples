//MYSMAIL JOB MSGLEVEL=1,CLASS=I,MSGCLASS=Y,NOTIFY=&SYSUID
//***************************************************
//** JOB D ENVOI DE MAIL *
//***************************************************
//MAIL EXEC PGM=ICEGENER
//SYSIN DD DUMMY
//SYSPRINT DD SYSOUT=*
//SYSUT2 DD SYSOUT=(A,SMTP)
//SYSOUT DD SYSOUT=*
//SYSUT1 DD *
HELO MYSERVERNAME
MAIL FROM:<egen@server.com>
RCPT TO:<fabrice@server.com>
DATA
FROM: EGEN<egen@server.com>
TO: <fabrice@server.com>
SUBJECT: TEST MAIL

CECI EST LE CORPS DU MAIL

.
QUIT
/*
//*
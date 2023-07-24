//VERIFSTC JOB MSGLEVEL=1,CLASS=A,MSGCLASS=B,NOTIFY=&SYSUID,
//         REGION=32M
//****************************************************************
//*                                                              *
//*  JOB INTERROGATION SDSF SUR ETAT STC + ENVOI MAIL            *
//*  V1.0 - BOISSIE - 14/03/2014                                 *
//*                                                              *
//* ]]]]] ATTENTION UN FICHIER EST EN DUR AU STEP SDSFLOG ]]]]]  *
//*   ]]] IL EST EN SYSIN DONC IMPOSSIBLE A VARIABILISER ]]]     *
//*                                                              *
//* MODIFS MANUELLES (EN FONCTION DES HORAIRES) :                *
//* - LIGNE 32 & 52 : PREFIXE PROG* (PROG1/PROG2...)             *
//* - LIGNE 68 & 69 : DATASET SORTIE + HORAIRES DEMARRAGE STC    *
//* - LIGNE 105 : ERREUR ERREUR404 A RECHERCHER + DATE DE LA LOG *
//* - LIGNE 193 ET + : SERVEUR SMTP Z/OS + ADRESSE MAIL DST      *
//*                                                              *
//****************************************************************
// SET FILE1=MY.FILE1
// SET FILE2=MY.FILE2
// SET FILE3=MY.FILE3
//*
//************************
//* RECUPERATION SDSF DA *
//************************
//SDSFDA   EXEC PGM=SDSF
//ISFIN    DD *
O=
PRE NOTHING
DA
ARR REAL A OWNER
ARR ECPU-TIME A REAL
PRE PROG*
/*
//ISFOUT   DD DSN=&FILE1,
//            DCB=(RECFM=FB,LRECL=200,BLKSIZE=0),
//            SPACE=(TRK,(5,2),RLSE),
//            DISP=(NEW,PASS,DELETE)
//SYSOUT   DD SYSOUT=*
//*
//*************************
//* EXTRACTION DES LIGNES *
//*************************
//CATGREP  EXEC PGM=SORT
//SORTIN   DD DSN=&FILE1,
//            DISP=(OLD,DELETE,DELETE)
//SORTOUT  DD DSN=&FILE2,
//            SPACE=(TRK,(1,1),RLSE),
//            DISP=(NEW,PASS,DELETE)
//SYSOUT   DD SYSOUT=*
//SYSIN    DD *
 SORT FIELDS=(1,7,CH,A)
 INCLUDE COND=(1,80,SS,EQ,C'PROG')
 INREC FIELDS=(1:8,7,
               9:26,7,
               17:35,8,
               26:44,4,
               31:51,6,
               38:62,6)
 OUTREC BUILD=(1,43,167X)
/*
//*
//*************************
//* RECUPERATION SDSF LOG *
//*************************
//SDSFLOG  EXEC PGM=SDSF
//ISFIN    DD *
LOG
PRINT ODSN 'MY.FILE1' * MOD
PT 00.59.00 02.00.00
PRINT CLOSE
/*
//ISFOUT   DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//*
//*******************
//* VB TO FB PROPRE *
//*******************
//VBTOFB   EXEC PGM=IEBGENER
//SYSUT1   DD DSN=&FILE1,
//            DISP=(OLD,DELETE,DELETE)
//SYSUT2   DD DSN=&FILE3,
//            DCB=(RECFM=FB,LRECL=240,BLKSIZE=0),
//            SPACE=(CYL,(5,2),RLSE),
//            DISP=(NEW,PASS,DELETE)
//SYSOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  GENERATE MAXFLDS=1
  RECORD FIELD=(240,1,,1)
/*
//*
//****************
//* FILTRAGE LOG *
//****************
//GREPLOG  EXEC PGM=SORT
//SORTIN   DD DSN=&FILE3,
//            DISP=(OLD,DELETE,DELETE)
//SORTOUT  DD DSN=&FILE1,
//            SPACE=(CYL,(5,1),RLSE),
//            DISP=(NEW,PASS,DELETE)
//SYSOUT   DD SYSOUT=*
//SYSIN    DD *
 SORT FIELDS=COPY
 INCLUDE COND=(23,5,Y2T,EQ,Y'DATE3',AND,
               1,240,SS,EQ,C'ERREUR404')
 OUTFIL OUTREC=(12,5,
                21,8,
                29,12,
                41,9,
                60,120,
                86X)
/*
//* POUR VERIFIER DATE DU JOUR & ERREUR :
//* INCLUDE COND=(23,5,Y2T,EQ,Y'DATE3',AND,
//*               1,240,SS,EQ,C'ERREUR404')
//* POUR VERIFIER DATE DE LA VEILLE OU D'APRES :
//*                           Y'DATE3+1' OU -1 (JUSQUE 20)
//* MSG EXACT : 'ERREUR404 PAGE NOT FOUND'
//*
//************
//* JOIN STC *
//************
//JOINLOGS EXEC PGM=SORT
//SORTJNF1 DD DSN=&FILE1,
//            DISP=(OLD,DELETE,DELETE)
//SORTJNF2 DD DSN=&FILE2,
//            DISP=(OLD,DELETE,DELETE)
//SORTOUT  DD DSN=&FILE3,
//            SPACE=(TRK,(1,1),RLSE),
//            DISP=(NEW,PASS,DELETE)
//SYSOUT   DD SYSOUT=*
//SYSIN    DD *
* JOIN SUR LE CHAMP STC00420 , F1 = SDSF LOG,  F2 = SDSF DA
* ICI ON VA INDIQUER QUELS CHAMPS TRIER POUR JOINDRE
 JOINKEYS FILE=F1,FIELDS=(26,8,A),INCLUDE=ALL
 JOINKEYS FILE=F2,FIELDS=(17,8,A),INCLUDE=ALL
* ON VA FAIRE L'EQUIVALENT D'UN RIGHT OUTER JOIN
 JOIN UNPAIRED,F2
* ON COPIE/COLLE DU SUPPLEMENT POUR QUE LE LRECL DE SORTIE SOIT 200
 REFORMAT FIELDS=(F2:1,43,?,F2:45,156),FILL=C' '
* LE '?' PERMET DE DIRE SI ON A TROUVE OU NON LE CHAMP DANS F1 ET F2
* ? => 'B' SI LA CLE EST DANS F1 & F2
*      '1' SI LA CLE EST DANS F1 MAIS PAS F2
*      '2' SI LA CLE EST DANS F2 MAIS PAS F1
 SORT FIELDS=COPY
 OUTFIL FNAMES=SORTOUT,INCLUDE=(44,1,SS,EQ,C'1,2,B'),
   IFTHEN=(WHEN=(44,1,CH,EQ,C'B'),
   BUILD=(1,43,44:C' KO',154X)),
   IFTHEN=(WHEN=NONE,
     BUILD=(1,43,44:C' OK',154X))
/*
//*
//*****************************
//* HTMLISATION DES RESULTATS *
//*  & SUPPRESSION DOUBLONS   *
//*****************************
//TOHTML   EXEC PGM=SORT
//SORTIN   DD DSN=&FILE3,
//            DISP=(OLD,DELETE,DELETE)
//SORTOUT  DD DSN=&FILE1,
//            SPACE=(TRK,(1,1),RLSE),
//            DISP=(NEW,PASS,DELETE)
//SYSOUT   DD SYSOUT=*
//SYSIN    DD *
 SORT FIELDS=(1,80,CH,A)
 SUM FIELDS=NONE
 INREC IFTHEN=(WHEN=(45,2,CH,EQ,C'OK'),
   BUILD=(1,44,45:C'<FONT COLOR="GREEN">OK</FONT></TD></TR>',123X)),
   IFTHEN=(WHEN=NONE,
     BUILD=(1,44,45:C'<FONT COLOR="RED">KO</FONT></TD></TR>',119X))
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
//             DCB=(RECFM=FB,LRECL=200,BLKSIZE=0),
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
SUBJECT: ETAT STC PROG
CONTENT-TYPE: MULTIPART/MIXED; BOUNDARY="SEPARATEUR"
MIME-VERSION: 1.0

--SEPARATEUR
CONTENT-TYPE: TEXT/HTML; CHARSET=ISO-8859-1

<HTML>
<HEAD>
</HEAD>
<BODY BGCOLOR="WHITE" TEXT="BLACK">
STC E-GEN & ICAN ACTUELLEMENT DEMARREES SUR CASA :
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
//SORTIN   DD DSN=&&HEADTMP1,
//            DISP=(OLD,DELETE,DELETE)
//SORTOUT  DD DSN=&&HEADTMP2,
//            SPACE=(TRK,(1,1),RLSE),
//            DISP=(NEW,PASS,DELETE)
//SYSOUT   DD SYSOUT=*
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
//             DCB=(RECFM=FB,LRECL=200,BLKSIZE=0),
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
//            SPACE=(TRK,(1,1),RLSE),
//            DISP=(NEW,PASS,DELETE)
//SORTIN   DD DSN=&&FOOTTMP1,
//            DISP=(OLD,DELETE,DELETE)
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
//SYSOUT   DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  DSN=&&HEADTMP2,
//             DISP=(OLD,DELETE,DELETE)
//         DD  DSN=&FILE1,
//             DISP=(OLD,DELETE,DELETE)
//         DD  DSN=&&FOOTTMP2,
//             DISP=(OLD,DELETE,DELETE)
//SYSUT2   DD  SYSOUT=(A,SMTP)
//*

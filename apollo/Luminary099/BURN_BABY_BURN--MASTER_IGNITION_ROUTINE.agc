# Copyright:	Public domain.
# Filename:	BURN_BABY_BURN--MASTER_IGNITION_ROUTINE.agc
# Purpose: 	Part of the source code for Luminary 1A build 099.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	731-751
# Mod history:	2009-05-19 RSB	Adapted from the corresponding 
#				Luminary131 file, using page 
#				images from Luminary 1A.
#		2009-06-07 RSB	Corrected 3 typos.
#		2009-07-23 RSB	Added Onno's notes on the naming
#				of this function, which he got from
#				Don Eyles.
#
# This source code has been transcribed or otherwise adapted from
# digitized images of a hardcopy from the MIT Museum.  The digitization
# was performed by Paul Fjeld, and arranged for by Deborah Douglas of
# the Museum.  Many thanks to both.  The images (with suitable reduction
# in storage size and consequent reduction in image quality as well) are
# available online at www.ibiblio.org/apollo.  If for some reason you
# find that the images are illegible, contact me at info@sandroid.org
# about getting access to the (much) higher-quality images which Paul
# actually created.
#
# Notations on the hardcopy document read, in part:
#
#	Assemble revision 001 of AGC program LMY99 by NASA 2021112-61
#	16:27 JULY 14, 1969 

# Page 731
## At the get-together of the AGC developers celebrating the 40th anniversary
## of the first moonwalk, Don Eyles (one of the authors of this routine along
## with Peter Adler) has related to us a little interesting history behind the
## naming of the routine.
##
## It traces back to 1965 and the Los Angeles riots, and was inspired 
## by disc jockey extraordinaire and radio station owner Magnificent Montague.
## Magnificent Montague used the phrase "Burn, baby! BURN!" when spinning the 
## hottest new records. Magnificent Montague was the charismatic voice of
## soul music in Chicago, New York, and Los Angeles from the mid-1950s to 
## the mid-1960s.
# BURN, BABY, BURN -- MASTER IGNITION ROUTINE

		BANK	36
		SETLOC	P40S
		BANK
		EBANK=	WHICH
		COUNT*	$$/P40

# THE MASTER IGNITION ROUTINE IS DESIGNED FOR USE BY THE FOLLOWING LEM PROGRAMS:  P12, P40, P42, P61, P63.
# IT PERFORMS ALL FUNCTIONS IMMEDIATELY ASSOCIATED WITH APS OR DPS IGNITION:  IN PARTICULAR, EVERYTHING LYING
# BETWEEN THE PRE-IGNITION TIME CHECK -- ARE WE WITHIN 45 SECONDS OF TIG? -- AND TIG + 26 SECONDS, WHEN DPS
# PROGRAMS THROTTLE UP.
#
# VARIATIONS AMONG PROGRAMS ARE ACCOMODATED BY MEANS OF TABLES CONTAINING CONSTANTS (FOR AVEGEXIT, FOR
# WAITLIST, FOR PINBALL) AND TCF INSTRUCTIONS.  USERS PLACE THE ADRES OF THE HEAD OF THE APPROPRIATE TABLE
# (OF P61TABLE FOR P61LM, FOR EXAMPLE) IN ERASABLE REGISTER `WHICH' (E4).  THE IGNITION ROUTINE THEN INDEXES BY
# WHICH TO OBTAIN OR EXECUTE THE PROPER TABLE ENTRY.  THE IGNITION ROUTINE IS INITIATED BY A TCF BURNBABY,
# THROUGH BANKJUMP IF NECESSARY.  THERE IS NO RETURN.
#
# THE MASTER IGNITION ROUTINE WAS CONCEIVED AND EXECUTED, AND (NOTA BENE) IS MAINTAINED BY ADLER AND EYLES.
#
# 		   HONI SOIT QUI MAL Y PENSE
#
#	***********************************************
#		TABLES FOR THE IGNITION ROUTINE
#	***********************************************
#
#			NOLI SE TANGERE

P12TABLE	VN	0674		# (0)
		TCF	ULLGNOT		# (1)
		TCF	COMFAIL3	# (2)
		TCF	GOCUTOFF	# (3)
		TCF	TASKOVER	# (4)
		TCF	P12SPOT		# (5)
		DEC	0		# (6)	NO ULLAGE
		EBANK=	WHICH
		2CADR	SERVEXIT	# (7)

		TCF	DISPCHNG	# (11)
		TCF	WAITABIT	# (12)
		TCF	P12IGN		# (13)

P40TABLE	VN	0640		# (0)
		TCF	ULLGNOT		# (1)
		TCF	COMFAIL4	# (2)
		TCF	GOPOST		# (3)
		TCF	TASKOVER	# (4)
		TCF	P40SPOT		# (5)
# Page 732
		DEC	2240		# (6)
		EBANK=	OMEGAQ
		2CADR	STEERING	# (7)

		TCF	P40SJUNK	# (11)
		TCF	WAITABIT	# (12)
		TCF	P40IGN		# (13)
		TCF	REP40ALM	# (14)

P41TABLE	TCF	P41SPOT		# (5)
		DEC	-1		# (6)
		EBANK=	OMEGAQ
		2CADR	CALCN85		# (7)

		TCF	COMMON		# (11)
		TCF	TIGTASK		# (12)

P42TABLE	VN	0640		# (0)
		TCF	WANTAPS		# (1)
		TCF	COMFAIL4	# (2)
		TCF	GOPOST		# (3)
		TCF	TASKOVER	# (4)
		TCF	P42SPOT		# (5)
		DEC	2640		# (6)
		EBANK=	OMEGAQ
		2CADR	STEERING	# (7)

		TCF	P40SJUNK	# (11)
		TCF	WAITABIT	# (12)
		TCF	P42IGN		# (13)
		TCF	P42STAGE	# (14)

P63TABLE	VN	0662		# (0)
		TCF	ULLGNOT		# (1)
		TCF	COMFAIL3	# (2)
		TCF	V99RECYC	# (3)
		TCF	TASKOVER	# (4)
		TCF	P63SPOT		# (5)
		DEC	2240		# (6)
		EBANK=	WHICH
		2CADR	SERVEXIT	# (7)

		TCF	DISPCHNG	# (11)
		TCF	WAITABIT	# (12)
# Page 733
		TCF	P63IGN		# (13)

ABRTABLE	VN	0663		# (0)
		TCF	ULLGNOT		# (1)
		TCF	COMFAIL3	# (2)
		TCF	GOCUTOFF	# (3)
		TCF	TASKOVER	# (4)
		NOOP			# (5)
		NOOP			# (6)
		NOOP			# (7)
		NOOP
		TCF	DISPCHNG	# (11)
		TCF	WAITABIT	# (12)
		TCF	ABRTIGN		# (13)

#	*********************************
#	GENERAL PURPOSE IGNITION ROUTINES
#	*********************************

BURNBABY	TC	PHASCHNG	# GROUP 4 RESTARTS HERE
		OCT	04024

		CAF	ZERO		# EXTIRPATE JUNK LEFT IN DVTOTAL
		TS	DVTOTAL
		TS	DVTOTAL +1

		TC	BANKCALL	# P40AUTO MUST BE BANKCALLED EVEN FROM ITS
		CADR	P40AUTO		# OWN BANK TO SET UP RETURN PROPERLY

B*RNB*B*	EXTEND
		DCA	TIG		# STORE NOMINAL TIG FOR OBLATENESS COMP.
		DXCH	GOBLTIME	# AND FOR P70 OR P71.

		INHINT
		TC	IBNKCALL
		CADR	ENGINOF3
		RELINT

		INDEX	WHICH
		TCF	5

P42SPOT		=	P40SPOT		# (5)
P12SPOT		=	P40SPOT		# (5)
P63SPOT		=	P41SPOT		# (5)	IN P63 CLOKTASK ALREADY GOING
P40SPOT		CS	CNTDNDEX	# (5)
# Page 734
		TC	BANKCALL	# MUST BE BANKCALLED FOR GENERALIZED
		CADR	STCLOK2		# 	RETURN
P41SPOT		TC	INTPRET		# (5)
		DLOAD	DSU
			TIG
			D29.9SEC
		STCALL	TDEC1
			INITCDUW
		BOFF	CALL
			MUNFLAG
			GOMIDAV
			CSMPREC
		VLOAD	MXV
			VATT1
			REFSMMAT
		VSR1
		STOVL	V(CSM)		# CSM VELOCITY -- M/CS*2(7)
			RATT1
		VSL4	MXV
			REFSMMAT
		STCALL	R(CSM)		# CSM POSITION -- M*2(24)
			MUNGRAV
		STODL	G(CSM)		# CSM GRAVITY VEC. -- M/CS*2(7)
			TAT
		STORE	TDEC1		# RELOAD TDEC1 FOR MIDTOAV.
GOMIDAV		CALRB
			MIDTOAV1
		TCF	CALLT-35	# MADE IT IN TIME.

		EXTEND			# TIG WAS SLIPPED, SO RESET TIG TO 29.9
		DCA	PIPTIME1	# SECONDS AFTER THE TIME TO WHICH WE DID
		DXCH	TIG		# INTEGRATE.
		EXTEND
		DCA	D29.9SEC
		DAS	TIG

CALLT-35	DXCH	MPAC
		DXCH	SAVET-30	# DELTA-T UNTIL TIG-30
		EXTEND
		DCS	5SECDP
		DAS	SAVET-30	# DELTA-T UNTIL TIG-35
		EXTEND
		DCA	SAVET-30
		TC	LONGCALL
		EBANK=	TTOGO
		2CADR	TIG-35

		TC	PHASCHNG
		OCT	20254		# 4.25SPOT FOR TIG-35 RESTART.
# Page 735
		TC	CHECKMM
		DEC	63
		TCF	ENDOFJOB	# NOT P63
		CS	CNTDNDEX	# P63 CAN START DISPLAYING NOW.
		TS	DISPDEX
		TC	INTPRET
		VLOAD	ABVAL
			VN1
		STORE	ABVEL		# INITIALIZE ABVEL FOR P63 DISPLAY
		EXIT
		TCF	ENDOFJOB

#	********************************

TIG-35		CAF	5SEC
		TC	TWIDDLE
		ADRES	TIG-30

		TC	PHASCHNG
		OCT	40154		# 4.15SPOT FOR TIG-30 RESTART

		CS	BLANKDEX	# BLANK DSKY FOR 5 SECONDS
		TS	DISPDEX

		INDEX	WHICH
		CS	6		# CHECK ULLAGE TIME.
		EXTEND
		BZMF	TASKOVER
		CAF	4.9SEC		# SET UP TASK TO RESTORE DISPLAY AT TIG-30
		TC	TWIDDLE
		ADRES	TIG-30.1

		CAF	PRIO17		# A NEGATIVE ULLAGE TIME INDICATES P41, IN
		TC	NOVAC		# WHICH CASE WE HAVE TO SET UP A JOB TO
		EBANK=	TTOGO		# BLANK THE DSKY FOR FIVE SECONDS, SINCE
		2CADR	P41BLANK	# CLOKJOB IS NOT RUNNING DURING P41.

		TCF	TASKOVER

P41BLANK	TC	BANKCALL	# BLANK DSKY.
		CADR	CLEANDSP
		TCF	ENDOFJOB

TIG-30.1	CAF	PRIO17		# SET UP JOB TO RESTORE DISPLAY AT TIG-30
		TC	NOVAC
		EBANK=	TTOGO
		2CADR	TIG-30A

		TCF	TASKOVER
# Page 736
TIG-30A		CAF	V16N85B
		TC	BANKCALL	# RESTORE DISPLAY.
		CADR	REGODSP		# REGODSP DOES A TCF ENDOFJOB

#	********************************

TIG-30		CAF	S24.9SEC
		TC	TWIDDLE
		ADRES	TIG-5

		CS	CNTDNDEX	# START UP CLOKTASK AGAIN
		TS	DISPDEX

		INDEX	WHICH		# PICK UP APPROPRIATE ULLAGE -- ON TIME
		CA	6		# Was CAF --- RSB 2009.
		EXTEND
		BZMF	ULLGNOT		# DON'T SET UP ULLAGE IF DT IS NEG OR ZERO
		TS	SAVET-30	# SAVE DELTA-T FOR RESTART
		TC	TWIDDLE
		ADRES	ULLGTASK

		CA	THREE		# RESTART PROTECT ULLGTASK (1.3SPOT)
		TS	L
		CS	THREE
		DXCH	-PHASE1
		CS	TIME1
		TS	TBASE1

		INDEX	WHICH
		TCF	1

WANTAPS		CS	FLGWRD10	# (1) FOR P42 ENSURE APSFLAG IS SET.  IF IT
		MASK	APSFLBIT	# WASN'T SET, DAP WILL BE INITIALIZED TO
		ADS	FLGWRD10	# ASCENT VALUES BY 1/ACCS IN 2 SECONDS.

ULLGNOT		EXTEND			# (1)
		INDEX	WHICH
		DCA	7		# LOAD AVEGEXIT WITH APPROPRIATE 2CADR
		DXCH	AVEGEXIT

		CAF	TWO		# 4.2SPOT RESTARTS IMMEDIATELY AT REDO4.2
		TS	L
		CS	TWO		# AND ALSO AT TIG-5 AT THE CORRECT TIME.
		DXCH	-PHASE4

		CS	TIME1
		TS	TBASE4		# SET TBASE4 FOR TIG-5 RESTART

REDO2.17	EXTEND
# Page 737
		DCA	NEG0		# CLEAR OUT GROUP 2 SO LAMBERT CAN START
		DXCH	-PHASE2		# IF NEEDED.

REDO4.2		CCS	PHASE5		# IF SERVICER GOING?
		TCF	TASKOVER	# YES, DON'T START IT UP AGAIN.

		TC	POSTJUMP
		CADR	PREREAD		# PREREAD END THIS TASK

# 	*********************************

ULLGTASK	TC	ONULLAGE	# THIS COMES AT TIG-7.5 OR TIG-3.5
		TC	PHASCHNG
		OCT	1
		TCF	TASKOVER

# 	*********************************

TIG-5		EXTEND
		DCA	NEG0		# INSURE THAT GROUP 3 IS INACTIVE.
		DXCH	-PHASE3

		CAF	5SEC
		TC	TWIDDLE
		ADRES	TIG-0

		TC	DOWNFLAG	# RESET IGNFLAG AND ASINFLAG
		ADRES	IGNFLAG		# 	FOR LIGHT-UP LOGIC.
		TC	DOWNFLAG
		ADRES	ASTNFLAG
		
		INDEX	WHICH
		TCF	11

P40SJUNK	CCS	PHASE3		# (11) P40 AND P42.  S40.13 IN PROGRESS?
		TCF	DISPCHNG	# YES

		CAF	PRIO20
		TC	FINDVAC
		EBANK=	TTOGO
		2CADR	S40.13

		TC	PHASCHNG	# 3.5SPOT FOR S40.13
		OCT	00053
DISPCHNG	CS	VB99DEX		# (11)
		TS	DISPDEX

# Page 738		
COMMON		TC	PHASCHNG	# RESTART TIG-0 (4.7SPOT)
		OCT	40074
		TCF	TASKOVER

# 	*********************************

TIG-0		CS	FLAGWRD7	# SET IGNFLAG SINCE TIG HAS ARRIVED
		MASK	IGNFLBIT
		ADS	FLAGWRD7

		TC	CHECKMM		# IN P63 CASE, THROTTLE-UP IS ZOOMTIME
		DEC	63		# AFTER NOMINAL IGNITION, NOT ACTUAL
		TCF	IGNYET?
		CA	ZOOMTIME
		TC	WAITLIST
		EBANK=	DVCNTR
		2CADR	P63ZOOM

		TC	2PHSCHNG
		OCT	40033

		OCT	05014
		OCT	77777

IGNYET?		CAF	ASTNBIT		# CHECK ASTNFLAG:  HAS ASTRONAUT RESPONDED
		MASK	FLAGWRD7	# TO OUR ENGINE ENABLE REQUEST?
		EXTEND
		INDEX	WHICH
		BZF	12		# BRANCH IF HE HAS NOT RESPONDED YET

IGNITION	CS	FLAGWRD5	# INSURE ENGONFLG IS SET.
		MASK	ENGONBIT
		ADS	FLAGWRD5
		CS	PRIO30		# TURN ON THE ENGINE.
		EXTEND
		RAND	DSALMOUT
		AD	BIT13
		EXTEND
		WRITE	DSALMOUT
		EXTEND			# SET TEVENT FOR DOWNLINK
		DCA	TIME2
		DXCH	TEVENT

		EXTEND			# UPDATE TIG USING TGO FROM S40.13
		DCA	TGO
		DXCH	TIG
		EXTEND
		DCA	TIME2
		DAS	TIG

# Page 739
		CS	FLUNDBIT	# PERMIT GUIDANCE LOOP DISPLAYS
		MASK	FLAGWRD8
		TS	FLAGWRD8

		INDEX	WHICH
		TCF	13

P63IGN		EXTEND			# (13)	INITIATE BURN DISPLAYS
		DCA	DSP2CADR
		DXCH	AVGEXIT

		CA	Z		# ASSASSINATE CLOKTASK
		TS	DISPDEX

		CS	FLAGWRD9	# SET FLAG FOR P70-P71
		MASK	LETABBIT
		ADS	FLAGWRD9
		
		CS	FLAGWRD7	# SET SWANDISP TO ENABLE R10.
		MASK	SWANDBIT
		ADS	FLAGWRD7
		
		CS	PULSES		# MAKE SURE DAP IS NOT IN MINIMUM-IMPULSE
		MASK	DAPBOOLS	# MODE, IN CASE OF SWITCH TO P66
		TS	DAPBOOLS

		EXTEND			# INITIALIZE TIG FOR P70 AND P71.
		DCA	TIME2
		DXCH	TIG

		CAF	ZERO		# INITIALIZE WCHPHASE, AND FLPASS0
		TS	WCHPHASE
		TS	WCHPHOLD	# ALSO WHCPHOLD
		CA	TWO
		TS	FLPASS0

		TCF	P42IGN
P40IGN		CS	FLAGWRD5	# (13)
		MASK	NOTHRBIT
		EXTEND
		BZF	P42IGN
		CA	ZOOMTIME
		TC	WAITLIST
		EBANK=	DVCNTR
		2CADR	P40ZOOM

P63IGN1		TC	2PHSCHNG
		OCT	40033		# 3.3SPOT FOR ZOOM RESTART.
		OCT	05014		# TYPE C RESTARTS HERE IMMEDIATELY
		OCT	77777

# Page 740
		TCF	P42IGN
P12IGN		CAF	EBANK6
		TS	EBANK
		EBANK=	AOSQ

		CA	IGNAOSQ		# INITIALIZE DAP BIAS ACCELERATION
		TS	AOSQ		# ESTIMATES AT P12 IGNITION.
		CA	IGNAOSR
		TS	AOSR

		CAF	EBANK7
		TS	EBANK
		EBANK=	DVCNTR

ABRTIGN		CA	Z		# (13) KILL CLOKTASK
		TS	DISPDEX

		EXTEND			# CONNECT ASCENT GYIDANCE TO SERVICER.
		DCA	ATMAGADR
		DXCH	AVGEXIT

		CS	FLAGWRD7	# ENABLE R10.
		MASK	SWANDBIT
		ADS	FLAGWRD7

P42IGN		CS	DRIFTBIT	# ENSURE THAT POWERED-FLIGHT SWITCHING
		MASK	DAPBOOLS	# CURVES ARE USED.
		TS	DAPBOOLS
		CAF	IMPULBIT	# EXAMINE IMPULSE SWITCH
		MASK	FLAGWRD2
		CCS	A
		TCF	IMPLBURN

DVMONCON	TC	DOWNFLAG
		ADRES	IGNFLAG		# CONNECT DVMON
		TC	DOWNFLAG
		ADRES	ASTNFLAG
		TC	DOWNFLAG
		ADRES	IDLEFLAG

		TC	PHASCHNG
		OCT	40054

		TC	FIXDELAY	# TURN ULLAGE OFF HALF A SECOND AFTER
		DEC	50		# LIGHT UP.

ULLAGOFF	TC	NOULLAGE

WAITABIT	EXTEND			# KILL GROUP 4
		DCA	NEG0
# Page 741
		DXCH	-PHASE4

		TCF	TASKOVER

TIGTASK		TC	POSTJUMP	# (12)
		CADR	TIGTASK1

#	********************************

		BANK	31
		SETLOC	P40S3
		BANK
		COUNT*	$$/P40

TIGTASK1	CAF	PRIO16
		TC	NOVAC
		EBANK=	TRKMKCNT
		2CADR	TIGNOW

		TC	PHASCHNG
		OCT	6		# KILL GROUP 6

		TCF	TASKOVER

#	********************************

P63ZOOM		EXTEND
		DCA	LUNLANAD
		DXCH	AVEGEXIT

		TC	IBNKCALL
		CADR	FLATOUT
		TCF	P40ZOOMA

P40ZOOM		CAF	BIT13
		TS	THRUST
		CAF	BIT4

		EXTEND
		WOR	CHAN14

P40ZOOMA	TC	PHASCHNG
		OCT	3
		TCF	TASKOVER

		EBANK=	DVCNTR
LUNLANAD	2CADR	LUNLAND

# Page 742
ZOOM		=	P40ZOOMA
		BANK	36
		SETLOC	P40S
		BANK
		COUNT*	$$/P40

#	********************************

COMFAIL		TC	UPFLAG		# (15)
		ADRES	IDLEFLAG
		TC	UPFLAG		# SET FLAG TO SUPPRESS CONFLICTING DISPLAY
		ADRES	FLUNDISP
		CAF	FOUR		# RESET DVMON
		TS	DVCNTR
		CCS	PHASE6		# CLOCKTASK ACTIVE?
		TCF	+3		# YES
		TC	BANKCALL	# OTHERWISE, START IT UP
		CADR	STCLOK1
 	+3	CS	VB97DEX
 		TS	DISPDEX
		TC	PHASCHNG	# TURN OFF GROUP 4.
		OCT	00004
		TCF	ENDOFJOB

COMFAIL1	INDEX	WHICH
		TCF	2

COMFAIL3	CA	Z		# (15)	KILL CLOKTASK USING Z
		TCF	+2

COMFAIL4	CS	CNTDNDEX
		TS	DISPDEX

		TC	DOWNFLAG	# RECONNECT DV MONITOR
		ADRES	IDLEFLAG
		TC	DOWNFLAG	# PERMIT GUIDANCE LOOP DISPLAYS
		ADRES	FLUNDISP
		TCF	ENDOFJOB

COMFAIL2	TC	PHASCHNG	# KILL ZOOM RESTART PROTECTION
		OCT	00003

		INHINT
		TC	KILLTASK	# KILL ZOOM IN CASE IT'S STILL TO COME
		CADR	ZOOM
		TC	IBNKCALL	# COMMAND ENGINE OFF
		CADR	ENGINOF4
		TC	UPFLAG		# SET THE DRIFT BIT FOR THE DAP.
		ADRES	DRIFTDFL
# Page 743
		TC	INVFLAG		# USE OTHER RCS SYSTEM
		ADRES	AORBTFLG
		TC	UPFLAG		# TURN ON ULLAGE
		ADRES	ULLAGFLG
		CAF	BIT1
		INHINT
		TC	TWIDDLE
		ADRES	TIG-5
		TCF	ENDOFJOB

#	***********************************
#	SUBROUTINES OF THE IGNITION ROUTINE
#	***********************************

INVFLAG		CA	Q
		TC	DEBIT
		COM
		EXTEND
		RXOR	LCHAN
		TCF	COMFLAG

#	***********************************

NOULLAGE	CS	ULLAGER		# MUST BE CALLED IN A TASK OR UNDER INHINT
		MASK	DAPBOOLS
		TS	DAPBOOLS
		TC	Q

#	***********************************

ONULLAGE	CS	DAPBOOLS	# TURN ON ULLAGE.  MUST BE CALLED IN
		MASK	ULLAGER		# A TASK OR WHILE INHINTED.
		ADS	DAPBOOLS
		TC	Q

# 	***********************************

STCLOK1		CA	ZERO		# THIS ROUTINE STARTS THE COUNT-DOWN
STCLOK2		TS	DISPDEX		# (CLOKTASK AND CLOKJOB).  SETTING
STCLOK3		TC	MAKECADR	# SETTING DISPDEX POSITIVE KILLS IT.
		TS	TBASE4		# RETURN SAVE (NOT FOR RESTARTS).
		EXTEND
		DCA	TIG
		DXCH	MPAC
		EXTEND
		DCS	TIME2
# Page 744		
		DAS	MPAC		# HAVE TIG -- TIME2, UNDOUBTEDLY A + NUMBER
		TC	TPAGREE		# POSITIVE, SINCE WE PASSED THE
		CAF	1SEC		# 45 SECOND CHECK.
		TS	Q
		DXCH	MPAC
		MASK	LOW5		# RESTRICT MAGNITUDE OF NUMBER IN A
		EXTEND
		DV	Q
		CA	L		# GET REMAINDER
		AD	TWO
		INHINT
		TC	TWIDDLE
		ADRES	CLOKTASK
		TC	2PHSCHNG
		OCT	40036		# 6.3SPOT FOR CLOKTASK
		OCT	05024
		OCT	13000

		CA	TBASE4
		TC	BANKJUMP

CLOKTASK	CS	TIME1		# SET TBASE6 FOR GROUP 6 RESTART
		TS	TBASE6

		CCS	DISPDEX
		TCF	KILLCLOK
		NOOP
		CAF	PRIO27
		TC	NOVAC
		EBANK=	TTOGO
		2CADR	CLOKJOB

		TC	FIXDELAY	# WAIT A SECOND BEFORE STARTING OVER
		DEC	100
		TCF	CLOKTASK

KILLCLOK	EXTEND			# KILL RESTART
		DCA	NEG0
		DXCH	-PHASE6
		TCF	TASKOVER

CLOKJOB		EXTEND
		DCS	TIG
		DXCH	TTOGO
		EXTEND
# Page 745		
		DCA	TIME2
		DAS	TTOGO
		INHINT
		CCS	DISPDEX		# IF DISPDEX HAS BEEN SET POSITIVE BY A
		TCF	ENDOFJOB	# TASK OR A HIGHER PRIORITY JOB SINCE THE
		TCF	ENDOFJOB	# LAST CLOKTASK, AVOID USING IT AS AN
		COM			# INDEX.
		RELINT			# ***** DISPDEX MUST NEVER B -0 *****
		INDEX	A
		TCF	DISPNOT -1	# (-1 DUE TO EFFECT OF CCS)

VB97DEX		=	OCT35		# NEGATIVE OF THIS IS PROPER FOR DISPDEX

 	-35	CS	ZERO		# INDICATE VERB 97 PASTE
 		TS	NVWORD1
		CA	NVWORD 	+2	# NVWORD+2 CONTAINS V06 & APPROPRIATE NOUN
		TC	BANKCALL
		CADR	CLOCPLAY
		TCF	STOPCLOK	# TERMINATE CLOKTASK ON THE WAY TO P00H
		TCF	COMFAIL1
		TCF	COMFAIL2

					# THIS DISPLAY IS CALLED VIA ASTNCLOK
 	-25	CAF	V06N61		# IT IS PRIMARILY USED BY THE CREW IN P63
 		TC	BANKCALL	# TO RESET HIS EVENT TIMER TO AGREE WITH
		CADR	REFLASH		# TIG.
		TCF	STOPCLOK
		TCF	ASTNRETN
		TCF	-6

CNTDNDEX	=	LOW4		# OCT17:  NEGATIVE PROPER FOR DISPDEX

 	-17	INDEX	WHICH		# THIS DISPLAY COMES UP AT ONE SECOND
		# Was CAF --- RSB 2009
 		CA	0		# INTERVALS.  IT IS NORMALLY OPERATED
		TC	BANKCALL	# BETWEEN TIG-30 SECONDS AND TIG-5 SECONDS
		CADR	REGODSP		# REGODSP DOES ITS OWN TCF ENDOFJOB

VB99DEX		=	ELEVEN		# OCT13:  NEGATIVE PROPER FOR DISPDEX

V99RECYC	EQUALS

 	-13	CS	BIT9		# INDICATE VERB 99 PASTE
 		TS	NVWORD1
		INDEX	WHICH		# THIS IS THE "PLEASE ENABLE ENGINE"
		# Was CAF --- RSB 2004
		CA	0		# DISPLAY; IT IS INITIATED AT TIG-5 SEC.
		TC	BANKCALL	# THE DISPLAY IS A V99NXX, WHERE XX IS
		CADR	CLOCPLAY	# NOUN THAT HAD PREVIOUSLY BEEN DISPLAYED
		TCF	STOPCLOK	# TERMINATE GOTOP00H TURNS OFF ULLAGE.
		TCF	*PROCEED
		TCF	*ENTER

# Page 746
BLANKDEX	=	TWO		# NEGATIVE OF THIS IS PROPER FOR DISPDEX

	-2	TC	BANKCALL	# BLANK DSKY.  THE DSKY IS BLANKED FOR
 		CADR	CLEANDSP	# 5 SECONDS AT TIG-35 TO INDICATE THAT
DISPNOT		TCF	ENDOFJOB	# AVERAGE G IS STARTING.

STOPCLOK	TC	NULLCLOK	# STOP CLOKTASK & TURN OFF ULLAGE ON THE
		TCF	GOTOP00H	# WAY TO P00 (GOTOP00H RELINTS)

NULLCLOK	INHINT
		EXTEND
		QXCH	P40/RET
		TC	NOULLAGE	# TURN OFF ULLAGE ...
		TC	KILLTASK	#	DON'T LET IT COME ON, EITHER ...
		CADR	ULLGTASK
		TC	PHASCHNG	#		NOT EVEN IF THERE'S A RESTART.
		OCT	1
		CA	Z		# KILL CLOKTASK
		TS	DISPDEX
		TC	P40/RET

ASTNRETN	TC	PHASCHNG
		OCT	04024
		CAF	ZERO		# STOP DISPLAYING BUT KEEP RUNNING
		TS	DISPDEX
		CAF	PRIO13
		TC	FINDVAC
		EBANK=	STARIND
		2CADR	ASTNRET

		TCF	ENDOFJOB

*PROCEED	TC	UPFLAG
		ADRES	ASTNFLAG

		TCF	IGNITE

*ENTER		INHINT
		INDEX	WHICH
		TCF	3

GOPOST		CAF	PRIO12		# (3) MUST BE LOWER PRIORITY THAN CLOKJOB
		TC	FINDVAC
		EBANK=	TTOGO
		2CADR	POSTBURN

# Page 747
		INHINT			# SET UP THE DAP FOR COASTING FLIGHT.
		TC	IBNKCALL
		CADR	ALLCOAST
		TC	NULLCLOK
		TC	PHASCHNG	# 4.13 RESTART FOR POSTBURN
		OCT	00134

		TCF	ENDOFJOB

GOCUTOFF	CAF	PRIO17		# (3)
		TC	FINDVAC
		EBANK=	TGO
		2CADR	CUTOFF

		TC	DOWNFLAG
		ADRES	FLUNDISP

		INHINT			# SET UP THE DAP FOR COASTING FLIGHT.
		TC	IBNKCALL
		CADR	ALLCOAST
		TC	NULLCLOK
		TC	PHASCHNG
		OCT	07024
		OCT	17000
		EBANK=	TGO
		2CADR	CUTOFF

		TCF	ENDOFJOB

IGNITE		CS	FLAGWRD7	# (2)
		MASK	IGNFLBIT
		CCS	A
		TCF	IGNITE1
		CAF	BIT1
		INHINT
		TC	TWIDDLE
		ADRES	IGNITION

		CAF	OCT23		# IMMEDIATE RESTART AT IGNITION
		TS	L
		COM
		DXCH	-PHASE4

IGNITE1		CS	CNTDNDEX	# RESTORE OLD DISPLAY.
		TS	DISPDEX

		TCF	ENDOFJOB

# Page 748
#	********************************

P40ALM		TC	ALARM		# PROGRAM SELECTION NOT CONSISTENT WITH
		OCT	1706		# VEHICLE CONFIGURATION

REP40ALM	CAF	V05N09		# (14)
		TC	BANKCALL
		CADR	GOFLASH

		TCF	GOTOP00H	# V34E 		TERMINATE
		TCF	+2		# PROCEED 	CHECK FOR P42
		TCF	REP40ALM	# V32E		REDISPLAY ALARM

		INDEX	WHICH		# FOR P42, ALLOW CREW TO PROCEED EVEN
		TCF	14		# THOUGH VEHICLE IS UNSTAGED.

#	********************************

		BANK	31
		SETLOC	P40S2
		BANK

		COUNT*	$$/P40

P40AUTO		TC	MAKECADR	# HELLO THERE.
		TS	TEMPR60		# FOR GENERALIZED RETURN TO OTHER BANKS.
P40A/P		TC	BANKCALL	# SUBROUTINE TO CHECK PGNCS CONTROL
		CADR	G+N,AUTO	# AND AUTO STABILIZATION MODES
		CCS	A		# +0 INDICATES IN PGNCS, IN AUTO
		TCF	TURNITON	# + INDICATES NOT IN PGNCS AND/OR AUTO
		CAF	APSFLBIT	# ARE WE ON THE DESCENT STAGE?
		MASK	FLGWRD10
		CCS	A
		TCF	GOBACK		# RETURN
		CAF	BIT5		# YES, CHECK FOR AUTO-THROTTLE MODE
		EXTEND
		RAND	CHAN30
		EXTEND
		BZF	GOBACK		# IN AUTO-THROTTLE MODE -- RETURN
TURNITON	CAF	P40A/PMD	# DISPLAYS V50N25 R1=203 PLEASE PERFORM
		TC	BANKCALL	# CHECKLIST 203 TURN ON PGNCS ETC.
		CADR	GOPERF1
		TCF	GOTOP00H	# V34E TERMINATE
		TCF	P40A/P		# RECYCLE
GOBACK		CA	TEMPR60
		TC	BANKJUMP	# GOODBYE.  COME AGAIN SOON.

P40A/PMD	OCT	00203

# Page 749
		BANK	36
		SETLOC	P40S
		BANK

		COUNT*	$$/P40

#	**********************************
#	CONSTANTS FOR THE IGNITION ROUTINE
#	**********************************

SERVCADR	=	P63TABLE +7

P40ADRES	ADRES	P40TABLE

P41ADRES	ADRES	P41TABLE -5

P42ADRES	ADRES	P42TABLE

		EBANK=	DVCNTR
DSP2CADR	2CADR	P63DISPS -2

		EBANK=	DVCNTR
ATMAGADR	2CADR	ATMAG

?		=	GOTOP00H

D29.9SEC	2DEC	2990

S24.9SEC	DEC	2490

4.9SEC		DEC	490

OCT20		=	BIT5

V06N61		VN	0661

# Page 750
# KILLTASK
# MOD NO:  NEW PROGRAM
# MOD BY:  COVELLI
#
# FUNCTIONAL DESCRIPTION:
#
#	KILLTASK IS USED TO REMOVE A TASK FROM THE WAITLIST BY SUBSTITUTING A NULL TASK CALLED `NULLTASK' (OF COURSE),
#	WHICH MERELY DOES A TC TASKOVER.  IF THE SAME TASK IS SCHEDULED MORE THAN ONCE, ONLY THE ONE WHICH WILL OCCUR
#	FIRST IS REMOVED.  IF THE TASK IS NOT SCHEDULED, KILLTASK TAKES NO ACTION AND RETURNS WITH NO ALARM.  KILLTASK
#	LEAVES INTERRUPTS INHIBITED SO CALLER MUST RELINT
#
# CALLING SEQUENCE
#	L	TC	KILLTASK	# IN FIXED-FIXED
#	L+1	CADR	????????	# CADR (NOT 2CADR) OF TASK TO BE REMOVED.
#	L+2	(RELINT)		# RETURN
#
# EXIT MODE:  AT L+2 OF CALLING SEQUENCE.
#
# ERASABLE INITIALIZATION:  NONE.
#
# OUTPUT:  2CADR OF NULLTASK IN LST2
#
# DEBRIS:  ITEMP1 - ITEMP4, A, L, Q.

		EBANK=	LST2
		BLOCK	3		# KILLTASK MUST BE IN FIXED-FIXED.
		SETLOC	FFTAG6
		BANK
		COUNT*	$$/KILL
KILLTASK	CA	KILLBB
		INHINT
		LXCH	A
		INDEX	Q
		CA	0		# GET CADR.
		LXCH	BBANK
		TCF	KILLTSK2	# CONTINUE IN SWITCHED FIXED.

		EBANK=	LST2
KILLBB		BBCON	KILLTSK2

		BANK	27

		SETLOC	P40S1
		BANK
		COUNT*	$$/KILL

KILLTSK2	LXCH	ITEMP2		# SAVE CALLER'S BBANK
# Page 751
		INCR	Q
		EXTEND
		QXCH	ITEMP1		# RETURN 2ADR IN ITEMP1,ITEMP2

		TS	ITEMP3		# CADR IS IN A
		MASK	LOW10
		AD	BIT11
		TS	ITEMP4		# GENADR OF TASK

		CS	LOW10
		MASK	ITEMP3
		TS	ITEMP3		# FBANK OF TASK

		ZL
ADRSCAN		INDEX	L
		CS	LST2
		AD	ITEMP4		# COMPARE GENADRS
		EXTEND
		BZF	TSTFBANK	# IF THEY MATCH, COMPARE FBANKS
LETITLIV	CS	LSTLIM
		AD	L
		EXTEND			# ARE WE DONE?
		BZF	DEAD		# YES -- DONE, SO RETURN
		INCR	L
		INCR	L
		TCF	ADRSCAN		# CONTINUE LOOP.

DEAD		DXCH	ITEMP1
		DTCB

TSTFBANK	CS	LOW10
		INDEX	L
		MASK	LST2 	+1	# COMPARE FBANKS ONLY.
		EXTEND
		SU	ITEMP3
		EXTEND
		BZF	KILLDEAD	# MATCH -- KILL IT.
		TCF	LETITLIV	# NO MATCH -- CONTINUE.

KILLDEAD	CA	TCTSKOVR
		INDEX	L
		TS	LST2		# REMOVE TASK BY INSERTING TASKOVER
		TCF	DEAD

LSTLIM		EQUALS	BIT5		# DEC 16

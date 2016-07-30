# Copyright:	Public domain.
# Filename:	AOSTASK_AND_AOSJOB.agc
# Purpose: 	Part of the source code for Luminary 1A build 099.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	1485-1506
# Mod history:	2009-05-27 RSB	Adapted from the corresponding 
#				Luminary131 file, using page 
#				images from Luminary 1A.
#		2009-06-05 RSB	Corrected a memory-bank error type.
#		2009-06-07 RSB	Corrected a typo.
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

# Page 1485
# PROGRAM NAME:		1/ACCS
# PROGRAM WRITTEN BY: 	BOB COVELLI AND MIKE HOUSTON
# LAST MODIFICATION:	FEB. 14, 1969 BY G. KALAN
#
# PROGRAM DESCRIPTION:
#	1/ACCS PROVIDES THE INTERFACE BETWEEN THE GUIDANCE PROGRAMS AND THE DIGITAL AUTOPILOT.  WHENEVER THERE IS A
# 	CHANGE IN THE MASS OF THE VEHICLE, IN THE DEADBAND SELECTED, IN THE VEHICLE CONFIGURATION (ASCENT-DESCENT-
#	DOCKED), AND DURING A FRESH START OR A RESTART, 1/ACCS IS CALLED TO COMMUNICATE THE DATA CHANGES TO THE DAP.
#
# 	THE INPUTS TO 1/ACCS ARE MASS, ACCELERATION (ABDELV), DEADBAND (DB), OFFSET ACCELERATIONS (AOSQ AND AOSR),
# 	STAGE VERIFY BIT (CHAN30, BIT2), DOCKED BIT (DAPBOOLS, BIT13), DRIFT BIT (DAPBOOLS, BIT8), USEQRJTS (DAPBOOLS,
# 	BIT14), AND SURFACE FLAG (FLAGWRDB, BIT8), AND CH5MASK.
#
#	1/ACCS COMPUTES THE JET ACCELERATIONS (1JACC, 1JACCQ, 1JACCR) AS FUNCTIONS OF MASS.  1JACCU AND 1JACCV ARE
#	FORMED BY RESOLVING 1JACCQ AND 1JACCR.  IN THE DESCENT CASE, THE DESCENT ENGINE MOMENT ARM (L, PVT-CG) IS ALSO
# 	COMPUTED AS A FUNCTION OF MASS.  THE RATE OF CHANGE OF ACCELERATION DUE TO ROTATION OF THE GIMBAL (ACCDOTQ,
#	ACCDOTR) IS ALSO COMPUTED IN THE DESCENT CASE.
#
#	AFTER THE ABOVE COMPUTATIONS, THE PROGRAM 1/ACCONT COMPUTES THE RECIPROCAL NET ACCELERATIONS ABOUT THE P, U,
# 	AND V AXES (2 JETS FOR P-AXIS, BOTH 1 AND 2 JETS FOR U AND V AXES), AND THE RECIPROCAL COAST ACCELERATIONS ABOUT
# 	THE P, U, AND V AXES.  THE ACCELERATION FUNCTIONS (ACCFCTZ1 AND ACCFCTZ5) ARE ALSO COMPUTED FOR THESE AXES.  THE
# 	FIRE AND COAST DEADBANDS AND AXISDIST ARE COMPUTED FOR EACH AXIS.  FLAT AND ZONE3LIM, THE WIDTH AND HEIGHT OF THE
# 	MINIMUM IMPULSE ZONE, ARE COMPUTED.  1/ACCONT ALSO SETS ACCSWU AND ACCSWV, WHICH INDICATE WHEN 1 JET ACCELERATION
#	IS NOT SUFFICIENT TO PRODUCE MINIMUM ACCELERATION.  AT THE COMPLETION OF 1/ACCS, THE ACCSOKAY BIT IS SET.
#
# SUBROUTINES CALLED:
#	TIMEGMBL
#	MAKECADR
#	ROT45DEG
#
# CALLING SEQUENCE:
#		TC	BANKCALL	# (1/ACCS MUST BE CALLED BY BANKCALL)
#		CADR	1/ACCS
#
# NORMAL EXIT:	VIA BANKJUMP
#
# ALARM AND EXIT MODES:  NONE
#
# INPUT/OUTPUT:  SEE PROGRAM DESCRIPTION.
#
# DEBRIS:
#	ALL OF THE EXECUTIVE TEMPORARY REGISTERS, EXCEPT FIXLOC AND OVFIND, AND THE CORE SET AREA FROM MPAC TO BANKSET.
#
# RESTRICTIONS:
#	1/ACCS MUST BE CALLED BY BANKCALL
#	EBANK IS SET TO 6, BUT NOT RESTORED.
# Page 1486

		BANK	20
		SETLOC	DAPS3
		BANK

		COUNT*	$$/DAPAO

		EBANK=	AOSQ

# ENTRY IS THROUGH 1/ACCJOB OR 1/ACCSIT WHEN 1/ACCS IS TO BE DONE AS A SEPARATE NOVAC JOB.
# IT IS POSSIBLE FOR MORE THAN ONE OF THESE JOBS TO BE SET UP CONCURRENTLY.  HOWEVER, SINCE THERE IS NO CHECK OF
# NEWJOB, A SECOND MANIFESTATION CANNOT BE STARTED UNTIL THE FIRST IS COMPLETED.

1/ACCSET	CAF	ZERO		# ENTRY FROM FRESH START/RESTART CODING.
		TS	AOSQ		#	NULL THE OFFSET ESTIMATES FOR 1/ACCS.
		TS	AOSR
		TS	ALPHAQ		#	NULL THE OFFSET ESTIMATES FOR DOWNLIST
		TS	ALPHAR

1/ACCJOB	TC	BANKCALL	# 1/ACCS ASSUMES ENTRY VIA BANKCALL.
		CADR	1/ACCS 	+2	# SKIP EBANK SETTING.

		TC	ENDOFJOB

1/ACCS		CA	EBANK6		# ***** EBANK SET BUT NOT RESTORED *****
		TS	EBANK

		TC	MAKECADR	# SAVE RETURN SO THAT BUF2 MAY BE USED
		TS	ACCRETRN

# DETERMINE MASS OF THE LEM.

		CA	DAPBOOLS	# IS THE CSM DOCKED
		MASK	CSMDOCKD
		TS	DOCKTEMP	# STORE RECORD OF STATE IN TEMP (MPAC +3).
		CCS	A
		CS	CSMMASS		#	DOCKED:  LEMMAS = MASS - CSMMASS
		AD	MASS		#	LEM ALONE:  LEMMASS = MASS
		TS	LEMMASS

# ON THE BASIS OF APSFLAG:
#	SET THE P-AXIS RATE COMMAND LIMIT FOR 2-JET/2-JET CONTROL
#	SET MPAC, WHICH INDICATES THE PROPER SET OF COEFFICIENTS FOR THE LEM-ALONE F(MASS) CALCULATIONS
#	ENSURE THAT THE LEM MASS VALUE IS WITHIN THE ACCEPTABLE RANGE

		INHINT
		CAE	FLGWRD10	# DETERMINE WHETHER STAGED.
		MASK	APSFLBIT
		EXTEND
		BZF	DPSFLITE
# Page 1487
		CS	POSMAX		# ASCENT (OR ON LUNAR SURFACE)
		TS	-2JETLIM	# ALWAYS 2 JETS FOR P-AXIS RATE COMMAND
		CAF	OCT14		# INITIALIZE INDEX AT 12.
		TS	MPAC
		CS	LEMMASS		# CHECK IF MASS TOO HIGH.  CATCH STAGING.
		AD	HIASCENT
		EXTEND
		BZMF	MASSFIX
		CS	LEMMASS		# CHECK IF MASS TOO LOW.  THIS LIMITS THE
		AD	LOASCENT	#	DECREMENTING BY MASSMON.
		EXTEND
		BZMF	F(MASS)

MASSFIX		ADS	LEMMASS		# STORE THE VIOLATED LIMIT AS LEMMASS.
		ZL			#	ALSO CORRECT TOTAL MASS, ZEROING THE
		CCS	DOCKTEMP	#	LOW-ORDER WORD.
		CAE	CSMMASS		#		DOCKED:  MASS = LEMMASS + CSMMASS
		AD	LEMMASS		#		LEM ALONE:  MASS = LEMMASS
		DXCH	MASS
		TCF	F(MASS)

DPSFLITE	CS	BIT10		# FOUR JETS FOR P-AXIS RATE COMMAND ERRORS
		TS	-2JETLIM	#	EXCEEDING 1.4 DEG/SEC (SCALED AT 45)
		CAF	SIX		# INITIALIZE INDEX AT 6.
		TS	MPAC
		CS	LEMMASS		# CHECK IF MASS TOO HIGH.  SHOULD NEVER
		AD	HIDESCNT	# 	OCCUR EXCEPT PERHAPS BEFORE THE PAD
		EXTEND			#	LOAD IS DONE.
		BZMF	MASSFIX
		CS	LEMMASS		# CHECK IF MASS TOO LOW.  THIS LIMITS THE
		AD	LODESCNT	#	DECREMENTING BY MASSMON.
		AD	HIASCENT
		EXTEND
		BZMF	F(MASS)
		TCF	MASSFIX

# COMPUTATION OF FUNCTIONS OF MASS

F(MASS)		RELINT
		CCS	DOCKTEMP
		TCF	DOCKED		# DOCKED:  USE SEPARATE COMPUTATION.
		CA	TWO
STCTR		TS	MPAC 	+1	# J=2,1,0 FOR 1JACCR,1JACCQ,1JACC

		CS	TWO
		ADS	MPAC		# JX=10,8,6 OR 4,2,0 TO INDEX COEFS.

STCTR1		CAE	LEMMASS
		INDEX	MPAC
		AD	INERCONC
		TS	MPAC 	+2	# MASS + C
# Page 1488
		EXTEND
		INDEX	MPAC
		DCA	INERCONA
		EXTEND
		DV	MPAC 	+2
		INDEX	MPAC
		AD	INERCONB
		INDEX	MPAC 	+1	# 1JACC(J)=A(JX)/(MASS+C(JX) + B(JX)
		TS	1JACC		# 1JACC(-1)=L,PVT-CG  SCALED AT 8 FEET

		CCS	MPAC 	+1
		TCF	STCTR
		TCF	COMMEQS
		TCF	LRESC

# COEFFQ AND COEFFR ARE COMPUTED IN THIS SECTION.  THEY ARE USED TO RESOLVE Q-R COMPONENTS INTO NON-ORTHOGONAL
# U AND V COMPONENTS (SEE ROT-TOUV SECTION).

COMMEQS		CS	1JACCR
		AD	1JACCQ
		EXTEND
		BZMF	BIGIQ
		EXTEND			# EPSILON IS A MEASURE OF COUPLING AND IS
		DV	1JACCQ		# DEFINED=1-IQ/IR FOR IR GREATER THAN IQ.
		TS	EPSILON		# THE COMPUTED EXPRESSION IS EQUIVALENT
		AD	-EPSMAX
		EXTEND
		BZMF	GOODEPS1
		CS	-EPSMAX
		TS	EPSILON		# EPSILON IS LIMITED TO A MAX. OF .42265
GOODEPS1	CA	EPSILON
		EXTEND
		MP	0.35356
		AD	.7071
		TS	COEFFR		# IN THIS CASE WHERE IR IS GREATER THAN
		CS	POSMAX		# IQ, COEFFQ=-.707(1+.5EPSILON)(1-EPSILON)
		AD	EPSILON		# AND COEFFR=.707(1+.5EPSILON)
		EXTEND
		MP	COEFFR
		TS	COEFFQ
		TCF	JACCUV
BIGIQ		EXTEND			# EPSILON IS DEFINED AS 1-IR/IQ FOR IQ
		DV	1JACCR		# GREATER THAN IR.  -EPSILON IS COMPUTED
		TS	-EPSILON	# RATHER THAN EPSILON FOR CONVENIENCE
		CS	-EPSILON
		AD	-EPSMAX
		EXTEND
		BZMF	GOODEPS2
		CA	-EPSMAX
		TS	-EPSILON	# EPSILON IS LIMITED TO A MAX. OF .42265
# Page 1489
GOODEPS2	CA	-EPSILON
		EXTEND
		MP	0.35356
		AD	-.7071
		TS	COEFFQ		# IN THIS CASE WHERE IQ IS GREATER THAN
		CS	-EPSILON	# IR, COEFFQ=-.707(1+.5EPSILON) AND
		AD	NEGMAX		# COEFFR=.707(1+.5EPSILON)(1-EPSILON)
		EXTEND
		MP	COEFFQ
		TS	COEFFR
JACCUV		CS	COEFFQ
		EXTEND
		MP	1JACCQ		# 1JACCQ IS SCALED AT PI/4
		TS	1JACCU		# 1JACCU USED AS TEMPORARY STORAGE
		CA	COEFFR
		EXTEND
		MP	1JACCR
		AD	1JACCU
		EXTEND
		MP	BIT14		# SCALING CHANGED FROM PI/4 TO PI/2
		TS	1JACCU
		TS	1JACCV		# SCALED AT PI/2 RADIANS/SEC(2)
		CCS	MPAC		# COMPUTE L,PVT-CG IF IN DESCENT
		CAF	ZERO		# ZERO SWITCHES AND GO TO 1/ACCONT IN
		TS	ALLOWGTS	#	ASCENT
		TCF	1/ACCONT -1

		CS	TWO
		TS	MPAC
		CS	ONE
		TS	MPAC 	+1
		TCF	STCTR1

# THIS SECTION COMPUTES THE RATE OF CHANGE OF ACCELERATION DUE TO THE ROTATION OF THE GIMBALS.  THE EQUATION
# IMPLEMENTED IN BOTH THE Y-X PLANE AND THE Z-X PLANE IS -- D(ALPHA)/DT = TL/I*D(DELTA)/DT, WHERE
#	T = ENGINE THRUST FORCE
#	L = PIVOT TO CG DISTANCE OF ENGINE
#	I = MOMENT OF INERTIA

LRESC		CAE	ABDELV		# SCALED AT 2(13) CM/SEC(2)
		EXTEND
		MP	MASS		# SCALED AT B+16 KGS
		TC	DVOVSUB		# GET QUOTIENT WITH OVERFLOW PROTECTION
		ADRES	GFACTM

# MASS IS DIVIDED BY ACCELERATION OF GRAVITY IN ORDER TO MATCH THE UNITS OF IXX,IYY,IZZ, WHICH ARE SLUG-FT(2).
# THE RATIO OF ACCELERATION FROM PIPAS TO ACCELERATION OF GRAVITY IS THE SAME IN METRIC OR ENGINEERING UNITS, SO
# THAT IS UNCONVERTED.  2.20462 CONVERTS KG. TO LB.  NOW T IN IN A SCALED AT 2(14).

		EXTEND
		MP	L,PVT-CG	# SCALED AT 8 FEET.
# Page 1490		
		INHINT
		TS	MPAC
		EXTEND
		MP	1JACCR
		TC	DVOVSUB		# GET QUOTIENT WITH OVERFLOW PROTECTION
		ADRES	TORKJET1

		TS	ACCDOTR		# SCALED AT PI/2(7)
		CA	MPAC
		EXTEND
		MP	1JACCQ
		TC	DVOVSUB		# GET QUOTIENT WITH OVERFLOW PROTECTION
		ADRES	TORKJET1

SPSCONT		TS	ACCDOTQ		# SCALED AT PI/2(7)
		EXTEND
		MP	DGBF		# .3ACCDOTQ SCALED AT PI/2(8)
		TS	KQ
		CAE	ACCDOTR		# .3ACCDOTR AT PI/2(8)
		EXTEND
		MP	DGBF
		TS	KRDAP
		EXTEND			# NOW COMPUTE QACCDOT, RACCDOT, THE SIGNED
		READ	CHAN12		# JERK TERMS.  STORE CHANNEL 12. WITH GIMBAL
		TS	MPAC 	+1	# DRIVE BITS 9 THROUGH 12 SET LOOP
		CAF	BIT2		# INDEX TO COMPUTE RACCDOT, THEN QACCDOT.
		TCF	LOOP3
		CAF	ZERO		# ACCDOTQ AND ACCDOTR ARE NOT NEGATIVE,
LOOP3		TS	MPAC		# BECAUSE THEY ARE MAGNITUDES
		CA	MPAC 	+1
		INDEX	MPAC		# MASK CHANNEL IMAGE FOR ANY GIMBAL MOTION
		MASK	GIMBLBTS
		EXTEND
		BZF	ZACCDOT		# IF NONE, Q(R)ACCDOT IS ZERO.
		CA	MPAC 	+1
		INDEX	MPAC		# GIMBAL IS MOVING.  IS ROTATION POSITIVE.
		MASK	GIMBLBTS +1
		EXTEND
		BZF	FRSTZERO	# IF NOT POSITIVE, BRANCH
		INDEX	MPAC		# POSITIVE ROTATION, NEGATIVE Q(R)ACCDOT.
		CS	ACCDOTQ
		TCF	STACCDOT
FRSTZERO	INDEX	MPAC		# NEGATIVE ROTATION, POSITIVE Q(R)ACCDOT.
		CA	ACCDOTQ
		TCF	STACCDOT
ZACCDOT		CAF	ZERO
STACCDOT	INDEX	MPAC
		TS	QACCDOT		# STORE Q(R)ACCDOT.
		CCS	MPAC
		TCF	LOOP3 	-1	# NOW DO QACCDOT.
# Page 1491
		CS	DAPBOOLS	# IS GIMBAL USABLE?
		MASK	USEQRJTS
		EXTEND
		BZF	DOWNGTS		# NO. BE SURE THE GIMBAL SWITCHES ARE DOWN
		CS	T5ADR		# YES.  IS THE DAP RUNNINT?
		AD	PAXISADR
		EXTEND
		BZF	+2
		TCF	DOWNGTS		# NO. BE SURE THE GIMBAL SWITCHES ARE DOWN
		CCS	INGTS		# YES.  IS GTS IN CONTROL?
		TCF	DOCKTEST	# YES.  PROCEED WITH 1/ACCS.
		TC	IBNKCALL	# NO. NULL OFFSET AND FIND ALLOWGTS
		CADR	TIMEGMBL

DOCKTEST	CCS	DOCKTEMP	# BYPASS 1/ACCONT WHEN DOCKED.
		TCF	1/ACCRET
		TCF	1/ACCONT

# Page 1492
# SUBROUTINE:	DVOVSUB
# AUTHOR:	C. WORK, MOD 0, 12 JUNE 68
# PURPOSE:	THIS SUBROUTINE PROVIDES A SINGLE-PRECISION MACHINE LANGUAGE DIVISION OPERATION WHICH RETURNS
#		(1) THE QUOTIENT, IF THE DIVISION WAS NORMAL.
#		(2) NEGMAX, IF THE QUOTIENT WAS IMPROPER AND NEGATIVE.
#		(3) POSMAX, IF THE QUOTIENT WAS IMPROPER AND POSITIVE OR IF THERE WAS A ZERO DIVISOR.
#		THE CALLING PROGRAM IS PRESUMED TO BE A JOB IN THE F BANK WHICH CONTAINS DVOVSUB.  E BANK MUST BE 6.
#		THE DIVISOR FOR THIS ROUTINE MAY BE IN EITHER FIXED OR ERASABLE STORAGE.  SIGN AGREEMENT IS
#		ASSUMED BETWEEN THE TWO HALVES OF THE DIVIDEND.  (THIS IS CERTAIN IF THE A AND L REGISTERS ARE THE
#		RESULT OF A MULTIPLICATION OPERATION.)
# CALL SEQUENCE:	L	TC	DVOVSUB
#			L +1	ADRES	(DIVISOR)
#			L +2	RETURN HERE, WITH RESULT IN A,L
# INPUT:	DIVIDEND IN A,L (SIGN AGREEMENT ASSUMED), DIVISOR IN LOCATION DESIGNATED BY "ADRES".
#		DIVISOR MAY BE IN THE DVOVSUB FBANK,FIXED-FIXED FBANK,EBANK 6, OR UNSWITCHED ERASABLE.
# OUTPUT:	QUOTIENT AND REMAINDER, OR POSMAX (NEGMAX), WHICHEVER IS APPROPRIATE.
# DEBRIS:	SCRATCHX,SCRATCHY,SCRATCHZ,A,L	(NOTE: SCRATCHX,Y,Z ARE EQUATED TO MPAC +4,+5, AND +6.)
# ABORTS OR ALARMS:  NONE
# EXITS:	TO THE CALL POINT +2.
# SUBROUTINES CALLED:  NONE.

DVOVSUB		TS	SCRATCHY	# SAVE UPPER HALF OF DIVIDEND
		TS	SCRATCHX
		INDEX	Q		# OBTAIN ADDRESS OF DIVISOR.
		CA	0
		INCR	Q		# STEP Q FOR PROPER RETURN SEQUENCE.
		INDEX	A
		CA	0		# PICK UP THE DIVISOR.
		EXTEND			# RETURN POSMAX FOR A ZERO DIVISOR.
		BZF	MAXPLUS

		TS	SCRATCHZ	# STORE DIVISOR.

		CCS	A		# GET ABS(DIVISOR) IN THE A REGISTER.
		AD	BIT1
		TCF	ZEROPLUS
		AD	BIT1

ZEROPLUS	XCH	SCRATCHY	# STORE ABS(DIVISOR).  PICK UP TOP HALF OF
		EXTEND			# DIVIDEND.
		BZMF	GOODNEG		# GET -ABS(DIVIDEND)
# Page 1493
		CS	A

GOODNEG		AD	SCRATCHY	# ABS(DIVISOR) - ABS(DIVIDEND)
		EXTEND
		BZMF	MAKEMAX		# BRANCH IF DIVISION IS NOT PROPER.

		CA	SCRATCHX	# RE-ESTABLISH THE DIVIDEND
		EXTEND
		DV	SCRATCHZ	# QUOTIENT IN THE A, REMAINDER IN L.
		TC	Q		# RETURN TO CALLER.

MAKEMAX		CCS	SCRATCHX	# DETERMINE THE SIGN OF THE QUOTIENT.
		CCS	SCRATCHZ	# SCRATCHX AND SCRATCHZ ARE NON-ZERO.
		TCF	MAXPLUS
		CCS	SCRATCHZ
		CAF	NEGMAX		# +,- OR -,+
		TC	Q
MAXPLUS		CAF	POSMAX		# -,- OR +,+
		TC	Q

# COEFFICIENTS FOR THE JET ACCELERATION CURVE FITS
# THE CURVE FITS ARE OF THE FORM --
#
#	1JACC = A/(MASS + C) + B
#
# A IS SCALED AT PI/4 RAD/SEC**2 B+16KG, B IS SCALED AT PI/4 RAD/SEC**2, AND C IS SCALED AT B +16 KG.
#
# THE CURVE FIT FOR L,PVT-CG IS OF THE SAME FORM, EXCEPT THAT A IS SCALED AT 8 FT B+16 KG, B IS SCALED AT 8 FT,
# AND C IS SCALED AT B+16 KG.

		2DEC	+.0410511917	# L		A		DESCENT
		
INERCONA	2DEC	+.0059347674	# 1JACCP	A		DESCENT

		2DEC	+.0014979264	# 1JACCQ	A		DESCENT
		
		2DEC	+.0010451889	# 1JACCR	A		DESCENT
		
		2DEC	+.0065443852	# 1JACCP	A		ASCENT
		
		2DEC	+.0035784354	# 1JACCQ	A		ASCENT
		
		2DEC	+.0056946631	# 1JACCR	A		ASCENT
		
		DEC	+.155044	# L		B		DESCENT
		DEC	-.025233	# L		C		DESCENT
# Page 1494
INERCONB	DEC	+.002989	# 1JACCP	B		DESCENT
INERCONC	DEC	+.008721	# 1JACCP	C		DESCENT
		DEC	+.018791	# 1JACCQ	B		DESCENT
		DEC	-.068163	# 1JACCQ	C		DESCENT
		DEC	+.021345	# 1JACCR	B		DESCENT
		DEC	-.066027	# 1JACCR	C		DESCENT

		DEC	+.000032	# 1JACCP	B		ASCENT
		DEC	-.006923	# 1JACCP	C		ASCENT
		DEC	+.162862	# 1JACCQ	B		ASCENT
		DEC	+.002588	# 1JACCQ	C		ASCENT
		DEC	+.009312	# 1JACCR	B		ASCENT
		DEC	-.023608	# 1JACCR	C		ASCENT

GIMBLBTS	OCTAL	01400
		OCTAL	01000
		OCTAL	06000
		OCTAL	04000
DGBF		DEC	0.6		# .3 SCALED AT 1/2
0.35356		DEC	0.35356		# .70711 SCALED AT 2
GFACTM		OCT	337		# 979.24/2.20462 AT B+15
.7071		DEC	.70711
-.7071		DEC	-.70711
-EPSMAX		DEC	-.42265

# CSM-DOCKED INERTIA COMPUTATIONS

DOCKED		CA	ONE		# COEFTR  = 1 FOR INERTIA COEFFICIENTS
SPSLOOP1	TS	COEFCTR		#         = 7 FOR CG COEFFICIENTS
		CA	ONE		# MASSCTR = 1 FOR CSM
		TS	MASSCTR		#         = 0 FOR LEM

		INDEX	COEFCTR
		CA	COEFF 	-1	# COEFF -1 = C
		EXTEND
		MP	LEMMASS
		EXTEND
		MP	CSMMASS		# LET X = CSMMASS AND Y = LEMMASS

		INDEX	COEFCTR
		AD	COEFF		# COEFF = F
		TS	MPAC		# MPAC = C X Y + F
		TCF	+4

SPSLOOP2	TS	MASSCTR		# LOOP TWICE THROUGH HERE TO OBTAIN
		EXTEND			# MPAC = MPAC + (A X +D)X + (B Y +E)Y
		DIM	COEFCTR		#		 LOOP #1     LOOP #2
		INDEX	COEFCTR
		CA	COEFF 	+2	# COEFF +2 = A OR B
		EXTEND
# Page 1495
		INDEX	MASSCTR
		MP	LEMMASS
		INDEX	COEFCTR
		AD	COEFF 	+4	# COEFF +4 = E OR D
		EXTEND
		INDEX	MASSCTR
		MP	LEMMASS
		ADS	MPAC

		CCS	MASSCTR
		TCF	SPSLOOP2
		CCS	COEFCTR		# IF COEFCTR IS POS, EXIT FROM LOOP WITH
		TCF	+7		# CG X DELDOT = MPAC X 4 PI RAD-CM/SEC
TORQCONS	2DEC	0.51443 B-14	# CORRESPONDS TO 500 LB-FT

		CA	MPAC
		TS	MPAC 	+1	# INERTIA = (MPAC +1) X 2(38) KG-CM(2)
		CA	SEVEN
		TCF	SPSLOOP1

		CA	1JACCCON	# 1JACC=1JACCCON/MASS
		ZL
		TC	DVOVSUB
		ADRES	MASS
		TS	1JACC		# SCALED AT PI/4

		CA	POSMAX		# SET INVERSE JET ACCELERATIONS TO POSMAX,
		TS	1/ANETP		# WHICH CORRESPONDS TO ACCEL. OF 1.4 D/SS.
		TS	1/ANET2 +1
		TS	1/ANET2 +2
		TS	1/ANET2 +17D
		TS	1/ANET2 +18D
		EXTEND
		DCA	TORQCONS
		EXTEND
		DV	MPAC 	+1
		INHINT
		TS	1JACCQ		# SCALED AT PI/4
		TS	1JACCR

		CA	-.7071
		TS	COEFFQ		# COEFFQ AND COEFFR ARE CHOSEN TO MAKE U-
		CA	.7071		# AND V-AXES ORTHOGONAL FOR DOCKED CASE
		TS	COEFFR
		CA	MASS		# SCALED AT 2(16) KG
		EXTEND
		MP	MPAC		# SCALED AT 4 PI RAD-CM/SEC
		EXTEND
		MP	ABDELV		# SCALED AT 2(13) CM/SEC(2)
		TC	DVOVSUB		# GET QUOTIENT WITH OVERFLOW PROTECTION
# Page 1496
		ADRES	MPAC 	+1

		TS	ACCDOTR
		TCF	SPSCONT		# CONTINUE K, KSQ CALCULATIONS

1JACCCON	OCT	00167		# SCALED AT PI/4X2(16) RAD/SEC(2)-KG

#                                               2     2
# COEFFICIENTS FOR CURVE FIT OF THE FORM Z = A X  +B Y  +C X Y +D X +E Y +F

COEFF		DEC	.19518		# C  COEFFICIENT OF INERTIA
		DEC	-.00529		# F             "
		DEC	-.17670		# B             "
		DEC	-.03709		# A             "
		DEC	.06974		# E             "
		DEC	.02569		# D             "

		DEC	.20096		# C  COEFFICIENT OF CG
		DEC	.13564		# F          "
		DEC	.75704		# B          "
		DEC	-.37142		# A          "
		DEC	-.63117		# E          "
		DEC	.41179		# D          "

# ASSIGNMENT OF TEMPORARIES FOR 1/ACCS (EXCLUDING 1/ACCONT)
# MPAC, MPAC +1, MPAC +2  USED EXPLICITLY
COEFCTR 	EQUALS	MPAC 	+4
MASSCTR		EQUALS	MPAC 	+5
SCRATCHX	EQUALS	MPAC 	+4	# SCRATCH AREA FOR DVOVSUB ROUTINE.
SCRATCHY	EQUALS	SCRATCHX +1
SCRATCHZ	EQUALS	SCRATCHX +2

DOCKTEMP	EQUALS	MPAC 	+3	# RECORD OF CSMDOCKED BIT OF DAPBOOLS
EPSILON		EQUALS	MPAC 	+1
-EPSILON	EQUALS	EPSILON
-.1875		DEC	-.18750

# Page 1497
		BANK	20
		SETLOC	DAPS3
		BANK

		EBANK=	AOSQ

		COUNT*	$$/DAPAO

	-1	TS	INGTS		# ZERO INGTS IN ASCENT
1/ACCONT	CA	DB		# INITIALIZE DBVAL1,2,3
		EXTEND
		MP	BIT13
		TS	L		# 0.25 DB
		AD	A
		TS	DBVAL3		# 0.50 DB
		CS	DBVAL1
		AD	L
		TS	DBVAL2		# -.75 DB

GETAOSUV	INHINT
		CAE	AOSR		# COMPUTE ASOU AND AOSV BY ROTATING
		TS	L		#	AOSQ AND AOSR.
		CAE	AOSQ
		TC	IBNKCALL
		CADR	ROT-TOUV
		DXCH	AOSU

		RELINT
		CA	DAPBOOLS
		MASK	DRIFTBIT	# ZERO DURING ULLAGE AND POWERED FLIGHT.
		CCS	A		# IF DRIFTING LIGHT,
		CA	ONE		# 	SET DRIFTER TO 1
		TS	DRIFTER		# SAVE TO TEST FOR DRIFTING FLIGHT LATER
		AD	ALLOWGTS	# NON-ZERO IF DRIFT OR GTS NEAR
		CCS	A
		CA	FLATVAL		# DRIFTING FLIGHT, STORE .8 IN FLAT
		TS	FLATEMP		# IN POWERED FLIGHT, STORE ZERO IN FLAT
		EXTEND
		BZF	DOPAXIS		# IF POWERED AND NO GTS, START P AXIS,
		CCS	DRIFTER		# OTHERWISE SET ZONE3LIM
		CA	ZONE3MAX	# 17.5 MS, SCALED AT 4 SECONDS.
		TS	Z3TEM

DOPAXIS		CA	1JACC		# 1JACC AT PI/4 = 2JACC AT PI/2 =
					# ANET AT PI/2 = ANET/ACOAST AT 2(6).
		AD	BIT9		# 1 + ANET/ACOAST AT 2(6)
		TS	FUNTEM

		CA	1JACC
# Page 1498
		TC	INVERT
		INHINT			# P AXIS DATA MUST BE CONSISTENT
		TS	1/ANETP		# SCALED AT 2(7)/PI.
		TS	1/ANETP +1

		CS	BIT9		# -1 AT 2(6)
		EXTEND
		MP	1/ANETP		# -1/ANET AT 2(13)/PI
		EXTEND
		DV	FUNTEM		# -1/(ANET + ANET**2/ACOAST) AT 2(7)/PI
		TS	PACCFUN
		TS	PACCFUN +1

		CA	1/.03		# NO AOS FOR P AXIS, ACOAST = AMIN
		TS	1/ACOSTP
		TS	1/ACOSTP +1
		RELINT

		ZL
		CCS	DRIFTER
		DXCH	AOSU		# ZERO AOSU,V IF IN DRIFT, JUST TO BE SURE

UAXIS		CA	ZERO		# DO U AXIS COMPUTATIONS
		TS	UV		# ZERO FOR U AXIS, ONE FOR V AXIS.

BOTHAXES	TS	SIGNAOS		# CODING COMMON TO U,V AXES
		INDEX	UV
		CCS	AOSU		# PICK UP ABS(AOSU OR AOSV)
		AD	ONE		# RESTORE TO PROPER VALUE
		TCF	+3		# AND LEAVE SIGNAOS AT ZERO
		AD	ONE		# NEGATIVE, RESTORE TO PROPER VALUE
		INCR	SIGNAOS		# AND SET SIGNAOS TO ONE TO SHOW AOS NEG
		TS	ABSAOS		# SAVE ABS(AOS)
		CS	SIGNAOS
		TS	-SIGNAOS	# USED AS AN INDEX

		CA	DBVAL1		# SET DB1, DB2 TO DBVAL1 (= DB)
		TS	DBB1
		TS	DBB2

		CA	ABSAOS		# TEST MAGNITUDE OF ABS(AOS)
		AD	-.03R/S2
		EXTEND
		BZMF	NOTMUCH		# ABS(AOS) LESS THAN AMIN
BIGAOS		CCS	FLATEMP		# AGS(AOS) GREATER THAN AMIN
		TCF	SKIPDB1		# I DRIFT OR GTS, DO NOT COMPUTE DB

		CA	DBVAL1
		INDEX	-SIGNAOS
# Page 1499
		ADS	DBB2		# DB2(1) = 2 DB
		INDEX	SIGNAOS
		TS	DBB4		# DB4(3) = 1 DB
		CA	-.1875		# -.1875 PI/2 RAD/SEC(2) SCALED AT PI/2
		AD	ABSAOS		# ABSAOS IS SCALED AT PI/2
		EXTEND
		BZMF	+3
		CS	DBVAL3		# -.5 DB
		TCF	DBONE
		CS	ABSAOS
		DOUBLE
		DOUBLE
		AD	BIT14
		DOUBLE			# 1-8 ABSAOS.  (8 IS 16/PI SCALED AT 2/PI)
		EXTEND
		MP	DB
DBONE		INDEX	SIGNAOS		# DB1(2)=(1-8 ABSAOS) DB.  IF ABSAOS IS
		TS	DBB1		# GREATER THAN .1875 THEN DB1(2) = -.5 DB
		CA	DBVAL2
		INDEX	-SIGNAOS
		TS	DBB3		# DB3(4) = -.75 DB

SKIPDB1		CA	ABSAOS		# ABS(AOS) GREATER THAN AMIN, SO IT IS
		EXTEND
		MP	BIT12
		AD	ABSAOS		# (9/8) ABSAOS.
		TC	INVERT		# ALL RIGHT TO DIVIDE
		INDEX	-SIGNAOS
		TS	1/ACOSTT +1	# 1/ACOASTPOS(NET) = 1/ABS(AOS)
		CA	1/.03
		INDEX	SIGNAOS
		TS	1/ACOSTT	# 1/ACOASTNEG(POS) = 1/AIN

		CA	ABSAOS
		AD	1JACCU
		AD	1JACCU		# 2 JACC + ABS(AOS)
		AD	BIT9		# MAXIMUM VALUE IN COMPUTATIONS
		TS	A		# TEST FOR OVERFLOW
		TCF	SKIPDB2		# NO OVERFLOW, DO NORMAL COMPUTATION

		CA	ABSAOS		# RESCALE TO PI TO PREVENT OVERFLOW
		EXTEND
		MP	BIT14
		AD	1JACCU		# 1 JACC AT PI/2 = 2JACC AT PI
		TS	ANET		# ANETPOS(NEG) MAX SCALED AT PI =
					# ANETPOS(NEG) MAX/ACOASTNEG(POS) AT 2(7)
		AD	BIT8		# 1 + ANETPOS/ACOASTNEG AT 2(7)
		XCH	ANET		# SAVE IN ANET, WHILE PICKING UP ANET
		TC	INVERT
		EXTEND
# Page 1500
		MP	BIT14		# SCALE 1/ANET AT 2(7)/PI
		TS	1/ANET

		CA	ACCHERE		# SET UP RETURN FROM COMPUTATION ROUTINE
		TS	ARET
		CS	BIT8		# -1 AT 2(7)
		TCF	DOACCFUN	# FINISH ACCFUN COMPUTATION

ACCHERE		TCF	ACCTHERE

NOTMUCH		TS	L		# ABS(AOS) LESS THAN AMIN, SAVE IN L
		CA	1/.03		# ACOASTPOS,NEG = AMIN
		TS	1/ACOSTT
		TS	1/ACOSTT +1

		CCS	FLATEMP
		TCF	SKIPDB2		# DO NOT COMPUTE DB IF DRIFT OR GTS

		CA	.0125RS		# AMIN/2
		AD	L		# L HAS ABS(AOS) - AMIN
		EXTEND			# RESULT IS ABS(AOS)- AMIN/2
		BZMF	NOAOS		# ABS(AOS) LESS THAN AMIN/2
		
SOMEAOS		CA	DBVAL3		# AMIN/2 LT ABS(AOS) LT AMIN
		INDEX	-SIGNAOS
		TS	DBB3		# DB3(4) = DB/2
		AD	A
		INDEX	SIGNAOS
		TS	DBB4		# DB4(3) = DB
		TCF	SKIPDB2

NOAOS		CA	DBVAL1
		TS	DBB3		# DB3,4 = DB
		TS	DBB4

SKIPDB2		CA	ABSAOS		# ANETPOS(NEG) MAX = 2 JACC + ABS(AOS)
		AD	1JACCU
		AD	1JACCU
		TS	ANET		# CANNOT OVERFLOW HERE
CL1/NET+	TC	DO1/NET+	# COMPUTE 1/ANET, ACCFUN

ACCTHERE	INDEX	-SIGNAOS
		TS	Z5TEM 	+2	# STORE ACCFUN IN TEMPORARY BUFFER
		CA	1/ANET
		INDEX	-SIGNAOS
		TS	1/ATEM2 +2	# STORE 1/ANET IN TEMPORARY BUFFER

		CA	ABSAOS		# SEE IF OVERFLOW IN MIN CASE
		AD	1JACCU
# Page 1501		
		AD	BIT9		# MAXIMUM POSSIBLE VALUE
		TS	A		# OVERFLOW POSSIBLE BUT REMOTE
		TCF	+2
		CA	POSMAX		# IF OVERFLOW, TRUNCATE TO PI/2
		AD	-.03R/S2	# RESTORE TO CORRECT VALUE
		TS	ANET
		TC	DO1/NET+	# COMPUTE 1/ANET, ACCFUN

		INDEX	-SIGNAOS	# STORE MIN VALUES JUST AS MAX VALUES
		TS	Z5TEM
		CA	1/ANET
		INDEX	-SIGNAOS
		TS	1/ATEM2

		CS	ABSAOS		# NOW DO NEG(POS) CASES
		AD	1JACCU
		AD	1JACCU		# ANETNEG(POS) MAX
		TC	1/ANET-		# COMPUTE 1/ANET, ACCFUN, AND ACCSW
		INDEX	SIGNAOS		# STORE NEG(POS) VALUES JUST AS POS(NEG)
		TS	Z1TEM 	+2
		TS	L		# SAVE IN L FOR POSSIBLE FUTURE USE
		CA	1/ANET
		INDEX	SIGNAOS
		TS	1/ATEM1 +2
		CS	ABSAOS
		AD	1JACCU		# 1/ANETNEG(POS) MIN
		TS	ANET
		AD	-.03R/S2	# TEST FOR AMIN
		EXTEND			# IF ANET LESS THAN AMIN, STORE MAX JET
		BZMF	FIXMIN		# VALUES FOR MIN JETS AND SET ACCSW

		TC	1/NETMIN	# OTHERWISE DO MIN JET COMPUTATIONS
STMIN-		INDEX	SIGNAOS		# STORE VALUES
		TS	Z1TEM
		CA	1/ANET
		INDEX	SIGNAOS
		TS	1/ATEM1

		INDEX	UV
		CA	+UMASK
		MASK	CH5MASK		# TEST FOR +U (+V) JET FAILURES
		EXTEND
		BZF	FAIL-
		CA	1/ATEM2		# REPLACE FUNCTION VALUES DEPENDING ON THE
		TS	1/ATEM2 +2	# FAILED JET PAIR WITH CORRESPONDING ONE-
		CA	Z5TEM		# JET (OR AMIN) FUNCTION VALUES
		TS	Z5TEM 	+2
FAIL-		INDEX	UV
# Page 1502
		CA	-UMASK
		MASK	CH5MASK		# TEST FOR -U (-V) JET FAILURES
		EXTEND
		BZF	DBFUN
		CA	1/ATEM1		# REPLACE FUNCTION VALUES DEPENDING ON THE
		TS	1/ATEM1 +2	# FAILED JET PAIR WITH CORRESPONDING ONE-
		CA	Z1TEM		# JET (OR AMIN) FUNCTION VALUES
		TS	Z1TEM 	+2

DBFUN		CS	DBB3		# COMPUTE AXISDIST
		AD	DBB1
		AD	FLATEMP
		TS	AXDSTEM
		CS	DBB4
		AD	DBB2
		AD	FLATEMP
		TS	AXDSTEM +1

		INHINT
		CCS	UV		# TEST FOR U OR V AXIS
		TCF	STORV		# V AXIS 	STORE V VALUES

		CA	ACCSW		# U AXIS 	STORE U VALUES
		TS	ACCSWU

		CA	NINE		# TRANSFER 10 WORDS VIA GENTRAN
		TC	GENTRAN +1
		ADRES	1/ATEM1		# TEMPORARY BUFFER
		ADRES	1/ANET1		# THE REAL PLACE

		RELINT
		DXCH	DBB1		# SAVE U DBS FOR LATER STORING
		DXCH	UDB1
		DXCH	DBB4
		DXCH	UDB4

		DXCH	AXDSTEM
		DXCH	UAXDIST

		CA	ONE		# NOW DO V AXIS
		TS	UV
		CA	ZERO
		TCF	BOTHAXES	# AND DO IT AGAIN

STORV		CA	ACCSW		# STORE V AXIS VALUES
		TS	ACCSWV
		CA	NINE
		TC	GENTRAN +1
# Page 1503		
		ADRES 	1/ATEM1		# TEMPORARY BUFFER
		ADRES	1/ANET1 +16D	# THE REAL PLACE

					# NOW STORE DEADBANDS FOR ALL AXES
		DXCH	FLATEMP		# FLAT AND ZONE3LIM
		DXCH	FLAT

		CA	DBVAL1		# COMPUTE P AXIS DEADBANDS
		TS	PDB1
		TS	PDB2
		AD	FLAT
		TS	PDB3
		TS	PDB4
		CA	ZERO
		TS	PAXDIST
		TS	PAXDIST +1

		CCS	FLAT
		TCF	DRFDB		# DRIFT OR GTS -- COMPUTE DBS

		DXCH	UDB1		# STORE U DEADBANDS
		DXCH	FIREDB		# CANNOT USE GENTRAN BECAUSE OF RELINT
		DXCH	UDB4
		DXCH	COASTDB
		DXCH	UAXDIST
		DXCH	AXISDIST
		DXCH	DBB1		# STORE V AXIS DEADBANDS
		DXCH	FIREDB 	+16D	# COULD USE GENTRAN IF DESIRED
		DXCH	DBB4
		DXCH	COASTDB +16D
		DXCH	AXDSTEM
		DXCH	AXISDIST +16D

		TCF	1/ACCRET +1	# ALL DONE
DRFDB		CA	DBVAL1		# DRIFT DEADBANDS
		TS	FIREDB
		TS	FIREDB 	+1
		TS	FIREDB 	+16D
		TS	FIREDB 	+17D
		AD	FLAT
		TS	COASTDB
		TS	COASTDB +1
		TS	COASTDB +16D
		TS	COASTDB +17D
		CA	ZERO
		TS	AXISDIST
		TS	AXISDIST +1
		TS	AXISDIST +16D
		TS	AXISDIST +17D

# Page 1504
1/ACCRET	INHINT
		CS	DAPBOOLS	# SET BIT TO INDICATE DATA GOOD.
		MASK	ACCSOKAY
		ADS	DAPBOOLS
		RELINT
		CA	ACCRETRN
		TC	BANKJUMP	# RETURN TO CALLER

INVERT		TS	HOLD		# ROUTINE TO INVERT -INPUT AT PI/2
		CA	BIT9		# 1 AT 2(6)
		ZL			# ZERO L FOR ACCURACY AND TO PREVENT OVFLO
		EXTEND
		DV	HOLD
		TC	Q		# RESULT AT 2(7)/PI

DOWNGTS		CAF	ZERO		# ZERO SWITCHES WHEN USEQRJTS BIT IS UP
		TS	ALLOWGTS	#	OR DAP IS OFF
		TS	INGTS
		TCF	DOCKTEST

1/ANET-		ZL
		LXCH	ACCSW		# ZERO ACCSW
		TS	ANET		# SAVE ANET
		AD	-.03R/S2	# TEST FOR MIN VALUE
		EXTEND
		BZMF	NETNEG		# ANET LESS THAN AMIN, SO FAKE IT
1/NETMIN	CA	ANET
		EXTEND
		INDEX	-SIGNAOS
		MP	1/ACOSTT +1	# ANETNEG(POS)/ACOASTPOS(NEG) AT 2(6)

# THE FOLLOWING CODING IS VALID FOR BOTH POS OR NEG
#	VALUES OF AOS

DO1/NET+	AD	BIT9		# 1 + ANET/ACOAST AT 2(6)
		XCH	ANET		# SAVE AND PICK UP ANET
		EXTEND
		QXCH	ARET		# SAVE RETURN
		TC	INVERT
		TS	1/ANET		# 1/ANET AT 2(7)/PI
		CS	BIT9		# -1 AT 2(6)
DOACCFUN	EXTEND
		MP	1/ANET		# -1/ANET AT 2(13)/PI
		EXTEND
		DV	ANET		# ACCFUN AT 2(7)/PI
		TC	ARET		# RETURN

NETNEG		CS	-.03R/S2	# ANET LESS THAN AMIN -- SET EQUAL TO AMIN
		TS	ANET
# Page 1505		
		TCF	1/NETMIN +1	# CONTINUE AS IF NOTHING HAPPENED.

FIXMIN		CCS	SIGNAOS
		CA	TWO		# IF AOS NEG, ACCSW = +1
		AD	NEGONE		# IF AOS POS, ACCSW = -1
		TS	ACCSW
		AD	UV		# IF ACCSW = +1, TEST FOR +U (+V) JET FAIL
		INDEX	A		# IF ACCSW = -1, TEST FOR -U (-V) JET FAIL
		CA	-UMASK 	+1
		MASK	CH5MASK
		EXTEND
		BZF	+4
		CS	-.03R/S2	# JET FAILURE -- CANNOT USE 2-JET VALUES
		TS	ANET		# ANET = AMIN
		TCF	STMIN- 	-1	# CALCULATE FUNCTIONS USING AMIN
		CA	L		# L HAS ACCFUN
		TCF	STMIN-		# STORE MAX VALUES FOR MIN JETS

# ERASABLE ASSIGNMENTS FOR 1/ACCONT

1/ANETP		EQUALS	BLOCKTOP +2
1/ACOSTP	EQUALS	BLOCKTOP +4
PACCFUN		EQUALS	BLOCKTOP +8D
PDB1		EQUALS	BLOCKTOP +10D
PDB2		EQUALS	BLOCKTOP +11D
PDB4		EQUALS	BLOCKTOP +12D
PDB3		EQUALS	BLOCKTOP +13D
PAXDIST		EQUALS	BLOCKTOP +14D

ACCSW		EQUALS	VBUF		# EXECUTIVE TEMPORARIES
					# CANNOT DO CCS NEWJOB DURING 1/ACCS
1/ATEM1		EQUALS	ACCSW 	+1	# TEMP BUFFER FOR U AND V AXES
1/ATEM2		EQUALS	1/ATEM1 +1
1/ACOSTT	EQUALS	1/ATEM1 +4
Z1TEM		EQUALS	1/ATEM1 +6
Z5TEM		EQUALS	1/ATEM1 +7

UDB1		EQUALS	1/ATEM1 +10D	# UAXIS DEADBAND BUFFER
UDB2		EQUALS	1/ATEM1 +11D
UDB4		EQUALS	1/ATEM1 +12D
UDB3		EQUALS	1/ATEM1 +13D
UAXDIST		EQUALS	1/ATEM1 +14D

DBB1		EQUALS	1/ATEM1 +16D	# TEMP DEADBAND BUFFER, ALSO V AXIS
DBB2		EQUALS	1/ATEM1 +17D
DBB4		EQUALS	1/ATEM1 +18D
DBB3		EQUALS	1/ATEM1 +19D
AXDSTEM		EQUALS	1/ATEM1 +20D

# Page 1506
FLATEMP		EQUALS	1/ATEM1 +22D
Z3TEM		EQUALS	1/ATEM1 +23D	# MUST FOLLOW FLATEMP

DBVAL1		EQUALS	DB
DBVAL2		EQUALS	INTB15+
DBVAL3		EQUALS	INTB15+ +1

DRIFTER		EQUALS	INTB15+ +2

UV		EQUALS	MPAC
ANET		EQUALS	MPAC 	+3
FUNTEM		EQUALS	MPAC 	+3
1/ANET		EQUALS	MPAC 	+4
ARET		EQUALS	MPAC 	+5
ABSAOS		EQUALS	MPAC 	+6
SIGNAOS		EQUALS	MPAC 	+7
-SIGNAOS	EQUALS	MPAC 	+8D
HOLD		EQUALS	MPAC 	+9D
ACCRETRN	EQUALS	FIXLOC 	-1

ZONE3MAX	DEC	.004375		# 17.5 MS (35 MS FOR 1 JET) AT 4 SECONDS
FLATVAL		DEC	.01778		# .8 AT PI/4 RAD
-.03R/S2	OCT	77377		# -PI/2(7) AT PI/2

.0125RS		EQUALS	BIT8		# PI/2(+8) AT PI/2
1/.03		EQUALS	POSMAX		# 2(7)/PI AT 2(7)/PI

PAXISADR	GENADR	PAXIS

					# THE FOLLOWING 4 CONSTANTS ARE JET
					# FAILURE MASKS AND ARE INDEXED
-UMASK		OCT	00110		# -U
		OCT	00022		# -V
+UMASK		OCT	00204		# +U
		OCT	00041		# +V
		

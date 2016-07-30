# Copyright:	Public domain.
# Filename:	TVCMASSPROP.agc
# Purpose:	Part of the source code for Colossus 2A, AKA Comanche 055.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	951-955
# Mod history:	2009-05-13 RSB	Adapted from the Colossus249/ file of the
#				same name, using Comanche055 page images.
#
# This source code has been transcribed or otherwise adapted from digitized
# images of a hardcopy from the MIT Museum.  The digitization was performed
# by Paul Fjeld, and arranged for by Deborah Douglas of the Museum.  Many
# thanks to both.  The images (with suitable reduction in storage size and
# consequent reduction in image quality as well) are available online at
# www.ibiblio.org/apollo.  If for some reason you find that the images are
# illegible, contact me at info@sandroid.org about getting access to the 
# (much) higher-quality images which Paul actually created.
#
# Notations on the hardcopy document read, in part:
#
#	Assemble revision 055 of AGC program Comanche by NASA
#	2021113-051.  10:28 APR. 1, 1969  
#
#	This AGC program shall also be referred to as
#			Colossus 2A

# Page 951
# PROGRAM NAME....MASSPROP
# LOG SECTION....TVCMASSPROP		PROGRAMMER...MELANSON (ENGEL, SCHLUNDT)
#
# FUNCTIONAL DESCRIPTION:
#
#	MASSPROP OPERATES IN TWO MODES: (1) IF LEM MASS OR CONFIGURATION ARE UPDATED (MASSPROP DOES NOT TEST
#	FOR THIS) THE ENTIRE PROGRAM MUST BE RUN THROUGH, BREAKPOINT VALUES AND DERIVATIVES OF THE OUTPUTS WITH
#	RESPECT TO CSM MASS BEING CALCULATED PRIOR TO CALCULATION OF THE OUTPUTS.  (2) OTHERWISE, THE OUTPUTS CAN BE
#	CALCULATED USING PREVIOUSLY COMPUTED BREAKPOINT VALUES AND DERIVATIVES.
#
# CALLING SEQUENCES
#
#	IF LEM MASS OR CONFIGURATION HAS BEEN UPDATED, TRANSFER TO MASSPROP, OTHERWISE TRANSFER TO FIXCW.
#		L	TC	BANKCALL or IBNKCALL
#		L+1	CADR	MASSPROP
#			OR
#		L+1	CADR	FIXCW
#		L+2	RETURNS VIA Q
#
# CALLED:  IN PARTICULAR BY DONOUN47 (JOB) AND TVCEXECUTIVE (TASK)
#
# JOBS OR TASKS INITIATED:  NONE
#
# SUBROUTINES CALLED:  NONE
#
# ERASABLE INITIALIZATION REQUIRED
#
#	LEMMASS MUST CONTAIN LEM MASS SCALED AT B+16 KILOGRAMS
#	CSMMASS MUST CONTAIN CSM MASS SCALED AT B+16 KILOGRAMS
#	DAPDATR1 MUST BE SET TO INDICATE VEHICLE CONFIGURATION.
#		BITS (15,14,13)  =  ( 0 , 0 , 1 )	LEM OFF
#				    ( 0 , 1 , 0 )	LEM ON (ASCNT,DSCNT)
#				    ( 1 , 1 , 0 )	LEM ON (ASCNT ONLY)
#
# ALARMS:  NONE
#
# EXIT:		TC	Q
#
# OUTPUTS:
#
#	(1)	IXX, SINGLE PRECISION SCALED AT B+20 IN KG-M SQ.
#	(2)	IAVG, SINGLE PRECISION SCALED AT B+20 IN KG-M SQ.
#	(3)	IAVG/TLX, SINGLE PRECISION, SCALED AT B+2 SEC-SQD
#	
#	THEY ARE STORED IN CONSECUTIVE REGISTERS IXX0, IXX1, IXX2
#	CONVERSION FACTOR:  (SLUG-FTSQ) = 0.737562 (KG-MSQ)
# Page 952
#
# OUTPUTS ARE CALCULATED AS FOLLOWS:
#
#	(1)	IF LEM DOCKED, LEMMASS IS FIRST ELIMINATED AS A PARAMETER
#
#		VARST0 = INTVALUE0 + LEMMASS(SLOPEVAL0)		IXX		BREAKPOINT VALUE
#		VARST1 = INTVALUE1 + LEMMASS(SLOPEVAL1)		IAVG		BREAKPOINT VALUE
#		VARST2 = INTVALUE2 + LEMMASS(SLOPEVAL2)		IAVG/TLX	BREAKPOINT VALUE
#
#		VARST3 = INTVALUE3 + LEMMASS(SLOPEVAL3)		IAVG/TLX	SLOPE FOR CSMMASS > 33956 LBS (SPS > 10000 LBS)
#		VARST4 = INTVALUE4 + LEMMASS(SLOPEVAL4)		IAVG		SLOPE FOR CSMMASS > 33956 LBS (SPS > 10000 LBS)
#
#		VARST5 = INTVALUE5 + LEMMASS(SLOPEVAL5)		IXX		SLOPE FOR ALL VALUES OF CSMMASS
#
#		VARST6 = INTVALUE6 + LEMMASS(SLOPEVAL6)		IAVG		SLOPE FOR CSMMASS < 33956 LBS (SPS < 10000 LBS)
#		VARST7 = INTVALUE7 + LEMMASS(SLOPEVAL7)		IAVG/TLX	SLOPE FOR CSMMASS < 33956 LBS (SPS < 10000 LBS)
#
#		VARST8 = INTVALUE8 + LEMMASS(SLOPEVAL8)		IAVG		DECREMENT TO BRKPT VALUE WHEN LEM DSCNT STAGE OFF
#		VARST9 = INTVALUE9 + LEMMASS(SLOPEVAL9)		IAVG/TLX	DECREMENT TO BRKPT VALUE WHEN LEM DSCNT STAGE OFF
#
#	(2)	IF LEM NOT DOCKED
#
#		VARST0 = NOLEMVAL0	WHERE THE MEANING AND SCALING OF VARST0
#			.		TO VARST9 ARE THE SAME AS GIVEN ABOVE
#			.
#			.		NOTE... FOR THIS CASE, VARST8,9 HAVE NO
#		VARST9 = NOLEMVAL9	MEANING (THEY ARE COMPUTED BUT NOT USED)
#
# 	(3)	THE FINAL OUTPUT CALCULATIONS ARE THEN DONE
#
#		IXX0 = VARST0 + (CSMMASS + NEGBPW)VARST5		IXX
#
#		IXX1 = VARST1 + (CSMMASS + NEGBPW)VARST(4 OR 6)		IAVG
#
#		IXX2 = VARST2 + (CSMMASS + NEGBPW)VARST(3 OR 7)		IAVG/TLX
#
# 	THE DATA USED CAME FROM THE CSM/LM SPACECRAFT OPERATIONAL DATA BOOK
#		VOL. 3, NASA DOCUMENT SNA-8-D-027 (MARCH 1968)
#
# 	PERTINENT MASS DATA:		CSM WEIGHT	(FULL)	64100 LBS.
#							(EMPTY)	23956 LBS.
#					LEM WEIGHT	(FULL)	32000 LBS.
#							(EMPTY)	14116 LBS.
#
# 	(WEIGHTS ARE FROM AMMENDMENT #1 (APRIL 24, 1968) TO ABOVE DATA BOOK)
# Page 953

		BANK	25
		SETLOC	DAPMASS
		BANK
		EBANK=	BZERO
		COUNT*	$$/MASP
		
MASSPROP	CAF	NINE		# MASSPROP USES TVC/RCS INTERRUPT TEMPS
		TS	PHI333		# SET UP TEN PASSES
		
LEMTEST		CAE	DAPDATR1	# DETERMINE LEM STATUS
		MASK	BIT13
		EXTEND
		BZF	LEMYES
		
LEMNO		INDEX	PHI333		# LEM NOT ATTACHED
		CAF	NOLEMVAL
		TCF	STOINST
		
LEMYES		CAE	LEMMASS		# LEM IS ATTACHED
		DOUBLE
		EXTEND
		INDEX	PHI333
		MP	SLOPEVAL
		DDOUBL
		INDEX	PHI333
		AD	INTVALUE
		
STOINST		INDEX	PHI333		# STORAGE INST BEGIN HERE
		TS	VARST0
		CCS	PHI333		# ARE ALL TEN PASSES COMPLETED
		TCF	MASSPROP +1	# NO: GO DECREMENT PHI333
		
DXTEST		CCS	DAPDATR1	# IF NEG, BIT15 IS 1, LEM DSCNT STAGE OFF
		TCF	FIXCW
		TCF	FIXCW
		DXCH	VARST0 +8D
		DAS	VARST0 +1
		CA	DXITFIX
		ADS	VARST0 +7
		
FIXCW		CAF	BIT2		# COMPUTATION PHASE BEGINS HERE. SET UP
		TS	PHI333		# THREE PASSES
		TS	PSI333
		
		CAE	CSMMASS		# GET DELTA CSM WEIGHT:  SIGN DETERMINES
		AD	NEGBPW		# SLOPE LOCATIONS.
		DOUBLE
		TS	TEMP333
# Page 954
		EXTEND
		BZMF	PEGGY		# DETERMINE CORRECT SLOPE
		CAF	NEG2
		TS	PHI333
		
PEGGY		INDEX	PHI333		# ALL IS READY:  CALCULATE OUTPUTS NOW
		CAE	VARST5		# GET SLOPE
		EXTEND
		MP	TEMP333		# MULT BY DELTA CSM WEIGHT
		DOUBLE
		INDEX	PSI333
		AD	VARST0		# ADD BREAKPOINT VALUE
		INDEX	PSI333
		TS	IXX		# ***** OUTPUTS (IXX0, IXX1, IXX2) *****
		
		CCS	PSI333		# BOOKKEEPING: MASSPROP FINISHED OR NOT
		TCF	BOKKEP2		# NO:  GO TAKE CARE OF INDEXING REGISTERS
		
		CAE	DAPDATR1	# UPDATE WEIGHT/G
		MASK	BIT14
		CCS	A
		CA	LEMMASS
		AD	CSMMASS
		TS	WEIGHT/G	# SCALED AT B+16 KILOGRAMS
ENDMASSP	TC	Q

BOKKEP2		TS	PSI333		# REDUCE PSI BY ONE
		EXTEND
		DIM	PHI333
		TCF	PEGGY
		
# Page 955
NOLEMVAL	DEC	25445 B-20
		DEC	87450 B-20
		DEC	.30715 B-2
		DEC	1.22877 E-5 B+12
		DEC	1.6096 B-6
		DEC	1.54 B-6
		DEC	7.77177 B-6
		DEC	3.46458 E-5 B+12
		
INTVALUE	DEC	26850 B-20
		DEC	127518 B-20
		DEC	.54059 B-2
		DEC	.153964 E-4 B+12
		DEC	-.742923 B-6
		DEC	1.5398 B-6
		DEC	9.68 B-6
		DEC	.647625	E-4 B+12
		DEC	-27228 B-20
		DEC	-.206476 B-2
		
SLOPEVAL	DEC	1.96307 B-6
		DEC	27.5774 B-6
		DEC	2.3548 E-5 B+12
		DEC	2.1777 E-9 B+26
		DEC	1.044 E-3 B+8
		DEC	0
		DEC	2.21068 E-3 B+8
		DEC	1.5166 E-9 B+26
		DEC	-1.284 B-6
		DEC	2 E-5 B+12
		
NEGBPW		DEC	-15402.17 B-16
DXITFIX		DEC*	-1.88275 E-5 B+12*


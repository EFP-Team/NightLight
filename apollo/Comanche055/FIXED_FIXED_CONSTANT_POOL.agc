# Copyright:	Public domain.
# Filename:	FIXED_FIXED_CONSTANT_POOL.agc
# Purpose:	Part of the source code for Colossus 2A, AKA Comanche 055.
#		It is part of the source code for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	1200-1204
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

# Page 1200
		BLOCK	02
		COUNT	02/FCONS

# THE FOLLOWING TABLE OF 18 VALUES IS INDEXED.  DO NOT INSERT OR REMOVE ANY QUANTITIES

DPOSMAX		OCT	37777		# MUST PRECED POSMAX
POSMAX		OCT	37777

LIMITS		=	NEG1/2

NEG1/2		OCT	-20000		# USED BY SIN ROUTINE (MUST BE TWO 
					# LOCATIONS IN FRONT OF BIT14)
					
# BIT TABLE					
					
BIT15		OCT	40000
BIT14		OCT	20000
BIT13		OCT	10000
BIT12		OCT	04000
BIT11		OCT	02000
BIT10		OCT	01000
BIT9		OCT	00400
BIT8		OCT	00200
BIT7		OCT	00100
BIT6		OCT	00040
BIT5		OCT	00020
BIT4		OCT	00010
BIT3		OCT	00004
BIT2		OCT	00002
BIT1		OCT	00001

# DO NOT DESTROY THIS COMBINATION, SINCE IT IS USED IN DOUBLE PRECISION INSTRUCTIONS.
NEG0		OCT	-0		# MUST PRECEDE ZERO
ZERO		OCT	0		# MUST FOLLOW NEG0
# BIT1		OCT	00001
# NO.WDS	OCT	2		# INTERPRETER
# OCTAL3	OCT	3		# INTERPRETER
# R3D1		OCT	4		# PINBALL
FIVE		OCT	5
# REVCNT	OCT	6		# INTERPRETER
SEVEN		OCT	7
# BIT4		OCT	00010
# R2D1		OCT	11		# PINBALL
OCT11		=	R2D1		# P20S
# BINCON	DEC	10		# PINBALL		(OCTAL 12)
ELEVEN		DEC	11
# OCT14		OCT	14		# ALARM AND ABORT (FILLER)
OCT15		OCT	15
# R1D1		OCT	16		# PINBALL
# Page 1201
LOW4		OCT	17
# BIT5		OCT	00020
# ND1		OCT	21		# PINBALL
# VD1		OCT	23		# PINBALL
# OCT24		OCT	24		# SERVICE ROUTINES
# MD1		OCT	25		# PINBALL
BITS4&5		OCT	30
# OCT31		OCT	31		# SERVICE ROUTINES
CALLCODE	OCT	00032
# LOW5		OCT	37		# PINBALL
# 33DEC		DEC	33		# PINBALL		(OCTAL 41)
# 34DEC		DEC	34		# PINBALL		(OCTAL 42)
TBUILDFX	DEC	37		# BUILDUP FOR CONVENIENCE IN DAPTESTING
TDECAYFX	DEC	38		# CONVENIENCE FOR DAPTESTING
# BIT6		OCT	00040
OCT50		OCT	50
DEC45		DEC	45
SUPER011	OCT	60		# BITS FOR SUPERBNK SETTING 011.
.5SEC		DEC	50
# BIT7		OCT	00100

SUPER100	=	BIT7		# BITS FOR SUPERBNK SETTING 100
					# (LAST 4K OF ROPE)
SUPER101	OCT	120		# BITS FOR SUPERBNK SETTING 101
# OCT121	OCT	121		# SERVICE ROUTINES
					# (FIRST 8K OF ACM)
SUPER110	OCT	140		# BITS FOR SUPERBNK SETTING 110.
					# (LAST BK OF ACM)
1SEC		DEC	100
# LOW7		OCT	177		# INTERPRETER
# BIT8		OCT	00200
# OT215		OCT	215		# ALARM AND ABORT
# 8,5		OCT	00220		# P20-P25 SUNDANCE
2SECS		DEC	200
# LOW8		OCT	377		# PINBALL
# BIT9		OCT	00400
GN/CCODE	OCT	00401		# SET S/C CONTROL SWITCH TO G/N
3SECS		DEC	300
4SECS		DEC	400
LOW9		OCT	777
# BIT10		OCT	01000
# 5.5DEGS	DEC	.03056		# P20-P25 SUNDANCE 	(OCTAL 00765)
# OCT1103	OCT	1103		# ALARM AND ABORT
C5/2		DEC	.0363551	#		   	(OCTAL 01124)
V05N09		VN	0509		# (SAME AS OCTAL 1211)
OCT1400		OCT	01400
V06N22		VN	0622
# MID5		OCT	1740		# PINBALL
BITS2-10	OCT	1776
LOW10		OCT	1777
# Page 1202
# BIT11		OCT	02000
# 2K+3		OCT	2003		# PINBALL
LOW7+2K		OCT	2177		# OP CODE MASK + BANK 1 FBANK SETTING
EBANK5		OCT	02400
PRIO3		OCT	03000
EBANK7		OCT	03400
# LOW11		OCT	3777		# PINBALL
# BIT12		OCT	04000
# RELTAB	OCT	04025		# T4RUPT
PRIO5		OCT	05000
PRIO6		OCT	06000
PRIO7		OCT	07000

# BIT13		OCT	10000
#		OCT	10003		# T4RUPT	RELTAB +1D
# 13,7,2	OCT	10102		# P20-P25 SUNDANCE
PRIO11		OCT	11000
# PRIO12	OCT	12000		# BANKCALL
PRIO13		OCT	13000
PRIO14		OCT	14000
#		OCT	14031		# T4RUPT	RELTAB +2D
PRIO15		OCT	15000
PRIO16		OCT	16000
# 85DEGS	DEC	.45556		# P20-P25 SUNDANCE	(OCTAL 16450)
PRIO17		OCT	17000
OCT17770	OCT	17770
# BIT14		OCT	20000
#		OCT	20033		# T4RUPT	RELTAB +3D
PRIO21		OCT	21000
		BLOCK	03
		COUNT	03/FCONS
		
PRIO22		OCT	22000		# SERVICE ROUTINES
PRIO23		OCT	23000
PRIO24		OCT	24000
# 5/8+1		OCT	24001		# SINGLE PRECISION SUBROUTINES
#		OCT	24017		# T4RUPT	RELTAB +4D
PRIO25		OCT	25000
PRIO26		OCT	26000
PRIO27		OCT	27000
# CHRPRIO	OCT	30000		# PINBALL
#		OCT	30036		# T4RUPT	RELTAB +5D
PRIO31		OCT	31000
C1/2		DEC	.7853134	#			(OCTAL 31103)
PRIO32		OCT	32000
PRIO33		OCT	33000
PRIO34		OCT	34000
#		OCT	34034		# T4RUPT	RELTAB +6D		
PRIO35		OCT	35000
PRIO36		OCT	36000
# Page 1203
PRIO37		OCT	37000
63/64+1		OCT	37401
# MID7		OCT	37600		# PINBALL
OCT37766	OCT	37766
OCT37774	OCT	37774
OCT37776	OCT	37776
# DPOSMAX	OCT	37777
# BIT15		OCT	40000
# OCT40001	OCT	40001		# INTERPRETER (CS 1 INSTRUCTION)
DLOADCOD	OCT	40014
DLOAD*		OCT	40015
#		OCT	40023		# T4RUPT	RELTAB +7D
BIT15+6		OCT	40040
OCT40200	OCT	40200
#		OCT	44035		# T4RUPT	RELTAB +8D
#		OCT	50037		# T4RUPT	RELTAB +9D
#		OCT	54000		# T4RUPT	RELTAB +10D
-BIT14		OCT	57777
# RELTAB11	OCT	60000		# T4RUPT
C3/2		DEC	-.3216147	#			(OCTAL 65552)
13,14,15	OCT	70000
-1/8		OCT	73777
HIGH4		OCT	74000
-ENDERAS	DEC	-2001		#			(OCTAL 74056)
# HI5		OCT	76000		# PINBALL
HIGH9		OCT	77700
# -ENDVAC	DEC	-45		# INTERPRETER		(OCTAL 77722)
# -OCT10	OCT	-10		#			(OCTAL 77767)
# NEG4		DEC	-4		#			(OCTAL 77773)
NEG3		DEC	-3
NEG2		OCT	77775
NEGONE		DEC	-1

# Page 1204

# DEFINED BY EQUALS

# IT WOULD BE TO THE USERS ADVANTAGE TO OCCASIONALLY CHECK ANY OF THESE SYMBOLS IN ORDER TO PREVENT ANY
# ACCIDENTAL DEFINITION CHANGES.

MINUS1		=	NEG1
NEG1		=	NEGONE
ONE		=	BIT1
TWO		=	BIT2
THREE		=	OCTAL3
LOW2		=	THREE
FOUR		=	BIT3
SIX		=	REVCNT
LOW3		=	SEVEN
EIGHT		=	BIT4
NINE		=	R2D1
TEN		=	BINCON
NOUTCON		=	ELEVEN
OCT23		=	VD1
OCT25		=	MD1
PRIO1		=	BIT10
EBANK3		=	OCT1400
PRIO2		=	BIT11
OCT120		=	SUPER101
OCT140		=	SUPER110
2K		=	BIT11
EBANK4		=	BIT11
PRIO4		=	BIT12
EBANK6		=	PRIO3
QUARTER		=	BIT13
PRIO10		=	BIT13
OCT10001	=	CCSL
POS1/2		=	HALF
PRIO20		=	BIT14
HALF		=	BIT14
PRIO30		=	CHRPRIO
BIT13-14	=	PRIO30		# INTERPRETER USES IN PROCESSING STORECODE
OCT30002	=	TLOAD +1
B12T14		=	PRIO34
NEGMAX		=	BIT15
VLOADCOD	=	BIT15
VLOAD*		=	OCT40001
OCT60000	=	RELTAB11
BANKMASK	=	HI5


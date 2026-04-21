
;     --------- "Game Over" Audio Source File (SID/65xx system) -----------

;   --------- Design, code, music & arrangements by Martin Galway -----------

;   -------------------- Work started 10th February 1987. -------------------

;     ------ (C) MARTIN GALWAY 18:15  Thursday 9th      July 1987. --------

;======================*===CODE ENTRY INFORMATION===*==========================

;  LETTER TUNE VALUE ITEM
;  ------ ---------- ----
;  B      1*7-2  *   Title screen
;  C      2*7-2  *   Game Over
;  D             *   Laser
;  E             *   Boomerang
;  F             *   Grenade
;  G             *   Grenade Explodes
;  H             *   Monster Thud
;  I             *   Alien Fires
;  J             *   Energy getting drained
;  K             *   Picks up a heart
;  L             *   Laser turret firing
;  M             *   Kangaroos Hop
;  N             *   Imps Appear
;  O             *   Lift Dings
;  P             *   Statue Eyes Hit


;Recommended screen Y-coordinates for the 200 Hz refresh on P.A.L.:
;          32         110        188         10(+256) gap=78
;Recommended screen Y-coordinates for the 200 Hz refresh on N.T.S.C.:
;          47         107        172           237    gap=65

;===========================*===SYSTEM VARIABLES===*===========================

ZER0                EQU $0010;\
PC0                 EQU ZER0+00
PC1                 EQU ZER0+02
PC2                 EQU ZER0+04
CLOCK0              EQU ZER0+06
CLOCK1              EQU ZER0+07
CLOCK2              EQU ZER0+08
SP0                 EQU ZER0+09
SP1                 EQU ZER0+10
SP2                 EQU ZER0+11
TR0                 EQU ZER0+12
TR1                 EQU ZER0+13
TR2                 EQU ZER0+14
IN                  EQU ZER0+15
S0PCURR             EQU ZER0+17
S1PCURR             EQU ZER0+19
S2PCURR             EQU ZER0+21
S0FCURR             EQU ZER0+23
S1FCURR             EQU ZER0+25
S2FCURR             EQU ZER0+27
OUT                 EQU ZER0+29;this z.p. word to be used OUTSIDE INTERRUPTS ONLY!!!
Z8                  EQU ZER0+31

COM                 EQU $C0
Sil                 EQU HiFrq-LoFrq-1;@
Rest                EQU $5F
R                   EQU $60
RestR               EQU Rest+R
Ret                 EQU COM+0
Call                EQU COM+2
Jmp                 EQU COM+4
CT                  EQU COM+6
JT                  EQU COM+8
Moke                EQU COM+10
For                 EQU COM+12
Next                EQU COM+14
SLoad               EQU COM+16
FLoad               EQU COM+18
Vlm                 EQU COM+20
Soke                EQU COM+22
Code                EQU COM+24
Transp              EQU COM+26
DMoke               EQU COM+28
DSoke               EQU COM+30
Master              EQU COM+32
Filter              EQU COM+34
Disown              EQU COM+36
Own                 EQU COM+38
MBendOff            EQU COM+40
MBendOn             EQU COM+42
Freq                EQU COM+44
Trigger             EQU COM+46

FMG0                EQU 0
FMG1                EQU 2
FMG2                EQU 4
FMG3                EQU 6
FMD0                EQU 8
FOLA                EQU 8; F.O.M. Offset List Address (new feature)
FMD1                EQU 9
CHS                 EQU 9
FMD2                EQU 10
FMD3                EQU 11
FMDLY               EQU 12
FMC                 EQU 13
CFINIT              EQU 14
PMD0                EQU 14
PMD1                EQU 15
PMDLY               EQU 16
PMC                 EQU 17
PMG0                EQU 18
PMG1                EQU 20
PINIT               EQU 22
VWF                 EQU 24
VADV                EQU 25
VSRV                EQU 26
VADSD               EQU 27
VRD                 EQU 28

FOLDC               EQU 4; F.O.M. Duration Counter (new feature)
FBG                 EQU 6
FOLOD               EQU 6; F.O.M. Offset Duration (new feature)
CFMD0               EQU 8
CFMD1               EQU 9
CFMD2               EQU 10
FOLB                EQU 10
CFMD3               EQU 11
FOLII               EQU 11
FBD                 EQU 12
FOLCI               EQU 12
CPMD0               EQU 14
CPMD1               EQU 15
FINIT               EQU 24
VWFG                EQU 26
VADSC               EQU 27
VRC                 EQU 28
FMD0C               EQU 29
FMD1C               EQU 30
FMD2C               EQU 31
FMD3C               EQU 32
PMD0C               EQU 33
PMD1C               EQU 34
DEPTHOFSTACKS       EQU 4

;=== P.A.L. FREQUENCY TABLE (NOT TO BE USED ON N.T.S.C.) : 1.019 MHz CLOCK ===

;BASE "A" VALUE FOR THIS OCTAVE IS 235. (EQUIVALENT TO N-03)

N00                 EQU 279
N01                 EQU 296
N02                 EQU 314
N03                 EQU 332
N04                 EQU 352
N05                 EQU 373
N06                 EQU 395
N07                 EQU 419
N08                 EQU 444
N09                 EQU 470
N10                 EQU 498
N11                 EQU 528
N12                 EQU 559
N13                 EQU 592
N14                 EQU 627
N15                 EQU 665
N16                 EQU 704
N17                 EQU 746
N18                 EQU 790
N19                 EQU 837
N20                 EQU 887
N21                 EQU 940
N22                 EQU 996
N23                 EQU 1055
N24                 EQU 1118
N25                 EQU 1184
N26                 EQU 1255
N27                 EQU 1330
N28                 EQU 1408
N29                 EQU 1492
N30                 EQU 1581
N31                 EQU 1675
N32                 EQU 1774
N33                 EQU 1880
N34                 EQU 1992
N35                 EQU 2110
N36                 EQU 2236
N37                 EQU 2369
N38                 EQU 2509
N39                 EQU 2659
N40                 EQU 2817
N41                 EQU 2984
N42                 EQU 3162
N43                 EQU 3350
N44                 EQU 3549
N45                 EQU 3760
N46                 EQU 3984
N47                 EQU 4220
N48                 EQU 4471
N49                 EQU 4737
N50                 EQU 5019
N51                 EQU 5317
N52                 EQU 5634
N53                 EQU 5969
N54                 EQU 6324
N55                 EQU 6700
N56                 EQU 7098
N57                 EQU 7520
N58                 EQU 7967
N59                 EQU 8441
N60                 EQU 8943
N61                 EQU 9475
N62                 EQU 10038
N63                 EQU 10635
N64                 EQU 11267
N65                 EQU 11937
N66                 EQU 12647
N67                 EQU 13399
N68                 EQU 14195
N69                 EQU 15040
N70                 EQU 15934
N71                 EQU 16881
N72                 EQU 17886
N73                 EQU 18949
N74                 EQU 20076
N75                 EQU 21270
N76                 EQU 22534
N77                 EQU 23875
N78                 EQU 25294
N79                 EQU 26798
N80                 EQU 28391
N81                 EQU 30080
N82                 EQU 31869
N83                 EQU 33764
N84                 EQU 35771
N85                 EQU 37898
N86                 EQU 40151
N87                 EQU 42540
N88                 EQU 45069
N89                 EQU 47749
N90                 EQU 50588
N91                 EQU 53596
N92                 EQU 56783
N93                 EQU 60160
NSil                EQU 00000

SCREEN              EQU $0400
ROW0                EQU SCREEN+0*40
SPEED               EQU ROW0+33
YYY                 EQU ROW0+37
ROW1                EQU SCREEN+1*40
TIMER               EQU ROW1+08
FASTER              EQU ROW1+39
ROW2                EQU SCREEN+2*40
ROW3                EQU SCREEN+3*40
ROW4                EQU SCREEN+4*40
ROW5                EQU SCREEN+5*40
ROW6                EQU SCREEN+6*40
ROW7                EQU SCREEN+7*40
ROW8                EQU SCREEN+8*40
ROW9                EQU SCREEN+9*40
ROW10               EQU SCREEN+10*40
ROW11               EQU SCREEN+11*40
ROW12               EQU SCREEN+12*40
ROW13               EQU SCREEN+13*40
ROW14               EQU SCREEN+14*40
ROW15               EQU SCREEN+15*40
ROW16               EQU SCREEN+16*40
ROW17               EQU SCREEN+17*40
ROW18               EQU SCREEN+18*40
ROW19               EQU SCREEN+19*40
ROW20               EQU SCREEN+20*40
ROW21               EQU SCREEN+21*40
ROW22               EQU SCREEN+22*40
ROW23               EQU SCREEN+23*40
ROW24               EQU SCREEN+24*40
BDR                 EQU $D020
MREFCOLOUR          EQU 1;                                 White, for music refreshes
DREFCOLOUR          EQU 0;                       Desired colour for display refreshes

; === FILE CONTROL CHARACTERS ===

; \ PROGRAM ASSEMBLY MODE (DEVELOPMENT/MOBJ)
; @ SILENCE HANDLING ON/OFF

;======================************************================================
;======================*=== DRIVER PROGRAM ===*================================
;======================************************================================

                    ORG $0800:ENT;\

Start               SEI:JSR InitScreen
                    JSR INITSOUND
                    JSR Title
                    LDX #DRUMDATA:LDY ^DRUMDATA:LDA #2:JSR RIFF
                    JSR FastForward
                    JSR INITRASTERS:CLI:JMP MAIN
                    LDA #Q:BNE DLoop:LDY #10:JSR Delay

DLoop               SEI:LDA #0:STA BDR
                    JSR DREFRESH
                    JSR $EA87:JSR $F13E:BEQ nk:STA BDR
cf0                 CMP #13:BNE cf1:INC RF:JMP nk
cf1                 CMP #"+":BNE cf2:JSR IncRefsp:JMP nk
cf2                 CMP #"-":BNE cf3:JSR DecRefsp:JMP nk
cf3                 CMP #"@":BNE cf4:LDX #1:STX Refsp+1:DEX:STX Refsp:JMP nk
cf4                 CMP #"*":BNE cf5:LDX #0:STX Refsp+1:INX:STX Refsp:JMP nk
cf5                 CMP #"Z"+1:BCS nk:CMP #"A":BCC nk:ASL:TAY:LDA DVTABL-"A"*2,Y
                    STA DVEC+1:LDA DVTABL-"A"*2+1,Y:STA DVEC+2
DVEC                JSR $DDDD
nk                  JMP DLoop

DVTABL              DFW INITSOUND,Title,GameOver
                    DFW Laser,Boomerang,Grenade,GrenExplodes
                    DFW MonsterThuds,AlienFires,EnergyDrain,PicksUpHeart
                    DFW LaserTurret,KangaroosHop,ImpsAppear
                    DFW LiftDings,StatueEyesHit,FaFo,FaFo
                    DFW FaFo,FaFo,FaFo,FaFo
                    DFW FaFo,FaFo,FaFo,FaFo

Title               JSR ResetCl:JSR StartCl:LDY #1*7-2:JMP TUNE
GameOver            JSR ResetCl:JSR StartCl:LDY #2*7-2:JMP TUNE

Laser               LDX #2:LDA #LASER:LDY ^LASER:JMP EFFECT
Boomerang           LDX #1:LDA #BOOMERANG:LDY ^BOOMERANG:JMP EFFECT
Grenade             LDX #2:LDA #GRENADE:LDY ^GRENADE:JMP EFFECT
GrenExplodes        LDX #0:LDA #GRENEXPLODES:LDY ^GRENEXPLODES:JMP EFFECT
MonsterThuds        LDX #1:LDA #MONSTERTHUDS:LDY ^MONSTERTHUDS:JMP EFFECT
AlienFires          LDX #2:LDA #ALIENFIRES:LDY ^ALIENFIRES:JMP EFFECT
EnergyDrain         LDX #0:LDA #ENERGYDRAIN:LDY ^ENERGYDRAIN:JMP EFFECT
PicksUpHeart        LDX #1:LDA #PICKSUPHEART:LDY ^PICKSUPHEART:JMP EFFECT
LaserTurret         LDX #2:LDA #LASERTURRET:LDY ^LASERTURRET:JMP EFFECT
KangaroosHop        LDX #1:LDA #KANGAROOSHOP:LDY ^KANGAROOSHOP:JMP EFFECT
ImpsAppear          LDX #2:LDA #IMPSAPPEAR:LDY ^IMPSAPPEAR:JMP EFFECT
LiftDings           LDX #1:LDA #LIFTDINGS:LDY ^LIFTDINGS:JMP EFFECT
StatueEyesHit       LDX #2:LDA #STATUEEYESHIT:LDY ^STATUEEYESHIT:JMP EFFECT

HANG                INC BDR:JMP HANG

HANG0               LDX #0:DFB $2C
HANG1               LDX #1:DFB $2C
HANG2               LDX #2
                    SEI:LDA #3
HANGLOOP            STA BDR:STX BDR:JMP HANGLOOP

WAITCLOCK00         LDX $D011:BMI WAITCLOCK00:BPL WAITCLOCKa
WAITCLOCK80         LDX $D011:BPL WAITCLOCK80
WAITCLOCKa          CMP $D012:BNE WAITCLOCKa
WAITCLOCKb          LDA Refsp:ADD CREFSP:STA CREFSP:LDA CREFSP+1:PHA:ADC Refsp+1
                    STA CREFSP+1:PLA:CMP CREFSP+1:RTS

FaFo                JSR f2
f2                  JSR f3
f3                  JSR f4
f4                  JSR f5
f5                  JSR f6
f6                  JSR f7
f7                  JSR f8
f8                  JSR f9
f9                  JSR f10
f10                 JSR UpdateCl
                    INC BDR
                    JSR WAITCLOCKb
REFRESH             PHP
                    INC ClkAdd:PLP:BEQ xit:INC BDR:JSR FILTER
;              JSR DRUMS
                    LDX #CH0VALUE:BEQ R1x:JSR MUSIC0:JSR SOUND0
R1x                 LDX #CH1VALUE:BEQ R1y:JSR MUSIC1:JSR SOUND1
R1y                 LDX #CH2VALUE:BEQ xit:JSR MUSIC2:JSR SOUND2
xit                 DEC BDR:RTS

ResetCl             LDA #"0":LDX #5
RCLoop              STA CD5,X:DEX:BPL RCLoop
StopCl              LDA #0:DFL $2C
StartCl             LDA #+1:STA ClkAdd
sc2                 RTS

DREFRESH            LDA #32:JSR WAITCLOCK00:JSR REFRESH:JSR RefScreen1
REF2                LDA #110:JSR WAITCLOCK00:JSR REFRESH:JSR RefScreen2
REF3                LDA #188:JSR WAITCLOCK00:JSR REFRESH:JSR RefScreen3
REF4                LDA #10:JSR WAITCLOCK80:JSR REFRESH:JSR RefScreen4:JMP UpdateCl

UpdateCl            LDA #0
                    LDX #CH0VALUE:BEQ u1:ORA MFL0:ORA S0+VRC
u1                  LDX #CH1VALUE:BEQ u2:ORA MFL1:ORA S1+VRC
u2                  LDX #CH2VALUE:BEQ ua:ORA MFL2:ORA S2+VRC
ua                  TAX:BEQ StopCl:LDA ClkAdd:CMP #4:BCC sc2:LSR:LDX #0:STX ClkAdd
                    ADD CD0:CMP #"9"+1:BCC ncu0:LDA #"0"
ncu0                STA CD0:BCC PrintCl:LDA CD1:ADC #0:CMP #"9"+1:BCC ncu1:LDA #"0"
ncu1                STA CD1:BCC PrintCl:LDA CD2:ADC #0:CMP #"9"+1:BCC ncu2:LDA #"0"
ncu2                STA CD2:BCC PrintCl:LDA CD3:ADC #0:CMP #"5"+1:BCC ncu3:LDA #"0"
ncu3                STA CD3:BCC PrintCl:LDA CD4:ADC #0:CMP #"9"+1:BCC ncu4:LDA #"0"
ncu4                STA CD4:BCC PrintCl:LDA CD5:ADC #0:CMP #"5"+1:BCC ncu5:LDA #"0"
ncu5                STA CD5
PrintCl             LDX #1
PCL                 LDA CD5,X:STA TIMER,X:LDA CD3,X:STA TIMER+3,X:LDA CD1,X
                    STA TIMER+6,X:DEX:BPL PCL:LDA #"-":STA TIMER+2:STA TIMER+5
udc2                RTS

CD5                 DFS 1
CD4                 DFS 1
CD3                 DFS 1
CD2                 DFS 1
CD1                 DFS 1
CD0                 DFS 1
CG                  DFB 0
ClkAdd              DFB 0
CREFSP              DFW 0
Refsp               DFW 0
xcstr               DFM "0123456789ABCDEF"

IncRefsp            LDX Refsp:BEQ DR2:INX:BNE DR1:INC Refsp+1:BNE DR1
DecRefsp            LDX Refsp:DEX:BEQ DR2:LDA #0:STA Refsp+1
DR1                 STX Refsp
DR2                 RTS

FastForward         LDA #QSOUND:STA RF:LDA #Q:STA FASTER
Fast1               LDA FASTER:BEQ Fast2
XXXLOOP             JSR FaFo;DEC COUNT:BNE XXXLOOP
                    DEC FASTER:JMP Fast1
Fast2               LDX #CH0VALUE*1+CH1VALUE*2+CH2VALUE*4:STX RF:RTS
;COUNT         DFB 0

Delay               LDA #100:LDX #101
delayloop1          CMP $D012:BNE delayloop1
delayloop2          CPX $D012:BNE delayloop2:DEY:BNE delayloop1
Fz                  RTS

InitScreen          LDX #256:LDY #15
                    STX CREFSP:STX CREFSP+1
is1                 LDA #32:STA $400,X:STA $500,X:STA $600,X:STA $700,X:TYA
                    STA $D800,X:STA $D900,X:STA $DA00,X:STA $DB00,X:DEX:BNE is1
                    DEX:STX 650;                  enable autorepeat on whole keyboard
                    LDX #refsp:STX Refsp
                    LDY ^refsp:STY Refsp+1
                    JSR PrintCl
                    LDA #0:STA BDR
                    RTS
                    JSR RefScreen1:JSR RefScreen2:JSR RefScreen3:JMP RefScreen4

RefScreen1          LDA #DREFCOLOUR:STA BDR
                    LDX #32-1
sh3                 LDA IDRT,X:STA ROW24,X:DEX:BPL sh3:LDX #2:DFB $A9
RF                  DFB $DF
sh5                 LSRA:PHA:BCC sh6:LDA #"Y":DFL $2C
sh6                 LDA #"N":STA YYY,X:PLA:DEX:BPL sh5:LDX #"0":LDA Refsp+1:BEQ sh10
                    INX
sh10                STX SPEED:LDA Refsp:TAY:LSR:LSR:LSR:LSR:TAX:LDA xcstr,X
                    STA SPEED+1:TYA:AND #15:TAX:LDA xcstr,X:STA SPEED+2
                    LDX #Z8-ZER0
sh1                 LDA ZER0,X:STA ROW0,X:DEX:BPL sh1
                    LDA #0:STA BDR
                    RTS

RefScreen2          LDA #DREFCOLOUR:STA BDR
                    LDX #D1-D0-1
sh2                 LDA D0,X:STA ROW3,X:LDA D1,X:STA ROW6,X:LDA D2,X:STA ROW9,X
                    DEX:BPL sh2
                    LDA #0:STA BDR
                    RTS

RefScreen3          LDA #DREFCOLOUR:STA BDR
                    LDX #S1-S0-1
sh4                 LDA S0,X:STA ROW15,X:LDA S1,X:STA ROW17,X:LDA S2,X:STA ROW19,X
                    DEX:BPL sh4
                    LDA #0:STA BDR
                    RTS

RefScreen4          LDA #DREFCOLOUR:STA BDR
                    LDA FilterChannel:STA ROW24+33
                    LDX #5
sh7                 LDA MFL0,X:STA ROW24+34,X:DEX:BPL sh7:LDX #21
sh8                 LDA CUT,X:STA ROW21,X:DEX:BPL sh8:LDX #15
sh9                 LDA CUTST,X:STA ROW12,X:DEX:BPL sh9
                    LDA #0:STA BDR
                    RTS

MAIN                JSR PLEY
                    JSR RefScreen1
                    JSR PLEY
                    JSR RefScreen2
                    JSR PLEY
                    JSR RefScreen3
                    JSR PLEY
                    JSR RefScreen4
                    JMP MAIN

INITRASTERS         LDA #$35:STA $01:LDA #10:STA $D012:LDA #$FF:STA $D019
                    LDA #$F1:STA $D01A:LDX #%01111111:STA $DC0D:LDA $DC0D:LDA #0
                    STA $DC0E:LDX #IRQ:LDY ^IRQ:STX $FFFE:STY $FFFF
                    LDX #NMI:LDY ^NMI:STX $FFFA:STY $FFFB:RTS

;=== INTERRUPT ROUTINE ===

IRQ                 PHA:LDA $D019:STA $D019:LDA #10:STA $D012:CLD:TYA:PHA:TXA:PHA
;              LDA CURRDRM:ADD #drmsp:STA CURRDRM:BCC ndr
                    LDA #0:STA BDR
                    JSR MUSIC0
                    JSR MUSIC1
                    JSR MUSIC2
                    JSR SOUND0
                    JSR SOUND1
                    JSR SOUND2
                    JSR FILTER
                    JSR DRUMS
ndr                 LDA #12:STA BDR:PLA:TAX:PLA:TAY:PLA:RTI

CURRDRM             DFB 0

;=======================*******************************========================
;=======================*=== END OF DRIVER PROGRAM ===*========================
;=======================*******************************========================
























SP;=====================********************************=======================
;=======================*=== START OF MUSIC PROGRAM ===*=======================
;=======================********************************=======================

                    ORG $1000

vt0                 DFW retsubrut0
                    DFW call0
                    DFW goto0
                    DFW callt0
                    DFW gotot0
                    DFW mpoke0
                    DFW for0
                    DFW next0
                    DFW HANG0;sload0
                    DFW fload0
                    DFW volume0
                    DFW spoke0
                    DFW code0
                    DFW transp0
                    DFW dmpoke0
                    DFW dspoke0
                    DFW master0
                    DFW filter0
                    DFW HANG0;disown0
                    DFW HANG0;own0
                    DFW mbendoff0
                    DFW mbendon0
                    DFW freq0
                    DFW trigger0

vt1                 DFW retsubrut1
                    DFW call1
                    DFW goto1
                    DFW callt1
                    DFW HANG1;gotot1
                    DFW mpoke1
                    DFW for1
                    DFW next1
                    DFW HANG1;sload1
                    DFW fload1
                    DFW volume1
                    DFW spoke1
                    DFW code1
                    DFW transp1
                    DFW dmpoke1
                    DFW dspoke1
                    DFW master1
                    DFW filter1
                    DFW HANG1;disown1
                    DFW HANG1;own1
                    DFW mbendoff1
                    DFW mbendon1
                    DFW freq1

vt2                 DFW retsubrut2
                    DFW call2
                    DFW goto2
                    DFW callt2
                    DFW HANG2;gotot2
                    DFW mpoke2
                    DFW for2
                    DFW next2
                    DFW HANG2;sload2
                    DFW fload2
                    DFW volume2
                    DFW spoke2
                    DFW code2
                    DFW transp2
                    DFW dmpoke2
                    DFW dspoke2
                    DFW master2
                    DFW filter2
                    DFW disown2
                    DFW HANG2;own2
                    DFW mbendoff2
                    DFW mbendon2
                    DFW freq2

ST;============================================================================

D418                DFB 0;                                     used by drum programs
D0                  DFS 29,$DD
ST0L                DFS DEPTHOFSTACKS,$DD;                    stack (low bytes only)
ST0H                DFS DEPTHOFSTACKS,$DD;                   stack (high bytes only)
ST0C                DFS DEPTHOFSTACKS,$DD;                  stack(for/next counters)
D1                  DFS 29,$DD
ST1L                DFS DEPTHOFSTACKS,$DD
ST1H                DFS DEPTHOFSTACKS,$DD
ST1C                DFS DEPTHOFSTACKS,$DD
D2                  DFS 29,$DD
ST2L                DFS DEPTHOFSTACKS,$DD
ST2H                DFS DEPTHOFSTACKS,$DD
ST2C                DFS DEPTHOFSTACKS,$DD
CUTST               DFS 16,$DD
CUT                 DFS 22,$DD
S0                  DFS 35,$DD
S1                  DFS 35,$DD
S2                  DFS 35,$DD
FilterChannel       DFB $DD
FilterByte          DFB $DD
MFL0                DFB $DD
MFL1                DFB $DD
MFL2                DFB $DD
channel             DFB $DD
offset              DFB $DD
IDRT                DFS 32,$DD
DTAB                DFL D0-D0,D1-D0,D2-D0
CHTAB               DFL 0*7+2,1*7+2,2*7+2
SBTAB               DFL S0+23-S0,S1+23-S0,S2+23-S0
LoFrq               DFL N00,N01,N02,N03,N04,N05,N06,N07,N08,N09
                    DFL N10,N11,N12,N13,N14,N15,N16,N17,N18,N19
                    DFL N20,N21,N22,N23,N24,N25,N26,N27,N28,N29
                    DFL N30,N31,N32,N33,N34,N35,N36,N37,N38,N39
                    DFL N40,N41,N42,N43,N44,N45,N46,N47,N48,N49
                    DFL N50,N51,N52,N53,N54,N55,N56,N57,N58,N59
                    DFL N60,N61,N62,N63,N64,N65,N66,N67,N68,N69
                    DFL N70,N71,N72,N73,N74,N75,N76,N77,N78,N79
                    DFL N80,N81,N82,N83,N84,N85,N86,N87,N88,N89
                    DFL NSil
HiFrq               DFH N00,N01,N02,N03,N04,N05,N06,N07,N08,N09
                    DFH N10,N11,N12,N13,N14,N15,N16,N17,N18,N19
                    DFH N20,N21,N22,N23,N24,N25,N26,N27,N28,N29
                    DFH N30,N31,N32,N33,N34,N35,N36,N37,N38,N39
                    DFH N40,N41,N42,N43,N44,N45,N46,N47,N48,N49
                    DFH N50,N51,N52,N53,N54,N55,N56,N57,N58,N59
                    DFH N60,N61,N62,N63,N64,N65,N66,N67,N68,N69
                    DFH N70,N71,N72,N73,N74,N75,N76,N77,N78,N79
                    DFH N80,N81,N82,N83,N84,N85,N86,N87,N88,N89
                    DFL NSil

;==============================================================================

TUNE                LDA TUNETABLE+1,Y:STA CalcDurations+1
                    LDX #2:STX channel:LDX #4:STX offset:DEY
get.tune.data       LDA TUNETABLE,Y:ORA TUNETABLE+1,Y:BEQ leve.it.alone:LDX offset
                    LDA TUNETABLE,Y:STA PC0,X:LDA TUNETABLE+1,Y:STA PC0+1,X:STY OUT
                    LDX channel:LDY DTAB,X:LDA #0:STA TR0,X:STA D0+FMC,Y:STA D0+PMC,Y
                    LDA #DEPTHOFSTACKS-1:STA SP0,X:LDA #1:STA CLOCK0,X:STA MFL0,X
                    LDY OUT
;              STA SFL0,X;[
leve.it.alone       DEY:DEY:DEC offset:DEC offset:DEC channel:BPL get.tune.data
NewDurations        CLC:LDA #0
CalcDurations       ADC #$DD:STA IDRT,X:INX:CPX #32:BCC CalcDurations
                    LDA #192:STA IDRT+30;        a duration of 64 beats instead of 31
                    RTS

transferpm0         LDX S0+PINIT:LDY S0+PINIT+1
transferpm0a        STX S0PCURR:STY S0PCURR+1:LDA S0+CPMD0:STA S0+PMD0C
                    LDA S0+CPMD1:STA S0+PMD1C:RTS
transferpm1         LDX S1+PINIT:LDY S1+PINIT+1
transferpm1a        STX S1PCURR:STY S1PCURR+1:LDA S1+CPMD0:STA S1+PMD0C
                    LDA S1+CPMD1:STA S1+PMD1C:RTS
transferpm2         LDX S2+PINIT:LDY S2+PINIT+1
transferpm2a        STX S2PCURR:STY S2PCURR+1:LDA S2+CPMD0:STA S2+PMD0C
                    LDA S2+CPMD1:STA S2+PMD1C:RTS
transfercf          LDX CUT+14:LDY CUT+15:STX CUT+16:STY CUT+17
transfercfa         LDA CUT+8:STA CUT+18:LDA CUT+9:STA CUT+19:LDA CUT+10:STA CUT+20
                    LDA CUT+11:STA CUT+21:RTS

EFFECT              STA OUT:STY OUT+1:STX channel:LDA CHTAB,X:STA el2a+1:TAY:LDA #8
                    STA $D402,Y:LDY #26:LDX #4
el2                 LDA (OUT),Y
el2a                STA $D4DD,X:DEY:DEX:BPL el2:LDY #29:LDX el2+3:LDA (OUT),Y
                    STA $D3FE,X:INY:LDA (OUT),Y:STA $D3FF,X:LDY channel:LDX SBTAB,Y
                    LDY #30:STA S0+2,X:DEY:LDA (OUT),Y:STA S0+1,X:DEY:LDA (OUT),Y
                    STA S0+5,X:DEY:LDA (OUT),Y:STA S0+4,X:LDY #24:LDA (OUT),Y
                    STA S0+3,X:LDY #23
el3                 LDA (OUT),Y:STA S0+0,X:DEX:DEY:BPL el3:INX:BNE ch1or2
                    LDA S0+PMC:BEQ transferf0:JSR transferpm0
transferf0          LDX S0+FINIT:LDY S0+FINIT+1:STX S0FCURR:STY S0FCURR+1
transferf0a         LDA S0+CFMD3:STA S0+FMD3C:LDA S0+CFMD2:STA S0+FMD2C
                    LDA S0+CFMD1:STA S0+FMD1C:LDA S0+CFMD0:STA S0+FMD0C:RTS
ch1or2              CPX #$46:BEQ ch2:LDA S1+PMC:BEQ lll1:JSR transferpm1
lll1                LDA S1+FMC:BEQ ex0
transferf1          LDX S1+FINIT:LDY S1+FINIT+1:STX S1FCURR:STY S1FCURR+1
transferf1a         LDA S1+CFMD3:STA S1+FMD3C:LDA S1+CFMD2:STA S1+FMD2C
                    LDA S1+CFMD1:STA S1+FMD1C:LDA S1+CFMD0:STA S1+FMD0C
ex0                 RTS
ch2                 LDA S2+PMC:BEQ lll2:JSR transferpm2
lll2                LDA S2+FMC:BEQ ex0
transferf2          LDX S2+FINIT:LDY S2+FINIT+1:STX S2FCURR:STY S2FCURR+1
transferf2a         LDA S2+CFMD3:STA S2+FMD3C:LDA S2+CFMD2:STA S2+FMD2C
                    LDA S2+CFMD1:STA S2+FMD1C:LDA S2+CFMD0:STA S2+FMD0C:RTS

INITSOUND           JSR ResetCl:LDA #$97:STA $DD00;\
                    LDX #$17
ResetLoop           LDA #8:STA $D400,X:LDA #0:STA $D400,X:DEX:BPL ResetLoop
                    STA S0+VRC:STA S1+VRC:STA S2+VRC:STA CUT+FMC:STA MFL0:STA MFL1
                    STA MFL2:STX FilterChannel:LDX #15:STX $D418:STA D418
                    RTS

;=========================*=== MUSIC CONTROL ===*==============================

MC0
callt0              LDA (PC0),Y:STA TR0:INY:LDA #4:DFB $2C
call0               LDA #3:LDX SP0:ADD PC0:STA ST0L,X:LDA #0:ADC PC0+1:STA ST0H,X
                    DEC SP0:LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STX PC0:STA PC0+1
                    JMP read.byte0
code0               LDA ^add3c0-1:PHA:LDA #add3c0-1:PHA:LDA (PC0),Y:STA IN:INY
                    LDA (PC0),Y:STA IN+1:JMP (IN)
dmpoke0             LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STA D0,X:INY:LDA (PC0),Y
                    STA D0+1,X:LDA #4:JMP addc0
dspoke0             LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STA S0,X:INY:LDA (PC0),Y
                    STA S0+1,X:LDA #4:JMP addc0
filter0             LDA (PC0),Y:STA filt0loop+1:INY:LDA (PC0),Y:STA filt0loop+2
                    LDX #15
filt0loop           LDA $DDDD,X:STA CUTST,X:DEX:BPL filt0loop:JMP add3c0
fload0              LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STA fload0loop+1:INY:LDA (PC0),Y
                    STA fload0loop+2
fload0loop          LDA $DDDD,X:STA D0,X:DEX:BPL fload0loop:LDA #4:JMP addc0
for0                LDX SP0:LDA #2:ADD PC0:STA ST0L,X:LDA #0:ADC PC0+1:STA ST0H,X
                    LDA (PC0),Y:STA ST0C,X:DEC SP0:LDA #2:JMP addc0
freq0               LDA (PC0),Y:STA frqpoke0+1:INY:LDA (PC0),Y:STA frqpoke0+2
                    LDX #13
frqpoke0            LDA $DDDD,X:STA D0,X:DEX:BPL frqpoke0:JMP add3c0
gotot0              LDA (PC0),Y:STA TR0:INY
goto0               LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STX PC0:STA PC0+1:JMP read.byte0
master0a            LDY #%11110001:STY $D417
master0b            STX FilterChannel:LDA #1:JMP addc0
master0             LDX #0:BEQ master0a
mbendoff0           LDA #5:DFB $2C
mbendon0            LDA #7:STA D0+FMC:TYA:JMP addc0
mpoke0              LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STA D0,X:JMP add3c0
next0               LDX SP0:DEC ST0C+1,X:BEQ n0a:LDY ST0L+1,X:LDA ST0H+1,X:STY PC0
                    STA PC0+1:JMP read.byte0
n0a                 INC SP0:TYA:JMP addc0
retsubrut0          LDY SP0:CPY #DEPTHOFSTACKS-1:BEQ rc0:INC SP0
                    LDX ST0L+1,Y:LDA ST0H+1,Y:STX PC0:STA PC0+1:JMP read.byte0
rc0                 DEC MFL0:RTS
spoke0              LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STA S0,X:JMP add3c0
transp0             LDA (PC0),Y:STA TR0:LDA #2:JMP addc0
trigger0            LDA trig0a:EOR #$B1:STA trig0a:STA trig1a:STA trig2a
                    LDA trig0b:EOR #$60:STA trig0b:STA trig1b:STA trig2b
                    LDA #1:JMP addc0
volume0             LDA (PC0),Y:STA IN:INY:LDA (PC0),Y:STA IN+1:LDY #4
vo0                 LDA (IN),Y:STA D0+VWF,Y:DEY:BPL vo0:JMP add3c0

MC1
callt1              LDA (PC1),Y:STA TR1:INY:LDA #4:DFB $2C
call1               LDA #3:LDX SP1:ADD PC1:STA ST1L,X:LDA #0:ADC PC1+1:STA ST1H,X
                    DEC SP1:LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STX PC1:STA PC1+1
                    JMP read.byte1
code1               LDA ^add3c1-1:PHA:LDA #add3c1-1:PHA:LDA (PC1),Y:STA IN:INY
                    LDA (PC1),Y:STA IN+1:JMP (IN)
dmpoke1             LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STA D1,X:INY:LDA (PC1),Y
                    STA D1+1,X:LDA #4:JMP addc1
dspoke1             LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STA S1,X:INY:LDA (PC1),Y
                    STA S1+1,X:LDA #4:JMP addc1
filter1             LDA (PC1),Y:STA filt1loop+1:INY:LDA (PC1),Y:STA filt1loop+2
                    LDX #15
filt1loop           LDA $DDDD,X:STA CUTST,X:DEX:BPL filt1loop:JMP add3c1
fload1              LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STA fload1loop+1:INY:LDA (PC1),Y
                    STA fload1loop+2
fload1loop          LDA $DDDD,X:STA D1,X:DEX:BPL fload1loop:LDA #4:JMP addc1
for1                LDX SP1:LDA #2:ADD PC1:STA ST1L,X:LDA #0:ADC PC1+1:STA ST1H,X
                    LDA (PC1),Y:STA ST1C,X:DEC SP1:LDA #2:JMP addc1
freq1               LDA (PC1),Y:STA frqpoke1+1:INY:LDA (PC1),Y:STA frqpoke1+2
                    LDX #13
frqpoke1            LDA $DDDD,X:STA D1,X:DEX:BPL frqpoke1:JMP add3c1
goto1               LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STX PC1:STA PC1+1:JMP read.byte1
master1a            LDY #%11110010:STY $D417
master1b            STX FilterChannel:LDA #1:JMP addc1
master1             LDX #1:BNE master1a
mbendoff1           LDA #5:DFB $2C
mbendon1            LDA #7:STA D1+FMC:TYA:JMP addc1
mpoke1              LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STA D1,X:JMP add3c1
next1               LDX SP1:DEC ST1C+1,X:BEQ n1a:LDY ST1L+1,X:LDA ST1H+1,X:STY PC1
                    STA PC1+1:JMP read.byte1
n1a                 INC SP1:TYA:JMP addc1
retsubrut1          LDY SP1:CPY #DEPTHOFSTACKS-1:BEQ rc1:INC SP1
                    LDX ST1L+1,Y:LDA ST1H+1,Y:STX PC1:STA PC1+1:JMP read.byte1
rc1                 DEC MFL1:RTS
transp1             LDA (PC1),Y:STA TR1:LDA #2:JMP addc1
spoke1              LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STA S1,X:JMP add3c1
volume1             LDA (PC1),Y:STA IN:INY:LDA (PC1),Y:STA IN+1:LDY #4
vo1                 LDA (IN),Y:STA D1+VWF,Y:DEY:BPL vo1:JMP add3c1

MC2
callt2              LDA (PC2),Y:STA TR2:INY:LDA #4:DFB $2C
call2               LDA #3:LDX SP2:ADD PC2:STA ST2L,X:LDA #0:ADC PC2+1:STA ST2H,X
                    DEC SP2:LDA (PC2),Y:TAX:INY:LDA (PC2),Y:STX PC2:STA PC2+1
                    JMP read.byte2
code2               LDA ^add3c2-1:PHA:LDA #add3c2-1:PHA:LDA (PC2),Y:STA IN:INY
                    LDA (PC2),Y:STA IN+1:JMP (IN)
dmpoke2             LDA (PC2),Y:TAX:INY:LDA (PC2),Y:STA D2,X:INY:LDA (PC2),Y
                    STA D2+1,X:LDA #4:JMP addc2
dspoke2             LDA (PC2),Y:TAX:INY:LDA (PC2),Y:STA S2,X:INY:LDA (PC2),Y
                    STA S2+1,X:LDA #4:JMP addc2
filter2             LDA (PC2),Y:STA filt2loop+1:INY:LDA (PC2),Y:STA filt2loop+2
                    LDX #15
filt2loop           LDA $DDDD,X:STA CUTST,X:DEX:BPL filt2loop:JMP add3c2
fload2              LDA (PC2),Y:TAX:INY:LDA (PC2),Y:STA fload2loop+1:INY:LDA (PC2),Y
                    STA fload2loop+2
fload2loop          LDA $DDDD,X:STA D2,X:DEX:BPL fload2loop:LDA #4:JMP addc2
for2                LDX SP2:LDA #2:ADD PC2:STA ST2L,X:LDA #0:ADC PC2+1:STA ST2H,X
                    LDA (PC2),Y:STA ST2C,X:DEC SP2:LDA #2:JMP addc2
freq2               LDA (PC2),Y:STA frqpoke2+1:INY:LDA (PC2),Y:STA frqpoke2+2
                    LDX #13
frqpoke2            LDA $DDDD,X:STA D2,X:DEX:BPL frqpoke2:JMP add3c2
goto2               LDA (PC2),Y:TAX:INY:LDA (PC2),Y:STX PC2:STA PC2+1:JMP read.byte2
disown2             DEY:STY CUT+FMC:STY D418:LDX #3:LDY #%11110000:DFB $2C
master2a            LDY #%11110100:STY $D417
master2b            STX FilterChannel:LDA #1:JMP addc2
master2             LDA #%00010000:STA D418:LDA #$1F:STA $D418:LDX #2:BNE master2a
mbendoff2           LDA #5:DFB $2C
mbendon2            LDA #7:STA D2+FMC:TYA:JMP addc2
mpoke2              LDA (PC2),Y:TAX:INY:LDA (PC2),Y:STA D2,X:JMP add3c2
next2               LDX SP2:DEC ST2C+1,X:BEQ n2a:LDY ST2L+1,X:LDA ST2H+1,X:STY PC2
                    STA PC2+1:JMP read.byte2
n2a                 INC SP2:TYA:JMP addc2
retsubrut2          LDY SP2:CPY #DEPTHOFSTACKS-1:BEQ rc2:INC SP2:LDX ST2L+1,Y
                    LDA ST2H+1,Y:STX PC2:STA PC2+1:JMP read.byte2
rc2                 DEC MFL2:RTS
spoke2              LDA (PC2),Y:TAX:INY:LDA (PC2),Y:STA S2,X:JMP add3c2
transp2             LDA (PC2),Y:STA TR2:LDA #2:JMP addc2
volume2             LDA (PC2),Y:STA IN:INY:LDA (PC2),Y:STA IN+1:LDY #4
vo2                 LDA (IN),Y:STA D2+VWF,Y:DEY:BPL vo2:JMP add3c2

;=====================*=== MUSIC & SOUND REFRESH ===*==========================

FILTER              LDA CUT+FMC:BEQ cxit:LDX CUT+16:LDY CUT+17:CLC:LDA CUT+FMDLY
                    BEQ cms0+1:DEC CUT+FMDLY:LDA CUT+FMC:AND #2:BNE cms3a
cxit                RTS
cms0                CLC
                    LDA CUT+18:BEQ cms1:DEC CUT+18
                    TXA:ADC CUT+FMG0:TAX:TYA:ADC CUT+FMG0+1:JMP stcTAY
cms1                LDA CUT+19:BEQ cms2:DEC CUT+19
                    TXA:ADC CUT+FMG1:TAX:TYA:ADC CUT+FMG1+1:JMP stcTAY
cms2                LDA CUT+20:BEQ cms3:DEC CUT+20
                    TXA:ADC CUT+FMG2:TAX:TYA:ADC CUT+FMG2+1:JMP stcTAY
cms3                LDA CUT+21:BEQ cmrep:DEC CUT+21
cms3a               TXA:ADC CUT+FMG3:TAX:TYA:ADC CUT+FMG3+1
stcTAY              TAY
stc                 STX CUT+16:STY CUT+17
pokecutofffrq       TXA:AND #7:STA $D415:TYA:STX FilterByte:LSR:RORFilterByte:LSR
                    RORFilterByte:LSR:LDA FilterByte:ROR:STA $D416:RTS
cmrep               LDA CUT+FMC:AND #$81:BEQ stc:BPL nocfcopy:JSR transfercf:JMP cms0
nocfcopy            JSR transfercfa:JMP cms0

StartFilter         LDX #7
SFL                 LDA CUTST+0,X:STA CUT+0,X:LDA CUTST+8,X:STA CUT+8,X:DEX:BPL SFL
                    JSR transfercf:JMP pokecutofffrq

MUSIC0              LDA MFL0:BEQ mx0:DEC CLOCK0:BEQ read.byte0
mx0                 RTS
crossedover0a       INC PC0+1:BNE read.byte0
add3c0              LDA #3
addc0               ADD PC0:STA PC0:BCS crossedover0a
read.byte0          LDY #0:LDA (PC0),Y:CMP #COM:BCC not.control0:INY:ADC #vt0-COM-1
v0                  STA v0+4:JMP (vt0)
js0                 JMP st0
not.control0        STA Z8:CMP #R:BCC in.du.re.0:SBC #R
in.du.re.0          CMP #Rest:BEQ js0:CMP #Sil:BEQ got.note0;@
                    ADC TR0
got.note0           TAX:LDA RF:AND #1:BEQ js0;\
NOTE0               LDA #8
trig0a              STA $D404
                    LDA FilterChannel:BNE nf0:STX IN:JSR StartFilter:LDX IN
nf0                 LDY HiFrq,X:LDA LoFrq,X:STA S0+FINIT:STY S0+FINIT+1:STA $D400
                    STY $D401:LDX D0+PINIT:LDY D0+PINIT+1:STX $D402:STY $D403
trig0b              BIT pasttrig0:LDA D0+VADV:STA $D405:LDA D0+VSRV
                    STA $D406:LDA D0+VWF:STA S0+VWFG:AND #%11110111:STA $D404

pasttrig0           JSR transferpm0a;LDX #PINIT+1
dll0;          LDA D0,X:STA S0,X:DEX:BPL dll0:LDA S0+FMC

dlpw0               LDA D0+PMC:STA S0+PMC:BEQ dlfrq0:STX S0+PINIT:STY S0+PINIT+1
                    STX S0PCURR:STY S0PCURR+1:LDA D0+PMG1+1:STA S0+PMG1+1
                    LDA D0+PMG1:STA S0+PMG1:LDA D0+PMG0+1:STA S0+PMG0+1:LDA D0+PMG0
                    STA S0+PMG0:LDA D0+PMDLY:STA S0+PMDLY:LDX D0+PMD0:LDY D0+PMD1
                    STX S0+CPMD0:STX S0+PMD0C:STY S0+PMD1C:STY S0+CPMD1

dlfrq0              LDA D0+FMC:STA S0+FMC:BEQ dldur0
                    LDX D0+12:STX S0+12:LDX D0+11:STX S0+11:LDX D0+10:STX S0+10
                    LDX D0+9:STX S0+9:LDX D0+8:STX S0+8:LDX D0+7:STX S0+7
                    LDX D0+6:STX S0+6:LDX D0+5:STX S0+5:LDX D0+4:STX S0+4
                    LDX D0+3:STX S0+3:LDX D0+2:STX S0+2:LDX D0+1:STX S0+1
                    LDX D0+0:STX S0+0

                    AND #8:BEQ no.of.li.mo0:LDA Z8:CMP #R:BCC in.du.re0a:SBC #R-1
in.du.re0a          ADC TR0:STA S0+FOLB:BNE dldur0
no.of.li.mo0        JSR transferf0
dldur0              LDX D0+VADSD:LDY D0+VRD:STX S0+VADSC:STY S0+VRC
st0                 LDY #1:LDA (PC0),Y:LDX Z8:CPX #R:BCS di.du.re0:TAX:LDA IDRT-1,X
di.du.re0           STA CLOCK0:LDA #2
addn0               ADD PC0:STA PC0:BCS crossedover0b:RTS
crossedover0b       INC PC0+1:RTS

MUSIC1              LDA MFL1:BEQ mx1:DEC CLOCK1:BEQ read.byte1
mx1                 RTS
crossedover1a       INC PC1+1:BNE read.byte1
add3c1              LDA #3
addc1               ADD PC1:STA PC1:BCS crossedover1a
read.byte1          LDY #0:LDA (PC1),Y:CMP #COM:BCC not.ctrl1:INY:ADC #vt1-COM-1
v1                  STA v1+4:JMP (vt1)
js1                 JMP st1
not.ctrl1           STA Z8:CMP #R:BCC in.du.re1:SBC #R
in.du.re1           CMP #Rest:BEQ js1:CMP #Sil:BEQ got.note1;@
                    ADC TR1
got.note1           TAX:LDA RF:AND #2:BEQ js1;\
NOTE1               LDA #8
trig1a              STA $D40B
ntb1                LDA FilterChannel:CMP #1:BNE nf1:STX IN:JSR StartFilter:LDX IN
nf1                 LDY HiFrq,X:LDA LoFrq,X:STA S1+FINIT:STY S1+FINIT+1:STA $D407
                    STY $D408:LDX D1+PINIT:LDY D1+PINIT+1:STX $D409:STY $D40A
trig1b              BIT pasttrig1:LDA D1+VADV:STA $D40C:LDA D1+VSRV
                    STA $D40D:LDA D1+VWF:STA S1+VWFG:AND #%11110111:STA $D40B

pasttrig1           JSR transferpm1a;LDX #PINIT+1
dll1;          LDA D1,X:STA S1,X:DEX:BPL dll1:LDA S1+FMC

dlpw1               LDA D1+PMC:STA S1+PMC:BEQ dlfrq1:STX S1+PINIT:STY S1+PINIT+1
                    STX S1PCURR:STY S1PCURR+1:LDA D1+PMG1+1:STA S1+PMG1+1
                    LDX D1+PMG1:STX S1+PMG1:LDA D1+PMG0+1:STA S1+PMG0+1:LDA D1+PMG0
                    STA S1+PMG0:LDA D1+PMDLY:STA S1+PMDLY:LDX D1+PMD0:LDY D1+PMD1
                    STX S1+CPMD0:STX S1+PMD0C:STY S1+CPMD1:STY S1+PMD1C

dlfrq1              LDA D1+FMC:STA S1+FMC:BEQ dldur1
                    LDX D1+12:STX S1+12:LDX D1+11:STX S1+11:LDX D1+10:STX S1+10
                    LDX D1+9:STX S1+9:LDX D1+8:STX S1+8:LDX D1+7:STX S1+7
                    LDX D1+6:STX S1+6:LDX D1+5:STX S1+5:LDX D1+4:STX S1+4
                    LDX D1+3:STX S1+3:LDX D1+2:STX S1+2:LDX D1+1:STX S1+1
                    LDX D1+0:STX S1+0

                    AND #8:BEQ no.of.li.mo1:LDA Z8:CMP #R:BCC in.du.re1a:SBC #R-1
in.du.re1a          ADC TR1:STA S1+FOLB:BNE dldur1
no.of.li.mo1        JSR transferf1
dldur1              LDX D1+VADSD:LDY D1+VRD:STX S1+VADSC:STY S1+VRC
st1                 LDY #1:LDA (PC1),Y:LDX Z8:CPX #R:BCS di.du.re1:TAX:LDA IDRT-1,X
di.du.re1           STA CLOCK1:LDA #2
addn1               ADD PC1:STA PC1:BCS crossedover1b:RTS
crossedover1b       INC PC1+1:RTS

MUSIC2              LDA MFL2:BEQ mx2:DEC CLOCK2:BEQ read.byte2
mx2                 RTS
crossedover2a       INC PC2+1:BNE read.byte2
add3c2              LDA #3
addc2               ADD PC2:STA PC2:BCS crossedover2a
read.byte2          LDY #0:LDA (PC2),Y:CMP #COM:BCC not.ctrl2:INY:ADC #vt2-COM-1
v2                  STA v2+4:JMP (vt2)
js2                 JMP st2
not.ctrl2           STA Z8:CMP #R:BCC in.du.re2:SBC #R
in.du.re2           CMP #Rest:BEQ js2:CMP #Sil:BEQ got.note2;@
                    ADC TR2
got.note2           TAX:LDA RF:AND #4:BEQ js2;\
NOTE2               LDA #8
trig2a              STA $D412
ntb2                LDA FilterChannel:CMP #2:BNE nf2:STX IN:JSR StartFilter:LDX IN
nf2                 LDY HiFrq,X:LDA LoFrq,X:STA S2+FINIT:STY S2+FINIT+1:STA $D40E
                    STY $D40F:LDX D2+PINIT:LDY D2+PINIT+1:STX $D410:STY $D411
trig2b              BIT pasttrig2:LDA D2+VADV:STA $D413:LDA D2+VSRV
                    STA $D414:LDA D2+VWF:STA S2+VWFG:AND #%11110111:STA $D412

pasttrig2           JSR transferpm2a;LDX #PINIT+1
dll2;          LDA D2,X:STA S2,X:DEX:BPL dll2:LDA S2+FMC

dlpw2               LDA D2+PMC:STA S2+PMC:BEQ dlfrq2:STX S2+PINIT:STY S2+PINIT+1
                    STX S2PCURR:STY S2PCURR+1:LDA D2+PMG1+1:STA S2+PMG1+1
                    LDA D2+PMG1:STA S2+PMG1:LDA D2+PMG0+1:STA S2+PMG0+1:LDA D2+PMG0
                    STA S2+PMG0:LDA D2+PMDLY:STA S2+PMDLY:LDX D2+PMD0:LDY D2+PMD1
                    STX S2+CPMD0:STX S2+PMD0C:STY S2+CPMD1:STY S2+PMD1C

dlfrq2              LDA D2+FMC:STA S2+FMC:BEQ dldur2
                    LDX D2+12:STX S2+12:LDX D2+11:STX S2+11:LDX D2+10:STX S2+10
                    LDX D2+9:STX S2+9:LDX D2+8:STX S2+8:LDX D2+7:STX S2+7
                    LDX D2+6:STX S2+6:LDX D2+5:STX S2+5:LDX D2+4:STX S2+4
                    LDX D2+3:STX S2+3:LDX D2+2:STX S2+2:LDX D2+1:STX S2+1
                    LDX D2+0:STX S2+0

                    AND #8:BEQ no.of.li.mo2:LDA Z8:CMP #R:BCC in.du.re2a:SBC #R-1
in.du.re2a          ADC TR2:STA S2+FOLB:BNE dldur2
no.of.li.mo2        JSR transferf2
dldur2              LDX D2+VADSD:LDY D2+VRD:STX S2+VADSC:STY S2+VRC
st2                 LDY #1:LDA (PC2),Y:LDX Z8:CPX #R:BCS di.du.re2:TAX:LDA IDRT-1,X
di.du.re2           STA CLOCK2:LDA #2
addn2               ADD PC2:STA PC2:BCS crossedover2b:RTS
crossedover2b       INC PC2+1
nosound0            RTS

SOUND0              LDX S0+VRC:BEQ nosound0:LDA S0+VWFG:AND #8:BEQ adsr0:LDA CLOCK0
                    CMP S0+VADSC:BCS PM0:LDA #0:STA S0+VADSC:LDA S0+VWFG
                    AND #%11110110:STA S0+VWFG:BNE trigrel0
adsr0               LDA S0+VADSC:BNE ad0:LDY S0+VRC:INY:BEQ PM0:DEC S0+VRC:BNE PM0
                    LDX #6
cc0                 STA $D400,X:DEX:BPL cc0;STX SFL0;[
CheckFilter         CMP FilterChannel:BNE nosound0:INX:STX CUT+FMC:RTS
ad0                 LDY S0+VADSC:INY:BEQ PM0:DEC S0+VADSC:BNE PM0:LDA S0+VWFG
                    AND #246
trigrel0            STA $D404
PM0                 LDA S0+PMC:BEQ FM0
                    LDA S0FCURR:ORA S0FCURR+1:BEQ FM0;@
                    LDA S0+PMDLY:BEQ pmdel0:DEC S0+PMDLY:JMP FM0
pmdel0              CLC:LDX S0PCURR:LDY S0PCURR+1
pms00               LDA S0+PMD0C:BEQ pms10:DEC S0+PMD0C
                    TXA:ADC S0+PMG0:TAX:TYA:ADC S0+PMG0+1:TAY:JMP stpm0
pms10               LDA S0+PMD1C:BEQ pmrep0:DEC S0+PMD1C
                    TXA:ADC S0+PMG1:TAX:TYA:ADC S0+PMG1+1:TAY:JMP stpm0
pmrep0              LDA S0+PMC:AND #$81:BEQ stpm0:BPL nopmcopy0:JSR transferpm0
                    JMP pmdel0
nopmcopy0           JSR transferpm0a:JMP pmdel0
stpm0               STX S0PCURR:STY S0PCURR+1:STX $D402:STY $D403
FM0                 LDA S0+FMC:BEQ xit0
                    AND #8:BNE olm0;]
                    LDA S0FCURR:ORA S0FCURR+1:BEQ xit0;@
                    LDX S0FCURR:LDY S0FCURR+1:CLC:LDA S0+FMDLY:BEQ fcs10+1
                    DEC S0+FMDLY:LDA S0+FMC:AND #2:BNE fcs40l1
xit0                RTS
olm0                DEC S0+FOLDC:BNE xit0:LDY S0+FOLOD:STY S0+FOLDC:LDY S0+FOLCI;]
                    BPL no0:LDY S0+FOLII
no0                 LDX S0+FOLA:STX IN:LDX S0+FOLA+1:STX IN+1:LDA S0+FOLB:ADD (IN),Y
                    DEY:STY S0+FOLCI:TAY
POKEFRQ0            LDX LoFrq,Y:LDA HiFrq,Y:STX $D400:STA $D401:RTS
fcs10               CLC:LDA S0+FMD0C:BEQ fcs20:DEC S0+FMD0C
                    TXA:ADC S0+FMG0:TAX:TYA:ADC S0+FMG0+1:JMP stf0TAY
fcs20               LDA S0+FMD1C:BEQ fcs30:DEC S0+FMD1C
                    TXA:ADC S0+FMG1:TAX:TYA:ADC S0+FMG1+1:JMP stf0TAY
fcs30               LDA S0+FMD2C:BEQ fcs40:DEC S0+FMD2C
                    TXA:ADC S0+FMG2:TAX:TYA:ADC S0+FMG2+1:JMP stf0TAY
fcs40               LDA S0+FMD3C:BEQ fcrep0:DEC S0+FMD3C
fcs40l1             TXA:ADC S0+FMG3:TAX:TYA:ADC S0+FMG3+1
stf0TAY             TAY
stf0                STX $D400:STY $D401:STX S0FCURR:STY S0FCURR+1
nosound1            RTS
fcrep0              LDA S0+FMC:AND #$81:BEQ stf0:BPL nofrqcopy0:JSR transferf0
                    JMP fcs10
nofrqcopy0          JSR transferf0a:JMP fcs10

SOUND1              LDX S1+VRC:BEQ nosound1:LDA S1+VWFG:AND #8:BEQ adsr1:LDA CLOCK1
                    CMP S1+VADSC:BCS PM1:LDA #0:STA S1+VADSC:LDA S1+VWFG
                    AND #%11110110:STA S1+VWFG:BNE trigrel1
adsr1               LDA S1+VADSC:BNE ad1:LDY S1+VRC:INY:BEQ PM1:DEC S1+VRC:BNE PM1
                    LDX #6
cc1                 STA $D407,X:DEX:BPL cc1;STX SFL1;[
                    LDA #1:JMP CheckFilter
ad1                 LDY S1+VADSC:INY:BEQ PM1:DEC S1+VADSC:BNE PM1:LDA S1+VWFG
                    AND #246
trigrel1            STA $D40B
PM1                 LDA S1+PMC:BEQ FM1
                    LDA S1FCURR:ORA S1FCURR+1:BEQ FM1;@
                    LDA S1+PMDLY:BEQ pmdel1:DEC S1+PMDLY:JMP FM1
pmdel1              CLC:LDX S1PCURR:LDY S1PCURR+1
pms01               LDA S1+PMD0C:BEQ pms11:TXA:ADC S1+PMG0:TAX:TYA:ADC S1+PMG0+1
                    TAY:DEC S1+PMD0C:JMP stpm1
pms11               LDA S1+PMD1C:BEQ pmrep1:TXA:ADC S1+PMG1:TAX:TYA:ADC S1+PMG1+1
                    TAY:DEC S1+PMD1C:JMP stpm1
pmrep1              LDA S1+PMC:AND #$81:BEQ stpm1:BPL nopmcopy1:JSR transferpm1
                    JMP pmdel1
nopmcopy1           JSR transferpm1a:JMP pmdel1
stpm1               STX S1PCURR:STY S1PCURR+1:STX $D409:STY $D40A
FM1                 LDA S1+FMC:BEQ xit1
                    AND #8:BNE olm1;]
                    LDA S1FCURR:ORA S1FCURR+1:BEQ xit1;@
                    LDX S1FCURR:LDY S1FCURR+1:CLC:LDA S1+FMDLY:BEQ fcs11+1
                    DEC S1+FMDLY:LDA S1+FMC:AND #2:BNE fcs41l1
xit1                RTS
olm1                DEC S1+FOLDC:BNE xit1:LDY S1+FOLOD:STY S1+FOLDC:LDY S1+FOLCI;]
                    BPL no1:LDY S1+FOLII
no1                 LDX S1+FOLA:STX IN:LDX S1+FOLA+1:STX IN+1:LDA S1+FOLB:ADD (IN),Y
                    DEY:STY S1+FOLCI:TAY
POKEFRQ1            LDX LoFrq,Y:LDA HiFrq,Y:STX $D407:STA $D408:RTS
fcs11               CLC:LDA S1+FMD0C:BEQ fcs21:DEC S1+FMD0C
                    TXA:ADC S1+FMG0:TAX:TYA:ADC S1+FMG0+1:JMP stf1TAY
fcs21               LDA S1+FMD1C:BEQ fcs31:DEC S1+FMD1C
                    TXA:ADC S1+FMG1:TAX:TYA:ADC S1+FMG1+1:JMP stf1TAY
fcs31               LDA S1+FMD2C:BEQ fcs41:DEC S1+FMD2C
                    TXA:ADC S1+FMG2:TAX:TYA:ADC S1+FMG2+1:JMP stf1TAY
fcs41               LDA S1+FMD3C:BEQ fcrep1:DEC S1+FMD3C
fcs41l1             TXA:ADC S1+FMG3:TAX:TYA:ADC S1+FMG3+1
stf1TAY             TAY
stf1                STX $D407:STY $D408:STX S1FCURR:STY S1FCURR+1
nosound2            RTS
fcrep1              LDA S1+FMC:AND #$81:BEQ stf1:BPL nofrqcopy1:JSR transferf1
                    JMP fcs11
nofrqcopy1          JSR transferf1a:JMP fcs11

SOUND2              LDX S2+VRC:BEQ nosound2:LDA S2+VWFG:AND #8:BEQ adsr2:LDA CLOCK2
                    CMP S2+VADSC:BCS PM2:LDA #0:STA S2+VADSC:LDA S2+VWFG
                    AND #%11110110:STA S2+VWFG:BNE trigrel2
adsr2               LDA S2+VADSC:BNE ad2:LDY S2+VRC:INY:BEQ PM2:DEC S2+VRC:BNE PM2
                    LDX #6
cc2                 STA $D40E,X:DEX:BPL cc2;STX SFL2;[
                    LDA #2:JMP CheckFilter
ad2                 LDY S2+VADSC:INY:BEQ PM2:DEC S2+VADSC:BNE PM2:LDA S2+VWFG
                    AND #246
trigrel2            STA $D412
PM2                 LDA S2+PMC:BEQ FM2
                    LDA S2FCURR:ORA S2FCURR+1:BEQ FM2;@
                    LDA S2+PMDLY:BEQ pmdel2:DEC S2+PMDLY:JMP FM2
pmdel2              CLC:LDX S2PCURR:LDY S2PCURR+1
pms02               LDA S2+PMD0C:BEQ pms12:DEC S2+PMD0C
                    TXA:ADC S2+PMG0:TAX:TYA:ADC S2+PMG0+1:TAY:JMP stpm2
pms12               LDA S2+PMD1C:BEQ pmrep2:DEC S2+PMD1C
                    TXA:ADC S2+PMG1:TAX:TYA:ADC S2+PMG1+1:TAY:JMP stpm2
pmrep2              LDA S2+PMC:AND #$81:BEQ stpm2:BPL nopmcopy2:JSR transferpm2
                    JMP pmdel2
nopmcopy2           JSR transferpm2a:JMP pmdel2
stpm2               STX S2PCURR:STY S2PCURR+1:STX $D410:STY $D411
FM2                 LDA S2+FMC:BEQ xit2
                    AND #8:BNE olm2;]
                    LDA S2FCURR:ORA S2FCURR+1:BEQ xit2;@
                    LDX S2FCURR:LDY S2FCURR+1:CLC:LDA S2+FMDLY:BEQ fcs12+1
                    DEC S2+FMDLY:LDA S2+FMC:AND #2:BNE fcs42l1
xit2                RTS
olm2                DEC S2+FOLDC:BNE xit2:LDY S2+FOLOD:STY S2+FOLDC:LDY S2+FOLCI;]
                    BPL no2:LDY S2+FOLII
no2                 LDX S2+FOLA:STX IN:LDX S2+FOLA+1:STX IN+1:LDA S2+FOLB:ADD (IN),Y
                    DEY:STY S2+FOLCI:TAY
POKEFRQ2            LDX LoFrq,Y:LDA HiFrq,Y:STX $D40E:STA $D40F:RTS
fcs12               CLC:LDA S2+FMD0C:BEQ fcs22:DEC S2+FMD0C
                    TXA:ADC S2+FMG0:TAX:TYA:ADC S2+FMG0+1:JMP stf2TAY
fcs22               LDA S2+FMD1C:BEQ fcs32:DEC S2+FMD1C
                    TXA:ADC S2+FMG1:TAX:TYA:ADC S2+FMG1+1:JMP stf2TAY
fcs32               LDA S2+FMD2C:BEQ fcs42:DEC S2+FMD2C
                    TXA:ADC S2+FMG2:TAX:TYA:ADC S2+FMG2+1:JMP stf2TAY
fcs42               LDA S2+FMD3C:BEQ fcrep2:DEC S2+FMD3C
fcs42l1             TXA:ADC S2+FMG3:TAX:TYA:ADC S2+FMG3+1
stf2TAY             TAY
stf2                STX $D40E:STY $D40F:STX S2FCURR:STY S2FCURR+1:RTS
fcrep2              LDA S2+FMC:AND #$81:BEQ stf2:BPL nofrqcopy2:JSR transferf2
                    JMP fcs12
nofrqcopy2          JSR transferf2a:JMP fcs12

MUSICTEST           LDA MFL0:ORA MFL1:ORA MFL2:ORA S0+VRC:ORA S1+VRC:ORA S2+VRC:RTS

;==============================================================================

;Game Over percussion program starts here

NMI                 EQU $0107
StacksDepth         EQU 4

bass                EQU $81
snare               EQU $82
tomhi               EQU $83
cowbell             EQU $84
tomlo               EQU $85
hihat               EQU $86
Drest               EQU $87
tube4               EQU $88
Dcowbell            EQU $89

ZERO                EQU $0050
seqPC               EQU ZERO+0;2
seqCLK              EQU ZERO+2;1
seqSP               EQU ZERO+3;1
synwksp             EQU ZERO+4;1

PLEY                LDA DRUMFLAG:BEQ exit:LDA #0:STA DRUMFLAG:STA synwksp:STA BDR
DRMvc               JMP $DDDD
DRMret              LDA #15:ORA D418:STA $D418:LDA #12:STA BDR:RTS

RIFF                STA seqCLK:STX seqPC:STY seqPC+1:LDA #StacksDepth-1:STA seqSP:RTS

DRUMS               DEC seqCLK:BNE exit
repeat              LDY #0:LDA (seqPC),Y:BMI drum:LDX #255
control             INX:CMP DRUMCONTROLS,X:BNE control
                    LDA CNTRLVCSl,X:STA cntrlvc+1:LDA CNTRLVCSh,X:STA cntrlvc+2
cntrlvc             JSR $DDDD:JMP repeat
drum                STA DRUMFLAG:TAX:INY:LDA (seqPC),Y:STA seqCLK:LDA seqPC:ADD #2
                    STA seqPC:BCC nodadd:INC seqPC+1
nodadd              LDA VCTRSlow-$81,X:STA DRMvc+1:LDA VCTRShigh-$81,X:STA DRMvc+2
exit                RTS

STK                 LDX seqSP:ADD seqPC:STA STKLOW,X:LDA seqPC+1:ADC #0:STA STKHIGH,X
                    DEX:STX seqSP:RTS

DESTK               INC seqSP:LDX seqSP
DESTKa              LDA STKLOW,X:STA seqPC:LDA STKHIGH,X:STA seqPC+1:RTS

DRUMJSR             LDA #3:JSR STK
DRUMJMP             INY:LDA (seqPC),Y:TAX:INY:LDA (seqPC),Y:STX seqPC:STA seqPC+1:RTS

DRUMFoR             LDA #2:JSR STK:PHA:INY:LDA (seqPC),Y:STA STKCNT+1,X:PLA
                    STA seqPC+1:LDA STKLOW+1,X:STA seqPC:RTS

DRUMNEXT            INC seqSP:LDX seqSP:DEC STKCNT,X:BEQ EOL:JSR DESTKa:DEC seqSP:RTS
EOL                 STX seqSP:INC seqPC:BNE exit:INC seqPC+1:RTS

HIHAT               LDY #5
H1                  LDX #25
H2                  LDA HIHATTABLE,Y:SEC
H3                  SBC #1:BNE H3:LDA synwksp:ADD #152:STA synwksp:AND #15:STA $D418
                    DEX:BNE H2:DEY:BPL H1:JMP DRMret

TOMhig              LDY #5
X1                  LDX #25
X2                  LDA TOMhiTABLE,Y
X3                  SUB #1:BNE X3:LDA synwksp:ADD #101:STA synwksp:AND #15:STA $D418
                    DEX:BNE X2:DEY:BPL X1:JMP DRMret

TOMlow              LDY #5
Y1                  LDX #25
Y2                  LDA TOMloTABLE,Y
Y3                  SUB #1:BNE Y3:LDA synwksp:ADD #$DD:STA synwksp:AND #15:STA $D418
                    DEX:BNE Y2:DEY:BPL Y1:JMP DRMret

TUBE4               LDY #5
O1                  LDX #55
O2                  LDA TUBE4TABLE,Y
O3                  SUB #1:BNE O3:LDA synwksp:ADD #13:STA synwksp:AND #15:STA $D418
                    DEX:BNE O2:DEY:BPL O1:JMP DRMret

TOMhiTABLE          DFB 32,16,8,4,2,1
TOMloTABLE          DFB 35,20,12,9,6,3
TUBE4TABLE          DFB 46,23,12,6,3,1
HIHATTABLE          DFB 60,10,40,10,20,10
DRUMCONTROLS        DFB $20,$40,$60,$49,$4C;JSR, RTI, RTS, EOR & JMP!
CNTRLVCSl           DFL DRUMJSR,DRUMNEXT,DESTK,DRUMFoR,DRUMJMP
CNTRLVCSh           DFH DRUMJSR,DRUMNEXT,DESTK,DRUMFoR,DRUMJMP
VCTRSlow            DFL BASSDRUM,SNAREDRUM,TOMhig,COWBELL,TOMlow,HIHAT,DRMret,TUBE4
                    DFL DCOWBELL
VCTRShigh           DFH BASSDRUM,SNAREDRUM,TOMhig,COWBELL,TOMlow,HIHAT,DRMret,TUBE4
                    DFH DCOWBELL

DRUMFLAG            DFB 0
STKLOW              DFS StacksDepth,0
STKHIGH             DFS StacksDepth,0
STKCNT              DFS StacksDepth,0

;===================== TITLE SCREEN DRUM DATA =================================

D                   EQU 3

DTL4                DFL tomlo,2,tomlo,4*D-2
                    RTS
DTL2                DFL tomlo,2,tomlo,2*D-2
                    RTS
DTH2                DFL tomhi,2,tomhi,2*D-2
                    RTS
DT42                DFL tube4,2,tube4,2*D-2
                    RTS
DHH2                DFL hihat,2,hihat,2*D-2
                    RTS
DCB2                DFL cowbell,2*D,cowbell,2*D
                    RTS
DBD2                DFL bass,2*D,bass,2*D
                    RTS
DSN2                DFL snare,2*D,snare,2*D
                    RTS
THT2                DFL tomhi,2*D,hihat,2*D,tomhi,2*D
                    RTS
TDS0                EOR #6
                    JSR DCB2
                    DFL tomhi,2*D,cowbell,2*D,snare,2*D,cowbell,2*D,tomhi,2*D
                    DFL cowbell,2*D
                    RTI
                    RTS
TDS1                DFL bass,2*D,cowbell,2*D,bass,2*D
                    JSR DCB2
                    DFL bass,2*D,tomhi,2*D
                    JSR DBD2
                    JSR DBD2
                    JSR DCB2
                    JSR DBD2
                    DFL cowbell,2*D
                    RTS
TDS2                JSR TDS0
                    JSR DCB2
                    DFL tomhi,2*D,cowbell,2*D,snare,2*D,bass,2*D,tomhi,2*D,bass,2*D
                    DFL cowbell,2*D,bass,2*D,tomhi,2*D,cowbell,2*D,bass,8*D
TDS2a               JSR TDS0
                    JSR DCB2
                    DFL tomhi,2*D,cowbell,2*D,snare,2*D,tube4,2*D,tomhi,2*D,tube4,2*D
                    DFL cowbell,2*D,tube4,2*D,tomhi,2*D,cowbell,2*D,tube4,8*D
                    RTS
TDS3                DFL bass,14*D
                    JSR DTL2
                    JSR DTL4
                    JSR DTL4
                    DFL Drest,2*D
                    JSR DTL4
                    JSR DTL2
                    JSR DTL4
                    DFL Drest,10*D
                    JSR DTL2
                    JSR DTL4
                    JMP DTL4
TDS4                EOR #16
                    DFL cowbell,2*D,cowbell,2*D
                    JSR DTH2
                    DFL cowbell,2*D
                    RTI
                    RTS
TDS5                DFL cowbell,2*D,tomhi,4*D,tomhi,2*D
                    RTS

DRUMDATA            EOR #64
                    DFL Drest,15
                    RTI
                    DFL Drest,8
                    JSR TDS4
                    JSR TDS2
                    EOR #2
                    JSR TDS1
                    JSR DT42
                    DFL cowbell,2*D,tomhi,2*D
                    JSR DT42
                    JSR DCB2
                    JSR DT42
                    JSR DT42
                    DFL cowbell,2*D
                    JSR DT42
                    DFL tomhi,2*D,cowbell,2*D
                    JSR DT42
                    DFL cowbell,2*D,snare,2*D,cowbell,2*D
                    JSR TDS1
                    JSR DT42
                    DFL cowbell,2*D,tomhi,2*D
                    JSR DT42
                    JSR DCB2
                    JSR DT42
                    JSR DT42
                    DFL cowbell,2*D,snare,2*D,tomhi,2*D,cowbell,2*D,snare,2*D
                    DFL cowbell,2*D,tomhi,2*D,cowbell,2*D
                    RTI
                    JSR TDS2
                    EOR #2
                    JSR TDS3
                    JSR DTL2
                    JSR DTL4
                    JSR DTL2
                    JSR TDS3
                    DFL snare,2*D
                    JSR DTL4
                    JSR DTL2
                    RTI
                    DFL bass,64*D,Drest,64*D,Drest,64*D,Drest,32*D,bass,4*D,snare,2*D
                    JSR DCB2
                    DFL snare,2*D
                    JSR DTH2
                    DFL cowbell,2*D,snare,2*D,cowbell,2*D,snare,2*D,cowbell,2*D
                    JSR DSN2
                    DFL snare,4*D,tomhi,2,tomhi,2,tomhi,6*D-4,cowbell,2,cowbell,2
                    DFL cowbell,6*D-4,tomlo,2,tomlo,2,tomlo,6*D-4,snare,2,snare,2
                    DFL snare,6*D-4,tube4,2,tube4,2,tube4,8*D-4
                    JSR TDS0
                    JSR DCB2
                    DFL bass,2*D,cowbell,2*D,snare,2*D,cowbell,2*D,bass,2*D
                    DFL cowbell,2*D
                    JSR DBD2
                    DFL tomhi,2*D,bass,2*D,bass,8*D
                    JSR TDS2a
                    EOR #2
                    EOR #7
                    DFL Dcowbell,8*D
                    RTI
                    JSR TDS5
                    EOR #6
                    DFL Dcowbell,8*D
                    RTI
                    JSR TDS5
                    JSR TDS5
                    RTI
                    EOR #2
                    EOR #3
                    DFL Dcowbell,2*D
                    JSR THT2
                    RTI
                    EOR #4
                    DFL Dcowbell,8*D
                    RTI
                    JSR TDS5
                    EOR #3
                    DFL Dcowbell,2*D
                    JSR THT2
                    RTI
                    EOR #3
                    DFL Dcowbell,8*D
                    RTI
                    JSR TDS5
                    JSR TDS5
                    RTI
                    EOR #4
                    EOR #7
                    DFL Dcowbell,2*D
                    JSR THT2
                    RTI
                    JSR TDS5
                    EOR #6
                    DFL Dcowbell,2*D
                    JSR THT2
                    RTI
                    JSR TDS5
                    JSR TDS5
                    RTI
                    EOR #2
                    EOR #7
                    DFL bass,2*D
                    JSR THT2
                    RTI
                    JSR TDS5
                    EOR #6
                    DFL bass,2*D
                    JSR THT2
                    RTI
                    JSR TDS5
                    JSR TDS5
                    RTI
                    EOR #2
                    EOR #3
                    DFL bass,2*D
                    JSR THT2
                    DFL snare,2*D
                    JSR THT2
                    RTI
                    JSR TDS5
                    JSR TDS5
                    EOR #6
                    DFL bass,2*D
                    JSR DTH2
                    JSR DHH2
                    JSR DTH2
                    RTI
                    JSR TDS5
                    JSR TDS5
                    RTI
                    EOR #4
                    EOR #7
                    DFL bass,2*D
                    JSR THT2
                    DFL snare,2*D
                    JSR THT2
                    RTI
                    DFL bass,2*D,tomhi,2*D,hihat,2*D
                    JSR DSN2
                    DFL tomhi,2*D
                    JSR DSN2
                    RTI

                    EOR #2
                    EOR #3
                    DFL bass,2*D,tomhi,2*D,cowbell,2*D,tomhi,2*D,snare,2*D,tomhi,2*D
                    DFL cowbell,2*D,tomhi,2*D,bass,2*D,cowbell,2*D,hihat,2*D
                    DFL cowbell,2*D,snare,2*D
                    JSR DCB2
                    DFL tomhi,2*D
                    RTI
                    DFL bass,2*D,tomhi,2*D,cowbell,2*D,tomhi,2*D,snare,2*D,tomhi,2*D
                    DFL cowbell,2*D,tomhi,2*D,bass,2*D,cowbell,2*D,hihat,2*D
                    JSR DSN2
                    DFL cowbell,2*D
                    JSR DSN2
                    RTI

DX                  EOR #2
                    EOR #3
                    DFL bass,4*D,cowbell,4*D,snare,4*D
                    JSR DCB2
                    DFL bass,2*D,cowbell,4*D,cowbell,2*D
                    DFL snare,2*D,cowbell,2*D,cowbell,4*D
                    RTI
                    DFL bass,4*D
                    JSR DCB2
                    DFL snare,4*D
                    JSR DCB2
                    DFL bass,2*D
                    DFL cowbell,4*D
                    JSR DSN2
                    DFL cowbell,2*D
                    JSR DSN2
                    RTI

                    EOR #18
                    DFL Drest,32*D
                    RTI
                    DFL Drest,1
                    JMP DRUMDATA

;========================== BASS DRUM ROUTINE =================================

BASSDRUM            LDX #0
BD1                 LDA ROCKBASS+256*0,X:LSR:LSR:LSR:LSR:JSR DBD
                    LDA ROCKBASS+256*0,X:NOP:NOP:NOP:AND #15:JSR DBD:INX:BNE BD1
                    JMP DRMret

DBD                 STA $D418:LDY #16
DBD1                DEY:BPL DBD1:RTS

ROCKBASS            DFB $00,$00,$00,$00,$23,$56,$7A,$AE;256 bytes, speed 20
                    DFB $BE,$EE,$EE,$FE,$ED,$DB,$AA,$77
                    DFB $65,$44,$44,$33,$44,$46,$66,$77
                    DFB $78,$77,$76,$55,$43,$20,$00,$00
                    DFB $00,$00,$00,$02,$22,$44,$56,$66
                    DFB $78,$88,$8A,$AA,$AA,$AA,$AA,$AA
                    DFB $AA,$88,$76,$66,$55,$56,$32,$22
                    DFB $20,$20,$00,$00,$02,$02,$02,$22
                    DFB $34,$34,$56,$56,$66,$66,$56,$66
                    DFB $66,$66,$77,$78,$AA,$AB,$AA,$EA
                    DFB $BB,$BD,$BB,$A8,$A6,$63,$62,$32
                    DFB $33,$22,$22,$10,$22,$22,$42,$43
                    DFB $54,$55,$66,$64,$46,$65,$65,$65
                    DFB $66,$66,$76,$78,$8A,$7A,$88,$97
                    DFB $77,$76,$66,$62,$42,$22,$02,$22
                    DFB $22,$23,$33,$45,$66,$56,$77,$78
                    DFB $8A,$8A,$AA,$AA,$AA,$AA,$A8,$88
                    DFB $77,$66,$65,$64,$43,$32,$20,$00
                    DFB $00,$00,$00,$23,$34,$67,$7A,$AB
                    DFB $BB,$BD,$BB,$EB,$DB,$DB,$BA,$BA
                    DFB $A7,$87,$76,$65,$33,$22,$22,$22
                    DFB $22,$22,$22,$22,$12,$22,$21,$22
                    DFB $32,$22,$44,$66,$67,$88,$AA,$AA
                    DFB $AA,$BA,$AB,$AA,$AA,$AA,$AA,$AA
                    DFB $A8,$A7,$9A,$77,$A7,$76,$66,$44
                    DFB $43,$24,$22,$22,$22,$02,$22,$33
                    DFB $35,$55,$66,$76,$67,$77,$47,$65
                    DFB $77,$A6,$97,$A8,$AA,$AA,$BB,$AA
                    DFB $9A,$98,$A7,$77,$67,$76,$77,$67
                    DFB $67,$68,$67,$67,$06,$53,$22,$42
                    DFB $33,$12,$22,$22,$03,$22,$23,$44
                    DFB $55,$77,$A8,$AB,$BB,$BE,$DE,$DD

;========================= SNARE DRUM ROUTINE =================================

SNAREDRUM           LDX #0
SN1                 LDA ROCKSNARE+256*0,X:LSR:LSR:LSR:LSR:JSR DSN
                    LDA ROCKSNARE+256*0,X:NOP:NOP:NOP:AND #15:JSR DSN:INX:BNE SN1
SN2                 LDA ROCKSNARE+256*1,X:LSR:LSR:LSR:LSR:JSR DSN
                    LDA ROCKSNARE+256*1,X:NOP:NOP:NOP:AND #15:JSR DSN:INX:BNE SN2
SN1A                LDA ROCKSNARE+256*0,X:LSR:LSR:LSR:LSR:JSR DSN
                    LDA ROCKSNARE+256*0,X:NOP:NOP:NOP:AND #15:JSR DSN:INX:BNE SN1A
SN2A                LDA ROCKSNARE+256*1,X:LSR:LSR:LSR:LSR:JSR DSN
                    LDA ROCKSNARE+256*1,X:NOP:NOP:NOP:AND #15:JSR DSN:INX:BNE SN2A
                    JMP DRMret

DSN                 STA $D418:LDY #3
DSN1                DEY:BPL DSN1:RTS

ROCKSNARE           DFB $47,$78,$87,$88,$88,$88,$87,$80;512 bytes, speed 8
                    DFB $24,$33,$34,$27,$80,$05,$E2,$F0
                    DFB $FB,$AF,$FF,$FF,$FF,$FF,$FD,$CB
                    DFB $A8,$95,$95,$54,$57,$14,$73,$14
                    DFB $23,$10,$00,$00,$00,$00,$00,$00
                    DFB $00,$11,$24,$56,$AA,$DF,$FF,$FF
                    DFB $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    DFB $FE,$FF,$BD,$B8,$75,$53,$11,$00
                    DFB $00,$00,$00,$00,$00,$00,$00,$00
                    DFB $00,$00,$91,$49,$7F,$CF,$FF,$FF
                    DFB $FF,$FF,$FF,$FF,$F9,$FD,$AA,$CC
                    DFB $7B,$AC,$AA,$69,$49,$46,$E4,$A7
                    DFB $68,$53,$24,$11,$30,$20,$10,$10
                    DFB $10,$36,$39,$28,$64,$D8,$B8,$F4
                    DFB $B6,$B8,$58,$88,$78,$9B,$AD,$CC
                    DFB $EE,$CD,$EF,$BE,$9F,$B9,$CD,$8C
                    DFB $BB,$B8,$86,$B6,$87,$78,$46,$31
                    DFB $93,$62,$70,$27,$52,$15,$55,$47
                    DFB $20,$57,$33,$02,$4A,$67,$3A,$97
                    DFB $4A,$89,$7F,$9F,$FD,$DF,$DF,$FE
                    DFB $EF,$DF,$DF,$DD,$DA,$8E,$96,$68
                    DFB $61,$34,$71,$12,$72,$43,$40,$30
                    DFB $05,$00,$01,$01,$03,$18,$34,$15
                    DFB $46,$69,$A7,$C8,$9A,$BB,$AE,$DD
                    DFB $FF,$DF,$DA,$FC,$FC,$EB,$DA,$AA
                    DFB $8C,$B9,$69,$5B,$75,$A2,$92,$34
                    DFB $45,$42,$80,$00,$10,$61,$35,$37
                    DFB $35,$77,$56,$56,$66,$D5,$87,$A9
                    DFB $97,$D8,$B9,$B9,$F8,$DA,$8C,$BE
                    DFB $8F,$7A,$8E,$9C,$AB,$CA,$AB,$CD
                    DFB $7C,$89,$47,$92,$61,$36,$36,$24
                    DFB $02,$43,$54,$24,$68,$55,$67,$56
                    DFB $57,$99,$07,$77,$77,$77,$72,$9A
                    DFB $8F,$27,$08,$A1,$72,$50,$1F,$76
                    DFB $85,$C6,$40,$76,$7B,$AF,$7D,$FE
                    DFB $7B,$D6,$07,$51,$07,$57,$BE,$B8
                    DFB $5B,$89,$A3,$87,$BC,$8C,$50,$68
                    DFB $B5,$A5,$46,$7B,$66,$79,$A7,$88
                    DFB $85,$A2,$53,$58,$89,$7A,$9C,$77
                    DFB $66,$A9,$63,$65,$47,$8B,$8A,$A8
                    DFB $68,$86,$36,$47,$75,$38,$89,$78
                    DFB $B7,$99,$95,$96,$66,$37,$88,$56
                    DFB $86,$96,$96,$8A,$98,$99,$87,$88
                    DFB $66,$67,$98,$88,$67,$99,$78,$79
                    DFB $79,$A8,$88,$88,$98,$78,$68,$88
                    DFB $98,$9A,$88,$87,$78,$86,$76,$86
                    DFB $56,$86,$79,$78,$97,$99,$98,$8B
                    DFB $78,$86,$79,$77,$87,$CA,$78,$87
                    DFB $76,$86,$77,$76,$67,$88,$77,$89
                    DFB $88,$77,$77,$87,$77,$86,$78,$77
                    DFB $78,$78,$98,$96,$88,$88,$77,$78
                    DFB $77,$78,$87,$77,$77,$77,$88,$78
                    DFB $88,$87,$87,$77,$77,$65,$68,$88
                    DFB $88,$89,$88,$87,$67,$87,$78,$67
                    DFB $77,$78,$88,$77,$87,$87,$88,$78
                    DFB $88,$77,$78,$78,$87,$87,$87,$77
                    DFB $77,$78,$78,$77,$88,$88,$88,$87
                    DFB $78,$77,$77,$77,$88,$87,$88,$88
                    DFB $88,$78,$87,$87,$77,$77,$77,$77
                    DFB $78,$87,$88,$88,$87,$88,$88,$88
                    DFB $78,$78,$77,$77,$78,$87,$87,$77
                    DFB $77,$88,$88,$88,$77,$78,$77,$77
                    DFB $87,$87,$88,$78,$78,$88,$88,$88
                    DFB $77,$77,$77,$77,$77,$78,$77,$77

;=========================== COWBELL ROUTINE ==================================

DCOWBELL            JSR BELL
COWBELL             JSR BELL
                    JMP DRMret

BELL                LDX #0
CB1                 LDA ROCKCOWBELL+256*0,X:LSR:LSR:LSR:LSR:JSR DCB
                    LDA ROCKCOWBELL+256*0,X:NOP:NOP:NOP:AND #15:JSR DCB:INX:BNE CB1
                    RTS

DCB                 STA $D418:LDY #15
DCB1                DEY:BPL DCB1:RTS

ROCKCOWBELL         DFB $77,$74,$4A,$0A,$04,$D3,$7C,$F4;256 bytes, speed 15
                    DFB $4F,$56,$97,$CB,$4A,$A7,$67,$36
                    DFB $40,$BC,$CC,$ED,$AA,$34,$42,$5E
                    DFB $CC,$97,$A6,$52,$03,$48,$AB,$AC
                    DFB $BB,$73,$02,$43,$AC,$BE,$FA,$B5
                    DFB $01,$24,$8B,$CF,$FD,$B7,$20,$10
                    DFB $56,$9E,$EE,$CA,$73,$00,$03,$AC
                    DFB $FF,$FB,$B6,$00,$01,$6A,$CF,$EC
                    DFB $D9,$51,$00,$35,$BF,$FE,$DC,$93
                    DFB $00,$03,$9C,$EF,$FD,$E6,$00,$01
                    DFB $67,$CF,$EF,$EA,$51,$00,$24,$9D
                    DFB $EF,$FC,$A4,$00,$02,$69,$FF,$FE
                    DFB $B6,$40,$00,$36,$BF,$FF,$EA,$84
                    DFB $00,$02,$9C,$EF,$FC,$A7,$20,$00
                    DFB $5A,$DF,$FD,$D9,$62,$00,$36,$BC
                    DFB $DF,$EC,$94,$00,$02,$7B,$CF,$FC
                    DFB $B7,$21,$01,$57,$BE,$EF,$D9,$62
                    DFB $00,$24,$8C,$DF,$EB,$95,$12,$01
                    DFB $69,$DF,$EC,$B7,$52,$00,$47,$AE
                    DFB $DD,$DA,$74,$11,$24,$9B,$DE,$DB
                    DFB $96,$31,$02,$69,$BE,$DC,$C8,$53
                    DFB $02,$56,$9C,$CD,$DA,$74,$12,$34
                    DFB $8A,$CD,$DB,$96,$32,$24,$68,$BD
                    DFB $CC,$B7,$53,$23,$56,$9C,$DD,$C8
                    DFB $75,$23,$34,$8A,$CD,$CA,$96,$42
                    DFB $24,$69,$BD,$CB,$A7,$54,$23,$56
                    DFB $AB,$CD,$B9,$75,$22,$36,$9A,$BC
                    DFB $CA,$96,$33,$35,$78,$AC,$CC,$A7
                    DFB $53,$33,$57,$9B,$CC,$B8,$74,$24
                    DFB $46,$99,$BC,$CA,$85,$43,$45,$78
                    DFB $77,$77,$77,$77,$77,$77,$77,$77
                    DFB $77,$77,$77,$77,$77,$77,$77,$77

EP;======================******************************========================
;========================*=== END OF MUSIC PROGRAM ===*========================
;========================******************************========================
























;=========================********************=================================
;=========================*=== MUSIC DATA ===*=================================
SD;=======================********************=================================

TUNETABLE           DFW TITLE0,TITLE1,TITLE2:DFL 3
                    DFW GAMEOVER0,GAMEOVER1,GAMEOVER2:DFL 3

;========================= TITLE SCREEN SID DATA ==============================

TF10                DFW -30,0,0,0:DFL 255,0,0,0,13,4
TV10                DFL 41,$99,$FD,2,254
TV11                DFL 21,$0C,$C6,3,3
TD11                DFW +39,-39,+39,0:DFL 2,5,3,0,12,5
                    DFL 50,250,0,5:DFW +20,-8,$0400
                    DFL 65,$09,$ED,100,254
TD12                DFW +15,-15,+15,0:DFL 2,5,3,0,9,5
                    DFL 150,250,0,5:DFW +20,-20,$0800
                    DFL 65,$03,$99,5,50
TS10                DFL DSoke,FMDLY:DFW 255+256*7
                    DFL DSoke,FBG:DFW -20
                    DFL Rest,4,Ret
TS11                DFL 58,6
TS11a               DFL 70,6,65,4,63,4,65,4,62,8,Ret
TX10                LDA #0:STA S0+VRC:STA $D404:LDA #11500:STA $D400:LDA ^11500
                    STA $D401:RTS

TITLE1              DFL RestR,2
                    DFL Call:DFW TS00
                    DFL MBendOff
                    DFL RestR,1
                    DFL Rest,32
                    DFL Rest,16
                    DFL 45,31
                    DFL 44,31
                    DFL 43,31
                    DFL Moke,VADSD,50
                    DFL 41,31
                    DFL FLoad,VRC:DFW TD20
                    DFL Rest,31
                    DFL For,4
                    DFL CT,-12:DFW TS20
                    DFL Next
                    DFL FLoad,PINIT+1:DFW TD01
                    DFL For,2
                    DFL Vlm:DFW TV01
                    DFL 58,31,Rest,24
                    DFL Call:DFW TS10
                    DFL Vlm:DFW TV02
                    DFL Rest,4
                    DFL 67,12
                    DFL Call:DFW TS10
                    DFL 63,12
                    DFL Call:DFW TS10
                    DFL Next
                    DFL FLoad,VRC:DFW TD20
                    DFL For,4
                    DFL CT,-12:DFW TS20
                    DFL Next
                    DFL Moke,VRD,255,Moke,VSRV,$CE
                    DFL 67,31
                    DFL 59,31
                    DFL 55,31
                    DFL 47,31
                    DFL Vlm:DFW TV10
                    DFL Moke,PMC,0
                    DFL 58,24,Rest,8,57,12,Rest,4,55,12,Rest,4
                    DFL Moke,VSRV,$ED,Moke,VRD,254
                    DFL 50,31
                    DFL Vlm:DFW TV10
                    DFL 62,24,Rest,8,60,12,Rest,4,57,12,Rest,4
                    DFL Moke,VSRV,$ED,Moke,VRD,254
                    DFL 59,31
                    DFL FLoad,VRC:DFW TD11
                    DFL 45,6,48,6,53,6,57,6,60,8,62,32
                    DFL FLoad,VRC:DFW TD04
                    DFL Transp,+0
                    DFL Moke,FMDLY,2
                    DFL For,23,Rest,32,Next
                    DFL 63,32
                    DFL DMoke,PINIT:DFW $0800
                    DFL For,11,Rest,31,Next
                    DFL Moke,VADV,$AF,Soke,VADSD,70,Rest,32
                    DFL 53,31
                    DFL For,6*2-1,Rest,16,Next
                    DFL Call:DFW TS05
                    DFL Moke,FMC,0,Moke,PMC,0,Vlm:DFW TV11
                    DFL Code:DFW TX10
                    DFL For,48
                    DFL 55,2,47,2,51,2,43,2,50,2,45,2,54,2,46,2
                    DFL Next
                    DFL FLoad,VRC:DFW TD12
                    DFL For,16
                    DFL Call:DFW TS11
                    DFL Next
                    DFL Moke,VSRV,$5E
                    DFL For,8
                    DFL Call:DFW TS11
                    DFL Next
                    DFL Rest,32,Rest,32,Jmp:DFW TITLE1


TC20                DFW +10,-10,+10,-10:DFL 8,16,8,0,50,7:DFW 900
TD20                DFW +30,-30,+30,0:DFL 2,5,3,0,15,5
                    DFL 25,250,0,5:DFW +50,-10,$0400
                    DFL 73,$09,$D6,2,10
TC21                DFW +10,-10,+10,-100:DFL 8,16,8,0,10,7:DFW 1100
TD21                DFW +30,-30,+30,0:DFL 2,5,3,0,15,5
                    DFL 1,250,1,4:DFW +$400,+50,$0100
                    DFL 65,$09,$E6,20,8
TS20                DFL 31,6,43,6,31,4,34,4,38,4,41,2,38,2,34,2,35,2
                    DFL 36,12,Rest,20,Ret
TS21                DFL 22,6,22,2,22,2,10,4,22,4,34,2,22,4,22,2,10,2,20,4,Ret
TS22                DFL CT,+12:DFW TS21
                    DFL Rest,18,5,6,8,4,9,4
                    DFL Call:DFW TS21
                    DFL Rest,10,20,6,8,6,8,2,20,4,8,4
                    DFL CT,+8:DFW TS21
                    DFL Rest,18,20,6,15,4,15,4
                    DFL Call:DFW TS21
                    DFL Rest,32
                    DFL Ret

TITLE2              DFL Disown
                    DFL Rest,1
                    DFL Call:DFW TS00
                    DFL MBendOff
                    DFL Rest,32
                    DFL Rest,16
                    DFL 48,31
                    DFL 47,31
                    DFL 46,31
                    DFL Moke,VADSD,50
                    DFL 45,31
                    DFL FLoad,VRC:DFW TD20
                    DFL Filter:DFW TC20
                    DFL Rest,31
                    DFL Master
                    DFL For,4
                    DFL Call:DFW TS20
                    DFL Next
                    DFL FLoad,VRC:DFW TD00
                    DFL Moke,FMC,0,Moke,VADV,$AA
                    DFL 19,32
                    DFL FLoad,VRC:DFW TD20
                    DFL For,7,Rest,32,Next
                    DFL For,4
                    DFL Call:DFW TS20
                    DFL Next
                    DFL Moke,VRD,255,Moke,VSRV,$CE
                    DFL 58,31
                    DFL 55,31
                    DFL 46,31
                    DFL 43,32
                    DFL FLoad,VRC:DFW TD21
                    DFL Filter:DFW TC21
                    DFL Rest,32
                    DFL For,2
                    DFL CT,+0:DFW TS21
                    DFL Call:DFW TS21
                    DFL CT,-3:DFW TS21
                    DFL Call:DFW TS21
                    DFL Next
                    DFL Transp,+0
                    DFL FLoad,VRC:DFW TD11
                    DFL Disown
                    DFL 41,6,45,6,48,6,53,6,57,8,58,32
                    DFL FLoad,VRC:DFW TD04
                    DFL Transp,+0
                    DFL Moke,FMDLY,4
                    DFL For,31,Rest,32,Next
                    DFL 60,32
                    DFL DMoke,PINIT:DFW $0800
                    DFL For,11,Rest,31,Next
                    DFL Moke,VADV,$AF,Soke,VADSD,70
                    DFL FLoad,VRC:DFW TD11
                    DFL Freq:DFW TF10
                    DFL Rest,24
                    DFL 36,8
                    DFL FLoad,VRC:DFW TD21
                    DFL Moke,VSRV,$F6
                    DFL Filter:DFW TC21
                    DFL Master
                    DFL For,2
                    DFL CT,+12:DFW TS21
                    DFL Rest,32
                    DFL Next
                    DFL For,2
                    DFL CT,+8:DFW TS21
                    DFL Rest,32
                    DFL Next
                    DFL Moke,VSRV,$E6
                    DFL Call:DFW TS22
                    DFL Call:DFW TS22
                    DFL Moke,VRD,128,Moke,VSRV,$EE
                    DFL For,3
                    DFL Call:DFW TS22
                    DFL Next
                    DFL Rest,32,Rest,32,Transp,+0,Jmp:DFW TITLE2


TD00                DFW +25,-25,+25,+54:DFL 2,5,3,0,20,7
                    DFL 25,250,0,5:DFW +100,-10,$0400
                    DFL 65,$29,$C9,255,40
TD01                DFW +45,-45,+45,0:DFL 2,5,3,0,30,5
                    DFS 8,0:DFW $500
TV01                DFL %00101001,$A9,$EF,10,254
TF02                DFW +183,+0,-183,0:DFL 8,8,8,0,10,4
TV02                DFL %00100001,$48,$DA,100,50
TF03                DFW +70,+0,-136,0:DFL 8,10,8,0,0,4
OHMYGOD             DFW +85,-85,+85,+121:DFL 2,4,2,0,96,7
                    DFL 25,255,0,5:DFW +150,-30,$0080
                    DFL 65,$09,$E9,255,40
TD04                DFW +35,-35,+35,0:DFL 3,6,3,0,20,5
                    DFL 255,255,0,5:DFW +1,+1,$0000
                    DFL 65,$FF,$CA,255,20
TS00                DFL FLoad,VRC:DFW TD00
                    DFL 60+R,10*3-2,MBendOff,60+R,4,62+R,4,60,12
                    DFL 57,6,55,6,53,4,55,2,57,4,53,2
                    DFL For,6,50+R,3,48+R,3,45+R,5,Next
                    DFL MBendOn,DMoke,FBG:DFW +27
                    DFL 48,12,Ret
TS01                DFL 50,1,58,1,50,1
                    DFL Code:DFW TX02
                    DFL 55,1,50,1,58,1,50,1
                    DFL Code:DFW TX02
                    DFL Ret
TS03                DFL 50,1,58,1,50,1
                    DFL Code:DFW TX04
                    DFL 55,1,50,1,58,1,50,1
                    DFL Code:DFW TX04
                    DFL Ret
TS02                DFL 50,1,55,1,50,1
                    DFL Code:DFW TX02
                    DFL 53,1,50,1,55,1,50,1
                    DFL Code:DFW TX02
                    DFL Ret
TS04                DFL 50,1,55,1,50,1
                    DFL Code:DFW TX04
                    DFL 53,1,50,1,55,1,50,1
                    DFL Code:DFW TX04
                    DFL Ret
TS05                DFL DSoke,FMDLY:DFW 255+256*7
                    DFL DSoke,FMG3:DFW +60
                    DFL Soke,VADSC,16*3,Rest,16,Ret
TX00                LDA #0:STA S0+FBG+0:STA S0+FBG+1:LDA #8*3:STA S0+FMDLY:LDY #65
                    JMP POKEFRQ0
TX01                LDA D0+PINIT+0:ADD #240:STA D0+PINIT+0
                    LDA D0+PINIT+1:ADC ^240:STA D0+PINIT+1:RTS
TX02                LDA SToRE+0:ADD #210:STA SToRE+0:ORA #$880:STA D0+PINIT+0
                    LDA SToRE+1:ADC ^200:STA SToRE+1:ORA ^$880:STA D0+PINIT+1:RTS
TX04                LDA SToRE+0:SUB #210:STA SToRE+0:ORA #$880:STA D0+PINIT+0
                    LDA SToRE+1:SBC ^200:STA SToRE+1:ORA ^$880:STA D0+PINIT+1:RTS
TX03                LDA #0:STA SToRE:STA SToRE+1:RTS
SToRE               DFW $D3DD

TITLE0              DFL Call:DFW TS00
                    DFL Rest+R,1*3;+1
                    DFL For,6,Rest,30,Rest,10,Next
                    DFL Soke,VADSD,50
                    DFL FLoad,VRC:DFW TD20
                    DFL For,4,Rest,31,Next
                    DFL For,2
                    DFL 34,6,46,6,34,4,38,4,41,4,45,2,41,2,38,2,39,2
                    DFL 40,12,Rest,20
                    DFL Next
                    DFL FLoad,PINIT+1:DFW TD01
                    DFL For,2
                    DFL Vlm:DFW TV01
                    DFL 55,31,Rest,24
                    DFL Call:DFW TS10
                    DFL Vlm:DFW TV02
                    DFL Rest,4
                    DFL 63,12
                    DFL Call:DFW TS10
                    DFL 60,12
                    DFL Call:DFW TS10
                    DFL Next
                    DFL Sil,31,Rest,32
                    DFL FLoad,VRC:DFW OHMYGOD
                    DFL 0,32
                    DFL Code:DFW TX00
                    DFL Rest,8
                    DFL Soke,FMDLY,8*3
                    DFL DSoke,FBG:DFW +60
                    DFL MBendOff
                    DFL Rest,10
                    DFL Soke,PMD1C,1
                    DFL Rest,18
                    DFL DSoke,FMDLY:DFW 24+256*7
                    DFL DSoke,FBG:DFW -60
                    DFL Rest+R,8*3+1
                    DFL For,10,65+R,3
                    DFL Code:DFW TX01
                    DFL 62+R,3
                    DFL Code:DFW TX01
                    DFL Next
                    DFL Freq:DFW TF02
                    DFL Moke,PMC,4,DMoke,PINIT:DFW $0080
                    DFL Moke,VADSD,254
                    DFL 65,16
                    DFL Freq:DFW TF03
                    DFL 61,12
                    DFL FLoad,FMD2:DFW OHMYGOD
                    DFL DMoke,FMDLY:DFW 20+256*5
                    DFL 58,2,60,2
                    DFL MBendOn,DMoke,FBG:DFW +56
                    DFL 60,24
                    DFL MBendOn,DMoke,FBG:DFW -150
                    DFL 50+R,8*3-1
                    DFL Moke,FMC,0
                    DFL For,4
                    DFL Code:DFW TX03
                    DFL 74,1,Call:DFW TS01
                    DFL 72,1,Call:DFW TS01
                    DFL 70,1,Call:DFW TS01
                    DFL 69,1,Call:DFW TS03
                    DFL 62,1,Call:DFW TS03
                    DFL 60,1,Call:DFW TS03
                    DFL 58,1,Call:DFW TS01
                    DFL 57,1,Call:DFW TS01
                    DFL 74,1,Call:DFW TS02
                    DFL 73,1,Call:DFW TS04
                    DFL 71,1,Call:DFW TS04
                    DFL 69,1,Call:DFW TS04
                    DFL 62,1,Call:DFW TS02
                    DFL 61,1,Call:DFW TS02
                    DFL 59,1,Call:DFW TS02
                    DFL 57,1,Call:DFW TS04
                    DFL Next
                    DFL FLoad,VRC:DFW TD11
                    DFL 48,6,53,6,57,6,60,6,65,8,67,32
                    DFL FLoad,VRC:DFW TD04
                    DFL For,15,Rest,32,Next
                    DFL 67,32
                    DFL DMoke,PINIT:DFW $0800
                    DFL For,11,Rest,31,Next
                    DFL Moke,VADV,$AF,Soke,VADSD,70,Rest,32,56,31
                    DFL For,14*2-1,Rest,16,Next
                    DFL Call:DFW TS05
                    DFL FLoad,VRC:DFW TD12
                    DFL Moke,VSRV,$59
                    DFL For,24*8+2,Rest,32/8,Next
                    DFL For,16,Call:DFW TS11
                    DFL Next,Moke,VSRV,$5E,58,6,Trigger
                    DFL Call:DFW TS11a
                    DFL For,7,Call:DFW TS11
                    DFL Next,Trigger
                    DFL Rest,32,Rest,24,Jmp:DFW TITLE0

;====================== GAME OVER SCREEN SID DATA =============================

GOV00               DFL 65,$06,$D8,8,10

GAMEOVER0           DFL FLoad,VRC:DFW TD11
                    DFL 64,6,62,6,59,4,57,2,53,1,54,1,55,2
                    DFL 52,8,50,6,47,4,45,2,41,1,42,1,43,2
                    DFL 40,8,38,6,35,4,33,2,29,1,30,1,31,4,40,10
                    DFL Vlm:DFW GOV00
                    DFL 40,4,Ret


GAMEOVER1           DFL FLoad,VRC:DFW TD11
                    DFL Rest,24
                    DFL 64,6,62,6,59,4,57,2,53,1,54,1,55,2
                    DFL 52,8,50,6,47,4,45,2,41,1,42,1,43,4,44,10
                    DFL Vlm:DFW GOV00
                    DFL 44,4,Ret


GAMEOVER2           DFL FLoad,VRC:DFW TD11
                    DFL Rest,24,Rest,24
                    DFL 64,6,62,6,59,4,57,2,53,1,54,1,55,4,47,10
                    DFL Vlm:DFW GOV00
                    DFL 47,4,Ret

;==============================================================================

LASER               DFW +39000,-3900,+59000,19000:DFL 5,5,5,5,0,5
                    DFS 10,0
                    DFL 33,$03,$87,18,5
                    DFW 33000
BOOMERANG           DFW +2000,-17000,+2000,0:DFL 10,1,255,0,0,4
                    DFS 10,0
                    DFL 33,$03,$C7,25,5
                    DFW 7000
GRENADE             DFW -1000,0,0,0:DFL 255,0,0,0,0,5
                    DFS 10,0
                    DFL 33,$99,$E9,20,20
                    DFW 50000
GRENEXPLODES        DFW -100,0,0,0:DFL 255,0,0,0,0,4
                    DFS 10,0
                    DFL 129,$03,$9D,20,2
                    DFW 3000
MONSTERTHUDS        DFW -7,0,0,+330:DFL 20,0,0,0,5,129
                    DFL 20,0,3,129:DFW +110,0,$0800
                    DFL 65,$03,$99,20,20
                    DFW 1000
ALIENFIRES          DFW -900,-1800,+1000,0:DFL 5,5,255,0,0,5
                    DFS 10,0
                    DFL 33,$09,$89,10,15
                    DFW 25000
ENERGYDRAIN         DFS 14,0
                    DFS 10,0
                    DFL 129,$95,$89,11,15
                    DFW 2500
PICKSUPHEART        DFW -1200,0,0,0:DFL 9,0,0,0,0,129
                    DFS 10,0
                    DFL 33,$03,$CA,5,40
                    DFW 40000
LASERTURRET         DFW -1800,-3600,+2000,0:DFL 3,3,255,0,0,5
                    DFS 10,0
                    DFL 33,$05,$87,5,7
                    DFW 25000
KANGAROOSHOP        DFW +4000,0,0,0:DFL 1,2,0,0,0,5
                    DFS 10,0
                    DFL 33,$03,$C7,25,5
                    DFW 4000
IMPSAPPEAR          DFW +39000,0,0,0:DFL 255,0,0,0,0,5
                    DFS 10,0
                    DFL 33,$A3,$82,30,1
                    DFW 33000
LIFTDINGS           DFW +59,-59,+59,0:DFL 2,5,3,0,9,5
                    DFL 50,250,0,5:DFW +20,-8,$0400
                    DFL 65,$05,$89,20,35
                    DFW 10000
STATUEEYESHIT       DFW +500,0,0,0:DFL 6,0,0,0,0,129
                    DFL 50,250,0,5:DFW +150,-8,$0400
                    DFL 65,$04,$99,10,10
                    DFW 30000

ED;============================================================================

SIZE                EQU .-$1000
DAMAGE              EQU SIZE-8*1024
GAP                 EQU 8*1024-SIZE
CH0VALUE            EQU 1
CH1VALUE            EQU 1
CH2VALUE            EQU 1
QSOUND              EQU %000
Q                   EQU 0;80
refsp               EQU $0040
drmsp               EQU $0080

;^^^^^^^^^^^^^^^ This is the end of the source file... (or is it?) ^^^^^^^^^^^^
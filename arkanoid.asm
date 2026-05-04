
;     =========== "Arkanoid" Audio Source File (SID/65xx system) ==========

;   ==================== Code & design by Martin Galway =====================

; =================== Compositions by Martin Galway & Taito ===================

;   =================== Work started 23rd   January 1987. ===================

;     ==== (C) OCEAN SOFTWARE LTD 12:12    Friday  6th  February 1987. ====

;======================*===CODE ENTRY INFORMATION===*==========================

;  ROUTINE       INSIDE INTERRUPTS?
;  -------       ------------------
;
;  InitSound     OUT
;  Sound0        IN
;  Sound1        IN
;  Sound2        IN
;  Music0        IN
;  Music1        IN
;  Music2        IN
;  MusicTest     IN
;  RefFilter     IN
;  Effect        OUT
;  Tune          OUT

;  TAITO LETTER TUNE VALUE SPEED SOUND
;  ----- ------ ---------- ----- -----
;  03    B *                     Bat-ball bounce/ball leaving bat (catch mode)
;  04    C *                     Ball hitting a brick & knocking it away
;  05    D
;  07    E
;  09    F *                     Expansion
;  0A    G *    1*7-2      100Hz Opening sequence
;  0B    H *    2*7-2      100Hz Next screen/Next life
;  0C    I      3*7-2      100Hz Last screen intro ?
;  0D    J      4*7-2            ?
;  0E    K *    5*7-2      100Hz Game Over
;  0F    L *    6*7-2       50Hz Enter Name
;  10    M *    7*7-2      100Hz Extra Life
;  11    N *                     Laser Fire
;  13    O *                     Opening sequence sound effect
;  14    P *                     Alien exploding
;  16    Q *                     Ball hitting a brick but NOT knocking it away
;  17    R      8*7-2      100Hz Triumph ?
;  18    S *                     Breakthrough
;  19    T *                     Bat catching the ball (catch mode)
;  1A    U *                     Vaus exploding
;  1B    V                       Ball hitting head on last screen
;  1C    W                       Head exploding on last screen
;        X *    9*7-2       50Hz Title sequence

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
Noise               EQU COM+44
Square              EQU COM+46
Freq                EQU COM+48
Hang                EQU COM+50
MokeF6              EQU COM+52
Moke86              EQU COM+54

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
DEPTHOFSTACKS       EQU 8

;***** "OFFSET LIST" FM DATA STRUCTURE ***
;0&1 RESERVED - MUST BE 0
;2&3 RESERVED - MUST BE 0
;4&5 INITIAL SINGLE OFFSET DURATION COUNTER VALUE - USUALLY 1
;6&7 MAXIMUM-EVER SINGLE OFFSET DURATION - 1-255
;8&9 ADDRESS OF OFFSET LIST (LIST IS READ THROUGH END-FIRST, GOING BACKWARDS)
;10  RESERVED - MUST BE 0
;11  MAXIMUM OFFSET LIST INDEX 0-255
;12  RESERVED - MUST BE 0
;13  FM CONTROL - ANY VALUE THAT HAS BIT 3 SET (E.G. 8)

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

;=== N.T.S.C. FREQUENCY TABLE (NOT TO BE USED ON P.A.L.) : 1 MHz CLOCK RATE ===

;BASE "A" VALUE FOR THIS OCTAVE IS 231. (EQUIVALENT TO N-03)

;N00           EQU 274
;N01           EQU 291
;N02           EQU 308
;N03           EQU 326
;N04           EQU 346
;N05           EQU 366
;N06           EQU 388
;N07           EQU 411
;N08           EQU 435
;N09           EQU 461
;N10           EQU 489
;N11           EQU 518
;N12           EQU 548
;N13           EQU 581
;N14           EQU 616
;N15           EQU 652
;N16           EQU 691
;N17           EQU 732
;N18           EQU 776
;N19           EQU 822
;N20           EQU 871
;N21           EQU 923
;N22           EQU 978
;N23           EQU 1036
;N24           EQU 1097
;N25           EQU 1163
;N26           EQU 1232
;N27           EQU 1305
;N28           EQU 1383
;N29           EQU 1465
;N30           EQU 1552
;N31           EQU 1644
;N32           EQU 1742
;N33           EQU 1845
;N34           EQU 1966
;N35           EQU 2071
;N36           EQU 2195
;N37           EQU 2325
;N38           EQU 2463
;N39           EQU 2620
;N40           EQU 2765
;N41           EQU 2930
;N42           EQU 3104
;N43           EQU 3288
;N44           EQU 3484
;N45           EQU 3691
;N46           EQU 3910
;N47           EQU 4143
;N48           EQU 4389
;N49           EQU 4650
;N50           EQU 4927
;N51           EQU 5220
;N52           EQU 5530
;N53           EQU 5859
;N54           EQU 6207
;N55           EQU 6577
;N56           EQU 6968
;N57           EQU 7382
;N58           EQU 7821
;N59           EQU 8286
;N60           EQU 8779
;N61           EQU 9301
;N62           EQU 9854
;N63           EQU 10440
;N64           EQU 11060
;N65           EQU 11718
;N66           EQU 12415
;N67           EQU 13153
;N68           EQU 13935
;N69           EQU 14764
;N70           EQU 15742
;N71           EQU 16572
;N72           EQU 17557
;N73           EQU 18601
;N74           EQU 19708
;N75           EQU 20897
;N76           EQU 22121
;N77           EQU 23436
;N78           EQU 24730
;N79           EQU 26306
;N80           EQU 27871
;N81           EQU 29528
;N82           EQU 31284
;N83           EQU 33144
;N84           EQU 35115
;N85           EQU 37203
;N86           EQU 39145
;N87           EQU 41759
;N88           EQU 44242
;N89           EQU 46873
;N90           EQU 49660
;N91           EQU 52613
;N92           EQU 55741
;N93           EQU 59056

NSil                EQU 00000;                Silence (the same at both clock speeds)

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
SID                 EQU $D400
D418                EQU $3FFF
BDR                 EQU $D020
MREFCOLOUR          EQU 1;                                 White, for music refreshes
DREFCOLOUR          EQU 0;                       Desired colour for display refreshes

; === FILE CONTROL CHARACTERS ===

; \ PROGRAM ASSEMBLY MODE (DEVELOPMENT/MOBJ)
; @ SILENCE HANDLING ON/OFF
; [ SOUND EFFECT HANDLING ON/OFF

;======================************************================================
;======================*=== DRIVER PROGRAM ===*================================
;======================************************================================

                    ORG $0803:ENT;\

Start               SEI:JSR InitScreen
;              JMP $4000
                    JSR INITSOUND
                    JSR FastForward
                    LDA #Q:BNE DLoop:LDY #10:JSR Delay
                    JSR Vaus

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

DVTABL              DFW INITSOUND,Bounce,Hit,FaFo;AD
                    DFW FaFo,Expansion,OpeningSequen,NextScreen,FaFo;EI
                    DFW FaFo,GameOver,EnterName,ExtraLife,Laser,OpenFX,Alien,Brick;JQ
                    DFW FaFo,Breakthrough,Catch,Vaus,Head,Explosion;RW
                    DFW Title,FaFo,FaFo;XZ

Bounce              LDX #0:LDA #BOUNCE0:LDY ^BOUNCE0:JSR EFFECT
                    LDX #1:LDA #BOUNCE1:LDY ^BOUNCE1:JSR EFFECT
                    LDX #2:LDA #BOUNCE2:LDY ^BOUNCE2:JMP EFFECT
Hit                 LDX #0:LDA #HIT0:LDY ^HIT0:JSR EFFECT
                    LDX #1:LDA #HIT1:LDY ^HIT1:JSR EFFECT
                    LDX #2:LDA #HIT2:LDY ^HIT2:JMP EFFECT
Expansion           LDX #0:LDA #EXPANSION0:LDY ^EXPANSION0:JSR EFFECT
                    LDX #1:LDA #EXPANSION1:LDY ^EXPANSION1:JSR EFFECT
                    LDX #2:LDA #EXPANSION2:LDY ^EXPANSION2:JMP EFFECT
Laser               LDX #0:LDA #LASER0:LDY ^LASER0:JSR EFFECT
                    LDX #1:LDA #LASER1:LDY ^LASER1:JSR EFFECT
                    LDX #2:LDA #LASER2:LDY ^LASER2:JMP EFFECT
Brick               LDX #0:LDA #BRICK0:LDY ^BRICK0:JSR EFFECT
                    LDX #1:LDA #BRICK1:LDY ^BRICK1:JSR EFFECT
                    LDX #2:LDA #BRICK2:LDY ^BRICK2:JMP EFFECT
Alien               LDX #0:LDA #ALIEN0:LDY ^ALIEN0:JSR EFFECT
                    LDX #1:LDA #ALIEN1:LDY ^ALIEN1:JSR EFFECT
                    LDX #2:LDA #ALIEN2:LDY ^ALIEN2:JMP EFFECT
Breakthrough        LDX #0:LDA #BREAKTHROUGH0:LDY ^BREAKTHROUGH0:JSR EFFECT
                    LDX #1:LDA #BREAKTHROUGH1:LDY ^BREAKTHROUGH1:JSR EFFECT
                    LDX #2:LDA #BREAKTHROUGH2:LDY ^BREAKTHROUGH2:JMP EFFECT
Catch               LDX #0:LDA #CATCH0:LDY ^CATCH0:JSR EFFECT
                    LDX #1:LDA #CATCH1:LDY ^CATCH1:JSR EFFECT
                    LDX #2:LDA #CATCH2:LDY ^CATCH2:JMP EFFECT
OpenFX              LDX #0:LDA #OPENFX0:LDY ^OPENFX0:JSR EFFECT
                    LDX #1:LDA #OPENFX1:LDY ^OPENFX1:JSR EFFECT
                    LDX #2:LDA #OPENFX2:LDY ^OPENFX2:JMP EFFECT
Vaus                LDX #2:LDA #VAUS2:LDY ^VAUS2:JSR EFFECT
                    LDX #1:LDA #VAUS1:LDY ^VAUS1:JSR EFFECT
                    LDX #0:LDA #VAUS0:LDY ^VAUS0:JMP EFFECT
Head                LDX #2:LDA #HEAD2:LDY ^HEAD2:JSR EFFECT
                    LDX #1:LDA #HEAD1:LDY ^HEAD1:JSR EFFECT
                    LDX #0:LDA #HEAD0:LDY ^HEAD0:JMP EFFECT
Explosion           LDX #1:LDA #EXPLOSION1:LDY ^EXPLOSION1:JSR EFFECT
                    LDX #0:LDA #EXPLOSION0:LDY ^EXPLOSION0:JSR EFFECT
                    LDX #2:LDA #EXPLOSION2:LDY ^EXPLOSION2:JMP EFFECT

OpeningSequen       JSR ResetCl:JSR StartCl:LDY #1*7-2:JMP TUNE
NextScreen          JSR ResetCl:JSR StartCl:LDY #2*7-2:JMP TUNE
GameOver            JSR ResetCl:JSR StartCl:LDY #5*7-2:JMP TUNE
EnterName           JSR ResetCl:JSR StartCl:LDY #6*7-2:JMP TUNE
ExtraLife           JSR ResetCl:JSR StartCl:LDY #7*7-2:JMP TUNE
Title               JSR ResetCl:JSR StartCl:LDY #9*7-2:JMP TUNE

HANG                INC BDR:JMP HANG

HANG0               LDX #0:DFB $2C
HANG1               LDX #1:DFB $2C
HANG2               LDX #2
                    SEI:LDA #3
HANGLOOP            STA BDR:STX BDR:JMP HANGLOOP

WAITCLOCK00         LDX $D011:BMI WAITCLOCK00:BPL WAITCLOCKa
WAITCLOCK80         LDX $D011:BPL WAITCLOCK80
WAITCLOCKa          CMP $D012:BNE WAITCLOCKa
;              INC BDR:JSR SOUND2:JSR FILTER;JSR SOUND0:JSR SOUND1
;              DEC BDR
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
                    LDX #CH0VALUE:BEQ R1x:JSR MUSIC0:JSR SOUND0
R1x                 LDX #CH1VALUE:BEQ R1y:JSR MUSIC1:JSR SOUND1
R1y                 LDX #CH2VALUE
                    BEQ xit
                    JSR MUSIC2
                    JSR SOUND2
xit                 DEC BDR:RTS

ResetCl             LDA #"0":LDX #5
RCLoop              STA CD5,X:DEX:BPL RCLoop
StopCl              LDA #0:DFL $2C
StartCl             LDA #+1:STA ClkAdd
sc2                 RTS

DREFRESH            LDA #57:JSR WAITCLOCK00:JSR REFRESH:JSR RefScreen1
REF2                LDA #117:JSR WAITCLOCK00:JSR REFRESH:JSR RefScreen2
REF3                LDA #172:JSR WAITCLOCK00:JSR REFRESH:JSR RefScreen3
REF4                LDA #237:JSR WAITCLOCK00:JSR REFRESH:JSR RefScreen4
                    JMP UpdateCl

UpdateCl            LDA #0
                    LDX #CH0VALUE:BEQ u1:ORA MFL0:ORA S0+VRC
u1                  LDX #CH1VALUE:BEQ u2:ORA MFL1:ORA S1+VRC
u2                  LDX #CH2VALUE:BEQ ua:ORA MFL2:ORA S2+VRC
ua                  TAX:BEQ StopCl:LDA ClkAdd:CMP #4:BCC sc2:LSR:LDX #0:STX ClkAdd
                    ADD CD0:CMP #"9"+1:BCC ncu0:LDA #&0
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

CD5                 DFB "0"
CD4                 DFB "0"
CD3                 DFB "0"
CD2                 DFB "0"
CD1                 DFB "0"
CD0                 DFB "0"
CG                  DFB 0
ClkAdd              DFB 0
CREFSP              DFW 0
Refsp               DFW 0
xcstr               DFM "0123456789ABCDEF"

IncRefsp            LDX Refsp:BEQ DR2:INX:BNE DR1:INC Refsp+1:BNE DR1
DecRefsp            LDX Refsp:DEX:BEQ DR2:LDA #0:STA Refsp+1
DR1                 STX Refsp
DR2                 RTS

FastForward         LDA #0:STA RF:LDA #Q:STA FASTER
Fast1               LDA FASTER:BEQ Fast2:JSR FaFo:DEC FASTER:JMP Fast1
Fast2               LDX #CH0VALUE*1+CH1VALUE*2+CH2VALUE*4:STX RF:RTS

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

;=======================*******************************========================
;=======================*=== END OF DRIVER PROGRAM ===*========================
;=======================*******************************========================















SP;=====================********************************=======================
;=======================*=== START OF MUSIC PROGRAM ===*=======================
;=======================********************************=======================

SIZE                EQU EOVT2-$2000

                    ORG $3F00

JUMPS               JMP INITSOUND:JMP MUSICTEST:JMP TUNE:JMP EFFECT:JMP FILTER
                    JMP SOUND0:JMP SOUND1:JMP SOUND2:JMP MUSIC0:JMP MUSIC1:JMP MUSIC2
                    JMP RefScreen1:JMP RefScreen2:JMP RefScreen3:JMP RefScreen4

vt0                 DFW retsubrut0
                    DFW call0
                    DFW goto0
                    DFW callt0
                    DFW HANG0;gotot0
                    DFW mpoke0
                    DFW for0
                    DFW next0
                    DFW HANG0;sload0
                    DFW fload0
                    DFW volume0
                    DFW spoke0
                    DFW HANG0;code0
                    DFW HANG0;transp0
                    DFW HANG0;dmpoke0
                    DFW dspoke0
                    DFW HANG0;master0
                    DFW HANG0;filter0
                    DFW HANG0;disown0
                    DFW HANG0;own0
                    DFW HANG0;mbendoff0
                    DFW HANG0;mbendon0
                    DFW HANG0;noise0
                    DFW HANG0;square0
                    DFW freq0

vt1                 DFW retsubrut1
                    DFW call1
                    DFW goto1
                    DFW HANG1;callt1
                    DFW HANG1;gotot1
                    DFW mpoke1
                    DFW for1
                    DFW next1
                    DFW HANG1;sload1
                    DFW fload1
                    DFW volume1
                    DFW spoke1
                    DFW HANG1;code1
                    DFW HANG1;transp1
                    DFW dmpoke1
                    DFW dspoke1
                    DFW HANG1;master1
                    DFW HANG1;filter1
                    DFW HANG1;disown1
                    DFW HANG1;own1
                    DFW HANG1;mbendoff1
                    DFW HANG1;mbendon1
                    DFW HANG1;noise1
                    DFW HANG1;square1
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
                    DFW HANG2;spoke2
                    DFW code2
                    DFW HANG2;transp2
                    DFW dmpoke2
                    DFW dspoke2
                    DFW master2
                    DFW filter2
                    DFW HANG2;disown2
                    DFW HANG2;own2
                    DFW HANG2;mbendoff2
                    DFW HANG2;mbendon2
                    DFW HANG2;noise2
                    DFW HANG2;square2
                    DFW freq2

EOVT2               ORG $2000

BOUNCE0             DFW +8250,0,-8250,0:DFL 1,2,1,1,1,5
                    DFS 10,0
                    DFL 33,$03,$8A,15,90
                    DFW 8250
BOUNCE1             DFW -8250,0,+8250,0:DFL 1,1,1,2,1,5
                    DFS 10,0
                    DFL 33,$03,$8A,15,90
                    DFW 16600
BOUNCE2             DFW +8350,0,-8350,0:DFL 1,1,1,1,2,5
                    DFS 10,0
                    DFL 33,$03,$8A,15,90
                    DFW 16700
HIT0                DFW +6175,0,-6175,0:DFL 1,2,1,1,1,5
                    DFS 10,0
                    DFL 33,$03,$8A,15,90
                    DFW 12350
HIT1                DFW -12450,0,+12450,0:DFL 1,1,1,2,1,5
                    DFS 10,0
                    DFL 33,$03,$8A,15,90
                    DFW 24900
HIT2                DFW +12550,0,-12550,0:DFL 1,1,1,1,2,5
                    DFS 10,0
                    DFL 33,$03,$8A,15,90
                    DFW 25100
EXPANSION0          DFW +4,0,0,0:DFL 255,0,0,0,0,4
                    DFS 8,0:DFW $0800
                    DFL 65,$00,$F0,50,1
                    DFW 800
EXPANSION1          DFW +4,0,0,0:DFL 255,0,0,0,0,4
                    DFS 8,0:DFW $0800
                    DFL 65,$00,$F0,50,1
                    DFW 810
EXPANSION2          DFW +4,0,0,0:DFL 255,0,0,0,0,4
                    DFS 8,0:DFW $0800
                    DFL 65,$00,$F0,50,1
                    DFW 820
LASER0              DFW -10000,-1000,-100,0:DFL 4,5,10,0,0,133
                    DFS 8,0:DFW $0800
                    DFL 65,$09,$B9,30,50
                    DFW 50000
LASER1              DFW -10000,-1000,-100,+5500:DFL 4,5,10,0,10,135
                    DFS 8,0:DFW $0800
                    DFL 67,$09,$B9,30,50
                    DFW 1
LASER2              DFW -10000,-1000,-100,+3000:DFL 4,5,10,0,20,135
                    DFS 8,0:DFW $0800
                    DFL 65,$09,$B9,30,50
                    DFW 1
BRICK0              DFW +16500,0,-16500,0:DFL 1,2,1,1,1,5
                    DFS 10,0
                    DFL 33,$03,$8A,15,90
                    DFW 16500
BRICK1              DFW -16500,0,+16500,0:DFL 1,1,1,2,1,5
                    DFS 10,0
                    DFL 33,$03,$8A,15,90
                    DFW 16600
BRICK2              DFW +16700,0,-16700,0:DFL 1,1,1,1,2,5
                    DFS 10,0
                    DFL 33,$03,$8A,15,90
                    DFW 33400
ALIEN0              DFW +1250,-13000,0,0:DFL 9,1,0,0,0,5
                    DFS 10,0
                    DFL 33,$15,$9B,20,70
                    DFW 8250
ALIEN1              DFW -2250,+19000,0,0:DFL 9,1,1,0,0,5
                    DFS 10,0
                    DFL 33,$15,$9B,20,70
                    DFW 16600
ALIEN2              DFW +3350,-27000,0,0:DFL 7,1,0,0,0,5
                    DFS 10,0
                    DFL 33,$15,$9B,20,70
                    DFW 16700
BREAKTHROUGH0       DFW -6000,-35,+10,0:DFL 10,80,255,0,0,4
                    DFL 255,0,0,0:DFW +8,0,$0800
                    DFL 65,$19,$BB,40,200
                    DFW 63500
BREAKTHROUGH1       DFW -6000,-35,+10,0:DFL 10,80,255,0,4,4
                    DFL 255,0,0,0:DFW +8,0,$0800
                    DFL 65,$19,$BB,40,200
                    DFW 64000
BREAKTHROUGH2       DFW -6000,-35,+10,0:DFL 10,80,255,0,8,4
                    DFL 255,0,0,0:DFW +8,0,$0800
                    DFL 65,$19,$BB,40,200
                    DFW 64500
CATCH0              DFW +8250,0,-8250,0:DFL 1,2,1,1,1,5
                    DFS 10,0
                    DFL 33,$02,$A6,5,8
                    DFW 8250
CATCH1              DFW -8250,0,+8250,0:DFL 1,1,1,2,1,5
                    DFS 10,0
                    DFL 33,$02,$A6,5,8
                    DFW 16600
CATCH2              DFW +8350,0,-8350,0:DFL 1,1,1,1,2,5
                    DFS 10,0
                    DFL 33,$02,$A6,5,8
                    DFW 16700
OPENFX0             DFW +1250,-11000,0,0:DFL 10,1,0,0,1,5
                    DFS 10,0
                    DFL 33,$15,$9B,20,140
                    DFW 8250
OPENFX1             DFW -2250,+21000,0,0:DFL 9,1,0,0,2,5
                    DFS 10,0
                    DFL 33,$15,$9B,20,140
                    DFW 16600
OPENFX2             DFW +3350,-26000,0,0:DFL 8,1,0,0,3,5
                    DFS 10,0
                    DFL 33,$15,$9B,20,140
                    DFW 16700
VAUS0               DFW -6000,-50,+62000,0:DFL 10,40,1,0,0,5
                    DFL 255,0,0,0:DFW +8,0,$0800
                    DFL 65,$19,$BB,40,140
                    DFW 62001
VAUS1               DFW -6000,-50,+62000,0:DFL 10,40,1,0,2,5
                    DFL 255,0,0,0:DFW +8,0,$0800
                    DFL 65,$19,$BB,40,140
                    DFW 63001
VAUS2               DFW -6000,-50,+62000,0:DFL 10,40,1,0,4,5
                    DFL 255,0,0,0:DFW +8,0,$0800
                    DFL 65,$19,$BB,40,140
                    DFW 64001
HEAD0               DFW +1250,-13000,0,0:DFL 9,1,1,0,0,5
                    DFS 10,0
                    DFL 33,$15,$9A,10,60
                    DFW 8250
HEAD1               DFW -2250,+19000,0,0:DFL 9,1,1,0,5,5
                    DFS 10,0
                    DFL 33,$15,$9A,10,60
                    DFW 16600
HEAD2               DFW +3350,-27000,0,0:DFL 7,1,1,0,0,5
                    DFS 10,0
                    DFL 33,$15,$9A,10,60
                    DFW 16700
EXPLOSION0          DFW -1250,+11000,+1000,-11000:DFL 10,1,10,1,1,5
                    DFS 8,0:DFW $0800
                    DFL 65,$CC,$FC,254,254
                    DFW 10000
EXPLOSION1          DFW +2250,-21000,0,0:DFL 9,1,0,0,2,5
                    DFS 8,0:DFW $0800
                    DFL 65,$CC,$FC,254,254
                    DFW 22222
EXPLOSION2          DFW -3350,+26000,0,0:DFL 8,1,0,0,3,5
                    DFS 8,0:DFW $0800
                    DFL 65,$CC,$FC,254,254
                    DFW 34567

EOS                 ORG $3E00

                    ORG EOS

ST;============================================================================

D0                  DFS 29,$DD
ST0L                DFS DEPTHOFSTACKS,$DD;                     stack (low bytes only)
ST0H                DFS DEPTHOFSTACKS,$DD;                    stack (high bytes only)
ST0C                DFS DEPTHOFSTACKS,$DD;                   stack(for/next counters)
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
KnackerBits         DFB $DD
MFL0                DFB $DD
MFL1                DFB $DD
MFL2                DFB $DD
channel             DFB $DD
offset              DFB $DD
IDRT                DFS 32,$DD
CHTAB               DFL $D402+0*7-$D400,$D402+1*7-$D400,$D402+2*7-$D400
DTAB                DFL D0-D0,D1-D0,D2-D0
SBTAB               DFL S0+23-S0,S1+23-S0,S2+23-S0
LoFrq               DFL N00,N01,N02,N03,N04,N05,N06,N07,N08,N09
                    DFL N10,N11,N12,N13,N14,N15,N16,N17,N18,N19
                    DFL N20,N21,N22,N23,N24,N25,N26,N27,N28,N29
                    DFL N30,N31,N32,N33,N34,N35,N36,N37,N38,N39
                    DFL N40,N41,N42,N43,N44,N45,N46,N47,N48,N49
                    DFL N50,N51,N52,N53,N54,N55,N56,N57,N58,N59
                    DFL N60,N61,N62,N63,N64,N65,N66,N67,N68,N69
                    DFL N70,N71,N72,N73,N74,N75,N76,N77,N78,N79
;              DFL N80,N81,N82,N83,N84,N85,N86,N87,N88,N89
;              DFL N90,N91,N92,N93
                    DFL NSil
HiFrq               DFH N00,N01,N02,N03,N04,N05,N06,N07,N08,N09
                    DFH N10,N11,N12,N13,N14,N15,N16,N17,N18,N19
                    DFH N20,N21,N22,N23,N24,N25,N26,N27,N28,N29
                    DFH N30,N31,N32,N33,N34,N35,N36,N37,N38,N39
                    DFH N40,N41,N42,N43,N44,N45,N46,N47,N48,N49
                    DFH N50,N51,N52,N53,N54,N55,N56,N57,N58,N59
                    DFH N60,N61,N62,N63,N64,N65,N66,N67,N68,N69
                    DFH N70,N71,N72,N73,N74,N75,N76,N77,N78,N79
;              DFH N80,N81,N82,N83,N84,N85,N86,N87,N88,N89
;              DFH N90,N91,N92,N93
                    DFH NSil

;==============================================================================

                    JSR MUSIC0:JSR MUSIC1:JSR MUSIC2;This useless routine is intended
                    JSR SOUND0:JSR SOUND1:JSR SOUND2;to put hackers off, and MUST NOT
                    JSR FILTER:RTS;                  be used under ANY circumstances!

TUNE                LDA TUNETABLE+1,Y:STA KnackerBits:AND #15:STA CalcDurations+1
                    LDX #2:STX channel:LDX #4:STX offset:DEY
get.tune.data       LDA TUNETABLE,Y:ORA TUNETABLE+1,Y:BEQ leve.it.alone:LDX offset
                    LDA TUNETABLE,Y:STA PC0,X:LDA TUNETABLE+1,Y:STA PC0+1,X:STY OUT
                    LDX channel:LDY DTAB,X:LDA #0:STA TR0,X:STA D0+FMC,Y:STA D0+PMC,Y
                    LDA #DEPTHOFSTACKS-1:STA SP0,X:LDA #1:STA CLOCK0,X:STA MFL0,X
                    LDY OUT
;              STA SFL0,X;[
leve.it.alone       DEY:DEY:DEC offset:DEC offset:DEC channel:BPL get.tune.data
NewDurations        CLC:LDA #0
CalcDurations       ADC #$DD:STA IDRT,X:INX:CPX #32:BCC CalcDurations:RTS

INITSOUND           JSR ResetCl:LDA #$97:STA $DD00;\
                    LDX #$16
ResetLoop           LDA #8:STA $D400,X:LDA #0:STA $D400,X:DEX:BPL ResetLoop
;              STX SFL0:STX SFL1:STX SFL2;[
                    STA S0+VRC:STA S1+VRC:STA S2+VRC:STA CUT+FMC:STA MFL0:STA MFL1
                    STA MFL2:STX FilterChannel:LDA #%11110000:STA $D417
                    LDA #%00001111:STA D418:RTS

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

EFFECT              STA OUT:STY OUT+1:STX channel
                    LDA #%00000000:STA $D417
                    LDA #%00001111:STA $D418;      filters are "off" during the game!
;              LDA #0:STA SFL0,X
                    LDA CHTAB,X:STA el2a+1:LDA #8:LDY CHTAB,X:STA $D402,Y
                    LDY #26:LDX #4
el2                 LDA (OUT),Y
el2a                STA $D4DD,X:DEY:DEX:BPL el2:LDY #29:LDX el2+3:LDA (OUT),Y
                    STA $D3FE,X:INY:LDA (OUT),Y:STA $D3FF,X:LDY channel:LDX SBTAB,Y
                    LDY #30:STA S0+2,X:DEY:LDA (OUT),Y:STA S0+1,X:DEY:LDA (OUT),Y
                    STA S0+5,X:DEY:LDA (OUT),Y:STA S0+4,X:LDY #24:LDA (OUT),Y
                    STA S0+3,X:LDY #23
el3                 LDA (OUT),Y:STA S0+0,X:DEX:DEY:BPL el3:INX:BNE ch1or2
                    LDA S0+PMC:BEQ transferf0:JSR transferpm0
transferf0          LDX S0+FINIT:LDY S0+FINIT+1:STX S0FCURR:STY S0FCURR+1
                    LDA S0+CFMD3:STA S0+FMD3C:LDA S0+CFMD2:STA S0+FMD2C
                    LDA S0+CFMD1:STA S0+FMD1C:LDA S0+CFMD0:STA S0+FMD0C:RTS
ch1or2              CPX #$46:BEQ ch2:LDA S1+PMC:BEQ lll1:JSR transferpm1
lll1                LDA S1+FMC:BEQ ex0
transferf1          LDX S1+FINIT:LDY S1+FINIT+1:STX S1FCURR:STY S1FCURR+1
                    LDA S1+CFMD3:STA S1+FMD3C:LDA S1+CFMD2:STA S1+FMD2C
                    LDA S1+CFMD1:STA S1+FMD1C:LDA S1+CFMD0:STA S1+FMD0C
ex0                 RTS
ch2                 LDA S2+PMC:BEQ lll2:JSR transferpm2
lll2                LDA S2+FMC:BEQ ex0
transferf2          LDX S2+FINIT:LDY S2+FINIT+1:STX S2FCURR:STY S2FCURR+1
                    LDA S2+CFMD3:STA S2+FMD3C:LDA S2+CFMD2:STA S2+FMD2C
                    LDA S2+CFMD1:STA S2+FMD1C:LDA S2+CFMD0:STA S2+FMD0C:RTS

;=========================*=== MUSIC CONTROL ===*==============================

MC0
callt0              LDA (PC0),Y:STA TR0:INY:LDA #4:DFB $2C
call0               LDA #3:LDX SP0:ADD PC0:STA ST0L,X:LDA #0:ADC PC0+1:STA ST0H,X
                    DEC SP0:LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STX PC0:STA PC0+1
                    JMP read.byte0
;code0         LDA ^add3c0-1:PHA:LDA #add3c0-1:PHA:LDA (PC0),Y:STA IN:INY
;              LDA (PC0),Y:STA IN+1:JMP (IN)
;dmpoke0        LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STA D0,X:INY:LDA (PC0),Y
;              STA D0+1,X:LDA #4:JMP addc0
dspoke0             LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STA S0,X:INY:LDA (PC0),Y
                    STA S0+1,X:LDA #4:JMP addc0
;filter0       LDA (PC0),Y:STA filt0loop+1:INY:LDA (PC0),Y:STA filt0loop+2
;              LDX #15
;filt0loop     LDA $DDDD,X:STA CUTST,X:DEX:BPL filt0loop:JMP add3c0
fload0              LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STA fload0loop+1:INY:LDA (PC0),Y
                    STA fload0loop+2
fload0loop          LDA $DDDD,X:STA D0,X:DEX:BPL fload0loop:LDA #4:JMP addc0
for0                LDX SP0:LDA #2:ADD PC0:STA ST0L,X:LDA #0:ADC PC0+1:STA ST0H,X
                    LDA (PC0),Y:STA ST0C,X:DEC SP0:LDA #2:JMP addc0
freq0               LDA (PC0),Y:STA frqpoke0+1:INY:LDA (PC0),Y:STA frqpoke0+2
                    LDX #13
frqpoke0            LDA $DDDD,X:STA D0,X:DEX:BPL frqpoke0:JMP add3c0
;gotot0        LDA (PC0),Y:STA TR0:INY
goto0               LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STX PC0:STA PC0+1:JMP read.byte0
;disown0       DEY:STY CUT+FMC:LDX #3:LDY #%11110000:DFB $2C
;master0a      LDY #%11110001:STY $D417
;master0b      STX FilterChannel:LDA #1:JMP addc0
;own0          LDX #0:BNE master0b
;master0       LDX #0:BEQ master0a
;mbendoff0     LDA #5:DFB $2C
;mbendon0      LDA #7:STA D0+FMC:TYA:JMP addc0
mpoke0              LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STA D0,X:JMP add3c0
next0               LDX SP0:DEC ST0C+1,X:BEQ n0a:LDY ST0L+1,X:LDA ST0H+1,X:STY PC0
                    STA PC0+1:JMP read.byte0
n0a                 INC SP0:TYA:JMP addc0
retsubrut0          LDY SP0:CPY #DEPTHOFSTACKS-1:BEQ rc0:INC SP0
                    LDX ST0L+1,Y:LDA ST0H+1,Y:STX PC0:STA PC0+1:JMP read.byte0
rc0                 DEC MFL0:RTS
;sload0        LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STA Z8:INY:LDA (PC0),Y:STA IN
;              INY:LDA (PC0),Y:STA IN+1:LDY Z8
;sload0loop    LDA (IN),Y:STA D0,X:DEX:DEY:BPL sload0loop:LDA #5:JMP addc0
spoke0              LDA (PC0),Y:TAX:INY:LDA (PC0),Y:STA S0,X:JMP add3c0
;transp0       LDA (PC0),Y:STA TR0:LDA #2:JMP addc0
volume0             LDA (PC0),Y:STA IN:INY:LDA (PC0),Y:STA IN+1:LDY #4
vo0                 LDA (IN),Y:STA D0+VWF,Y:DEY:BPL vo0:JMP add3c0
;square0       LDA #65OR 8:DFB $2C
;noise0        LDA #129OR 8:STA D0+VWF:LDA #1:JMP addc0

MC1
;callt1        LDA (PC1),Y:STA TR1:INY:LDA #4:DFB $2C
call1               LDA #3:LDX SP1:ADD PC1:STA ST1L,X:LDA #0:ADC PC1+1:STA ST1H,X
                    DEC SP1:LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STX PC1:STA PC1+1
                    JMP read.byte1
;code1         LDA ^add3c1-1:PHA:LDA #add3c1-1:PHA:LDA (PC1),Y:STA IN:INY
;              LDA (PC1),Y:STA IN+1:JMP (IN)
dmpoke1             LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STA D1,X:INY:LDA (PC1),Y
                    STA D1+1,X:LDA #4:JMP addc1
dspoke1             LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STA S1,X:INY:LDA (PC1),Y
                    STA S1+1,X:LDA #4:JMP addc1
;filter1       LDA (PC1),Y:STA filt1loop+1:INY:LDA (PC1),Y:STA filt1loop+2
;              LDX #15
;filt1loop     LDA $DDDD,X:STA CUTST,X:DEX:BPL filt1loop:JMP add3c1
fload1              LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STA fload1loop+1:INY:LDA (PC1),Y
                    STA fload1loop+2
fload1loop          LDA $DDDD,X:STA D1,X:DEX:BPL fload1loop:LDA #4:JMP addc1
for1                LDX SP1:LDA #2:ADD PC1:STA ST1L,X:LDA #0:ADC PC1+1:STA ST1H,X
                    LDA (PC1),Y:STA ST1C,X:DEC SP1:LDA #2:JMP addc1
freq1               LDA (PC1),Y:STA frqpoke1+1:INY:LDA (PC1),Y:STA frqpoke1+2
                    LDX #13
frqpoke1            LDA $DDDD,X:STA D1,X:DEX:BPL frqpoke1:JMP add3c1
;gotot1        LDA (PC1),Y:STA TR1:INY
goto1               LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STX PC1:STA PC1+1:JMP read.byte1
;disown1       DEY:STY CUT+FMC:LDX #3:LDY #%11110000:DFB $2C
;master1a      LDY #%11110010:STY $D417
;master1b      STX FilterChannel:LDA #1:JMP addc1
;own1          LDX #1:BNE master1b
;master1       LDX #1:BNE master1a
;mbendoff1     LDA #5:DFB $2C
;mbendon1      LDA #7:STA D1+FMC:TYA:JMP addc1
mpoke1              LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STA D1,X:JMP add3c1
next1               LDX SP1:DEC ST1C+1,X:BEQ n1a:LDY ST1L+1,X:LDA ST1H+1,X:STY PC1
                    STA PC1+1:JMP read.byte1
n1a                 INC SP1:TYA:JMP addc1
retsubrut1          LDY SP1:CPY #DEPTHOFSTACKS-1:BEQ rc1:INC SP1
                    LDX ST1L+1,Y:LDA ST1H+1,Y:STX PC1:STA PC1+1:JMP read.byte1
rc1                 DEC MFL1:RTS
;sload1        LDA (PC1),Y:TAX:INY:LDA (PC1),Y:STA Z8:INY:LDA (PC1),Y:STA IN
;              INY:LDA (PC1),Y:STA IN+1:LDY Z8
;sload1loop    LDA (IN),Y:STA D1,X:DEX:DEY:BPL sload1loop:LDA #5:JMP addc1
;transp1       LDA (PC1),Y:STA TR1:LDA #2:JMP addc1
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
;gotot2        LDA (PC2),Y:STA TR2:INY
goto2               LDA (PC2),Y:TAX:INY:LDA (PC2),Y:STX PC2:STA PC2+1:JMP read.byte2
;disown2       DEY:STY CUT+FMC:LDX #2:LDY #%11110000:DFB $2C
master2a            LDY #%11110100:STY $D417
master2b            STX FilterChannel
                    LDX #%00011111:STX $D418;the low-pass filter always gets selected
                    LDA #1:JMP addc2
;own2          LDX #2:BNE master2b
master2             LDX #2:BNE master2a
;mbendoff2     LDA #5:DFB $2C
;mbendon2      LDA #7:STA D2+FMC:TYA:JMP addc2
mpoke2              LDA (PC2),Y:TAX:INY:LDA (PC2),Y:STA D2,X:JMP add3c2
next2               LDX SP2:DEC ST2C+1,X:BEQ n2a:LDY ST2L+1,X:LDA ST2H+1,X:STY PC2
                    STA PC2+1:JMP read.byte2
n2a                 INC SP2:TYA:JMP addc2
retsubrut2          LDY SP2:CPY #DEPTHOFSTACKS-1:BEQ rc2:INC SP2:LDX ST2L+1,Y
                    LDA ST2H+1,Y:STX PC2:STA PC2+1:JMP read.byte2
rc2                 DEC MFL2:RTS
;              INY:STY SP2
;sload2        LDA (PC2),Y:TAX:INY:LDA (PC2),Y:STA Z8:INY:LDA (PC2),Y:STA IN
;              INY:LDA (PC2),Y:STA IN+1:LDY Z8
;sload2loop    LDA (IN),Y:STA D2,X:DEX:DEY:BPL sload2loop:LDA #5:JMP addc2
;spoke2        LDA (PC2),Y:TAX:INY:LDA (PC2),Y:STA S2,X:JMP add3c2
;transp2       LDA (PC2),Y:STA TR2:LDA #2:JMP addc2
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
read.byte0          LDY #0:LDA (PC0),Y:CMP #COM:BCC not.ctrl0:INY:ADC #vt0-COM-1
v0                  STA v0+4:JMP (vt0)
js0                 JMP st0
not.ctrl0           STA Z8:CMP #R:BCC in.du.re0:SBC #R
in.du.re0           CMP #Rest:BEQ js0;CMP #Sil:BEQ got.note0;@
                    ADC TR0
got.note0           TAX:LDA RF:AND #1:BEQ js0;\
NOTE0
;              LDA SFL0:BEQ js0;[
                    LDA #8:STA $D404
                    LDA FilterChannel:BNE nf0:STX IN:JSR StartFilter:LDX IN
nf0                 LDY HiFrq,X:LDA LoFrq,X:STA S0+FINIT:STY S0+FINIT+1:STA $D400
                    STY $D401:LDX D0+PINIT:LDY D0+PINIT+1:STX $D402:STY $D403
                    LDA D0+VADV:STA $D405:LDA D0+VSRV:STA $D406:LDA D0+VWF
                    STA S0+VWFG:AND #%11110111:STA $D404

;              LDX #PINIT+1
dll0;          LDA D0,X:STA S0,X:DEX:BPL dll0:JSR transferpm0a:LDA S0+FMC

dlpw0               LDA D0+PMC:STA S0+PMC:BEQ dlfrq0:STX S0+PINIT:STY S0+PINIT+1
                    STX S0PCURR:STY S0PCURR+1:LDA D0+PMG1+1:STA S0+PMG1+1
                    LDA D0+PMG1:STA S0+PMG1:LDA D0+PMG0+1:STA S0+PMG0+1:LDA D0+PMG0
                    STA S0+PMG0:LDA D0+PMDLY:STA S0+PMDLY:LDX D0+PMD0:LDY D0+PMD1
                    STX S0+CPMD0:STX S0+PMD0C:STY S0+CPMD1:STY S0+PMD1C

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
in.du.re1           CMP #Rest:BEQ js1;CMP #Sil:BEQ got.note1;@
                    ADC TR1
got.note1           TAX:LDA RF:AND #2:BEQ js1;\
NOTE1
;              LDA SFL1:BEQ js1;[
                    LDA #8:STA $D40B
ntb1                LDA FilterChannel:CMP #1:BNE nf1:STX IN:JSR StartFilter:LDX IN
nf1                 LDY HiFrq,X:LDA LoFrq,X:STA S1+FINIT:STY S1+FINIT+1:STA $D407
                    STY $D408:LDX D1+PINIT:LDY D1+PINIT+1:STX $D409:STY $D40A
                    LDA D1+VADV:STA $D40C:LDA D1+VSRV:STA $D40D:LDA D1+VWF
                    STA S1+VWFG:AND #%11110111:STA $D40B

;              LDX #PINIT+1
dll1;          LDA D1,X:STA S1,X:DEX:BPL dll1:JSR transferpm1a:LDA S1+FMC

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
NOTE2
;              LDA SFL2:BEQ js2;[
                    LDA #8:STA $D412
ntb2                LDA FilterChannel:CMP #2:BNE nf2:STX IN:JSR StartFilter:LDX IN
nf2                 LDY HiFrq,X:LDA LoFrq,X:STA S2+FINIT:STY S2+FINIT+1:STA $D40E
                    STY $D40F:LDX D2+PINIT:LDY D2+PINIT+1:STX $D410:STY $D411
                    LDA D2+VADV:STA $D413:LDA D2+VSRV:STA $D414:LDA D2+VWF
                    STA S2+VWFG:AND #%11110111:STA $D412

;              LDX #PINIT+1
dll2;          LDA D2,X:STA S2,X:DEX:BPL dll2:JSR transferpm2a:LDA S2+FMC

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
;              LDA S0FCURR:ORA S0FCURR+1:BEQ FM0;@
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
;              AND #8:BNE olm0;]
;              LDA S0FCURR:ORA S0FCURR+1:BEQ xit0;@
                    LDX S0FCURR:LDY S0FCURR+1:CLC:LDA S0+FMDLY:BEQ fcs10+1
                    DEC S0+FMDLY:LDA S0+FMC:AND #2:BNE fcs40l1
xit0                RTS
;olm0          DEC S0+FOLDC:BNE xit0:LDY S0+FOLOD:STY S0+FOLDC:LDY S0+FOLCI;]
;              BPL no0:LDY S0+FOLII
;no0           LDX S0+FOLA:STX IN:LDX S0+FOLA+1:STX IN+1:LDA S0+FOLB:ADD (IN),Y
;              DEY:STY S0+FOLCI:TAY
;POKEFRQ0      LDX LoFrq,Y:LDA HiFrq,Y:STX $D400:STA $D401:RTS
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
nofrqcopy0          JSR transferf0+10:JMP fcs10

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
;              LDA S1FCURR:ORA S1FCURR+1:BEQ FM1;@
                    LDA S1+PMDLY:BEQ pmdel1:DEC S1+PMDLY:JMP FM1
pmdel1              CLC:LDX S1PCURR:LDY S1PCURR+1
pms01               LDA S1+PMD0C:BEQ pms11:DEC S1+PMD0C
                    TXA:ADC S1+PMG0:TAX:TYA:ADC S1+PMG0+1:TAY:JMP stpm1
pms11               LDA S1+PMD1C:BEQ pmrep1:DEC S1+PMD1C
                    TXA:ADC S1+PMG1:TAX:TYA:ADC S1+PMG1+1:TAY:JMP stpm1
pmrep1              LDA S1+PMC:AND #$81:BEQ stpm1:BPL nopmcopy1:JSR transferpm1
                    JMP pmdel1
nopmcopy1           JSR transferpm1a:JMP pmdel1
stpm1               STX S1PCURR:STY S1PCURR+1:STX $D409:STY $D40A
FM1                 LDA S1+FMC:BEQ xit1
                    AND #8:BNE olm1;]
;              LDA S1FCURR:ORA S1FCURR+1:BEQ xit1;@
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
nofrqcopy1          JSR transferf1+10:JMP fcs11

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
;              AND #8:BNE olm2;]
                    LDA S2FCURR:ORA S2FCURR+1:BEQ xit2;@
                    LDX S2FCURR:LDY S2FCURR+1:CLC:LDA S2+FMDLY:BEQ fcs12+1
                    DEC S2+FMDLY:LDA S2+FMC:AND #2:BNE fcs42l1
xit2                RTS
;olm2          DEC S2+FOLDC:BNE xit2:LDY S2+FOLOD:STY S2+FOLDC:LDY S2+FOLCI;]
;              BPL no2:LDY S2+FOLII
;no2           LDX S2+FOLA:STX IN:LDX S2+FOLA+1:STX IN+1:LDA S2+FOLB:ADD (IN),Y
;              DEY:STY S2+FOLCI:TAY
;POKEFRQ2      LDX LoFrq,Y:LDA HiFrq,Y:STX $D40E:STA $D40F:RTS
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
nofrqcopy2          JSR transferf2+10:JMP fcs12

MUSICTEST           LDA MFL0:ORA MFL1:ORA MFL2:ORA S0+VRC:ORA S1+VRC:ORA S2+VRC:RTS

TUNETABLE

EP;======================******************************========================
;========================*=== END OF MUSIC PROGRAM ===*========================
;========================******************************========================
























;=========================********************=================================
;=========================*=== MUSIC DATA ===*=================================
SD;=======================********************=================================

                    DFW OPENINGSEQUE0,OPENINGSEQUE1,OPENINGSEQUE2:DFL 9
                    DFW NEXTSCREEN0,NEXTSCREEN1,NEXTSCREEN2:DFL 11
                    DFW $DDDD,$DDDD,$DDDD:DFL $DD
                    DFW $DDDD,$DDDD,$DDDD:DFL $DD
                    DFW OVER0,OVER1,OVER2:DFL 13
                    DFW eNTER0,eNTER1,eNTER2:DFL 3
                    DFW EXTRA0,EXTRA1,EXTRA2:DFL 10
                    DFW $DDDD,$DDDD,$DDDD:DFL $DD
                    DFW TITLE0,TITLE1,TITLE2:DFL 4

;======================== TITLE SCREEN MUSIC DATA =============================

TD00                DFW +20,-20,+20,0:DFL 3,6,3,0,30,5
                    DFL 50,50,10,5:DFW +10,-10,$0800
                    DFL 65,$14,$C8,255,250
TD01                DFW +35,-35,+35,0:DFL 3,5,2,0,10,5
                    DFS 10,0
                    DFL %00011001,$A4,$F9,20,254

TITLE0              DFL FLoad,VRC:DFW TD00
                    DFL Rest,32
                    DFL 29,32
                    DFL For,3,Rest,32,Next
                    DFL 31,32
                    DFL For,3,Rest,32,Next
                    DFL DSoke,FMDLY:DFW 32*4+256*7
                    DFL DSoke,FBG:DFW +60
                    DFL CT,-12:DFW TS20
                    DFL Moke,VSRV,$8D
                    DFL CT,+0:DFW TS20a
                    DFL Soke,VADSD,1
                    DFL FLoad,VRC:DFW TD01
                    DFL For,4,Rest,32,Next
                    DFL For,4,67,16,66,16,64,16,62,16,60,16,59,16,57,16,55,16,Next
                    DFL For,21,Rest,16,Next,Jmp:DFW TITLE0

TD10                DFW +20,-20,+20,0:DFL 3,6,3,0,10,5
                    DFL 50,50,20,5:DFW +10,-10,$0800
                    DFL 65,$14,$C4,255,5
TL10                DFL 0,3,9,12
TL11                DFL 0,3,7,12
TL12                DFL 0,5,11,12
TL13                DFL 0,5,9,12
TD11                DFW 0,0,1,1,TL10:DFL 0,3,0,8
                    DFL 50,50,20,0:DFW +10,-10,$0800
                    DFL 65,$00,$F6,5,5

TITLE1              DFL FLoad,VRC:DFW TD10
                    DFL Rest,32,29,32
                    DFL For,3,Rest,32,Next
                    DFL 31,32
                    DFL For,3,Rest,32,Next
                    DFL DSoke,FMDLY:DFW 32*4+256*7
                    DFL DSoke,FBG:DFW +40
                    DFL FLoad,VRC:DFW TD11
                    DFL Rest,32
                    DFL For,2,DMoke,FOLA:DFW TL10
                    DFL For,16,57,2,Next
                    DFL DMoke,FOLA:DFW TL11
                    DFL For,16,57,2,Next
                    DFL DMoke,FOLA:DFW TL12
                    DFL For,16,55,2,Next
                    DFL DMoke,FOLA:DFW TL13
                    DFL For,16,55,2,Next,Next
                    DFL For,7,DMoke,FOLA:DFW TL10
                    DFL For,3,Moke,FMC,8,57,2,Moke,FMC,0,57,2,Next,69,2
                    DFL Moke,FMC,8,57,2,Moke,FMC,0,69,2
                    DFL Moke,FMC,8,57,2,Moke,FMC,0,57,2,69,2
                    DFL Moke,FMC,8,57,2,Moke,FMC,0,57,2,57,2,57,2
                    DFL DMoke,FOLA:DFW TL11
                    DFL Moke,FMC,8,57,2,Moke,FMC,0,57,2,Moke,FMC,8
                    DFL For,4,57,2,Next
                    DFL For,2,Moke,FMC,0,69,2,Moke,FMC,8,57,2,Next,57,2
                    DFL Moke,FMC,0,69,2,Moke,FMC,8,57,2
                    DFL Moke,FMC,0,69,2,57,2,57,2
                    DFL DMoke,FOLA:DFW TL12
                    DFL For,3,Moke,FMC,8,55,2,Moke,FMC,0,55,2,Next,72,2
                    DFL Moke,FMC,8,55,2,Moke,FMC,0,72,2
                    DFL Moke,FMC,8,55,2,Moke,FMC,0,55,2,72,2
                    DFL Moke,FMC,8,55,2,Moke,FMC,0,55,2,55,2,55,2
                    DFL DMoke,FOLA:DFW TL13
                    DFL Moke,FMC,8,55,2,Moke,FMC,0,55,2,Moke,FMC,8
                    DFL For,4,55,2,Next
                    DFL For,2,Moke,FMC,0,72,2,Moke,FMC,8,55,2,Next,55,2
                    DFL Moke,FMC,0,72,2,Moke,FMC,8,55,2
                    DFL Moke,FMC,0,72,2,55,2,55,2,Next
                    DFL For,21,Rest,16,Next,Jmp:DFW TITLE1

TC20                DFW +333,-30,0,0:DFL 3,20,0,0,0,4:DFW 1
TD20                DFW +20,-20,+20,+28:DFL 3,6,3,0,40,7
                    DFL 50,50,40,5:DFW +10,-10,$0800
                    DFL 65,$14,$C8,255,50
TC21                DFW +333,-45,-5,-1:DFL 3,20,10,50,0,4:DFW 1
TD21                DFW +25,-25,+25,0:DFL 2,4,2,0,6,5
                    DFL 50,50,0,5:DFW +20,-20,$0600
                    DFL 65,$14,$E8,30,40
TF22                DFW +32,0,0,0:DFL 255,0,0,0,10,4
TS20                DFL Rest,32
TS20a               DFL 33,32,Rest,26,35,6,36,32,Rest,26,38,2,40,2,36,2
                    DFL 33,32,Rest,26,35,6,36,32,Rest,32,Ret
TS21                DFL 33,4,33,4,45,1,Sil,1,33,4,33,8,33,2,45,2,28,2,31,4
                    DFL 33,4,33,2,33,2,45,1,Sil,1,33,4,33,4,33,4,33,2,45,2,33,2,35,4
                    DFL 36,4,36,2,36,2,48,1,Sil,3,36,2,36,4,36,2,36,2,36,2,48,2
                    DFL Freq:DFW TF22
                    DFL 31,6
                    DFL Freq:DFW TD21
                    DFL 36,2,24,2,36,2,24,2,48,4,36,2,36,4,36,2,52,2,36,2,48,2
                    DFL 40,2,43,2,45,2,Ret
TX20                LDA #%00010000:STA D418:RTS
TX21                LDA #%00000000:STA D418:STA $D417:STA FilterChannel:RTS

TITLE2              DFL Filter:DFW TC21
TITLE2Loop          DFL FLoad,VRC:DFW TD20
                    DFL RestR,32*4-40,5+R,40
                    DFL For,4,Rest,32,Next,Moke,FMC,5,31,32
                    DFL For,3,Rest,32,Next
                    DFL DSoke,FMDLY:DFW 32*4+256*7
                    DFL DSoke,FBG:DFW +20
                    DFL Moke,FMC,5
                    DFL Call:DFW TS20
                    DFL FLoad,VRC:DFW TD21
                    DFL Master,Code:DFW TX20
                    DFL Call:DFW TS21
                    DFL Call:DFW TS21
                    DFL FLoad,VRC:DFW TD01
                    DFL Filter:DFW TC20
                    DFL For,3,Rest,32,Next
                    DFL For,2,67,16,66,16,64,16,62,16,60,16,59,16,57,16,55,16,Next
                    DFL 67,16,66+R,16*4-41
                    DFL Filter:DFW TC21
                    DFL FLoad,VRC:DFW TD20
                    DFL RestR,1,5+R,40
                    DFL FLoad,VRC:DFW TD21
                    DFL Call:DFW TS21
                    DFL Call:DFW TS21
                    DFL Code:DFW TX21
                    DFL Rest,16
                    DFL For,10,Rest,32,Next,Jmp:DFW TITLE2Loop

;======================= ENTER NAME DATA ======================================

ED00                DFW +30,-30,+30,0:DFL 3,5,2,0,8,5
                    DFS 8,0:DFW $0800
                    DFL %01001001,$06,$99,4,40
ES00                DFL 55,4,57,2,58,2,57,3,Rest,1,55,3,Rest,1,Ret
ES01                DFL 57,3,Rest,1,62,3,Rest,1,57,7,Rest,1,Ret
ES02                DFL Call:DFW ES00
                    DFL Call:DFW ES01
                    DFL Call:DFW ES00
                    DFL 55,4,54,4,55,4,57,4
                    DFL Call:DFW ES00
                    DFL Call:DFW ES01
                    DFL 58,4,60,2,62,2,60,3,Rest,1,58,3,Rest,1
                    DFL 60,3,Rest,1,65,3,Rest,1,60,7,Rest,1
                    DFL For,2
                    DFL For,3,69,2,69,2,Rest,4,Next,69,2,67,2,65,2,60,2,62,28
                    DFL Rest,4,Next,Ret

eNTER0              DFL FLoad,VRC:DFW ED00
                    DFL RestR,1
eNTER0Loop          DFL For,4,Call:DFW ES02
                    DFL Next
                    DFL For,64,Rest,4,Next
                    DFL Jmp:DFW eNTER0Loop

ED10                DFW +30,-30,+30,0:DFL 2,4,2,0,6,5
                    DFS 8,0:DFW $0800
                    DFL %00101001,$06,$99,4,40

eNTER1              DFL FLoad,VRC:DFW ED10
                    DFL RestR,1
eNTER1Loop          DFL For,3,Call:DFW ES02
                    DFL Rest,2,Next
                    DFL For,250,Rest,1,Next
                    DFL Call:DFW ES02
                    DFL Jmp:DFW eNTER1Loop

ED20                DFS 14,0
                    DFL 255,0,1,4:DFW +100,0,$0200
                    DFL 65,$06,$48,10,20
ES20                DFL For,2,0,2,0,2,12,2,12,2,Next,Ret
ES21                DFL CT,+31:DFW ES20
                    DFL CT,+29:DFW ES20
                    DFL CT,+27:DFW ES20
                    DFL CT,+26:DFW ES20
                    DFL Ret

eNTER2              DFL FLoad,VRC:DFW ED20
                    DFL RestR,1
eNTER2Loop          DFL Call:DFW ES21
                    DFL CT,+31:DFW ES20
                    DFL CT,+29:DFW ES20
                    DFL CT,+27:DFW ES20
                    DFL CT,+29:DFW ES20
                    DFL Call:DFW ES21
                    DFL Call:DFW ES21
                    DFL Jmp:DFW eNTER2Loop

;======================= EXTRA LIFE DATA ======================================

XV00                DFL 17,$23,$E4,20,10

EXTRA0              DFL Vlm:DFW XV00
                    DFL RestR,21,55,1,61,1,62,1,65,1,67,1,71,1,Ret

EXTRA1              DFL Vlm:DFW XV00
                    DFL RestR,11,55,1,61,1,62,1,65,1,67,1,71,1,74,1,Ret

XV20                DFL 65,$24,$A4,20,4

EXTRA2              DFL Vlm:DFW XV20
                    DFL DMoke,PINIT:DFW $0800
                    DFL RestR,1
                    DFL 55,1,61,1,62,1,65,1,67,1,71,1,74,1,Ret

;======================== GAME OVER DATA ======================================

OF00                DFW -N43+1,0,+N43-1,0:DFL 1,3,1,9,9,5
OV00                DFL %00011001,$13,$E4,2,10

OVER0               DFL Vlm:DFW OV00
                    DFL RestR,27
OVER0a              DFL 58,1,53,1,55,1,50,1,53,1,48,1,50,1,46,1
                    DFL Freq:DFW OF00
                    DFL 43,3,Moke,FMC,0,43,2,Ret

OVER1               DFL Vlm:DFW OV00
                    DFL RestR,04,Jmp:DFW OVER0a

OV20                DFL 73,$24,$A4,2,4

OVER2               DFL Vlm:DFW OV20
                    DFL DMoke,PINIT:DFW $0800
                    DFL RestR,1,Jmp:DFW OVER0a

;================== OPENING SEQUENCE MUSIC DATA ===============================

SD00                DFW +14,-14,+14,0:DFL 5,10,5,0,20,5
                    DFL 255,0,0,4:DFW +10,0,$0800
                    DFL %01001001,$06,$98,5,30

OPENINGSEQUE0       DFL FLoad,VRC:DFW SD00
                    DFL 48,3,48,1,55,8,54+R,12,55+R,12,57+R,12,55,16
                    DFL 48,3,48,1,55,8,57,1,55,1,54,1,57,1,55,8,Ret

OPENINGSEQUE1       DFL FLoad,VRC:DFW SD00
                    DFL 43,3,43,1,52,8,51+R,12,52+R,12,53+R,12,52,16
                    DFL 43,3,43,1,52,8,53,1,52,1,51,1,53,1,52,8,Ret

SC20                DFW +333,-45,+20,-20:DFL 3,20,50,50,0,4:DFW 1
SD20                DFW +15,-15,+15,0:DFL 4,8,4,0,14,5
                    DFL 25,0,0,4:DFW +10,0,$0800
                    DFL %01001001,$06,$98,5,30

OPENINGSEQUE2       DFL FLoad,VRC:DFW SD20
                    DFL Master,Filter:DFW SC20
                    DFL For,3,36,4,31,4,Next,36,2,31,2,33,2,35,2
                    DFL For,2,36,4,31,4,Next,36,16,Rest,8,Ret

;================= NEXT SCREEN/NEXT LIFE MUSIC DATA ===========================

NEXTSCREEN2         DFL FLoad,VRC:DFW SD20
                    DFL Master,Filter:DFW SC20
                    DFL Rest,3,27,1,27,1,27,1,27,3,29,3,33,3
                    DFL For,2,36+R,16,31+R,17,Next,36,6,Ret

NEXTSCREEN1         DFL RestR,20
NEXTSCREEN0         DFL FLoad,VRC:DFW SD00
                    DFL 55,2,55,1,58,6,57+R,16,55+R,17,53+R,16,57+R,17,55,6,Ret

PE;============================================================================

CH0VALUE            EQU 1
CH1VALUE            EQU 1
CH2VALUE            EQU 1
Q                   EQU 0
refsp               EQU $080;                         Opening Sequence (100Hz P.A.L.)

;^^^^^^^^^^^^^ This is the end of Mart's source file... (or is it?) ^^^^^^^^^^^

;Mart's super "drum-kit" program 14:56 Thursday 5th February 1987...

NMI                 EQU $0107
N50                 EQU 4927
N54                 EQU 6207
N57                 EQU 7382
BDR                 EQU $D020
StacksDepth         EQU 8


EFFECTS             EQU $2000;  sound object code goes from $2000 to $3FFF inclusive.
JUMPS               EQU $3F00
INITSOUND           EQU JUMPS+3*0
MUSICTEST           EQU JUMPS+3*1
TUNE                EQU JUMPS+3*2
EFFECT              EQU JUMPS+3*3
FILTER              EQU JUMPS+3*4
SOUND0              EQU JUMPS+3*5
SOUND1              EQU JUMPS+3*6
SOUND2              EQU JUMPS+3*7
MUSIC0              EQU JUMPS+3*8
MUSIC1              EQU JUMPS+3*9
MUSIC2              EQU JUMPS+3*10
RefScreen1          EQU JUMPS+3*11
RefScreen2          EQU JUMPS+3*12
RefScreen3          EQU JUMPS+3*13
RefScreen4          EQU JUMPS+3*14
X

D418                EQU $3FFF

bass                EQU $81
snare               EQU $82
tomhi               EQU $83
tomme               EQU $84
tomlo               EQU $85
hihat               EQU $86
Drest               EQU $87

ZERO                EQU $0050
seqPC               EQU ZERO+0;2
seqCLK              EQU ZERO+2;1
seqSP               EQU ZERO+3;1
synwksp             EQU ZERO+4;1

;================================ DRIVER ======================================

                    ORG $4000:ENT

Start               JSR INITRASTERS
                    JSR INITSOUND

;              JSR INITSID
;              LDX #eNTERDATA:LDY ^eNTERDATA:LDA #1:JSR RIFF
;              LDY #6*7-2:JSR TUNE
                    LDX #TITLEDATA:LDY ^TITLEDATA:LDA #2:JSR RIFF
                    LDY #9*7-2:JSR TUNE

MAIN                JSR RefScreen1
                    JSR PLEY
                    JSR RefScreen2
                    JSR PLEY
                    JSR RefScreen3
                    JSR PLEY
                    JSR RefScreen4
                    JSR PLEY
                    JMP MAIN

;HANG          SEI:INC BDR:JMP HANG

INITRASTERS         SEI:LDA #$35:STA $01:LDA #20:STA $D012:LDA #$FF:STA $D019
                    LDA #$F1:STA $D01A:LDX #%01111111:STA $DC0D:LDA $DC0D:LDA #0
                    STA $DC0E:LDX #IRQ:LDY ^IRQ:STX $FFFE:STY $FFFF
                    LDX #NMI:LDY ^NMI:STX $FFFA:STY $FFFB:CLI:RTS

;INITSID       LDX #N50:LDY ^N50:STX $D400:STY $D401
;              LDX #N54:LDY ^N54:STX $D407:STY $D408
;              LDX #N57:LDY ^N57:STX $D40E:STY $D40F
;              LDA #$08:STA $D403:STA $D403+7:STA $D403+14
;              LDA #65:STA $D404:STA $D404+7:STA $D404+14
;              LDA #$FA:STA $D405:STA $D405+7:STA $D405+14
;              LDA #$80:STA $D406:STA $D406+7:STA $D406+14
;              LDA #15:STA $D418
;              RTS

;=== INTERRUPT ROUTINE ===

IRQ                 PHA:LDA $D019:STA $D019:LDA #20:STA $D012:CLD:TYA:PHA:TXA:PHA
                    LDA #0:STA BDR
                    JSR DRUMS
                    LDA #1:STA BDR
                    JSR MUSIC0
                    JSR MUSIC1
                    JSR MUSIC2
                    JSR SOUND0
                    JSR SOUND1
                    JSR SOUND2
                    JSR FILTER
                    LDA #12:STA BDR
                    PLA:TAX:PLA:TAY:PLA:RTI

;============================= ACTUAL CODE ====================================

                    ORG $5000

PLEY                LDA DRUMFLAG:BEQ exit:LDA #0:STA DRUMFLAG
DRMvc               JSR $DDDD:LDA #15:ORA D418:STA $D418:RTS

RIFF                STA seqCLK:STX seqPC:STY seqPC+1:LDA #StacksDepth-1:STA seqSP:RTS

DRUMS               DEC seqCLK:BNE exit
repeat              LDY #0:LDA (seqPC),Y:BMI drum:LDX #255
control             INX:CMP DRUMCONTROLS,X:BNE control
                    LDA CNTRLVCSl,X:STA cntrlvc+1:LDA CNTRLVCSh,X:STA cntrlvc+2
                    LDA #0:STA synwksp
cntrlvc             JSR $DDDD:JMP repeat
drum                STA DRUMFLAG:TAX:INY:LDA (seqPC),Y:STA seqCLK
                    LDA seqPC:ADD #2:STA seqPC:LDA seqPC+1:ADC #0:STA seqPC+1
                    LDA VCTRSlow-$81,X:STA DRMvc+1:LDA VCTRShigh-$81,X:STA DRMvc+2
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
                    DEX:BNE H2:DEY:BPL H1:RTS

TOMhig              LDY #5
X1                  LDX #25
X2                  LDA TOMhiTABLE,Y
X3                  SUB #1:BNE X3:LDA synwksp:ADD #101:STA synwksp:AND #15:STA $D418
                    DEX:BNE X2:DEY:BPL X1:RTS

TOMlow              LDY #5
Y1                  LDX #25
Y2                  LDA TOMmeTABLE,Y
Y3                  SUB #1:BNE Y3:LDA synwksp:ADD #$DD:STA synwksp:AND #15:STA $D418
                    DEX:BNE Y2:DEY:BPL Y1:RTS

TOMmed              LDY #5
Z1                  LDX #25
Z2                  LDA TOMloTABLE,Y
Z3                  SUB #1:BNE Z3:LDA synwksp:ADD #$DD:STA synwksp:AND #15:STA $D418
                    DEX:BNE Z2:DEY:BPL Z1:RTS

SNARE               LDY #15
N1                  LDX #12
N2                  LDA SNARETABLE,Y
N3                  SUB #1:BNE N3:LDA synwksp:ADD #14:STA synwksp:AND #15:STA $D418
                    DEX:BNE N2:DEY:BPL N1:RTS

BASS                LDY #5
B1                  LDX #25
B2                  LDA BASSTABLE,Y
B3                  SUB #1:BNE B3:LDA synwksp:ADD #1:STA synwksp:AND #15:STA $D418
                    DEX:BNE B2:DEY:BPL B1
DREST               RTS

TOMhiTABLE          DFB 32,16,8,4,2,1
TOMmeTABLE          DFB 35,20,12,9,6,3
TOMloTABLE          DFB 5,30,25,20,15,10
BASSTABLE           DFB 64,24,62,22,60,20
SNARETABLE          DFB 32,16,8,4,2,1,60,10,40,10,20,10,$20,$40,$60,$49
HIHATTABLE          DFB 60,10,40,10,20,10
DRUMCONTROLS        DFB $20,$40,$60,$49,$4C;JSR, RTI, RTS, EOR & JMP!
CNTRLVCSl           DFL DRUMJSR,DRUMNEXT,DESTK,DRUMFoR,DRUMJMP
CNTRLVCSh           DFH DRUMJSR,DRUMNEXT,DESTK,DRUMFoR,DRUMJMP
VCTRSlow            DFL BASS,SNARE,TOMhig,TOMmed,TOMlow,HIHAT,DREST
VCTRShigh           DFH BASS,SNARE,TOMhig,TOMmed,TOMlow,HIHAT,DREST

BSS

DRUMFLAG            DFB 0
STKLOW              DFS StacksDepth,0
STKHIGH             DFS StacksDepth,0
STKCNT              DFS StacksDepth,0

SD;================= TITLE SCREEN SEQUENCE DATA ===============================

D                   EQU 4

DS0                 EOR #8:DFL tomhi,1,tomhi,3:RTI
                    EOR #8:DFL tomlo,1,tomlo,3:RTI
                    JSR DHH4:JSR DHH4:JSR DHH2:JSR DHH2
DHH4                DFL hihat,2,hihat,4*D-2:RTS
DS1                 DFL bass,2*D
                    JSR DHH2
                    DFL bass,2*D
                    JSR DHH2:JSR DSN2:JSR DHH2:JSR DHH2
                    DFL bass,2*D
                    JSR DHH2
                    DFL bass,2*D,bass,2*D
                    JSR DHH2
DSN2                DFL snare,1,snare,1,snare,2*D-2:RTS
DS2                 JSR DHH2:DFL bass,2*D
DHH2                DFL hihat,2,hihat,2*D-2:RTS
DS3                 DFL bass,2*D:JSR DHH2:DFL bass,2*D:RTS
DS9                 JSR DS8:JMP DS4
DS4                 DFL bass,2*D,tomme,2,tomme,2*D-2,tomme,2,tomme,2*D-2:RTS
DS8                 JSR DS1:JSR DS2:JSR DS1:JSR DS3:JSR DS1:JSR DS2:JMP DS1
DS10                DFL bass,2*D
                    JSR DHH2
                    DFL tomhi,2,tomhi,2*D-2
                    JSR DHH2:JSR DSN2:JSR DHH2
                    DFL tomhi,2,tomhi,2*D-2
                    JMP DHH2
DS11                DFL tomme,2,tomme,2*D-2
                    JSR DHH2
                    DFL tomhi,2,tomhi,2*D-2
                    JSR DHH2:JSR DSN2:JSR DHH2
                    DFL tomhi,2,tomhi,2*D-2
                    JMP DHH2

TITLEDATA           JSR DS0:JSR DS9:JSR DS9:JSR DS0
                    EOR #2:JSR DS9:JSR DS8:EOR #3:DFL snare,1,snare,1,snare,6:RTI:RTI
                    DFL bass,32*4:EOR #7:DFL Drest,32*4:RTI
                    JSR DS1:JSR DS2:JSR DS1:JSR DS3:JSR DS1:JSR DS2
                    DFL bass,2*D
                    JSR DHH2
                    DFL bass,2*D
                    EOR #4
                    DFL bass,2*D
                    JSR DHH2:RTI
                    DFL bass,2*D,bass,8*D
                    JSR DS9:JSR DS9
                    EOR #3:JSR DS10:RTI
                    DFL bass,2*D
                    JSR DHH2
                    DFL tomme,2,tomme,2*D-2
                    JSR DHH2:JSR DSN2
                    DFL bass,2*D
                    DFL tomme,2,tomme,2*D-2
                    DFL bass,2*D
                    EOR #3:JSR DS10:RTI
                    DFL bass,2*D
                    JSR DHH2
                    DFL tomme,2,tomme,2*D-2,tomlo,D,tomlo,D
                    JSR DSN2
                    DFL tomlo,2,tomlo,2*D-2,bass,D*2
                    EOR #4:DFL hihat,2:RTI
                    EOR #3:JSR DS11:RTI
                    DFL tomme,2,tomme,2*D-2
                    JSR DHH2
                    DFL tomme,2,tomme,2*D-2
                    JSR DHH2:JSR DSN2
                    EOR #3
                    DFL tomme,2,tomme,2*D-2
                    RTI
                    EOR #3:JSR DS11:RTI
                    DFL tomme,2,tomme,2*D-2
                    JSR DHH2
                    DFL tomme,2,tomme,2*D-2,tomlo,D,tomlo,D
                    JSR DSN2
                    DFL tomlo,2,tomlo,2*D-2,tomme,2,tomme,2*D-2
                    EOR #4
                    DFL hihat,2
                    RTI
                    EOR #2
                    DFL tomme,2,tomme,4*D-2
                    JSR DHH2:JSR DHH2:JSR DSN2
                    DFL Drest,D*2
                    JSR DHH2:JSR DHH2:RTI
                    DFL tomme,2,tomme,4*D-2
                    JSR DHH2:JSR DHH2:JSR DSN2
                    DFL bass,2*D
                    JSR DHH2:JSR DHH2
                    DFL bass,32*D
                    JMP TITLEDATA

;==================== "ENTER NAME" SCREEN SEQUENCE DATA =======================

C                   EQU 3
ES0                 DFL tomme,C*4,hihat,C*2,hihat,C*2
                    DFL snare,C*4,hihat,C*2,hihat,C*2
                    DFL tomme,C*2,tomme,C*2,hihat,C*2,hihat,C*2
                    DFL snare,C*4,hihat,C*2,hihat,C*2
                    DFL tomme,C*4,hihat,C*2,hihat,C*2
                    DFL snare,C*4,hihat,C*2,hihat,C*2
                    DFL tomme,C*2,tomme,C*2,hihat,C*2,hihat,C*2
                    RTS

eNTERDATA           DFL Drest,1
eLOOP               EOR #7
                    DFL tomlo,C*8
                    RTI
                    DFL tomlo,C*4,tomlo,C*2,tomlo,C*2
                    EOR #6
                    DFL tomlo,2,tomlo,C*8-2
                    RTI
                    DFL snare,2,snare,C*8-2
                    EOR #2
                    DFL tomhi,2,tomhi,C*2-2
                    RTI
                    EOR #2
                    DFL tomme,2,tomme,C*2-2
                    RTI
                    EOR #4
                    EOR #3
                    JSR ES0
                    DFL snare,C*2,tomhi,C*2,hihat,C*2,hihat,C*2
                    RTI
                    JSR ES0
                    DFL snare,C*2,tomhi,C*2,snare,C*2,snare,C*2
                    RTI
                    JMP eLOOP

;==============================================================================

DATASIZE            EQU .-SD
SIZE                EQU .-Start

;^^^^^^^^^^^^^^^ This is the end of the source file... (or is it?) ^^^^^^^^^^^^
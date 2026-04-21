// ============================================================================
//  Wizball audio source file (SID / 65xx system) — KickAssembler port
//
//  Original source: Martin Galway, Ocean Software Ltd, April 1987
//  Original assembler: Ocean in-house 1987 cross-assembler
//  Port target: KickAssembler v5.x
//
//  This file is a faithful transcription of `wizball.asm` at the repo root.
//  Galway's original comments are preserved verbatim. Any comments added by
//  the port are prefixed `// PORT:` so they are easy to spot and strip.
//
//  Translation notes live in:
//    research/ocean-assembler/notes.md      — quirks, resolved ambiguities
//    research/kickass-mapping/directives.md — directive translation table
// ============================================================================

#importonce

// ============================================================================
// Zero-page workspace (Ocean: `ORG ZEROn` + `DFS` — virtual allocation)
// ============================================================================
// PORT: Ocean's `ORG ZERO0` / `DFS n` pattern lays out labels in zero page
// without emitting any bytes. In KickAssembler this maps to a `virtual`
// segment: the program counter advances and labels get addresses, but
// nothing is written to the output PRG. The `.-PC0` size idiom translates
// to `* - PC0`.

.label ZERO0         = $0004
.label ZERO1         = $0029
.label ZERO2         = $0087
.label DEPTHOFSTACKS = 5

.segmentdef ZeroPage0 [start=ZERO0, virtual]
.segmentdef ZeroPage1 [start=ZERO1, virtual]
.segmentdef ZeroPage2 [start=ZERO2, virtual]

.segment ZeroPage0
PC0:           .fill 2, 0
PC1:           .fill 2, 0
PC2:           .fill 2, 0
CLOCK0:        .fill 1, 0
CLOCK1:        .fill 1, 0
CLOCK2:        .fill 1, 0
SP0:           .fill 1, 0
SP1:           .fill 1, 0
SP2:           .fill 1, 0
TR0:           .fill 1, 0
TR1:           .fill 1, 0
TR2:           .fill 1, 0
IN:            .fill 2, 0
S1FCURR:       .fill 2, 0
S2FCURR:       .fill 2, 0
OUT:           .fill 2, 0    // this z.p. word to be used OUTSIDE INTERRUPTS ONLY!!!
Z8:            .fill 1, 0
.label ZPSIZE = * - PC0

.segment ZeroPage1
S0PCURR:       .fill 2, 0
S1PCURR:       .fill 2, 0
S2PCURR:       .fill 2, 0
S0FCURR:       .fill 2, 0
CUTST:         .fill 16, 0
CUT:           .fill 22, 0
FilterChannel: .fill 1, 0
FilterByte:    .fill 1, 0
MFL0:          .fill 1, 0
MFL1:          .fill 1, 0
MFL2:          .fill 1, 0
channel:       .fill 1, 0
offset:        .fill 1, 0
EOZP1:

.segment ZeroPage2
D0:            .fill 29, 0
D2:            .fill 29, 0
S2:            .fill 35, 0
ST0L:          .fill DEPTHOFSTACKS, 0    // stack (low bytes only)
ST0H:          .fill DEPTHOFSTACKS, 0    // stack (high bytes only)
ST0C:          .fill DEPTHOFSTACKS, 0    // stack (for/next counters)
ST1L:          .fill DEPTHOFSTACKS, 0
ST1H:          .fill DEPTHOFSTACKS, 0
EOZP2:

// ============================================================================
// Command opcodes — dispatch table offsets from base COM
// ============================================================================
// Every music-stream command is encoded as a byte >= COM. The low-nibble
// distinguishes commands (Ret, Call, Jmp, ...). Values below COM are split
// between rest-length encodings (Rest..Rest+R-1) and note-value encodings
// (R..COM-1). Note that Rest+R = $BF = COM-1, so the pre-COM range exactly
// tiles the rest/note namespace.

.label COM      = $C0
.label Rest     = $5F
.label R        = $60
.label RestR    = Rest+R
.label Ret      = COM+0
.label Call     = COM+2
.label Jmp      = COM+4
.label CT       = COM+6
.label JT       = COM+8
.label Moke     = COM+10
.label For      = COM+12
.label Next     = COM+14
.label FLoad    = COM+16
.label Vlm      = COM+18
.label Soke     = COM+20
.label Code     = COM+22
.label Transp   = COM+24
.label DMoke    = COM+26
.label DSoke    = COM+28
.label Master   = COM+30
.label Filter   = COM+32
.label Disown   = COM+34
.label MBendOff = COM+36
.label MBendOn  = COM+38
.label Freq     = COM+40
.label Time     = COM+42

// ============================================================================
// FM / PM data-structure offsets (primary view)
// ============================================================================
// FMG* and PMG* are glide targets; FMD* / PMD* are delta values; FMDLY/PMDLY
// are delay counters; FMC/PMC are control bytes; CFINIT / PINIT are init
// flags. Duplicate values (e.g. FMD1/CHS both = 9, CFINIT/PMD0 both = 14) are
// intentional — same byte offset viewed under different struct names.

.label FMG0   = 0
.label FMG1   = 2
.label FMG2   = 4
.label FMG3   = 6
.label FMD0   = 8
.label FMD1   = 9
.label CHS    = 9
.label FMD2   = 10
.label FMD3   = 11
.label FMDLY  = 12
.label FMC    = 13
.label CFINIT = 14
.label PMD0   = 14
.label PMD1   = 15
.label PMDLY  = 16
.label PMC    = 17
.label PMG0   = 18
.label PMG1   = 20
.label PINIT  = 22
.label VWF    = 24
.label VADV   = 25
.label VSRV   = 26
.label VADSD  = 27
.label VRD    = 28

// ============================================================================
// FM / PM data-structure offsets (secondary view — F.O.M. additions + runtime
// counters)
// ============================================================================
// This is the same struct viewed under a different name-set used by the
// "offset list" machinery. F.O.M. = Fixed / Fractional Offset Modulation
// (new-for-Wizball feature). FMDnC / PMDnC at offsets 29-34 are per-channel
// runtime counter bytes extending the struct beyond VRD=28.

.label FOLDC = 4    // F.O.M. Duration Counter (new feature)
.label FBG   = 6
.label FOLOD = 6    // F.O.M. Offset Duration (new feature)
.label CFMD0 = 8
.label FOLA  = 8    // F.O.M. Offset List Address (new feature)
.label CFMD1 = 9
.label CFMD2 = 10
.label FOLB  = 10
.label CFMD3 = 11
.label FOLII = 11
.label FBD   = 12
.label FOLCI = 12
.label CPMD0 = 14
.label CPMD1 = 15
.label FINIT = 24
.label VWFG  = 26
.label VADSC = 27
.label VRC   = 28
.label FMD0C = 29
.label FMD1C = 30
.label FMD2C = 31
.label FMD3C = 32
.label PMD0C = 33
.label PMD1C = 34

// ***** "OFFSET LIST" FM DATA STRUCTURE ***
// 0&1 RESERVED - MUST BE 0
// 2&3 RESERVED - MUST BE 0
// 4&5 INITIAL SINGLE OFFSET DURATION COUNTER VALUE - USUALLY 1
// 6&7 MAXIMUM-EVER SINGLE OFFSET DURATION - 1-255
// 8&9 ADDRESS OF OFFSET LIST (LIST IS READ THROUGH END-FIRST, GOING BACKWARDS)
// 10  RESERVED - MUST BE 0
// 11  MAXIMUM OFFSET LIST INDEX 0-255
// 12  RESERVED - MUST BE 0
// 13  FM CONTROL - ANY VALUE THAT HAS BIT 3 SET (E.G. 8)

// ============================================================================
//  P.A.L. FREQUENCY TABLE (NOT TO BE USED ON N.T.S.C.) : 1.019 MHz CLOCK
// ============================================================================
//  BASE "A" VALUE FOR THIS OCTAVE IS 235. (EQUIVALENT TO N-03)

.label N00 = 279
.label N01 = 296
.label N02 = 314
.label N03 = 332
.label N04 = 352
.label N05 = 373
.label N06 = 395
.label N07 = 419
.label N08 = 444
.label N09 = 470
.label N10 = 498
.label N11 = 528
.label N12 = 559
.label N13 = 592
.label N14 = 627
.label N15 = 665
.label N16 = 704
.label N17 = 746
.label N18 = 790
.label N19 = 837
.label N20 = 887
.label N21 = 940
.label N22 = 996
.label N23 = 1055
.label N24 = 1118
.label N25 = 1184
.label N26 = 1255
.label N27 = 1330
.label N28 = 1408
.label N29 = 1492
.label N30 = 1581
.label N31 = 1675
.label N32 = 1774
.label N33 = 1880
.label N34 = 1992
.label N35 = 2110
.label N36 = 2236
.label N37 = 2369
.label N38 = 2509
.label N39 = 2659
.label N40 = 2817
.label N41 = 2984
.label N42 = 3162
.label N43 = 3350
.label N44 = 3549
.label N45 = 3760
.label N46 = 3984
.label N47 = 4220
.label N48 = 4471
.label N49 = 4737
.label N50 = 5019
.label N51 = 5317
.label N52 = 5634
.label N53 = 5969
.label N54 = 6324
.label N55 = 6700
.label N56 = 7098
.label N57 = 7520
.label N58 = 7967
.label N59 = 8441
.label N60 = 8943
.label N61 = 9475
.label N62 = 10038
.label N63 = 10635
.label N64 = 11267
.label N65 = 11937
.label N66 = 12647
.label N67 = 13399
.label N68 = 14195
.label N69 = 15040
.label N70 = 15934
.label N71 = 16881
.label N72 = 17886
.label N73 = 18949
.label N74 = 20076
.label N75 = 21270
.label N76 = 22534
.label N77 = 23875
.label N78 = 25294
.label N79 = 26798
.label N80 = 28391
.label N81 = 30080
.label N82 = 31869
.label N83 = 33764
.label N84 = 35771
.label N85 = 37898
.label N86 = 40151
.label N87 = 42540
.label N88 = 45069
.label N89 = 47749
.label N90 = 50588
.label N91 = 53596
.label N92 = 56783
.label N93 = 60160

// ============================================================================
//  N.T.S.C. FREQUENCY TABLE (NOT TO BE USED ON P.A.L.) : 1 MHz CLOCK RATE
// ============================================================================
//  BASE "A" VALUE FOR THIS OCTAVE IS 231. (EQUIVALENT TO N-03)
//
//  PORT: The NTSC table was commented out in the Ocean source. Preserved in
//  commented form for historical fidelity — if porting to NTSC hardware,
//  comment out the PAL block above and uncomment this one.
//
//  .label N00 = 274
//  .label N01 = 291
//  .label N02 = 308
//  .label N03 = 326
//  .label N04 = 346
//  .label N05 = 366
//  .label N06 = 388
//  .label N07 = 411
//  .label N08 = 435
//  .label N09 = 461
//  .label N10 = 489
//  .label N11 = 518
//  .label N12 = 548
//  .label N13 = 581
//  .label N14 = 616
//  .label N15 = 652
//  .label N16 = 691
//  .label N17 = 732
//  .label N18 = 776
//  .label N19 = 822
//  .label N20 = 871
//  .label N21 = 923
//  .label N22 = 978
//  .label N23 = 1036
//  .label N24 = 1097
//  .label N25 = 1163
//  .label N26 = 1232
//  .label N27 = 1305
//  .label N28 = 1383
//  .label N29 = 1465
//  .label N30 = 1552
//  .label N31 = 1644
//  .label N32 = 1742
//  .label N33 = 1845
//  .label N34 = 1966
//  .label N35 = 2071
//  .label N36 = 2195
//  .label N37 = 2325
//  .label N38 = 2463
//  .label N39 = 2620
//  .label N40 = 2765
//  .label N41 = 2930
//  .label N42 = 3104
//  .label N43 = 3288
//  .label N44 = 3484
//  .label N45 = 3691
//  .label N46 = 3910
//  .label N47 = 4143
//  .label N48 = 4389
//  .label N49 = 4650
//  .label N50 = 4927
//  .label N51 = 5220
//  .label N52 = 5530
//  .label N53 = 5859
//  .label N54 = 6207
//  .label N55 = 6577
//  .label N56 = 6968
//  .label N57 = 7382
//  .label N58 = 7821
//  .label N59 = 8286
//  .label N60 = 8779
//  .label N61 = 9301
//  .label N62 = 9854
//  .label N63 = 10440
//  .label N64 = 11060
//  .label N65 = 11718
//  .label N66 = 12415
//  .label N67 = 13153
//  .label N68 = 13935
//  .label N69 = 14764
//  .label N70 = 15742
//  .label N71 = 16572
//  .label N72 = 17557
//  .label N73 = 18601
//  .label N74 = 19708
//  .label N75 = 20897
//  .label N76 = 22121
//  .label N77 = 23436
//  .label N78 = 24730
//  .label N79 = 26306
//  .label N80 = 27871
//  .label N81 = 29528
//  .label N82 = 31284
//  .label N83 = 33144
//  .label N84 = 35115
//  .label N85 = 37203
//  .label N86 = 39145
//  .label N87 = 41759
//  .label N88 = 44242
//  .label N89 = 46873
//  .label N90 = 49660
//  .label N91 = 52613
//  .label N92 = 55741
//  .label N93 = 59056

.label NSil = 0    // Silence (the same at both clock speeds)

// ============================================================================
//  Screen & debug-display constants
// ============================================================================

.label SCREEN     = $0400
.label ROW0       = SCREEN+0*40
.label SPEED      = ROW0+33
.label YYY        = ROW0+37
.label ROW1       = SCREEN+1*40
.label TIMER      = ROW1+08
.label FASTER     = ROW1+39
.label ROW2       = SCREEN+2*40
.label ROW3       = SCREEN+3*40
.label ROW4       = SCREEN+4*40
.label ROW5       = SCREEN+5*40
.label ROW6       = SCREEN+6*40
.label ROW7       = SCREEN+7*40
.label ROW8       = SCREEN+8*40
.label ROW9       = SCREEN+9*40
.label ROW10      = SCREEN+10*40
.label ROW11      = SCREEN+11*40
.label ROW12      = SCREEN+12*40
.label ROW13      = SCREEN+13*40
.label ROW14      = SCREEN+14*40
.label ROW15      = SCREEN+15*40
.label ROW16      = SCREEN+16*40
.label ROW17      = SCREEN+17*40
.label ROW18      = SCREEN+18*40
.label ROW19      = SCREEN+19*40
.label ROW20      = SCREEN+20*40
.label ROW21      = SCREEN+21*40
.label ROW22      = SCREEN+22*40
.label ROW23      = SCREEN+23*40
.label ROW24      = SCREEN+24*40
.label BDR        = $D020
.label MREFCOLOUR = 1     // White, for music refreshes
.label DREFCOLOUR = 15    // Desired colour for display refreshes

// PORT: restore the Default segment so importers can emit code/data after
// this file's zero-page declarations without accidentally landing in a
// virtual segment.
.segment Default

// ============================================================================
//  DRIVER PROGRAM  ($1000)
// ============================================================================
// PORT: Ocean's `ENT` directive declared the post-transfer jump target. The
// modern equivalent is to point a BASIC SYS upstart (or the harness loader)
// at the `Start` label below.

* = $1000 "Driver program"    // was $0800 (BOZ)

Start:         sei
               jsr InitScreen
               jsr InitKeyScan
               jsr INITSOUND
               ldx #$1F
               stx $D418
//             jsr Title
               jsr FilthRaid
               jsr FastForward
               lda #Q
               bne DLoop
               ldy #10
               jsr Delay

DLoop:         jsr DREFRESH
               jsr KeyScan
               beq nk
               sta BDR
cf0:           cmp #13
               bne cf1
               inc RF
               jmp nk
cf1:           cmp #'+'
               bne cf2
               jsr IncRefsp
               jmp nk
cf2:           cmp #'-'
               bne cf3
               jsr DecRefsp
               jmp nk
cf3:           cmp #'@'
               bne cf4
               ldx #1
               stx Refsp+1
               dex
               stx Refsp
               jmp nk
cf4:           cmp #'*'
               bne cf5
               ldx #0
               stx Refsp+1
               inx
               stx Refsp
               jmp nk
cf5:           cmp #'Z'+1
               bcs nk
               cmp #'A'
               bcc nk
               asl
               tay
lowbyte:       lda DVTABL-'A'*2,y
               sta DVEC+1
highbyte:      lda DVTABL-'A'*2+1,y
               sta DVEC+2
DVEC:          jsr $DDDD     // operand patched in place by lowbyte/highbyte above
nk:            jmp DLoop

DVTABL:        .word INITSOUND, FilthRaid, BonusMusic, EndOfLevel, Title, BonusBass    // A-F
               .word GetReady, InputName, GameOver, Laboratory, EndOfBonus, FaFo, FaFo // G-M
               .word FaFo, FaFo, FaFo, FaFo, FaFo, FaFo, FaFo                          // N-S
               .word FaFo, FaFo, FaFo, FaFo, FaFo, FaFo, FaFo                          // T-Z

FilthRaid:     jsr ResetCl
               jsr StartCl
               ldy #1*7-2
               jmp TUNE
BonusMusic:    jsr ResetCl
               jsr StartCl
               ldy #2*7-2
               jmp TUNE
EndOfLevel:    jsr ResetCl
               jsr StartCl
               ldy #3*7-2
               jmp TUNE
Title:         jsr ResetCl
               jsr StartCl
               ldy #4*7-2
               jmp TUNE
BonusBass:     jsr ResetCl
               jsr StartCl
               ldy #5*7-2
               jmp TUNE
GetReady:      jsr ResetCl
               jsr StartCl
               ldy #6*7-2
               jmp TUNE
InputName:     jsr ResetCl
               jsr StartCl
               ldy #7*7-2
               jmp TUNE
GameOver:      jsr ResetCl
               jsr StartCl
               ldy #8*7-2
               jmp TUNE
Laboratory:    jsr ResetCl
               jsr StartCl
               ldy #9*7-2
               jmp TUNE
EndOfBonus:    jsr ResetCl
               jsr StartCl
               ldy #10*7-2
               jmp TUNE

// ============================================================================
//  Raster-sync, HANG loops, FaFo padding chain, REFRESH core
// ============================================================================

HANG:          inc BDR
               jmp HANG

// PORT: HANG0/HANG1/HANG2 form a classic 6502 "skip-next-two-bytes" cascade.
// The $2C byte inserted between each `ldx #imm` reinterprets the following
// `A2 imm` as the operand of a harmless BIT absolute. Jumping to HANG0 runs
// ldx #0 then falls through (via two harmless BITs) to the SEI+LDA #3;
// jumping to HANG1 starts at `ldx #1` (first BIT byte pair, mid-execution);
// jumping to HANG2 starts at `ldx #2`. All three end up in HANGLOOP with X
// set to 0, 1, or 2 respectively. The `.byte $2C` here MUST be exactly one
// byte to preserve the instruction alignment.
HANG0:         ldx #0
               .byte $2C
HANG1:         ldx #1
               .byte $2C
HANG2:         ldx #2
               sei
               lda #3
HANGLOOP:      sta BDR
               stx BDR
               jmp HANGLOOP

WAITCLOCK00:   ldx $D011
               bmi WAITCLOCK00
               bpl WAITCLOCKa
WAITCLOCK80:   ldx $D011
               bpl WAITCLOCK80
WAITCLOCKa:    cmp $D012
               bne WAITCLOCKa
//             INC BDR:JSR SOUND2:JSR FILTER;JSR SOUND0:JSR SOUND1
//             DEC BDR
WAITCLOCKb:    lda Refsp
               adc CREFSP
               sta CREFSP
               lda CREFSP+1
               pha
               adc Refsp+1
               sta CREFSP+1
               pla
               cmp CREFSP+1
               rts

// PORT: FaFo is a JSR call chain 10 levels deep (f2..f10 → UpdateCl) that
// then increments BDR, waits a raster window (WAITCLOCKb), and falls
// through to REFRESH. It's invoked as the dispatch target for keys L-Z
// (see DVTABL above) and exercises stack depth alongside a refresh tick.
FaFo:          jsr f2
f2:            jsr f3
f3:            jsr f4
f4:            jsr f5
f5:            jsr f6
f6:            jsr f7
f7:            jsr f8
f8:            jsr f9
f9:            jsr f10
f10:           jsr UpdateCl
               inc BDR
               jsr WAITCLOCKb

REFRESH:       php
               inc ClkAdd
               plp
               beq xit
               inc BDR
               jsr FILTER
               ldx #CH0VALUE
               beq R1x
               jsr MUSIC0
               jsr SOUND0
R1x:           ldx #CH1VALUE
               beq R1y
               jsr MUSIC1
               jsr SOUND1
R1y:           ldx #CH2VALUE
               beq xit
               jsr MUSIC2
               jsr SOUND2
xit:           dec BDR
               rts

// ============================================================================
//  Clock counters, BCD display, Delay, FastForward
// ============================================================================

ResetCl:       lda #'0'
               ldx #5
RCLoop:        sta CD5,x
               dex
               bpl RCLoop
StopCl:        lda #0
               .byte $2C       // skip `lda #1` — same trick as HANG0/HANG1/HANG2
StartCl:       lda #1
               sta ClkAdd
sc2:           rts

DREFRESH:      lda #32
               jsr WAITCLOCK00
               jsr REFRESH
               jsr RefScreen1
REF2:          lda #110
               jsr WAITCLOCK00
               jsr REFRESH
               jsr RefScreen2
REF3:          lda #188
               jsr WAITCLOCK00
               jsr REFRESH
               jsr RefScreen3
REF4:          lda #10
               jsr WAITCLOCK80
               jsr REFRESH
               jsr RefScreen4
               jmp UpdateCl

UpdateCl:      lda #0
               ldx #CH0VALUE
               beq u1
               ora MFL0
               ora S0+VRC
u1:            ldx #CH1VALUE
               beq u2
               ora MFL1
               ora S1+VRC
u2:            ldx #CH2VALUE
               beq ua
               ora MFL2
               ora S2+VRC
ua:            tax
               beq StopCl
               lda ClkAdd
               cmp #4
               bcc sc2
               lsr
               ldx #0
               stx ClkAdd
               adc CD0
               cmp #'9'+1
               bcc ncu0
               lda #'0'
ncu0:          sta CD0
               bcc PrintCl
               lda CD1
               adc #0
               cmp #'9'+1
               bcc ncu1
               lda #'0'
ncu1:          sta CD1
               bcc PrintCl
               lda CD2
               adc #0
               cmp #'9'+1
               bcc ncu2
               lda #'0'
ncu2:          sta CD2
               bcc PrintCl
               lda CD3
               adc #0
               cmp #'5'+1
               bcc ncu3
               lda #'0'
ncu3:          sta CD3
               bcc PrintCl
               lda CD4
               adc #0
               cmp #'9'+1
               bcc ncu4
               lda #'0'
ncu4:          sta CD4
               bcc PrintCl
               lda CD5
               adc #0
               cmp #'5'+1
               bcc ncu5
               lda #'0'
ncu5:          sta CD5
PrintCl:       ldx #1
PCL:           lda CD5,x
               sta TIMER,x
               lda CD3,x
               sta TIMER+3,x
               lda CD1,x
               sta TIMER+6,x
               dex
               bpl PCL
               lda #'-'
               sta TIMER+2
               sta TIMER+5
udc2:          rts

CD5:           .fill 1, 0
CD4:           .fill 1, 0
CD3:           .fill 1, 0
CD2:           .fill 1, 0
CD1:           .fill 1, 0
CD0:           .fill 1, 0
CG:            .fill 1, 0
ClkAdd:        .fill 1, 0
CREFSP:        .fill 2, 0
Refsp:         .fill 2, 0
// PORT: Ocean's `DFM "0123456789ABCDEF"` emits 16 ASCII bytes. We expand to
// explicit character literals so the translation doesn't depend on KickAss's
// current `.text` encoding setting (which defaults to a screen/PETSCII
// mapping, not ASCII).
xcstr:         .byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'

IncRefsp:      ldx Refsp
               beq DR2
               inx
               bne DR1
               inc Refsp+1
               bne DR1
DecRefsp:      ldx Refsp
               dex
               beq DR2
               lda #0
               sta Refsp+1
DR1:           stx Refsp
DR2:           rts

FastForward:   lda #0
               sta RF
               lda #Q
               sta FASTER
Fast1:         lda FASTER
               beq Fast2
               jsr FaFo
               dec FASTER
               jmp Fast1
Fast2:         ldx #CH0VALUE*1+CH1VALUE*2+CH2VALUE*4
               stx RF
               rts

Delay:         lda #100
               ldx #101
delayloop1:    cmp $D012
               bne delayloop1
delayloop2:    cpx $D012
               bne delayloop2
               dey
               bne delayloop1
Fz:            rts

// ============================================================================
//  Screen init + RefScreen1-4 (debug display)
// ============================================================================

InitScreen:    lda #$97
               sta $DD00
               // PORT: Galway wrote `LDX #256`. Ocean silently truncated
               // immediates to 8 bits (cf. its `DFB 400` → 144 behaviour);
               // KickAss refuses out-of-range literals so we use the
               // explicit `<256` = 0. The `is1` loop then exercises X values
               // 0, 255, 254, ..., 1 — 256 iterations covering a full page.
               ldx #<256
               ldy #15
               stx CREFSP
               stx CREFSP+1
is1:           lda #32
               sta $400,x
               sta $500,x
               sta $600,x
               sta $700,x
               tya
               sta $D800,x
               sta $D900,x
               sta $DA00,x
               sta $DB00,x
               dex
               bne is1
               // PORT: `LDX #$0002` — 16-bit literal, low byte 2.
               ldx #<$0002
               lda #$DD
is2:           sta $0000,x
               inx
               bne is2
               // PORT: `LDX #refsp` — refsp is $100 (Phase E). Use low
               // byte ($00). `^refsp` is Ocean's high-byte operator = `>`.
               ldx #<refsp
               stx Refsp
               ldy #>refsp
               sty Refsp+1
               jsr PrintCl
               lda #0
               sta BDR
               rts

RefScreen1:    lda #DREFCOLOUR
               sta BDR
               ldx #32-1
sh3:           lda IDRT,x
               sta ROW24,x
               dex
               bpl sh3
               ldx #2
               // PORT: Self-modifying code. The $A9 byte is the LDA-immediate
               // opcode; the $DF byte at label RF is its operand. Together
               // they form `LDA #$DF`. Elsewhere `INC RF` (cf. cf0 in DLoop)
               // increments the operand byte so subsequent execution loads a
               // different value — which drives the Y/N pattern drawn below.
               .byte $A9
RF:            .byte $DF
sh5:           lsr
               pha
               bcc sh6
               lda #'Y'
               .byte $2C       // skip the `lda #'N'` that follows
sh6:           lda #'N'
               sta YYY,x
               pla
               dex
               bpl sh5
               ldx #'0'
               lda Refsp+1
               beq sh10
               inx
sh10:          stx SPEED
               lda Refsp
               tay
               lsr
               lsr
               lsr
               lsr
               tax
               lda xcstr,x
               sta SPEED+1
               tya
               and #15
               tax
               lda xcstr,x
               sta SPEED+2
               ldx #ZPSIZE
sh1:           lda ZERO0,x
               sta ROW0,x
               dex
               bpl sh1
               lda #0
               sta BDR
               rts

RefScreen2:    lda #DREFCOLOUR
               sta BDR
               // PORT: `LDX #D2-D1-1` — D1 lives at $4600+128, D2 in zero
               // page at $00A4 so the signed difference underflows an 8-bit
               // immediate. Ocean truncated silently; we use `<` to make
               // the low-byte extraction explicit. This is a debug display
               // loop — any oversized X just copies extra bytes into the
               // screen row, harmless to playback.
               ldx #<(D2-D1-1)
sh2:           lda D0,x
               sta ROW3,x
               lda D1,x
               sta ROW6,x
               lda D2,x
               sta ROW9,x
               dex
               bpl sh2
               lda #0
               sta BDR
               rts

RefScreen3:    lda #DREFCOLOUR
               sta BDR
               ldx #S1-S0-1
sh4:           lda S0,x
               sta ROW15,x
               lda S1,x
               sta ROW17,x
               lda S2,x
               sta ROW19,x
               dex
               bpl sh4
               lda #0
               sta BDR
               rts

RefScreen4:    lda #DREFCOLOUR
               sta BDR
               lda FilterChannel
               sta ROW24+33
               ldx #5
sh7:           lda MFL0,x
               sta ROW24+34,x
               dex
               bpl sh7
               ldx #21
sh8:           lda CUT,x
               sta ROW21,x
               dex
               bpl sh8
               ldx #15
sh9:           lda CUTST,x
               sta ROW12,x
               dex
               bpl sh9
               lda #0
               sta BDR
               rts

// ============================================================================
//  Keyboard scan routines
//  (this whole bit is by Chrix on 21/4/87)
// ============================================================================

kswk0:         .fill 1, 0
kswk1:         .fill 1, 0
kswk2:         .fill 1, 0
ksboing:       .fill 1, 0
kslastk:       .fill 1, 0
ksdcount:      .fill 1, 0
ksscount:      .fill 1, 0

InitKeyScan:   lda #0
               sta ksboing
               rts

KeyScan:       ldx #255
               stx $DC02
               inx
               stx $DC03
               stx kswk0
               inx
               lda #127
               sta kswk2
               lda #8
               sta kswk1
ks0:           lda kswk2
               sta $DC00
               lda $DC01
               ldy #8
ks1:           asl
               bcs ks2
               stx kswk0
ks2:           inx
               dey
               bne ks1
               sec
               ror kswk2
               dec kswk1
               bne ks0
               ldy kswk0
               lda kstable,y
               cmp ksboing
               beq ks4
               sta ksboing
               ldy #ksdelay
               sty ksdcount
               ldy #ksspeed
               sty ksscount
               bne ks6
ks3:           dec ksscount
               bne ks5
               ldy #ksspeed
               sty ksscount
               bne ks6
ks4:           ldy ksdcount
               beq ks3
               dec ksdcount
ks5:           lda #0
ks6:           sta kslastk
               rts             // A=ASCII value, 0 if no key pressed (& Z=1)

.label ksdelay = 10
.label ksspeed = 1

kstable:       .byte 0
               .byte 3,81,0,32,50,0,95,49,47,94,61,0,19,59,42,92
               .byte 44,64,58,46,45,76,80,43,78,79,75,77,48,74,73,57
               .byte 86,85,72,66,56,71,89,55,88,84,70,67,54,68,82,53
               .byte 0,69,83,90,52,65,87,51,17,135,134,133,136,29,13,20

// ============================================================================
//  END OF DRIVER PROGRAM
// ============================================================================

SP:            // section marker; no bytes emitted (decorative label)

// ============================================================================
//  START OF MUSIC PROGRAM  ($4600)
// ============================================================================

* = $4600 "Music program"

// JUMPS commentary (from Galway, preserved verbatim):
//   JMP INITSOUND:JMP SOUNDTEST:JMP TUNE:JMP MUSICTEST:JMP FILTER
//   JMP SOUND0:JMP SOUND1:JMP SOUND2:JMP MUSIC0:JMP MUSIC1:JMP MUSIC2
JUMPS:

vt0:           .word retsubrut0
               .word call0
               .word goto0
               .word callt0
               .word gotot0
               .word mpoke0
               .word for0
               .word next0
               .word fload0
               .word volume0
               .word spoke0
               .word code0
               .word transp0
               .word dmpoke0
               .word dspoke0
               .word master0
               .word filter0
               .word disown0
               .word mbendoff0
               .word mbendon0
               .word freq0

vt1:           .word retsubrut1
               .word call1
               .word goto1
               .word callt1
               .word gotot1
               .word mpoke1
               .word for1
               .word next1
               .word fload1
               .word volume1
               .word spoke1
               .word code1
               .word transp1
               .word dmpoke1
               .word dspoke1
               .word HANG1         // master1 — unsupported on ch1, traps to HANG1
               .word HANG1         // filter1 — unsupported on ch1
               .word HANG1         // disown1 — unsupported on ch1
               .word mbendoff1
               .word HANG1         // mbendon1 — unsupported on ch1
               .word freq1

vt2:           .word retsubrut2
               .word call2
               .word goto2
               .word callt2
               .word HANG2         // gotot2 — unsupported on ch2, traps to HANG2
               .word mpoke2
               .word for2
               .word next2
               .word fload2
               .word volume2
               .word spoke2
               .word code2
               .word transp2
               .word dmpoke2
               .word dspoke2
               .word master2
               .word filter2
               .word disown2
               .word HANG2         // mbendoff2 — unsupported on ch2
               .word HANG2         // mbendon2 — unsupported on ch2
               .word freq2
               .word time2

ST:            // section marker

// Post-ZP workspace ($4680 region). These are live variables but couldn't fit
// in zero page; they're allocated in the $4600 region with plain `.fill` so
// the PRG reserves the bytes.

D1:            .fill 29, 0
S0:            .fill 35, 0
S1:            .fill 35, 0
IDRT:          .fill 32, 0
ST1C:          .fill DEPTHOFSTACKS, 0
ST2L:          .fill DEPTHOFSTACKS, 0
ST2H:          .fill DEPTHOFSTACKS, 0
ST2C:          .fill DEPTHOFSTACKS, 0

// DTAB: low-byte offsets for D0/D1/D2 relative to D0. Used by code below to
// compute per-channel D-region addresses.
DTAB:          .byte <(D0-D0), <(D1-D0), <(D2-D0)

// PAL frequency tables (low bytes then high bytes) indexed by note number.
// PORT: Galway commented out N90-N93 from both tables — preserved verbatim.
// PORT: line 1088 in the Ocean source has `DFL NSil` under HiFrq where one
// would expect `DFH NSil` for symmetry. NSil = 0 so the emitted byte is $00
// either way; we translate as `.byte <NSil` to mirror the original exactly.

LoFrq:         .byte <N00, <N01, <N02, <N03, <N04, <N05, <N06, <N07, <N08, <N09
               .byte <N10, <N11, <N12, <N13, <N14, <N15, <N16, <N17, <N18, <N19
               .byte <N20, <N21, <N22, <N23, <N24, <N25, <N26, <N27, <N28, <N29
               .byte <N30, <N31, <N32, <N33, <N34, <N35, <N36, <N37, <N38, <N39
               .byte <N40, <N41, <N42, <N43, <N44, <N45, <N46, <N47, <N48, <N49
               .byte <N50, <N51, <N52, <N53, <N54, <N55, <N56, <N57, <N58, <N59
               .byte <N60, <N61, <N62, <N63, <N64, <N65, <N66, <N67, <N68, <N69
               .byte <N70, <N71, <N72, <N73, <N74, <N75, <N76, <N77, <N78, <N79
               .byte <N80, <N81, <N82, <N83, <N84, <N85, <N86, <N87, <N88, <N89
//             .byte <N90, <N91, <N92, <N93
               .byte <NSil
HiFrq:         .byte >N00, >N01, >N02, >N03, >N04, >N05, >N06, >N07, >N08, >N09
               .byte >N10, >N11, >N12, >N13, >N14, >N15, >N16, >N17, >N18, >N19
               .byte >N20, >N21, >N22, >N23, >N24, >N25, >N26, >N27, >N28, >N29
               .byte >N30, >N31, >N32, >N33, >N34, >N35, >N36, >N37, >N38, >N39
               .byte >N40, >N41, >N42, >N43, >N44, >N45, >N46, >N47, >N48, >N49
               .byte >N50, >N51, >N52, >N53, >N54, >N55, >N56, >N57, >N58, >N59
               .byte >N60, >N61, >N62, >N63, >N64, >N65, >N66, >N67, >N68, >N69
               .byte >N70, >N71, >N72, >N73, >N74, >N75, >N76, >N77, >N78, >N79
               .byte >N80, >N81, >N82, >N83, >N84, >N85, >N86, >N87, >N88, >N89
//             .byte >N90, >N91, >N92, >N93
               .byte <NSil    // see PORT note above — `DFL` in source, preserved

// ============================================================================
//  INITSOUND + TUNE + duration calc + PM/FM/CF transfer routines
// ============================================================================

INITSOUND:     jsr ResetCl
               ldx #$17
ResetLoop:     lda #8
               sta $D400,x
               lda #0
               sta $D400,x
               dex
               bpl ResetLoop
               sta S0+VRC
               sta S1+VRC
               sta S2+VRC
               sta CUT+FMC
               sta MFL0
               sta MFL1
               sta MFL2
               stx FilterChannel
               rts

// PORT: Galway's label `get.tune.data` contains a period, which KickAss
// reserves for directive prefixes. Renamed to `get_tune_data`.
TUNE:          lda TUNETABLE+1,y
               sta CalcDurations+1
               ldx #2
               stx channel
               ldx #4
               stx offset
               dey
get_tune_data: ldx offset
               lda TUNETABLE,y
               sta PC0,x
               lda TUNETABLE+1,y
               sta PC0+1,x
               sty OUT
               ldx channel
               ldy DTAB,x
               lda #0
               sta TR0,x
               sta D0+FMC,y
               sta D0+PMC,y
               lda #DEPTHOFSTACKS-1
               sta SP0,x
               lda #1
               sta CLOCK0,x
               sta MFL0,x
               ldy OUT
               dey
               dey
               dec offset
               dec offset
               dec channel
               bpl get_tune_data
NewDurations:  clc
               lda #0
// CalcDurations is self-modified: its `adc #$DD` immediate gets patched by
// the Time command handler (see `time2` at the end of MC2) to the duration
// stride for the current tune.
CalcDurations: adc #$DD
               sta IDRT,x
               inx
               cpx #32
               bcc CalcDurations
               rts

transferpm0:   ldx S0+PINIT
               ldy S0+PINIT+1
transferpm0a:  stx S0PCURR
               sty S0PCURR+1
               lda S0+CPMD0
               sta S0+PMD0C
               lda S0+CPMD1
               sta S0+PMD1C
               rts
transferpm1:   ldx S1+PINIT
               ldy S1+PINIT+1
transferpm1a:  stx S1PCURR
               sty S1PCURR+1
               lda S1+CPMD0
               sta S1+PMD0C
               lda S1+CPMD1
               sta S1+PMD1C
               rts
transferpm2:   ldx S2+PINIT
               ldy S2+PINIT+1
transferpm2a:  stx S2PCURR
               sty S2PCURR+1
               lda S2+CPMD0
               sta S2+PMD0C
               lda S2+CPMD1
               sta S2+PMD1C
               rts

transfercf:    ldx CUT+14
               ldy CUT+15
               stx CUT+16
               sty CUT+17
transfercfa:   lda CUT+8
               sta CUT+18
               lda CUT+9
               sta CUT+19
               lda CUT+10
               sta CUT+20
               lda CUT+11
               sta CUT+21
               rts

transferf0:    ldx S0+FINIT
               ldy S0+FINIT+1
               stx S0FCURR
               sty S0FCURR+1
transferf0a:   lda S0+CFMD3
               sta S0+FMD3C
               lda S0+CFMD2
               sta S0+FMD2C
               lda S0+CFMD1
               sta S0+FMD1C
               lda S0+CFMD0
               sta S0+FMD0C
               rts
transferf1:    ldx S1+FINIT
               ldy S1+FINIT+1
               stx S1FCURR
               sty S1FCURR+1
transferf1a:   lda S1+CFMD3
               sta S1+FMD3C
               lda S1+CFMD2
               sta S1+FMD2C
               lda S1+CFMD1
               sta S1+FMD1C
               lda S1+CFMD0
               sta S1+FMD0C
               rts
transferf2:    ldx S2+FINIT
               ldy S2+FINIT+1
               stx S2FCURR
               sty S2FCURR+1
transferf2a:   lda S2+CFMD3
               sta S2+FMD3C
               lda S2+CFMD2
               sta S2+FMD2C
               lda S2+CFMD1
               sta S2+FMD1C
               lda S2+CFMD0
               sta S2+FMD0C
               rts

// ============================================================================
//  MUSIC CONTROL — MC0 (channel 0 command dispatcher)
// ============================================================================
// PORT: Many labels in MC0/MC1/MC2 and the MUSIC0/1/2 blocks contain periods
// (e.g. `read.byte0`, `in.du.re.0`, `not.control0`, `got.note0`). KickAss
// reserves `.` for directives, so we map `.` → `_` across all such labels.
// We preserve Galway's per-channel naming asymmetries (e.g. `not_control0`
// on ch0 vs `not_ctrl1`/`not_ctrl2` on ch1/ch2; `in_du_re_0` with trailing
// underscore on ch0 vs `in_du_re1`/`in_du_re2` on ch1/ch2) verbatim — these
// are Galway's original identifiers, not regularisations.

MC0:
callt0:        sta TR0
               iny
               lda #4
               .byte $2C       // skip `lda #3`
call0:         lda #3
               ldx SP0
               clc
               adc PC0
               sta ST0L,x
               lda #0
               adc PC0+1
               sta ST0H,x
               dec SP0
               lda (PC0),y
               tax
               iny
               lda (PC0),y
               stx PC0
               sta PC0+1
               jmp read_byte0
// PORT: `LDA ^add3c0-1` (Ocean): the `^` prefix without `#` is Ocean's
// immediate high-byte operator (same shorthand used at `LDY ^refsp` in
// InitScreen). KickAss requires explicit `#>...`.
code0:         lda #>(add3c0-1)
               pha
               lda #<(add3c0-1)
               pha
               lda (PC0),y
               sta IN
               iny
               lda (PC0),y
               sta IN+1
               jmp (IN)
dmpoke0:       tax
               iny
               lda (PC0),y
               sta D0,x
               iny
               lda (PC0),y
               sta D0+1,x
               lda #4
               jmp addc0
dspoke0:       tax
               iny
               lda (PC0),y
               sta S0,x
               iny
               lda (PC0),y
               sta S0+1,x
               lda #4
               jmp addc0
filter0:       sta filt0loop+1
               iny
               lda (PC0),y
               sta filt0loop+2
               ldx #15
filt0loop:     lda $DDDD,x     // operand patched in place above
               sta CUTST,x
               dex
               bpl filt0loop
               jmp add3c0
fload0:        tax
               iny
               lda (PC0),y
               sta fload0loop+1
               iny
               lda (PC0),y
               sta fload0loop+2
fload0loop:    lda $DDDD,x     // operand patched in place above
               sta D0,x
               dex
               bpl fload0loop
               lda #4
               jmp addc0
for0:          ldx SP0
               lda #2
               clc
               adc PC0
               sta ST0L,x
               lda #0
               adc PC0+1
               sta ST0H,x
               lda (PC0),y
               sta ST0C,x
               dec SP0
               lda #2
               jmp addc0
freq0:         sta frqpoke0+1
               iny
               lda (PC0),y
               sta frqpoke0+2
               ldx #13
frqpoke0:      lda $DDDD,x     // operand patched in place above
               sta D0,x
               dex
               bpl frqpoke0
               jmp add3c0
gotot0:        sta TR0
               iny
goto0:         lda (PC0),y
               tax
               iny
               lda (PC0),y
               stx PC0
               sta PC0+1
               jmp read_byte0
disown0:       dey
               sty CUT+FMC
               ldx #3
               ldy #%11110000
               .byte $2C       // skip `ldy #%11110001` for master0a/b fall-through
master0a:      ldy #%11110001
               sty $D417
master0b:      stx FilterChannel
               lda #$1F
               sta $D418
               lda #1
               jmp addc0
//             own0          LDX #0:BNE master0b
master0:       ldx #0
               beq master0a
mbendon0:      lda #7
               .byte $2C       // skip `lda #5` for mbendoff0 fall-through
mbendoff0:     lda #5
               sta D0+FMC
               tya
               jmp addc0
mpoke0:        tax
               iny
               lda (PC0),y
               sta D0,x
               jmp add3c0
next0:         ldx SP0
               dec ST0C+1,x
               beq n0a
               ldy ST0L+1,x
               lda ST0H+1,x
               sty PC0
               sta PC0+1
               jmp read_byte0
n0a:           inc SP0
               tya
               jmp addc0
retsubrut0:    ldy SP0
               cpy #DEPTHOFSTACKS-1
               beq rc0
               inc SP0
               ldx ST0L+1,y
               lda ST0H+1,y
               stx PC0
               sta PC0+1
               jmp read_byte0
rc0:           dec MFL0
               rts
spoke0:        tax
               iny
               lda (PC0),y
               sta S0,x
               jmp add3c0
transp0:       sta TR0
               lda #2
               jmp addc0
volume0:       sta IN
               iny
               lda (PC0),y
               sta IN+1
               ldy #4
vo0:           lda (IN),y
               sta D0+VWF,y
               dey
               bpl vo0
               jmp add3c0

// ============================================================================
//  MUSIC CONTROL — MC1 (channel 1 command dispatcher)
// ============================================================================
// PORT: MC1 omits filter/disown/master/own handlers (ch1 doesn't participate
// in filter/master logic) and reverses `mbendoff`/`mbendon` order relative
// to MC0. The vt1 dispatch table routes those commands to HANG1. Also,
// `transp1`/`spoke1` are reordered vs MC0's `spoke0`/`transp0`. Preserved
// verbatim.

MC1:
callt1:        sta TR1
               iny
               lda #4
               .byte $2C       // skip `lda #3`
call1:         lda #3
               ldx SP1
               clc
               adc PC1
               sta ST1L,x
               lda #0
               adc PC1+1
               sta ST1H,x
               dec SP1
               lda (PC1),y
               tax
               iny
               lda (PC1),y
               stx PC1
               sta PC1+1
               jmp read_byte1
code1:         lda #>(add3c1-1)
               pha
               lda #<(add3c1-1)
               pha
               lda (PC1),y
               sta IN
               iny
               lda (PC1),y
               sta IN+1
               jmp (IN)
dmpoke1:       tax
               iny
               lda (PC1),y
               sta D1,x
               iny
               lda (PC1),y
               sta D1+1,x
               lda #4
               jmp addc1
dspoke1:       tax
               iny
               lda (PC1),y
               sta S1,x
               iny
               lda (PC1),y
               sta S1+1,x
               lda #4
               jmp addc1
//             filter1       LDA (PC1),Y:STA filt1loop+1:INY:LDA (PC1),Y:STA filt1loop+2
//                           LDX #15
//             filt1loop     LDA $DDDD,X:STA CUTST,X:DEX:BPL filt1loop:JMP add3c1
fload1:        tax
               iny
               lda (PC1),y
               sta fload1loop+1
               iny
               lda (PC1),y
               sta fload1loop+2
fload1loop:    lda $DDDD,x     // operand patched in place above
               sta D1,x
               dex
               bpl fload1loop
               lda #4
               jmp addc1
for1:          ldx SP1
               lda #2
               clc
               adc PC1
               sta ST1L,x
               lda #0
               adc PC1+1
               sta ST1H,x
               lda (PC1),y
               sta ST1C,x
               dec SP1
               lda #2
               jmp addc1
freq1:         sta frqpoke1+1
               iny
               lda (PC1),y
               sta frqpoke1+2
               ldx #13
frqpoke1:      lda $DDDD,x     // operand patched in place above
               sta D1,x
               dex
               bpl frqpoke1
               jmp add3c1
gotot1:        sta TR1
               iny
goto1:         lda (PC1),y
               tax
               iny
               lda (PC1),y
               stx PC1
               sta PC1+1
               jmp read_byte1
//             disown1       DEY:STY CUT+FMC:LDX #3:LDY #%11110000:DFB $2C
//             master1a      LDY #%11110010:STY $D417
//             master1b      STX FilterChannel:LDA #1:JMP addc1
//             own1          LDX #1:BNE master1b
//             master1       LDX #1:BNE master1a
mbendoff1:     lda #5
               .byte $2C       // skip `lda #7` for mbendon1 fall-through
mbendon1:      lda #7
               sta D1+FMC
               tya
               jmp addc1
mpoke1:        tax
               iny
               lda (PC1),y
               sta D1,x
               jmp add3c1
next1:         ldx SP1
               dec ST1C+1,x
               beq n1a
               ldy ST1L+1,x
               lda ST1H+1,x
               sty PC1
               sta PC1+1
               jmp read_byte1
n1a:           inc SP1
               tya
               jmp addc1
retsubrut1:    ldy SP1
               cpy #DEPTHOFSTACKS-1
               beq rc1
               inc SP1
               ldx ST1L+1,y
               lda ST1H+1,y
               stx PC1
               sta PC1+1
               jmp read_byte1
rc1:           dec MFL1
               rts
transp1:       sta TR1
               lda #2
               jmp addc1
spoke1:        tax
               iny
               lda (PC1),y
               sta S1,x
               jmp add3c1
volume1:       sta IN
               iny
               lda (PC1),y
               sta IN+1
               ldy #4
vo1:           lda (IN),y
               sta D1+VWF,y
               dey
               bpl vo1
               jmp add3c1

// ============================================================================
//  MUSIC CONTROL — MC2 (channel 2 command dispatcher)
// ============================================================================
// PORT: MC2 omits `gotot2`, `mbendoff2`/`mbendon2` (routed to HANG2 via vt2),
// uses a different `master2` body (lda #$1F/sta $D418/ldx #2/bne master2a),
// and uniquely includes `time2` — invoked by the `Time` stream command to
// patch the `CalcDurations` self-modifying ADC operand.

MC2:
callt2:        sta TR2
               iny
               lda #4
               .byte $2C       // skip `lda #3`
call2:         lda #3
               ldx SP2
               clc
               adc PC2
               sta ST2L,x
               lda #0
               adc PC2+1
               sta ST2H,x
               dec SP2
               lda (PC2),y
               tax
               iny
               lda (PC2),y
               stx PC2
               sta PC2+1
               jmp read_byte2
code2:         lda #>(add3c2-1)
               pha
               lda #<(add3c2-1)
               pha
               lda (PC2),y
               sta IN
               iny
               lda (PC2),y
               sta IN+1
               jmp (IN)
dmpoke2:       tax
               iny
               lda (PC2),y
               sta D2,x
               iny
               lda (PC2),y
               sta D2+1,x
               lda #4
               jmp addc2
dspoke2:       tax
               iny
               lda (PC2),y
               sta S2,x
               iny
               lda (PC2),y
               sta S2+1,x
               lda #4
               jmp addc2
filter2:       sta filt2loop+1
               iny
               lda (PC2),y
               sta filt2loop+2
               ldx #15
filt2loop:     lda $DDDD,x     // operand patched in place above
               sta CUTST,x
               dex
               bpl filt2loop
               jmp add3c2
fload2:        tax
               iny
               lda (PC2),y
               sta fload2loop+1
               iny
               lda (PC2),y
               sta fload2loop+2
fload2loop:    lda $DDDD,x     // operand patched in place above
               sta D2,x
               dex
               bpl fload2loop
               lda #4
               jmp addc2
for2:          ldx SP2
               lda #2
               clc
               adc PC2
               sta ST2L,x
               lda #0
               adc PC2+1
               sta ST2H,x
               lda (PC2),y
               sta ST2C,x
               dec SP2
               lda #2
               jmp addc2
freq2:         sta frqpoke2+1
               iny
               lda (PC2),y
               sta frqpoke2+2
               ldx #13
frqpoke2:      lda $DDDD,x     // operand patched in place above
               sta D2,x
               dex
               bpl frqpoke2
               jmp add3c2
//             gotot2        LDA (PC2),Y:STA TR2:INY
goto2:         lda (PC2),y
               tax
               iny
               lda (PC2),y
               stx PC2
               sta PC2+1
               jmp read_byte2
disown2:       dey
               sty CUT+FMC
               ldx #3
               ldy #%11110000
               .byte $2C       // skip `ldy #%11110100` for master2a/b fall-through
master2a:      ldy #%11110100
               sty $D417
master2b:      stx FilterChannel
               lda #1
               jmp addc2
//             own2          LDX #2:BNE master2b
master2:       lda #$1F
               sta $D418
               ldx #2
               bne master2a
//             mbendoff2     LDA #5:DFB $2C
//             mbendon2      LDA #7:STA D2+FMC:TYA:JMP addc2
mpoke2:        tax
               iny
               lda (PC2),y
               sta D2,x
               jmp add3c2
next2:         ldx SP2
               dec ST2C+1,x
               beq n2a
               ldy ST2L+1,x
               lda ST2H+1,x
               sty PC2
               sta PC2+1
               jmp read_byte2
n2a:           inc SP2
               tya
               jmp addc2
retsubrut2:    ldy SP2
               cpy #DEPTHOFSTACKS-1
               beq rc2
               inc SP2
               ldx ST2L+1,y
               lda ST2H+1,y
               stx PC2
               sta PC2+1
               jmp read_byte2
rc2:           dec MFL2
               rts
spoke2:        tax
               iny
               lda (PC2),y
               sta S2,x
               jmp add3c2
// PORT: `time2` is the runtime handler for the music stream's `Time` command.
// It patches `CalcDurations`'s immediate operand (a self-modifying ADC) to
// the new duration stride, then rebuilds the IDRT table.
time2:         sta CalcDurations+1
               ldx #0
               jsr NewDurations
               lda #2
               jmp addc2
transp2:       sta TR2
               lda #2
               jmp addc2
volume2:       sta IN
               iny
               lda (PC2),y
               sta IN+1
               ldy #4
vo2:           lda (IN),y
               sta D2+VWF,y
               dey
               bpl vo2
               jmp add3c2

// ============================================================================
//  MUSIC & SOUND REFRESH — FILTER sweep
// ============================================================================

FILTER:        lda CUT+FMC
               beq cxit
               ldx CUT+16
               ldy CUT+17
               clc
               lda CUT+FMDLY
               beq cms0a
               dec CUT+FMDLY
               lda CUT+FMC
               and #2
               bne cms3a
cxit:          rts
cms0:          clc
cms0a:         lda CUT+18
               beq cms1
               dec CUT+18
               txa
               adc CUT+FMG0
               tax
               tya
               adc CUT+FMG0+1
               jmp stcTAY
cms1:          lda CUT+19
               beq cms2
               dec CUT+19
               txa
               adc CUT+FMG1
               tax
               tya
               adc CUT+FMG1+1
               jmp stcTAY
cms2:          lda CUT+20
               beq cms3
               dec CUT+20
               txa
               adc CUT+FMG2
               tax
               tya
               adc CUT+FMG2+1
               jmp stcTAY
cms3:          lda CUT+21
               beq cmrep
               dec CUT+21
cms3a:         txa
               adc CUT+FMG3
               tax
               tya
               adc CUT+FMG3+1
stcTAY:        tay
stc:           stx CUT+16
               sty CUT+17
pokecutofffrq: txa
               and #7
               sta $D415
               tya
               stx FilterByte
               lsr
               ror FilterByte
               lsr
               ror FilterByte
               lsr
               lda FilterByte
               ror
               sta $D416
               rts
cmrep:         lda CUT+FMC
               and #%10000001
               beq stc
               bpl nocfcopy
               jsr transfercf
               jmp cms0
nocfcopy:      jsr transfercfa
               jmp cms0

StartFilter:   ldx #7
SFL:           lda CUTST+0,x
               sta CUT+0,x
               lda CUTST+8,x
               sta CUT+8,x
               dex
               bpl SFL
               jsr transfercf
               jmp pokecutofffrq

// ============================================================================
//  MUSIC0 / NOTE0 (channel 0 music stream interpreter)
// ============================================================================

MUSIC0:        lda MFL0
               beq mx0
               dec CLOCK0
               beq read_byte0
mx0:           rts
crossedover0a: inc PC0+1
               bne read_byte0
add3c0:        lda #3
// PORT: Galway's dispatch `adc #vtN-COM-1` leaves carry=1 when it hands
// control to a handler; without a `clc` here the advance is off by one and
// the stream dispatcher silently skips the next opcode (e.g. `master2`
// after `fload2`). Ocean's assembler supported an `ADD` pseudo-instruction
// that expanded to `CLC;ADC` (documented in Martin's 2026-04-20 update to
// ocean_assembler_directives.txt). The source shared here was transcribed
// to plain `ADC`, so Galway's implicit CLC was lost — this explicit `clc`
// restores it. Same fix applied at addc1/addc2/addn0/addn1/addn2 and at
// the `adc PCn` inside call0/1/2 and for0/1/2.
addc0:         clc
               adc PC0
               sta PC0
               bcs crossedover0a
read_byte0:    ldy #0
               lda (PC0),y
               cmp #COM
               bcc not_control0
               iny
               adc #vt0-COM-1
               sta v0+1
               lda (PC0),y
v0:            jmp (vt0)          // operand patched above for dispatch
js0:           jmp st0
not_control0:  sta Z8
               cmp #R
               bcc in_du_re_0
               sbc #R
in_du_re_0:    cmp #Rest
               beq js0
               adc TR0
got_note0:     tax
               lda RF
               and #1
               beq js0
NOTE0:
//             LDA #8:STA $D404
               lda FilterChannel
               bne nf0
               stx IN
               jsr StartFilter
               ldx IN
nf0:           ldy HiFrq,x
               lda LoFrq,x
               sta S0+FINIT
               sty S0+FINIT+1
               sta $D400
               sty $D401
               ldx D0+PINIT
               ldy D0+PINIT+1
               stx $D402
               sty $D403
               lda D0+VADV
               sta $D405
               lda D0+VSRV
               sta $D406
               lda D0+VWF
               sta S0+VWFG
               and #%11110111
               sta $D404

               jsr transferpm0a      // LDX #PINIT+1
dll0:          // LDA D0,X:STA S0,X:DEX:BPL dll0:LDA S0+FMC  (commented out, label preserved)

dlpw0:         lda D0+PMC
               sta S0+PMC
               beq dlfrq0
               stx S0+PINIT
               sty S0+PINIT+1
               stx S0PCURR
               sty S0PCURR+1
               lda D0+PMG1+1
               sta S0+PMG1+1
               lda D0+PMG1
               sta S0+PMG1
               lda D0+PMG0+1
               sta S0+PMG0+1
               lda D0+PMG0
               sta S0+PMG0
               lda D0+PMDLY
               sta S0+PMDLY
               ldx D0+PMD0
               ldy D0+PMD1
               stx S0+CPMD0
               stx S0+PMD0C
               sty S0+PMD1C
               sty S0+CPMD1

dlfrq0:        lda D0+FMC
               sta S0+FMC
               beq dldur0
               ldx D0+12
               stx S0+12
               ldx D0+11
               stx S0+11
               ldx D0+10
               stx S0+10
               ldx D0+9
               stx S0+9
               ldx D0+8
               stx S0+8
               ldx D0+7
               stx S0+7
               ldx D0+6
               stx S0+6
               ldx D0+5
               stx S0+5
               ldx D0+4
               stx S0+4
               ldx D0+3
               stx S0+3
               ldx D0+2
               stx S0+2
               ldx D0+1
               stx S0+1
               ldx D0+0
               stx S0+0

               and #8
               beq no_of_li_mo0
               lda Z8
               cmp #R
               bcc in_du_re0a
               sbc #R-1
in_du_re0a:    adc TR0
               sta S0+FOLB
               bne dldur0
no_of_li_mo0:  jsr transferf0
dldur0:        ldx D0+VADSD
               ldy D0+VRD
               stx S0+VADSC
               sty S0+VRC
st0:           ldy #1
               lda (PC0),y
               ldx Z8
               cpx #R
               bcs di_du_re0
               tax
               lda IDRT-1,x
di_du_re0:     sta CLOCK0
               lda #2
addn0:         clc
               adc PC0
               sta PC0
               bcs crossedover0b
               rts
crossedover0b: inc PC0+1
               rts

// ============================================================================
//  MUSIC1 / NOTE1 (channel 1 music stream interpreter)
// ============================================================================

MUSIC1:        lda MFL1
               beq mx1
               dec CLOCK1
               beq read_byte1
mx1:           rts
crossedover1a: inc PC1+1
               bne read_byte1
add3c1:        lda #3
addc1:         clc
               adc PC1
               sta PC1
               bcs crossedover1a
read_byte1:    ldy #0
               lda (PC1),y
               cmp #COM
               bcc not_ctrl1
               iny
               adc #vt1-COM-1
               sta v1+1
               lda (PC1),y
v1:            jmp (vt1)        // operand patched above for dispatch
js1:           jmp st1
not_ctrl1:     sta Z8
               cmp #R
               bcc in_du_re1
               sbc #R
in_du_re1:     cmp #Rest
               beq js1
               adc TR1
got_note1:     tax
               lda RF
               and #2
               beq js1
NOTE1:
               lda #8
               sta $D40B
nf1:           ldy HiFrq,x
               lda LoFrq,x
               sta S1+FINIT
               sty S1+FINIT+1
               sta $D407
               sty $D408
               ldx D1+PINIT
               ldy D1+PINIT+1
               stx $D409
               sty $D40A
               lda D1+VADV
               sta $D40C
               lda D1+VSRV
               sta $D40D
               lda D1+VWF
               sta S1+VWFG
               and #%11110111
               sta $D40B

               jsr transferpm1a      // LDX #PINIT+1
dll1:          // LDA D1,X:STA S1,X:DEX:BPL dll1:LDA S1+FMC  (commented out, label preserved)

dlpw1:         lda D1+PMC
               sta S1+PMC
               beq dlfrq1
               stx S1+PINIT
               sty S1+PINIT+1
               stx S1PCURR
               sty S1PCURR+1
               lda D1+PMG1+1
               sta S1+PMG1+1
               // PORT: MUSIC0 used `LDA` here; MUSIC1/MUSIC2 use `LDX`.
               // Preserved as-is (functionally equivalent through STX).
               ldx D1+PMG1
               stx S1+PMG1
               lda D1+PMG0+1
               sta S1+PMG0+1
               lda D1+PMG0
               sta S1+PMG0
               lda D1+PMDLY
               sta S1+PMDLY
               ldx D1+PMD0
               ldy D1+PMD1
               stx S1+CPMD0
               stx S1+PMD0C
               sty S1+CPMD1
               sty S1+PMD1C

dlfrq1:        lda D1+FMC
               sta S1+FMC
               beq dldur1
               ldx D1+12
               stx S1+12
               ldx D1+11
               stx S1+11
               ldx D1+10
               stx S1+10
               ldx D1+9
               stx S1+9
               ldx D1+8
               stx S1+8
               ldx D1+7
               stx S1+7
               ldx D1+6
               stx S1+6
               ldx D1+5
               stx S1+5
               ldx D1+4
               stx S1+4
               ldx D1+3
               stx S1+3
               ldx D1+2
               stx S1+2
               ldx D1+1
               stx S1+1
               ldx D1+0
               stx S1+0

               and #8
               beq no_of_li_mo1
               lda Z8
               cmp #R
               bcc in_du_re1a
               sbc #R-1
in_du_re1a:    adc TR1
               sta S1+FOLB
               bne dldur1
no_of_li_mo1:  jsr transferf1
dldur1:        ldx D1+VADSD
               ldy D1+VRD
               stx S1+VADSC
               sty S1+VRC
st1:           ldy #1
               lda (PC1),y
               ldx Z8
               cpx #R
               bcs di_du_re1
               tax
               lda IDRT-1,x
di_du_re1:     sta CLOCK1
               lda #2
addn1:         clc
               adc PC1
               sta PC1
               bcs crossedover1b
               rts
crossedover1b: inc PC1+1
               rts

// ============================================================================
//  MUSIC2 / NOTE2 (channel 2 music stream interpreter)
// ============================================================================

MUSIC2:        lda MFL2
               beq mx2
               dec CLOCK2
               beq read_byte2
mx2:           rts
crossedover2a: inc PC2+1
               bne read_byte2
add3c2:        lda #3
addc2:         clc
               adc PC2
               sta PC2
               bcs crossedover2a
read_byte2:    ldy #0
               lda (PC2),y
               cmp #COM
               bcc not_ctrl2
               iny
               adc #vt2-COM-1
               sta v2+1
               lda (PC2),y
v2:            jmp (vt2)        // operand patched above for dispatch
js2:           jmp st2
not_ctrl2:     sta Z8
               cmp #R
               bcc in_du_re2
               sbc #R
in_du_re2:     cmp #Rest
               beq js2
               adc TR2
got_note2:     tax
               lda RF
               and #4
               beq js2
NOTE2:
               lda #8
               sta $D412
ntb2:          lda FilterChannel
               cmp #2
               bne nf2
               stx IN
               jsr StartFilter
               ldx IN
nf2:           ldy HiFrq,x
               lda LoFrq,x
               sta S2+FINIT
               sty S2+FINIT+1
               sta $D40E
               sty $D40F
               ldx D2+PINIT
               ldy D2+PINIT+1
               stx $D410
               sty $D411
               lda D2+VADV
               sta $D413
               lda D2+VSRV
               sta $D414
               lda D2+VWF
               sta S2+VWFG
               and #%11110111
               sta $D412

               jsr transferpm2a      // LDX #PINIT+1
dll2:          // LDA D2,X:STA S2,X:DEX:BPL dll2:LDA S2+FMC  (commented out, label preserved)

dlpw2:         lda D2+PMC
               sta S2+PMC
               beq dlfrq2
               stx S2+PINIT
               sty S2+PINIT+1
               stx S2PCURR
               sty S2PCURR+1
               lda D2+PMG1+1
               sta S2+PMG1+1
               lda D2+PMG1
               sta S2+PMG1
               lda D2+PMG0+1
               sta S2+PMG0+1
               lda D2+PMG0
               sta S2+PMG0
               lda D2+PMDLY
               sta S2+PMDLY
               ldx D2+PMD0
               ldy D2+PMD1
               stx S2+CPMD0
               stx S2+PMD0C
               sty S2+CPMD1
               sty S2+PMD1C

dlfrq2:        lda D2+FMC
               sta S2+FMC
               beq dldur2
               ldx D2+12
               stx S2+12
               ldx D2+11
               stx S2+11
               ldx D2+10
               stx S2+10
               ldx D2+9
               stx S2+9
               ldx D2+8
               stx S2+8
               ldx D2+7
               stx S2+7
               ldx D2+6
               stx S2+6
               ldx D2+5
               stx S2+5
               ldx D2+4
               stx S2+4
               ldx D2+3
               stx S2+3
               ldx D2+2
               stx S2+2
               ldx D2+1
               stx S2+1
               ldx D2+0
               stx S2+0

               and #8
               beq no_of_li_mo2
               lda Z8
               cmp #R
               bcc in_du_re2a
               sbc #R-1
in_du_re2a:    adc TR2
               sta S2+FOLB
               bne dldur2
no_of_li_mo2:  jsr transferf2
dldur2:        ldx D2+VADSD
               ldy D2+VRD
               stx S2+VADSC
               sty S2+VRC
st2:           ldy #1
               lda (PC2),y
               ldx Z8
               cpx #R
               bcs di_du_re2
               tax
               lda IDRT-1,x
di_du_re2:     sta CLOCK2
               lda #2
addn2:         clc
               adc PC2
               sta PC2
               bcs crossedover2b
               rts
// PORT: unlike `crossedover0b`/`crossedover1b`, `crossedover2b` has NO
// immediately-following `rts` — it falls through to `nosound0` (the first
// label of the SOUND0 block below), whose `rts` serves both routines.
crossedover2b: inc PC2+1

// ============================================================================
//  SOUND0 (channel 0 voice refresh — ADSR/PM/FM tick)
// ============================================================================

nosound0:      rts

SOUND0:        ldx S0+VRC
               beq nosound0
               lda S0+VWFG
               and #8
               beq adsr0
               lda CLOCK0
               cmp S0+VADSC
               bcs PM0
               lda #0
               sta S0+VADSC
               lda S0+VWFG
               and #%11110110
               sta S0+VWFG
               bne trigrel0
adsr0:         lda S0+VADSC
               bne ad0
               ldy S0+VRC
               iny
               beq PM0
               dec S0+VRC
               bne PM0
               ldx #6
cc0:           sta $D400,x
               dex
               bpl cc0
CheckFilter:   cmp FilterChannel
               bne nosound0
               inx
               stx CUT+FMC
               rts
ad0:           ldy S0+VADSC
               iny
               beq PM0
               dec S0+VADSC
               bne PM0
               lda S0+VWFG
               and #246
trigrel0:      sta $D404
PM0:           lda S0+PMC
               beq FM0
               lda S0+PMDLY
               beq pmdel0
               dec S0+PMDLY
               jmp FM0
pmdel0:        clc
               ldx S0PCURR
               ldy S0PCURR+1
pms00:         lda S0+PMD0C
               beq pms10
               dec S0+PMD0C
               txa
               adc S0+PMG0
               tax
               tya
               adc S0+PMG0+1
               tay
               jmp stpm0
pms10:         lda S0+PMD1C
               beq pmrep0
               dec S0+PMD1C
               txa
               adc S0+PMG1
               tax
               tya
               adc S0+PMG1+1
               tay
               jmp stpm0
pmrep0:        lda S0+PMC
               and #$81
               beq stpm0
               bpl nopmcopy0
               jsr transferpm0
               jmp pmdel0
nopmcopy0:     jsr transferpm0a
               jmp pmdel0
stpm0:         stx S0PCURR
               sty S0PCURR+1
               stx $D402
               sty $D403
FM0:           lda S0+FMC
               beq xit0
               and #8
               bne olm0              // ]
               ldx S0FCURR
               ldy S0FCURR+1
               clc
               lda S0+FMDLY
               // PORT: `BEQ fcs10+1` branches into the middle of `fcs10`,
               // skipping only the `clc` that starts that block. Preserved.
               beq fcs10+1
               dec S0+FMDLY
               lda S0+FMC
               and #2
               bne fcs40l1
xit0:          rts
olm0:          dec S0+FOLDC
               bne xit0
               ldy S0+FOLOD
               sty S0+FOLDC
               ldy S0+FOLCI          // ]
               bpl no0
               ldy S0+FOLII
no0:           ldx S0+FOLA
               stx IN
               ldx S0+FOLA+1
               stx IN+1
               lda S0+FOLB
               adc (IN),y
               dey
               sty S0+FOLCI
               tay
POKEFRQ0:      ldx LoFrq,y
               lda HiFrq,y
               stx $D400
               sta $D401
               rts
fcs10:         clc
               lda S0+FMD0C
               beq fcs20
               dec S0+FMD0C
               txa
               adc S0+FMG0
               tax
               tya
               adc S0+FMG0+1
               jmp stf0TAY
fcs20:         lda S0+FMD1C
               beq fcs30
               dec S0+FMD1C
               txa
               adc S0+FMG1
               tax
               tya
               adc S0+FMG1+1
               jmp stf0TAY
fcs30:         lda S0+FMD2C
               beq fcs40
               dec S0+FMD2C
               txa
               adc S0+FMG2
               tax
               tya
               adc S0+FMG2+1
               jmp stf0TAY
fcs40:         lda S0+FMD3C
               beq fcrep0
               dec S0+FMD3C
fcs40l1:       txa
               adc S0+FMG3
               tax
               tya
               adc S0+FMG3+1
stf0TAY:       tay
stf0:          stx $D400
               sty $D401
               stx S0FCURR
               sty S0FCURR+1
nosound1:      rts
fcrep0:        lda S0+FMC
               and #$81
               beq stf0
               bpl nofrqcopy0
               jsr transferf0
               jmp fcs10
nofrqcopy0:    jsr transferf0a
               jmp fcs10

// ============================================================================
//  SOUND1 (channel 1 voice refresh)
// ============================================================================

SOUND1:        ldx S1+VRC
               beq nosound1
               lda S1+VWFG
               and #8
               beq adsr1
               lda CLOCK1
               cmp S1+VADSC
               bcs PM1
               lda #0
               sta S1+VADSC
               lda S1+VWFG
               and #%11110110
               sta S1+VWFG
               bne trigrel1
adsr1:         lda S1+VADSC
               bne ad1
               ldy S1+VRC
               iny
               beq PM1
               dec S1+VRC
               bne PM1
               ldx #6
cc1:           sta $D407,x
               dex
               bpl cc1
               rts
ad1:           ldy S1+VADSC
               iny
               beq PM1
               dec S1+VADSC
               bne PM1
               lda S1+VWFG
               and #246
trigrel1:      sta $D40B
PM1:           lda S1+PMC
               beq FM1
               lda S1+PMDLY
               beq pmdel1
               dec S1+PMDLY
               jmp FM1
pmdel1:        clc
               ldx S1PCURR
               ldy S1PCURR+1
// PORT: SOUND1's pms01/pms11 blocks do `DEC PMDnC` AFTER the ADC chain,
// whereas SOUND0's pms00/pms10 do DEC before. Preserved verbatim; both
// produce equivalent side-effects but with slightly different instruction
// sequences.
pms01:         lda S1+PMD0C
               beq pms11
               txa
               adc S1+PMG0
               tax
               tya
               adc S1+PMG0+1
               tay
               dec S1+PMD0C
               jmp stpm1
pms11:         lda S1+PMD1C
               beq pmrep1
               txa
               adc S1+PMG1
               tax
               tya
               adc S1+PMG1+1
               tay
               dec S1+PMD1C
               jmp stpm1
pmrep1:        lda S1+PMC
               and #$81
               beq stpm1
               bpl nopmcopy1
               jsr transferpm1
               jmp pmdel1
nopmcopy1:     jsr transferpm1a
               jmp pmdel1
stpm1:         stx S1PCURR
               sty S1PCURR+1
               stx $D409
               sty $D40A
FM1:           lda S1+FMC
               beq xit1
               and #8
               bne olm1              // ]
               ldx S1FCURR
               ldy S1FCURR+1
               clc
               lda S1+FMDLY
               beq fcs11+1
               dec S1+FMDLY
               lda S1+FMC
               and #2
               bne fcs41l1
xit1:          rts
olm1:          dec S1+FOLDC
               bne xit1
               ldy S1+FOLOD
               sty S1+FOLDC
               ldy S1+FOLCI          // ]
               bpl no1
               ldy S1+FOLII
no1:           ldx S1+FOLA
               stx IN
               ldx S1+FOLA+1
               stx IN+1
               lda S1+FOLB
               adc (IN),y
               dey
               sty S1+FOLCI
               tay
POKEFRQ1:      ldx LoFrq,y
               lda HiFrq,y
               stx $D407
               sta $D408
               rts
fcs11:         clc
               lda S1+FMD0C
               beq fcs21
               dec S1+FMD0C
               txa
               adc S1+FMG0
               tax
               tya
               adc S1+FMG0+1
               jmp stf1TAY
fcs21:         lda S1+FMD1C
               beq fcs31
               dec S1+FMD1C
               txa
               adc S1+FMG1
               tax
               tya
               adc S1+FMG1+1
               jmp stf1TAY
fcs31:         lda S1+FMD2C
               beq fcs41
               dec S1+FMD2C
               txa
               adc S1+FMG2
               tax
               tya
               adc S1+FMG2+1
               jmp stf1TAY
fcs41:         lda S1+FMD3C
               beq fcrep1
               dec S1+FMD3C
fcs41l1:       txa
               adc S1+FMG3
               tax
               tya
               adc S1+FMG3+1
stf1TAY:       tay
stf1:          stx $D407
               sty $D408
               stx S1FCURR
               sty S1FCURR+1
nosound2:      rts
fcrep1:        lda S1+FMC
               and #$81
               beq stf1
               bpl nofrqcopy1
               jsr transferf1
               jmp fcs11
nofrqcopy1:    jsr transferf1a
               jmp fcs11

// ============================================================================
//  SOUND2 (channel 2 voice refresh)
// ============================================================================

SOUND2:        ldx S2+VRC
               beq nosound2
               lda S2+VWFG
               and #8
               beq adsr2
               lda CLOCK2
               cmp S2+VADSC
               bcs PM2
               lda #0
               sta S2+VADSC
               lda S2+VWFG
               and #%11110110
               sta S2+VWFG
               bne trigrel2
adsr2:         lda S2+VADSC
               bne ad2
               ldy S2+VRC
               iny
               beq PM2
               dec S2+VRC
               bne PM2
               ldx #6
cc2:           sta $D40E,x
               dex
               bpl cc2
               // PORT: ch2 shares SOUND0's CheckFilter by loading #2 (its
               // channel number) and jumping in. SOUND1 has no equivalent
               // path because ch1 isn't routed through the filter.
               lda #2
               jmp CheckFilter
ad2:           ldy S2+VADSC
               iny
               beq PM2
               dec S2+VADSC
               bne PM2
               lda S2+VWFG
               and #246
trigrel2:      sta $D412
PM2:           lda S2+PMC
               beq FM2
               lda S2+PMDLY
               beq pmdel2
               dec S2+PMDLY
               jmp FM2
pmdel2:        clc
               ldx S2PCURR
               ldy S2PCURR+1
pms02:         lda S2+PMD0C
               beq pms12
               dec S2+PMD0C
               txa
               adc S2+PMG0
               tax
               tya
               adc S2+PMG0+1
               tay
               jmp stpm2
pms12:         lda S2+PMD1C
               beq pmrep2
               dec S2+PMD1C
               txa
               adc S2+PMG1
               tax
               tya
               adc S2+PMG1+1
               tay
               jmp stpm2
pmrep2:        lda S2+PMC
               and #$81
               beq stpm2
               bpl nopmcopy2
               jsr transferpm2
               jmp pmdel2
nopmcopy2:     jsr transferpm2a
               jmp pmdel2
stpm2:         stx S2PCURR
               sty S2PCURR+1
               stx $D410
               sty $D411
FM2:           lda S2+FMC
               beq xit2
               and #8
               bne olm2              // ]
               ldx S2FCURR
               ldy S2FCURR+1
               clc
               lda S2+FMDLY
               beq fcs12+1
               dec S2+FMDLY
               lda S2+FMC
               and #2
               bne fcs42l1
xit2:          rts
olm2:          dec S2+FOLDC
               bne xit2
               ldy S2+FOLOD
               sty S2+FOLDC
               ldy S2+FOLCI          // ]
               bpl no2
               ldy S2+FOLII
no2:           ldx S2+FOLA
               stx IN
               ldx S2+FOLA+1
               stx IN+1
               lda S2+FOLB
               adc (IN),y
               dey
               sty S2+FOLCI
               tay
POKEFRQ2:      ldx LoFrq,y
               lda HiFrq,y
               stx $D40E
               sta $D40F
               rts
fcs12:         clc
               lda S2+FMD0C
               beq fcs22
               dec S2+FMD0C
               txa
               adc S2+FMG0
               tax
               tya
               adc S2+FMG0+1
               jmp stf2TAY
fcs22:         lda S2+FMD1C
               beq fcs32
               dec S2+FMD1C
               txa
               adc S2+FMG1
               tax
               tya
               adc S2+FMG1+1
               jmp stf2TAY
fcs32:         lda S2+FMD2C
               beq fcs42
               dec S2+FMD2C
               txa
               adc S2+FMG2
               tax
               tya
               adc S2+FMG2+1
               jmp stf2TAY
fcs42:         lda S2+FMD3C
               beq fcrep2
               dec S2+FMD3C
fcs42l1:       txa
               adc S2+FMG3
               tax
               tya
               adc S2+FMG3+1
stf2TAY:       tay
stf2:          stx $D40E
               sty $D40F
               stx S2FCURR
               sty S2FCURR+1
               rts
fcrep2:        lda S2+FMC
               and #$81
               beq stf2
               bpl nofrqcopy2
               jsr transferf2
               jmp fcs12
nofrqcopy2:    jsr transferf2a
               jmp fcs12

// ============================================================================
//  SOUNDTEST / MUSICTEST (status accumulators used by the Start bootstrap)
// ============================================================================

SOUNDTEST:     lda MFL0
               ora MFL1
               ora MFL2
               ora S0+VRC
               ora S1+VRC
               ora S2+VRC
               rts

MUSICTEST:     lda MFL2
               rts

EP:            // section marker
// ============================================================================
//  END OF MUSIC PROGRAM
// ============================================================================

SD:            // section marker
// ============================================================================
//  MUSIC DATA
// ============================================================================

TUNETABLE:     .word Texit, Texit, FILTH                             // B — Filth Raid (ch2 only)
               .byte 4
               .word BONUS0, BONUS1, BONUS2                          // C — Bonus (music selected)
               .byte 6
               .word ENDOFLEVEL0, ENDOFLEVEL1, ENDOFLEVEL2           // D — End of Level jingle
               .byte 7
               .word TITLE0, TITLE1, TITLE2                          // E — Title screen music
               .byte 5
               .word Texit, Texit, BBASS2                            // F — Bonus (music not selected — single-channel bass)
               .byte 2
               .word GETREADY0, GETREADY1, GETREADY2                 // G — Get Ready jingle
               .byte 5
               // PORT: tune H (Input Name) ch0/ch1 entries are swapped in the
               // original — ch0 runs INPUTNAME1 and ch1 runs INPUTNAME0.
               // Preserved verbatim.
               .word INPUTNAME1, INPUTNAME0, INPUTNAME2              // H — Input Name
               .byte 9
               .word OVER0, OVER1, OVER2                             // I — Game Over
               .byte 2
               .word LABORATORY0, LABORATORY1, LABORATORY2           // J — Laboratory background
               .byte 8
               .word Texit, Texit, ENDOFBONUS2                       // K — End of Bonus Level (ch2 only)
               .byte 5

// ========================== INPUT NAME MUSIC DATA =============================

eD00:          .word 12, -12, 12, 0
               .byte 10, 20, 10, 0, 50, 5
               .fill 8, 0
               .word $0800
               .byte 73, $19, $89, 20, 255
eD01:          .word 17, -17, 17, 0
               .byte 10, 20, 10, 0, 100, 5
               .byte 70, 1, 0, 0
               .word 22, -1540, $0500
eV01:          .byte %00100001, $CD, $0F, 255, 200
eF02:          .word -10, 0, 0, 0
               .byte 255, 0, 0, 0, 90, 4
eV02:          .byte %00101001, $5A, $CB, 20, 200
eF03:          .word 12, -12, 12, 13
               .byte 10, 20, 10, 0, 40, 7
eV03:          .byte 33, $16, $87, 20, 10
eD04:          .fill 14, 0
               .fill 10, 0
               .byte 137, $03, $27, 25, 10
eS00:          .byte FLoad, VRC
               .word eD01
               .byte 57, 24, Rest, 24, Rest, 16, 55, 24, Rest, 24, Rest, 16, 54, 24, Rest, 24
               .byte Vlm
               .word eV02
               .byte 58, 5, 59, 5, 61, 6
               .byte Vlm
               .word eV01
               .byte 62, 16, For, 3, Rest, 16, Next
               .byte 62, 16, 65, 16, 64, 16, 69, 5, 65, 5, 62, 6
               .byte Moke, VADV, $BD
               .byte 64, 16, Rest, 8, 62, 8
               .byte Moke, VADV, $CD
               .byte 61, 16, Freq
               .word eF02
               .byte 59, 16
               .byte Freq
               .word eD01
               .byte 56, 24, 54, 8, 52, 16, 54, 7
               .byte Soke, FMC, 7
               .byte DSoke, FBG
               .word 21
               .byte Rest, 4
               .byte DSoke, FBG
               .word 0
               .byte Rest, 5
               .byte 54, 16, Ret
eS02:          .byte 0, 4, 0, 4, 0, 8, 0, 8, 0, 4, 0, 8, 0, 8, 0, 4, 0, 16, Ret

.label W = 60    // pitch of lower wood block

INPUTNAME0:    .byte FLoad, VRC
               .word eD11
               .byte For, 2, Rest, 8, 80, 8, 80, 16, 80, 12, 80, 12, 80, 8, Next
               .byte For, 9, Rest, 4, W, 2, W, 2, 86, 8, 86, 8, W, 4, W, 4, 86, 4, W, 4, W, 4, 86, 8, W, 4
               .byte 86, 8, Next
               .byte Call
               .word eS00
               .byte For, 2
               .byte For, 7, Rest, 16, Next
               .byte FLoad, VRC
               .word eD00
               .byte Rest, 12
               .byte 52, 4, 57, 4, 59, 8, 61, 8, 62, 8, 61, 8, 59, 4, 57, 8, 59, 4
               .byte Moke, VSRV, $8D, 55, 24, Rest, 24, Moke, VSRV, $89
               .byte Rest, 24
               .byte 54, 4, 58, 4, 59, 8, 61, 8, 62, 8, 64, 8, 62, 4, 61, 4
               .byte Moke, VSRV, $8D, 62, 24, Rest, 24, Moke, VSRV, $89
               .byte FLoad, FMC
               .word eD20
               .byte Rest, 16, Rest, 16
               .byte 50, 4, 53, 4, 57, 8, 62, 8, 64, 8, 65, 8, 64, 4, 62, 8, 61, 4, 57, 8
               .byte Moke, VSRV, $8D, 52, 16, Rest, 24, Moke, VSRV, $89, Rest, 4
               .byte 52, 4, 54, 4, 56, 8, 57, 4, 59, 8, 61, 8, 62, 8, 64, 8
               .byte Freq
               .word eF03
               .byte 60, 8
               .byte Freq
               .word eD00
               .byte 59, 12
               .byte Moke, VSRV, $8D, 57, 16
               .byte Next
               .byte FLoad, PINIT+1
               .word eD10
               .byte Vlm
               .word eV03
               .byte For, 15, Rest, 8, Next
               .byte CT, 45
               .word eS02
               .byte DMoke, FOLA
               .word eL11
               .byte CT, 43
               .word eS02
               .byte DMoke, FOLA
               .word eL12
               .byte CT, 42
               .word eS02
               .byte DMoke, FOLA
               .word eL13
               .byte CT, 47
               .word eS02
               .byte CT, 38
               .word eS02
               .byte DMoke, FOLA
               .word eL10
               .byte 7, 12, 7, 12
               .byte DMoke, FOLA
               .word eL13
               .byte 4, 12, 4, 12, 4, 12
               .byte DMoke, FOLA
               .word eL12
               .byte CT, 40
               .word eS02
               .byte DMoke, FOLA
               .word eL14
               .byte CT, 45
               .word eS02
               .byte 0, 4, 0, 4, 0, 8, 0, 8, 0, 4, 0, 8, 0, 8, 0, 4, 0, 12
               .byte JT, 0
               .word INPUTNAME0

eD10:          .word 0, 0, 1, 4, eL10
               .byte 0, 5, 0, 8
               .fill 10, 0
               .byte 33, $18, $6A, 30, 150
eD11:          .word 1200, 0, 0, 0
               .byte 255, 0, 0, 0, 0, 4
               .fill 10, 0
               .byte 17, $00, $F2, 5, 6
eL10:          .byte 0, 4, 7, 12, 24, 12      // major root
eL11:          .byte 0, 4, 9, 12, 24, 12
eL12:          .byte 0, 4, 10, 12, 24, 12     // 7th root
eL13:          .byte 0, 3, 7, 12, 24, 12      // minor root
eL14:          .byte 0, 4, 7, 9, 24, 12       // 6th root
eS10:          .byte DMoke, FOLA
               .word eL12
               .byte Rest, 4
               .byte For, 5, 42, 12, Next, Ret

INPUTNAME1:    .byte Rest, 4
INPUTNAME1Loo: .byte FLoad, VRC
               .word eD04
               .byte 89, 4, 89, 4, 89, 4
               .byte For, 7, 89, 8, 89, 4, 89, 4, Next
               .byte FLoad, VRC
               .word eD10
               .byte Rest, 4
               .byte For, 5
               .byte Rest, 4
               .byte For, 5, 45, 12, Next
               .byte DMoke, FOLA
               .word eL11
               .byte Rest, 4
               .byte For, 5, 43, 12, Next
               .byte Call
               .word eS10
               .byte DMoke, FOLA
               .word eL13
               .byte Rest, 4
               .byte For, 5, 47, 12, Next
               .byte Rest, 4
               .byte For, 5, 38, 12, Next
               .byte DMoke, FOLA
               .word eL10
               .byte Rest, 4
               .byte 45, 12, 45, 12
               .byte DMoke, FOLA
               .word eL13
               .byte 42, 12, 42, 12, 42, 12
               .byte CT, -2
               .word eS10
               .byte DMoke, FOLA
               .word eL14
               .byte Transp, 0
               .byte For, 2, Rest, 4
               .byte For, 5, 45, 12, Next, Next
               .byte DMoke, FOLA
               .word eL10
               .byte Next
               .byte Jmp
               .word INPUTNAME1Loo

eC20:          .word 10, -10, 10, -10
               .byte 8, 16, 8, 0, 50, 7
               .word 900
eD20:          .word 7, -7, 7, 0
               .byte 10, 20, 10, 0, 40, 5
               .byte 120, 120, 10, 5
               .word 3, -3, $0900
               .byte 73, $18, $6B, 15, 254
eF20:          .word 6, 0, 0, 0
               .byte 255, 0, 0, 0, 40, 4
eD21:          .word -10, 0, 0, 0
               .byte 255, 0, 0, 0, 25, 4
               .fill 8, 0
               .word $0800
               .byte 65, $07, $68, 40, 40
eS20:          .byte 33, 12, 40, 4, 40, 12, 33, 4, 33, 12, 40, 4, 40, 8
               .byte Freq
               .word eF20
               .byte 28, 8
               .byte Freq
               .word eD20
               .byte Ret
eS21:          .byte Call
               .word eS20
               .byte 31, 12, 40, 4, 40, 12, 31, 4, 31, 12, 40, 4, 40, 8
               .byte Freq
               .word eF20
               .byte 28, 8
               .byte Freq
               .word eD20
               .byte 30, 12, 40, 4, 40, 12, 30, 4, 30, 12, 40, 4, 40, 8
               .byte Freq
               .word eF20
               .byte 34, 8
               .byte Freq
               .word eD20
               .byte 35, 12, 42, 4, 42, 12, 35, 4, 35, 12, 42, 4, 42, 8, 23, 4, 25, 4
               .byte 26, 12, 33, 4, 33, 12, 26, 4, 26, 12, 33, 4, 33, 8
               .byte Freq
               .word eF20
               .byte 28, 8
               .byte Freq
               .word eD20
               .byte 33, 12, 40, 4, 40, 12, 33, 4, 30, 12, 37, 4, 37, 8, 28, 4, 30, 4
               .byte 28, 12, 35, 4, 35, 12, 28, 4, 28, 12, 35, 4, 35, 8, 23, 4, 25, 4
               .byte CT, -12
               .word eS20
               .byte Call
               .word eS20
               .byte Transp, 0, Ret

INPUTNAME2:    .byte FLoad, VRC
               .word eD21
               .byte Master, Filter
               .word eC20
               .byte For, 4
               .byte DMoke, FMG0
               .word -3
               .byte 20, 12, 20, 4, 20, 8
               .byte DMoke, FMG0
               .word -8
               .byte 35, 4, 35, 4, Next
               .byte FLoad, VRC
               .word eD20
               .byte For, 3
               .byte Call
               .word eS21
               .byte Next
               .byte Disown
               .byte Call
               .word eS00
               .byte FLoad, VRC
               .word eD20
               .byte For, 21, Rest, 4, Next
               .byte Master
               .byte 40, 8, 30, 8, 32, 12
               .byte Call
               .word eS21
               .byte Jmp
               .word INPUTNAME2

// ========================== END OF LEVEL MUSIC DATA =============================

XL00:          .byte 0, 5, 3, 7, 12, 0, 5, 7, 3, 12, 0, 7, 5, 3, 12, 5
XD00:          .word 0, 0, 1, 5
               .word XL00
               .byte 0, 15, 0, 8
               .fill 10, 0
               .byte 33, $33, $9A, 50, 50

ENDOFLEVEL2:   .byte RestR, 2
ENDOFLEVEL1:   .byte RestR, 2
ENDOFLEVEL0:   .byte FLoad, VRC
               .word XD00
               .byte 60, 32, Ret

// ========================== GET READY JINGLE DATA =============================

RD00:          .word 20000, -39000, 14000, -40000
               .byte 220, 220, 220, 220, 0, 5
               .fill 8, 0
               .word $0800
               .byte %01000001, $FF, $F0, 255, 1

GETREADY0:     .byte Master, Filter
               .word TC00
GETREADY0Labe: .byte FLoad, VRC
               .word RD00
               .byte 50, 32
               .byte For, 6, Rest, 32, Next, Soke, VADSC, 1
Texit:         .byte Ret

GETREADY1:     .byte Rest, 1
GETREADY2:     .byte Rest, 1
               .byte Jmp
               .word GETREADY0Labe

// ====================== END OF BONUS LEVEL MUSIC DATA =========================

CfS0:          .byte FLoad, VRC
               .word GD20a
               .byte Master, Filter
               .word GC20a
               .byte Ret

ENDOFBONUS2:   .byte Call
               .word CfS0
               .byte Moke, VSRV, $86
               .byte For, 2
               .byte 38, 8, 50, 8, 53, 2, 52, 2, 48, 2, 45, 4, 43, 2, 45, 4
               .byte 38, 8, 50, 8, 53, 2, 52, 2, 48, 2, 55, 4, 53, 2, 52, 2, 48, 2
               .byte Next
               .byte For, 2
               .byte 50, 8, 52, 6, 53, 1, 55, 1, 53, 6, 55, 2, 57, 3, 55, 3, 53, 2
               .byte 50, 6, 52, 1, 53, 1, 52, 6, 48, 2, 50, 16
               .byte Next
               .byte Ret

// ========================== GAME OVER MUSIC DATA ================================

OVER0:         .byte RestR, 2
OVER1:         .byte FLoad, VRC
               .word GD20a
               .byte RestR, 1
               .byte Jmp
               .word OVER2a


OF20:          .word 147, 0, 0, 0
               .byte 7, 0, 0, 0, 2, 4
OF21:          .word N61-N64, 0, 0, 0
               .byte 1, 0, 0, 0, 5, 4
OF22:          .word 85, -85, 0, 0
               .byte 4, 4, 2, 0, 4, 5

OVER2:         .byte Call
               .word CfS0
               .byte Filter
               .word CaC0
OVER2a:        .byte Moke, VWF, 65, Moke, VADSD, 45
               .byte Transp, 9
               .byte For, 4
               .byte Freq
               .word OF21
               .byte 55+R, 6*2-2
               .byte Freq
               .word OF20
               .byte 50, 6
               .byte Moke, FMC, 0
               .byte 52, 3
               .byte Next
               .byte Moke, FMC, 4, DMoke, FMG0
               .word 208
               .byte 55, 10, 55, 10
               .byte Moke, FMC, 0
               .byte 57, 4, 55, 4, 53, 4, 52, 2, 53, 2, 52, 2, 50, 4, 52, 4
               .byte 53, 2, 52, 2, 50, 2, 50, 2, 48, 2, 45, 2
               .byte 48, 2, 50, 2
               .byte Freq
               .word OF22
               .byte 48, 20
               .byte Rest, 1
               .byte Ret

// =================== IN THE LABORATORY BACKGROUND SOUND DATA ==================

LABORATORY2:   .byte Filter
               .word BC00
               .byte Code
               .word BX00
               .byte Rest, 8
LABORATORY1:   .byte Rest, 8
LABORATORY0:   .byte FLoad, VRC
               .word BD00
               .byte Moke, PMC, 0, Moke, VWF, %00010101
               .byte Jmp
               .word BONUS0Loop

// ========================= BONUS SCREEN MUSIC DATA ============================

BD00:          .word -200, 0, 0, 0
               .byte 255, 0, 0, 0, 10, 4
               .byte 255, 0, 0, 4
               .word 50, 0, $0800
               .byte %01000001, $03, $97, 13, 8

BC00:          .word -2, -2, 2, 2
               .byte 255, 255, 255, 255, 255, 5
               .word 1200
BS00:          .byte 12, 4, 10, 4, 8, 4, 5, 4, 3, 4, 0, 4, Ret
BS01:          .byte 0, 4, 3, 4, 5, 4, 8, 4, 10, 4, 12, 4, Ret
BS02:          .byte 12, 4, 0, 4, 10, 4, 0, 4, 7, 4, 3, 4, Ret
BS03:          .byte 0, 4, 3, 4, 7, 4, 12, 4, Ret
// PORT: BX00 is executable code embedded in the data stream — the music
// engine invokes it via the `Code` command (see `LABORATORY2`/`BONUS2`).
BX00:          lda #%11110111
               sta $D417
               lda #%00011111
               sta $D418
               lda #3
               sta FilterChannel
               jmp StartFilter

BONUS2:        .byte Filter
               .word BC00
               .byte Code
               .word BX00
               .byte Rest, 6
BONUS1:        .byte Rest, 6
BONUS0:        .byte FLoad, VRC
               .word BD00
BONUS0Loop:    .byte For, 2
               .byte For, 2
               .byte CT, 67
               .word BS00
               .byte CT, 55
               .word BS00
               .byte CT, 43
               .word BS00
               .byte CT, 31
               .word BS00
               .byte Next
               .byte For, 2
               .byte CT, 71
               .word BS01
               .byte CT, 57
               .word BS01
               .byte CT, 45
               .word BS01
               .byte CT, 31
               .word BS01
               .byte Next
               .byte Next
               .byte For, 4
               .byte CT, 50
               .word BS02
               .byte CT, 55
               .word BS02
               .byte CT, 53
               .word BS02
               .byte CT, 58
               .word BS02
               .byte Next
               .byte For, 4
               .byte CT, 50
               .word BS03
               .byte CT, 62
               .word BS03
               .byte CT, 55
               .word BS03
               .byte CT, 67
               .word BS03
               .byte CT, 60
               .word BS03
               .byte CT, 72
               .word BS03
               .byte CT, 65
               .word BS03
               .byte CT, 77
               .word BS03
               .byte Next, Jmp
               .word BONUS0Loop

// ====================== BONUS SCREEN BASS MUSIC DATA ==========================

BBD20:         .word 40, -40, 40, 0
               .byte 3, 5, 2, 0, 10, 5
               .byte 12, 255, 0, 4
               .word 160, -68, $0800
               .byte 73, $03, $A7, 2, 5
BBC20:         .word -40, 4, 12, -12
               .byte 20, 25, 20, 20, 0, 4
               .word 700
JeF20:         .word -45, 0, 45, 0
               .byte 4, 4, 4, 4, 16, 5
JeF21:         .word -30, 0, 0, 4
               .byte 255, 0, 0, 0, 15, 7
JaS0:          .byte Rest, 3, 38, 2, 40, 2, 38, 2, 35, 2, 34, 3, Rest, 1, 33, 6, Ret
JOPSd:         .byte 33, 8, 42, 4, Rest, 2, 43, 3, Rest, 1
               .byte 38, 2, 39, 2, 40, 2, 43, 2, 40, 2, 39, 2, 38, 2
               .byte 33, 8, 45, 4, Rest, 2, 43, 3, Rest, 1
               .byte 45, 1, 47, 1, 45, 2
               .byte 43, 1, 45, 1, 43, 2
               .byte 42, 1, 43, 1, 42, 2
               .byte 40, 2, 33, 6
               .byte 33, 2, 43, 2, 45, 2, 43, 2, 40, 2, Rest, 2, 22, 2, 34, 4, 47, 2
               .byte 45, 2, 43, 2, 21, 2
               .byte 33, 3, Rest, 1, 33, 4
               .byte 25, 2, 26, 2, 27, 2, 28, 4, 28, 2, 31, 3, Rest, 1
               .byte For, 2, 31, 2, 28, 2, Next
               .byte Ret
MaS0:          .byte 17, 2, 17, 2, 29, 2, 17, 2, Ret

BBASS2:        .byte Master, Filter
               .word BBC20
               .byte FLoad, VRC
               .word BBD20
               .byte 35, 4, 23, 4, 35, 4, 34, 4, 22, 4, 34, 4, 33, 4, 21, 4, 33, 4, 32, 4, 20, 4, 32, 4
               .byte For, 2
               .byte For, 2, 31, 9, 43, 9, 41, 9, 41, 3, 38, 6, 36, 6, 34, 6, Next
               .byte 27, 9, 39, 9, 37, 9
               .byte 37, 3, 34, 6, 32, 6, 30, 6, 26, 9, 38, 9, 36, 9, 36, 3, 14, 3, 26, 3, 17, 3, 29, 3
               .byte 18, 3, 30, 3
               .byte Next

               .byte Time, 4
               .byte Call
               .word CfS0

               .byte Call
               .word JOPSd

               .byte DMoke, PINIT
               .word $0800
               .byte 24, 8, 36, 3, Call
               .word JaS0
               .byte 23, 8, 35, 3, Call
               .word JaS0
               .byte 22, 8, 34, 3, Call
               .word JaS0
               .byte 21, 8, 33, 3, Call
               .word JaS0

               .byte Call
               .word JOPSd

               .byte For, 2
               .byte 45, 2, 43, 2, 40, 3, Rest, 1, 43, 2, 40, 4, 37, 4, 38, 2, 39, 2
               .byte 40, 4, 43, 4, 44, 2
               .byte 45, 2, 43, 2, 40, 3, Rest, 1, 43, 2, 40, 3, Rest, 1
               .byte Freq
               .word JeF20
               .byte 39, 12
               .byte Freq
               .word JeF21
               .byte 48, 6
               .byte Freq
               .word GD20a
               .byte Next

               .byte For, 4
               .byte 31, 8, 32, 6, 33, 2, Rest, 2, 21, 8, 31, 1, 33, 1
               .byte 36, 1, 38, 1, 36, 2, 31, 8, 32, 6, 33, 2, Rest, 2
               .byte 21, 2, 22, 2, 23, 2, 26, 2, 27, 2, 28, 2, 30, 2
               .byte Next

               .byte Time, 5
               .byte CT, 0
               .word CRIXa
               .byte Time, 3

               .byte Call
               .word CfS0
               .byte For, 4
               .byte 19, 8, 31, 2, 7, 2, 19, 2, 21, 2, 22, 6, 22, 2, 34, 2, 22, 4, 23, 2, 24, 6, 24, 2
               .byte 36, 2, 24, 4, 24, 2
               .byte CT, -2
               .word MaS0
               .byte CT, 0
               .word MaS0
               .byte Next

               .byte For, 4
               .byte For, 2
               .byte 31, 2, 31, 2, 43, 2, 31, 2, 31, 2, 41, 2, 31, 2, 31, 2
               .byte 38, 2, 31, 2, 36, 2, 31, 2, 34, 2, 31, 2, 29, 2, 26, 2
               .byte Next
               .byte For, 2
               .byte 29, 2, 29, 2, 43, 2, 29, 2, 29, 2, 41, 2, 29, 2, 29, 2
               .byte 38, 2, 29, 2, 36, 2, 29, 2, 34, 2, 31, 2, 29, 2, 26, 2
               .byte Next
               .byte Next

               .byte For, 4
               .byte For, 2
               .byte 31, 2, 31, 2, 19, 2, 31, 2, 19, 2
               .byte For, 4, 19, 2, 31, 2, Next
               .byte 31, 2, 31, 2, 19, 2
               .byte Next
               .byte 31, 2, 31, 2, 22, 2, 31, 2, 22, 2
               .byte For, 4, 22, 2, 31, 2, Next
               .byte 31, 2, 31, 2, 22, 2, 29, 2, 29, 2, 24, 2, 29, 2, 24, 2
               .byte For, 3, 24, 2, 29, 2, Next
               .byte 24, 2, 28, 2, 28, 2, 28, 2, 24, 2
               .byte Next

               .byte Time, 2
               .byte Jmp
               .word BBASS2

// ====================== FILTH ALARM MUSIC DATA ================================

FILTH:         .byte FLoad, VRC
               .word GD20a
               .byte Master, Filter
               .word GC20a
               .byte For, 2
               .byte 21, 2, 21, 2, 28, 2, 28, 2, 27, 2, 27, 2, 26, 2, 26, 2
               .byte 33, 2, 33, 2, 32, 2, 31, 2, 28, 2, 27, 2, 26, 2, 24, 2
               .byte Next, Ret

// =========================== GAME MUSIC DATA ==================================

// CHRIX A...

GC20a:         .word 20, -20, 50, -50
               .byte 4, 4, 4, 4, 10, 7
               .word 600
GD20a:         .word 20, -20, 20, 0
               .byte 2, 4, 2, 0, 8, 5
               .byte 20, 200, 0, 5
               .word 100, -10, $0400
               .byte 73, $01, $C4, 2, 5

CaC0:          .word 20, -20, 20, 120
               .byte 4, 4, 4, 0, 4, 7
               .word 100
CaF0:          .word 0, 0, 1, 5, CaL0
               .byte 0, 7, 7, 8
CaL0:          .byte -2, -4, -2, 3, -2, -4, -2, 0
CaL1:          .byte -2, -4, -2, 2, -2, -4, -2, 0
CaL2:          .byte -2, -4, -2, 5, -2, -4, -2, 0

CRIXa:         .byte Call
               .word CfS0
               .byte Freq
               .word CaF0
               .byte Filter
               .word TD00
               .byte Moke, VWF, 65, Moke, VADSD, 255
               .byte 59, 16
               .byte For, 3
               .byte Call
               .word CaS0
               .byte Rest, 16
               .byte Next
CaS0:          .byte DSoke, FOLA
               .word CaL1
               .byte Rest, 16
               .byte DSoke, FOLA
               .word CaL0
               .byte Rest, 16
               .byte DSoke, FOLA
               .word CaL2
               .byte Rest, 16
               .byte DSoke, FOLA
               .word CaL0
               .byte Ret

// ======================= TITLE SCREEN MUSIC DATA ==============================

TC00:          .word -6, -1, 1, 6
               .byte 128, 255, 255, 128, 0, 5
               .word 1100
TD00:          .word 25, -25, 25, 10
               .byte 9, 18, 9, 0, 100, 7
               .byte 160, 160, 0, 5
               .word 8, -8, $0800
               .byte 65, $06, $FA, 255, 254
TF01:          .word -73, 0, 73, 0
               .byte 10, 10, 10, 10, 10, 5
TV01:          .byte 65, $06, $F6, 20, 50
TF02:          .word 20, 0, -40, 0
               .byte 41, 40, 20, 0, 5, 4
TD03:          .word 4, 0, 0, 0
               .byte 255, 0, 0, 0, 10, 5
               .byte $1C, 4, 0, 133
               .word $29, $7C, $0480
               .byte %01010001, $09, $8A, 20, 254
// PORT: TX00 is executable code embedded in the stream (invoked by the
// `Code` command from TITLE0), not data.
TX00:          lda #3
               sta FilterChannel
               rts
TS00:          .byte For, 4
               .byte 50, 12, 74, 12, 69, 12, 65, 12
               .byte 62, 6, 65, 6, 65, 6
               .byte 57, 6, 62, 6, 62, 6
               .byte 53, 6, 57, 6
               .byte Next
               .byte For, 4
               .byte 47, 12, 76, 12, 71, 12, 68, 12
               .byte 64, 6, 68, 6, 68, 6
               .byte 59, 6, 64, 6, 56, 6, 59, 6, 52, 6
               .byte Next
               .byte Ret
TS01:          .byte For, 4
               .byte 41, 12, 65, 12, 60, 12, 58, 12
               .byte 53, 6, 58, 6, 58, 6
               .byte 48, 6, 53, 6, 53, 6, 46, 6, 48, 6
               .byte Next
               .byte For, 4
               .byte 40, 12, 64, 12, 58, 12, 56, 12
               .byte 52, 6, 56, 6, 56, 6
               .byte 46, 6, 52, 6, 52, 6, 40, 6, 46, 6
               .byte Next
               .byte For, 4
               .byte 39, 12, 63, 12, 58, 12, 55, 12
               .byte 51, 6, 55, 6, 55, 6
               .byte 46, 6, 51, 6, 51, 6, 43, 6, 46, 6
               .byte Next
               .byte For, 4
               .byte 38, 12, 62, 12, 58, 12, 54, 12
               .byte 50, 6, 54, 6, 54, 6
               .byte 46, 6, 50, 6, 50, 6, 42, 6, 46, 6
               .byte Next
               .byte For, 4
               .byte 37, 12, 61, 12, 58, 12, 53, 12
               .byte 49, 6, 53, 6, 53, 6
               .byte 46, 6, 49, 6, 49, 6, 41, 6, 46, 6
               .byte Next
               .byte For, 4
               .byte 36, 12, 60, 12, 58, 12, 52, 12
               .byte 48, 6, 52, 6, 52, 6
               .byte 46, 6, 48, 6, 48, 6, 40, 6, 46, 6
               .byte Next
               .byte For, 4
               .byte 35, 12, 59, 12, 58, 12, 51, 12
               .byte 47, 6, 51, 6, 51, 6
               .byte 46, 6, 47, 6, 47, 6, 39, 6, 42, 6
               .byte Next
               .byte For, 4
               .byte 34, 12, 58, 12, 53, 12, 50, 12
               .byte 46, 6, 50, 6, 50, 6
               .byte 41, 6, 46, 6, 46, 6, 38, 6, 41, 6
               .byte Next
               .byte Ret

TITLE0:        .byte FLoad, VRC
               .word TD00
               .byte Master
               .byte Filter
               .word TC00
               .byte 58, 32
               .byte Code
               .word TX00
               .byte For, 20, Rest, 32, Next
               .byte 58, 32, Rest, 32, Rest, 32
               .byte MBendOff
               .byte Rest, 24, 58, 4, 57, 4, 58, 32, Rest, 24, 55, 8, 62, 32
               .byte MBendOn, DMoke, FBG
               .word 6
               .byte 64, 32
               .byte MBendOff
               .byte 64, 32, Rest, 32, Rest, 32, Rest, 8, 60, 16
               .byte 55, 4, 53, 4, 52, 32, Rest, 32, 53, 32, 55, 32
               .byte Freq
               .word TF01
               .byte 55, 32
               .byte Freq
               .word TF02
               .byte Rest, 32
               .byte Rest, 32
               .byte Moke, FMC, 4, 55, 24, Moke, FMC, 0, 53, 8
               .byte Moke, FMD1, 5
               .byte For, 4
               .byte Moke, FMC, 4, 55, 16, Moke, FMC, 0, 53, 6
               .byte Next
               .byte FLoad, FMDLY
               .word TD00
               .byte MBendOff
               .byte 55, 32
               .byte Soke, VADSC, 254
               .byte Rest, 32
               .byte Rest, 32
               .byte Rest, 32
               .byte Rest, 24
               .byte 55, 16, 60, 32, Rest, 32, 64, 32, Rest, 32, 62, 32, Soke, VADSC, 150
               .byte Rest, 32
               .byte Rest, 32
               .byte Rest, 16
               .byte 58, 16, 62, 32, Rest, 32, 65, 32, Rest, 16
               .byte Freq
               .word TF02
               .byte Moke, FMDLY, 50, DMoke, FMG0
               .word -30
               .byte 67, 16
               .byte Freq
               .word TD00
               .byte MBendOff, 64, 32, Soke, VADSC, 254
               .byte Rest, 32, Rest, 32, Rest, 32
               .byte 67, 24, 69, 24, 67, 16
               .byte 65, 24, 64, 24, 60, 16
               .byte 62, 32, Rest, 32, Rest, 32, Rest, 16, 60, 16
               .byte 58, 32, Rest, 32
               .byte 55, 32, Rest, 16
               .byte DMoke, FBG
               .word 0
               .byte MBendOn
               .byte 53, 12
               .byte DSoke, FBG
               .word 18
               .byte Rest, 8
               .byte DSoke, FBG
               .word 0
               .byte MBendOn, Moke, VSRV, $AF, DMoke, FBG
               .word 0
               .byte For, 127, Rest, 4, Next
               .byte 60, 32
               .byte For, 6, Rest, 32, Next
               .byte Rest, 16
               .byte Soke, FMDLY, 100, DSoke, FBG
               .word -12
               .byte Rest, 16
               .byte DSoke, FBG
               .word 0
               .byte DSoke, VADSC
               .word 254+255*256
               .byte FLoad, VRC
               .word TD03
               .byte For, 24, Rest, 32, Next
               .byte Call
               .word TS00
               .byte Call
               .word TS00
               .byte Call
               .word TS01
               .byte Rest, 9
               .byte Jmp
               .word TITLE0


TD10:          .word 25, -25, 25, 0
               .byte 9, 18, 9, 0, 100, 0
               .byte 160, 160, 0, 5
               .word 8, -8, $0800
               .byte 65, $B6, $FF, 254, 255
TV11:          .byte 65, $00, $56, 12, 50
TL10:          .byte 5, 12, 0, 7, 4, 12, 0, 7, 2, 12, 0, 7, 4, 12, 0, 7
TL11:          .byte 5, 12, -2, 7, 4, 12, -2, 7, 2, 12, -2, 7, 4, 12, -2, 7
TL12:          .byte 4, -12, 12, 7, 4, -24, 4, 7, 12, -12, 4, 7, 12, -24, 12, 7
TL13:          .byte 2, -12, 10, 7, 2, -26, 2, 7, 10, -12, 2, 7, 10, -26, 10, 7

TITLE1:        .byte FLoad, VRC
               .word TD20
               .byte DMoke, FOLA
               .word TL10
               .byte For, 13, Rest, 32, Next
               .byte 60, 32
               .byte For, 7, Rest, 32, Next
               .byte For, 2
               .byte DSoke, FOLA
               .word TL11
               .byte For, 8, Rest, 32, Next
               .byte DSoke, FOLA
               .word TL10
               .byte For, 8, Rest, 32, Next
               .byte Next
               .byte DSoke, FOLA
               .word TL11
               .byte For, 8, Rest, 32, Next
               .byte DSoke, FOLA
               .word TL10
               .byte For, 12, Rest, 8, Next
               .byte Rest, 5
               .byte DSoke, PMG0
               .word -1
               .byte DSoke, FOLA
               .word TL12
               .byte Rest, 3
               .byte For, 19, Rest, 8, Next
               .byte DSoke, PMG0
               .word 0
               .byte DSoke, FOLA
               .word TL13
               .byte FLoad, VRC
               .word TD10
               .byte For, 8, Rest, 32, Next
               .byte For, 3
               .byte 24, 32
               .byte For, 7, Rest, 32, Next
               .byte 31, 32
               .byte For, 7, Rest, 32, Next
               .byte Next
               .byte FLoad, VRC
               .word TD03
               .byte Moke, FMC, 5
               .byte Rest, 9
               .byte For, 24, Rest, 32, Next
               .byte Call
               .word TS00
               .byte Call
               .word TS01
               .byte Jmp
               .word TITLE1


TC20:          .word -1, -1, -1, 7
               .byte 255, 255, 255, 0, 255, 7
               .word 100
TD20:          .word 0, 0, 1, 20, TL20
               .byte 0, 15, 0, 8
               .byte 1, 1, 0, 5
               .word 1, 0, $0001
               .byte 65, $FE, $BF, 255, 255
TD21:          .word 6, -6, 6, -6
               .byte 10, 20, 10, 0, 100, 5
               .byte 160, 160, 0, 5
               .word 8, -8, $0800
               .byte 65, $CC, $8A, 255, 254
//             .byte 33, $CC, $CA, 255, 254
TL20:          .byte 0, 7, 4, 12, 0, 7, 2, 12, 0, 7, 4, 12, 0, 7, 5, 12
TL21:          .byte -2, 7, 4, 12, -2, 7, 2, 12, -2, 7, 4, 12, -2, 7, 5, 12
TL22:          .byte 12, 7, 4, -12, 12, 7, 4, -24, 4, 7, 12, -12, 4, 7, 12, -24
TL23:          .byte 10, 7, 2, -12, 10, 7, 2, -26, 2, 7, 10, -12, 2, 7, 10, -26

TITLE2:        .byte FLoad, VRC
               .word TD20
               .byte For, 5, Rest, 32, Next
               .byte 60, 32
               .byte For, 15, Rest, 32, Next
               .byte For, 2
               .byte DSoke, FOLA
               .word TL21
               .byte For, 8, Rest, 32, Next
               .byte DSoke, FOLA
               .word TL20
               .byte For, 8, Rest, 32, Next
               .byte Next
               .byte DSoke, FOLA
               .word TL21
               .byte For, 25, Rest, 4, Next
               .byte Soke, VADSC, 254
               .byte DSoke, PMG0
               .word -1
               .byte DMoke, PINIT
               .word $0ECF
               .byte DMoke, PMG0
               .word -1
               .byte For, 15, Rest, 8, Next
               .byte 60, 32
               .byte For, 3
               .byte DSoke, FOLA
               .word TL22
               .byte For, 8, Rest, 32, Next
               .byte DSoke, FOLA
               .word TL23
               .byte For, 8, Rest, 32, Next
               .byte Next
               .byte FLoad, VRC
               .word TD10
               .byte Rest, 4
               .byte 29, 32
               .byte For, 7, Rest, 32, Next
               .byte 26, 32
               .byte FLoad, VRC
               .word TD21
               .byte For, 7, Rest, 32, Next
               .byte Master, Filter
               .word TC20
               .byte For, 2
               .byte 29, 32
               .byte For, 11, Rest, 32, Next
               .byte 23, 32
               .byte For, 11, Rest, 32, Next
               .byte Next
               .byte For, 6
               .byte 34, 32
               .byte For, 11, Rest, 32, Next
               .byte Next
               .byte 34, 32
               .byte For, 10, Rest, 32, Next
               .byte DSoke, FMDLY
               .word 255+256*7
               .byte Moke, VSRV, $8F, DMoke, VADSD
               .word 254+255*256
               .byte Rest, 32
               .byte 22, 32
               .byte For, 45, Rest, 8, Next
               .byte RestR, 5
               .byte Jmp
               .word TITLE2

ED:
// ============================================================================
//  End of music data. Trailing constants & size/gap markers.
// ============================================================================

.label SIZE     = ED-$45B0
.label GAP      = 15*512-SIZE    // I've currently got 7.5K to play with
.label CH0VALUE = 1
.label CH1VALUE = 1
.label CH2VALUE = 1
.label Q        = 82
.label refsp    = $100

// ^^^^^^^^^^^^^^^ This is the end of the source file... (or is it?) ^^^^^^^^^^^^

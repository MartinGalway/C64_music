// ============================================================================
//  Wizball Music Player — listener-friendly harness
//
//  Paints a title / credits / key-map screen once, then runs its own
//  raster-synced REFRESH loop. Does NOT call Galway's DREFRESH / RefScreen1-4
//  so the screen stays readable while the music plays. Reuses Galway's
//  per-tune entry points (FilthRaid / BonusMusic / …) for dispatch.
//
//  Keys:
//    B-K   select tune
//    SPACE silence (re-inits SID)
//    +     faster (Galway's IncRefsp)
//    -     slower (Galway's DecRefsp)
//    @     reset refresh speed to $0100
//    *     reset refresh speed to $0001
//    RET   cycle RF (toggle Y/N per-channel note enables)
// ============================================================================

#import "../port/wizball.asm"

.const tune_count = 10
.const line_count = 18

// Temporary zero-page pointers used only during paint_screen. These slots
// are outside Galway's engine workspace ($04-$1B, $29-$5D, $87-$FC).
.label ps_src = $FB
.label ps_dst = $FD

// BASIC upstart: `10 SYS 2064` → jumps to $0810.
* = $0801 "Basic Upstart"
    .byte $0c, $08, $0a, $00, $9e, $20, $32, $30, $36, $34, $00, $00, $00

* = $0810 "Player"

player_entry:
    sei
    // Set border/background to black for contrast.
    lda #0
    sta $D020
    sta $D021
    jsr paint_screen

    // Galway's keyscan needs its debounce slot initialised.
    jsr InitKeyScan

    // Reset SID + music engine state.
    jsr INITSOUND

    // Master volume + HP filter on; master2 would set this on first Master
    // command, but some tunes don't start with Master so we pre-set it.
    lda #$1F
    sta $D418

    // Boot default tune: Title screen (E).
    jsr Title

    // Enable note triggers on all three channels (bits 0/1/2 = ch0/1/2).
    lda #7
    sta RF

// ---------------------------------------------------------------------------
//  Main loop — 50 Hz raster-synced music refresh + keyboard poll
// ---------------------------------------------------------------------------
main_loop:
    // Wait for raster to hit line 0 (top of frame).
wait_top:
    lda $D012
    bne wait_top
    // Wait past line 0 so we only tick once per frame.
wait_past:
    lda $D012
    beq wait_past

    // Call REFRESH with Z=0 so it doesn't take its `beq xit` fast-exit.
    lda #$FF
    jsr REFRESH

    // Poll keyboard; Galway's KeyScan returns A=ASCII code (0 if no key).
    jsr KeyScan
    beq main_loop

    jsr dispatch_key
    jmp main_loop

// ---------------------------------------------------------------------------
//  Keyboard dispatcher — A = ASCII code
// ---------------------------------------------------------------------------
dispatch_key:
    // Try tune letters B-K against the key_table.
    ldx #tune_count-1
key_scan:
    cmp key_table,x
    beq play_by_index
    dex
    bpl key_scan
    // Not a tune letter — check control keys.
    cmp #'+'
    bne not_plus
    jmp IncRefsp
not_plus:
    cmp #'-'
    bne not_minus
    jmp DecRefsp
not_minus:
    cmp #'@'
    bne not_at
    // Galway's main.asm path for '@': Refsp = $0100.
    ldx #1
    stx Refsp+1
    dex
    stx Refsp
    rts
not_at:
    cmp #'*'
    bne not_star
    // '*' sets Refsp = $0001.
    ldx #0
    stx Refsp+1
    inx
    stx Refsp
    rts
not_star:
    cmp #13                   // RETURN cycles RF's low 3 bits.
    bne not_ret
    inc RF
    rts
not_ret:
    cmp #$20                  // SPACE: silence.
    bne not_space
    jsr INITSOUND
    lda #0
    sta RF
    rts
not_space:
    rts

// X = tune index (0-9). Sets master volume and calls the per-tune entry.
play_by_index:
    txa
    asl
    tay
    lda tune_table,y
    sta trampoline+1
    lda tune_table+1,y
    sta trampoline+2
    // Restore master volume (in case a previous SPACE ran INITSOUND).
    lda #$1F
    sta $D418
    // Re-enable note triggers — SPACE sets RF=0; track starts expect RF!=0.
    lda #7
    sta RF
trampoline:
    jsr $DDDD                 // operand patched above
    rts

key_table:
    .byte 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'
tune_table:
    .word FilthRaid, BonusMusic, EndOfLevel, Title,    BonusBass
    .word GetReady,  InputName,  GameOver,   Laboratory, EndOfBonus

// ---------------------------------------------------------------------------
//  Screen painter — clears to spaces, sets colour RAM white, then copies
//  the text blocks to their rows.
// ---------------------------------------------------------------------------
paint_screen:
    ldx #0
ps_clr:
    lda #$20                  // screen-code space
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    lda #14                   // light blue text on black background
    sta $D800,x
    sta $D900,x
    sta $DA00,x
    sta $DB00,x
    inx
    bne ps_clr

    // Copy each text line to its screen row using the line_table.
    ldx #0
line_loop:
    lda line_table_src_lo,x
    sta ps_src
    lda line_table_src_hi,x
    sta ps_src+1
    lda line_table_dst_lo,x
    sta ps_dst
    lda line_table_dst_hi,x
    sta ps_dst+1
    ldy line_table_len,x
    dey                       // Y = len-1 for count-down copy
copy_chars:
    lda (ps_src),y
    sta (ps_dst),y
    dey
    bpl copy_chars
    inx
    cpx #line_count
    bcc line_loop
    rts

// ---------------------------------------------------------------------------
//  Text data (screen codes, uppercase mode)
// ---------------------------------------------------------------------------
.encoding "screencode_upper"

text_title:      .text "WIZBALL MUSIC PLAYER"
text_sep1:       .text "------------------------"
text_credit1:    .text "MUSIC AND SID ENGINE BY"
text_credit2:    .text "MARTIN GALWAY - OCEAN 1987"
text_credit3:    .text "SOURCE SHARED APRIL 2026"
text_credit4:    .text "KICKASSEMBLER - MADS NIELSEN"
text_credit5:    .text "PORT - D.WESTBURY"
text_tunes:      .text "TUNE SELECT"
text_row_bc:     .text "B  FILTH RAID        C  BONUS MUSIC"
text_row_de:     .text "D  END OF LEVEL      E  TITLE SCREEN"
text_row_fg:     .text "F  BONUS BASS        G  GET READY"
text_row_hi:     .text "H  INPUT NAME        I  GAME OVER"
text_row_jk:     .text "J  LABORATORY        K  END OF BONUS"
text_ctrl1:      .text "SPACE SILENCE      + FASTER"
text_ctrl2:      .text "RETURN CYCLE RF    - SLOWER"

.encoding "petscii_mixed"     // back to default so char literals match ASCII

// ---------------------------------------------------------------------------
//  Line layout table — (source, destination, length) triples
// ---------------------------------------------------------------------------
// Per-row screen address = $0400 + row*40 + column.
.function scr_at(row, col) {
    .return $0400 + row*40 + col
}

// Row layout (all within 0-24):
//   1  title         2  sep
//   4-8 credits1-5
//  10  sep   11 tunes hdr  12 sep
//  14-18 tune rows B-K
//  20  sep
//  22 ctrl1   23 ctrl2
line_table_src_lo:
    .byte <text_title,   <text_sep1
    .byte <text_credit1, <text_credit2, <text_credit3, <text_credit4, <text_credit5
    .byte <text_sep1,    <text_tunes,   <text_sep1
    .byte <text_row_bc,  <text_row_de,  <text_row_fg,  <text_row_hi,  <text_row_jk
    .byte <text_sep1
    .byte <text_ctrl1,   <text_ctrl2
line_table_src_hi:
    .byte >text_title,   >text_sep1
    .byte >text_credit1, >text_credit2, >text_credit3, >text_credit4, >text_credit5
    .byte >text_sep1,    >text_tunes,   >text_sep1
    .byte >text_row_bc,  >text_row_de,  >text_row_fg,  >text_row_hi,  >text_row_jk
    .byte >text_sep1
    .byte >text_ctrl1,   >text_ctrl2

line_table_dst_lo:
    .byte <scr_at(1,10),  <scr_at(2,8)
    .byte <scr_at(4,8),   <scr_at(5,7),  <scr_at(6,8),  <scr_at(7,6),  <scr_at(8,11)
    .byte <scr_at(10,8),  <scr_at(11,14),<scr_at(12,8)
    .byte <scr_at(14,2),  <scr_at(15,2), <scr_at(16,2), <scr_at(17,2), <scr_at(18,2)
    .byte <scr_at(20,8)
    .byte <scr_at(22,6),  <scr_at(23,6)
line_table_dst_hi:
    .byte >scr_at(1,10),  >scr_at(2,8)
    .byte >scr_at(4,8),   >scr_at(5,7),  >scr_at(6,8),  >scr_at(7,6),  >scr_at(8,11)
    .byte >scr_at(10,8),  >scr_at(11,14),>scr_at(12,8)
    .byte >scr_at(14,2),  >scr_at(15,2), >scr_at(16,2), >scr_at(17,2), >scr_at(18,2)
    .byte >scr_at(20,8)
    .byte >scr_at(22,6),  >scr_at(23,6)

line_table_len:
    .byte 20, 24                  // title, sep
    .byte 23, 26, 24, 28, 17      // credits 1-5
    .byte 24, 11, 24              // sep, tunes heading, sep
    .byte 35, 36, 33, 33, 36      // tune rows B/C, D/E, F/G, H/I, J/K
    .byte 24                       // sep
    .byte 27, 27                  // control rows

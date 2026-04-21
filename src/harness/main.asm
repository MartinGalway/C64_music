// ============================================================================
//  Wizball music player — harness (scaffold)
//
//  This is the scaffold for the raster-IRQ music player harness. Right now
//  it does the bare minimum needed to smoke-test that the ported player
//  source in ../port/wizball.asm assembles and its labels resolve.
//
//  Future work: add raster interrupt driver that calls `InitSound` once and
//  the Music0/Music1/Music2 routines at the documented 50/100/200 Hz rates.
// ============================================================================

#import "../port/wizball.asm"

// BASIC upstart: `10 SYS 4096` → jumps straight to Galway's `Start` at $1000
// after the user types RUN. BASIC tokens: $9E = SYS, then the ASCII digits of
// 4096 (the decimal representation of $1000), then a NUL terminator.
* = $0801 "Basic Upstart"
    .byte $0c, $08, $0a, $00, $9e, $20, $34, $30, $39, $36, $00, $00, $00

* = $0810 "Harness"
// Safety net in case the program is started via `SYS 2064` instead of
// auto-run-from-BASIC: jump into Galway's entry point.
    jmp Start

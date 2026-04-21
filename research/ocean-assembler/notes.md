# Ocean 1987 In-House Assembler — Research Notes

Martin Galway's directive reference for the Ocean 1987 assembler lives at
the repo root as `ocean_assembler_directives.txt`. That file is authoritative
for what the directives meant at the time. This document is where we
accumulate findings as we port `wizball.asm` — quirks, ambiguities, and
anything the directive doc glosses over.

Martin updated the directive reference on 2026-04-20, adding several
directives and expression operators that were not in the first release
(including `ADD`, `SUB`, `DSP`, `DFC`, and the expression operators
`MOD`, `OR`, `XOR`, `DIV`, `AND`). The table below is from the updated
version.

## Directive reference

| Directive    | Meaning                                       | KickAss equivalent          |
| ------------ | --------------------------------------------- | --------------------------- |
| `ORG $x`     | Set program counter                           | `* = $x`                    |
| `ENT`        | Entry point after assemble+transfer           | (no direct equivalent)      |
| `EQU`        | Define a label/constant (no memory)           | `.label X = ...`            |
| `DFS n`      | Reserve n bytes of uninitialised space        | virtual segment + `.fill`   |
| `DSP n,v`    | Define Space, filled with value `v`           | `.fill n, v`                |
| `DFB`        | Emit one byte (low 8 bits of expression)      | `.byte`                     |
| `DFW`        | Emit one 16-bit word (low 16 bits)            | `.word`                     |
| `DFL`        | Emit low byte of a 16-bit value               | `.byte <expr`               |
| `DFH`        | Emit high byte of a 16-bit value              | `.byte >expr`               |
| `DFM "…"`    | Emit ASCII bytes of a string                  | `.byte 'x','y',…`           |
| `DFC`        | Unclear — Martin notes "define characters?"   | not used in Wizball         |
| `ADD op`     | Pseudo-op: `CLC` + `ADC op`                   | explicit `clc; adc op`      |
| `SUB op`     | Pseudo-op: `SEC` + `SBC op`                   | explicit `sec; sbc op`      |
| `MOD/OR/XOR/DIV/AND` | Expression-evaluator operators         | KickAss supports directly   |

## Resolved questions and observations

### Q1: `DFB` — does it emit 1 byte or 2? **RESOLVED: 1 byte.**

Martin's directive doc describes `DFB` as "Define A Byte" but then says it
"deposits a 16-bit word", contradicting the name. Martin's updated text
preserves the same wording. Resolved by inspecting usage in `wizball.asm`
(18 occurrences):

- Multiple `DFB $2C` lines appear immediately before a 2-byte instruction
  as the classic 6502 "skip next two bytes" trick (assembling `$2C` in
  front of e.g. an `LDA zp` reinterprets the following two bytes as the
  operand of a harmless `BIT absolute`). This trick only works if `DFB`
  emits **exactly one byte**. Two bytes would desynchronise execution.
  See lines 534, 536, 1237, 1339, 1351, 1406, 1503, 1558, 1659.
- The keyboard scancode table at `kstable` (line 946) contains 64
  single-byte values laid out as `DFB 3,81,0,32,...` — clearly one byte
  per value.

**Conclusion:** `DFB` emits one byte (low 8 bits of expression). Translate
to KickAss `.byte`. The "16-bit word" phrasing in Martin's doc is a
long-standing typo.

### Q2: `ORG` + `DFS` in zero page

The source uses `ORG ZERO0` followed by a run of `DFS` to carve out
zero-page workspace. The Ocean assembler tracks a separate "program
counter" for these zero-page allocations without emitting anything into
the output binary. In KickAssembler this maps to a `virtual` segment so
labels receive addresses but no bytes land in the PRG. See
`../kickass-mapping/directives.md` for the chosen translation.

### Q3: character set of `DFM` — **N/A for Wizball.**

The doc says "ASCII". C64 ROM is PETSCII, not ASCII — would matter for
punctuation and lowercase. `DFM` is used 0 times in `wizball.asm`, so
this is not a concern for this port. Flag here in case a future port
(Athena, Times Of Lore, Insects In Space) of the 2nd-generation player
needs it.

### Q4: the "implicit-CLC" mystery — **RESOLVED by Martin's 2026-04-20 update.**

During the port we found that many `ADC PCn` sites in the music engine
(`addcN`, `addnN`, the stack-saving `ADC PCn` inside `callN`/`forN`)
appeared to rely on carry being clear even though no `CLC` preceded them.
The preceding dispatch `ADC #vtN-COM-1` in `read_byteN` always leaves
C=1 for valid opcodes in $C0..$EA, and that carry leaks through the
subsequent `STA` / `LDA` / `JMP (indirect)` into the handler. Without a
`CLC`, every `lda #N / jmp addcN` advances PC by N+1 instead of N and
the dispatcher silently skips the next opcode. We fixed the port by
inserting 12 explicit `clc` instructions.

Martin's updated directive reference documents two pseudo-instructions
that were absent from the first release:

    ADD   Packages a CLC with an ADC to save you some typing
    SUB   Packages an SEC with an SBC to save you some typing

This almost certainly explains what happened. Galway's original Ocean
source likely used `ADD PCn` at the carry-cleared sites, and the version
he shared here was transcribed to standard `ADC PCn` (either by Galway
himself or by the tool he used to export the source). Ocean's `ADD`
macro expanded to `CLC; ADC`, so the transcription lost the `CLC` and
the hand-readable source now reads slightly differently from what the
Ocean assembler actually generated.

**Port implication:** the explicit `clc` we inserted at each affected
site matches what Ocean's `ADD` pseudo-instruction would have emitted.
It's not a compensation for a bug — it's the byte-faithful equivalent.

`wizball.asm` as shared by Martin does not contain any `ADD` mnemonics
(we grepped), so the transcription must have resolved them all to `ADC`
before the file was shared. The 12 sites where we reinserted `clc` in
the port are the places Galway almost certainly wrote `ADD`.

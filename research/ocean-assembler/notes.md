# Ocean 1987 In-House Assembler — Research Notes

Martin Galway's directive reference for the Ocean 1987 assembler lives at the
repo root as `ocean_assembler_directives.txt`. That file is authoritative for
what the directives meant at the time. This document is where we accumulate
findings as we port `wizball.asm` — quirks, ambiguities, and anything the
directive doc glosses over.

## Confirmed directives (from `ocean_assembler_directives.txt`)

| Directive | Meaning                                   |
| --------- | ----------------------------------------- |
| `ORG`     | Set program counter                       |
| `ENT`     | Set entry point after assemble+transfer   |
| `EQU`     | Define a label/constant (not memory)      |
| `DFS n`   | Reserve n bytes of uninitialised space    |
| `DFB`     | Emit one byte (low 8 bits of expression)  |
| `DFW`     | Emit one 16-bit word (low 16 bits)        |
| `DFL`     | Emit low byte of a 16-bit value           |
| `DFH`     | Emit high byte of a 16-bit value          |
| `DFM "…"` | Emit ASCII bytes of a string              |

## Open questions

### Q1: `DFB` — does it emit 1 byte or 2? **RESOLVED: 1 byte.**
Martin's directive doc describes `DFB` as "Define A Byte" but then says it
"deposits a 16-bit word", contradicting the name. Resolved by inspecting usage
in `wizball.asm` (18 occurrences):

- Multiple `DFB $2C` lines appear immediately before a 2-byte instruction as
  the classic 6502 "skip next two bytes" trick (assembling `$2C` in front of
  e.g. an `LDA zp` reinterprets the following two bytes as the operand of a
  harmless `BIT absolute`). This trick only works if `DFB` emits **exactly one
  byte**. Two bytes would desynchronise execution. See lines 534, 536, 1237,
  1339, 1351, 1406, 1503, 1558, 1659.
- The keyboard scancode table at `kstable` (line 946) contains 64 single-byte
  values laid out as `DFB 3,81,0,32,...` — clearly one byte per value.

**Conclusion:** the directive doc has a typo in the `DFB` description; `DFB`
emits one byte (low 8 bits of expression). Translate to KickAss `.byte`.

### Q2: ORG + DFS in zero page
The source uses `ORG ZERO0` followed by a run of `DFS` to carve out zero-page
workspace. The Ocean assembler evidently tracks a separate "program counter"
for these zero-page allocations without emitting anything into the output
binary. In KickAssembler this maps to `.label` with an incrementing virtual
counter, or to a `.segment` with `Virtual` attribute — see
`../kickass-mapping/directives.md` for the chosen translation.

### Q3: character set of `DFM` — **N/A for Wizball.**
The doc says "ASCII". C64 ROM is PETSCII, not ASCII — would matter for
punctuation and lowercase. `DFM` is used 0 times in `wizball.asm`, so this is
not a concern for this port. Flag here in case a future port (Athena, Times
Of Lore, Insects In Space) of the 2nd-generation player needs it.

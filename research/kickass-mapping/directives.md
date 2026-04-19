# Ocean 1987 → KickAssembler Directive Mapping

Translation table from the Ocean in-house 1987 assembler directives (as
documented by Martin Galway in `../../ocean_assembler_directives.txt`) to
KickAssembler 5.x equivalents. Open questions from initial inspection of
`wizball.asm` are resolved in `../ocean-assembler/notes.md`.

## Direct translations

| Ocean          | KickAssembler            | Notes                                      |
| -------------- | ------------------------ | ------------------------------------------ |
| `ORG $1000`    | `* = $1000`              | Set program counter                        |
| `ENT`          | (see below)              | No direct equivalent — handled in harness  |
| `LABEL EQU $n` | `.label LABEL = $n`      | Pure constant, no memory emitted           |
| `DFB $12`      | `.byte $12`              | One byte (low 8 bits of expression)        |
| `DFW $1234`    | `.word $1234`            | One 16-bit word, little-endian             |
| `DFL word`     | `.byte <word`            | Low byte of a 16-bit expression            |
| `DFH word`     | `.byte >word`            | High byte of a 16-bit expression           |
| `DFS n`        | `.fill n, 0` *or* virtual| See "zero-page workspace" below            |
| `DFM "text"`   | `.text "text"`           | Not used in `wizball.asm`; see notes Q3    |

## Zero-page workspace: `ORG ZERO0` + `DFS`

Wizball uses the pattern:

```
ZERO0          EQU $0004
               ORG ZERO0
PC0            DFS 2
PC1            DFS 2
...
ZPSIZE         EQU .-PC0
```

The Ocean assembler tracks this as *virtual* allocation — labels get
addresses, but no bytes land in the output binary. The pattern ends with
`EQU .-PC0` to compute the total size, using `.` as the "current PC" operator.

**KickAssembler translation — preferred approach:**

```kickass
.label ZERO0 = $0004

* = ZERO0 "ZeroPage" virtual
PC0:    .fill 2, 0
PC1:    .fill 2, 0
// ...
.label ZPSIZE = * - PC0
```

Using a `virtual` segment tells KickAss to assign addresses without emitting
bytes into the .prg. The `*` symbol gives current PC, so `* - PC0` matches the
Ocean `.-PC0` idiom exactly.

## `ENT` (entry point)

The Ocean assembler's `ENT` marker defined the jump target after the
source-machine-to-target-machine transfer step — this was part of the physical
cross-development rig, not the binary format. KickAssembler has no direct
equivalent because modern `.prg` files encode only a load address, not an
entry point.

**Approach:** drop `ENT` from the translation. The harness (`src/harness/`)
will be responsible for calling `InitSound` and setting up the raster IRQ to
call the music play routine — exactly what `ENT` would have pointed at on the
target machine.

## Labels and local scope

Ocean used a single flat label namespace. KickAssembler supports scoped labels
via `.namespace` and local `!label` syntax, but for the faithful port we'll
keep the flat namespace to preserve Galway's names 1:1. Modernisation is a
second-pass concern, not a fidelity concern.

## Comments

Ocean uses `;` for line comments, same as KickAssembler. No translation
needed — preserve Galway's comments verbatim.

## Numeric literals

Both assemblers accept:
- `$XX` for hex
- decimal as bare digits
- `%XXXXXXXX` for binary

Character literals (`'A'`) and string expressions will be checked case-by-case
if they appear.

## Open items to watch during porting

1. **Self-modifying code near `DFB $2C`:** the skip-next-two-bytes trick is
   fragile under any reformatting. Preserve line structure around these
   constructs.
2. **`.-LABEL` size expressions:** `* - LABEL` works inside virtual segments
   (confirmed 2026-04-19 in `src/port/wizball.asm` — `ZPSIZE = * - PC0`
   assembles cleanly).
3. **Forward references in `EQU`:** KickAssembler uses multi-pass resolution
   so forward refs should just work. If we hit an ordering issue, swap to
   `.label` (which is strictly hoisted).

## Gotcha: restore `Default` segment after virtual-segment blocks

A library-style `.asm` file that ends in a `.segment ZeroPageN` leaves that
segment active after `#import`. Any `* = $xxxx` the importer writes next will
land *inside that virtual segment* — the PC changes and labels still resolve,
but nothing gets emitted to the PRG. Symptom: KickAss reports "Writing Symbol
file" but never "Writing prg file", and no `.prg` is produced.

**Fix:** end any library-style file with `.segment Default` to restore the
emitting segment before control returns to the importer.

Confirmed 2026-04-19 during the zero-page workspace port: without the
trailing `.segment Default`, the harness's `BasicUpstart` and code blocks
silently landed inside `ZeroPage2` and no PRG was produced.

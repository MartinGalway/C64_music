# C64_music

Music source files from 1980's Commodore 64 games

So that folks can read through, analyse & understand the music players and how
I went about doing my work. Feel free to re-assemble, modify & generate new
music. Please credit the original author of this work, Martin Galway. I am the
current copyright owner in all this music & programming code, but was not the
owner at the time it was created in the 1980's. I acquired the rights from
Infogrames later. "Wizball" used the "1st Generation" player, whose design had
been in use since 1984 thu about mid-1987. The 2nd Generation player was first
used on "Athena" - written for that game, in fact - and later on games like
Times Of Lore and Insects In Space

-Martin Galway April 14th 2026

---

# Wizball SID Player — KickAssembler Port

A faithful transcription of Martin Galway's 1987 Ocean Software "1st
Generation" SID music player (as used in Wizball) into a form that compiles
with modern KickAssembler and plays under VICE.

## Goals

1. **Preservation.** Preserve Galway's code and design intent exactly. No
   modernization, no restructuring, no renaming. All original comments,
   commented-out alternatives, and engineer-view debug displays stay intact.
2. **Reproducibility.** Anyone with KickAssembler + VICE can clone this repo
   and run the music on a modern machine.
3. **Scene contribution.** Offered back to Martin and the C64 retro community
   as a new way to study the 1st-gen player.

## Repository layout

- `wizball.asm` — Martin's original Ocean source, unchanged.
- `ocean_assembler_directives.txt` — Martin's notes on the Ocean assembler
  directives, unchanged.
- `src/port/wizball.asm` — the KickAssembler transcription.
- `src/harness/main.asm` — minimal BASIC upstart into Galway's original
  `Start` at `$1000`. Runs the demo as it would have in 1987, complete with
  the engineer-view debug screen.
- `src/harness/player.asm` — user-friendly listener harness with a credits /
  tune-select screen.
- `research/ocean-assembler/` — notes on Ocean assembler quirks and
  conventions discovered during the port.
- `research/kickass-mapping/` — directive translation table.
- `build/build.sh`, `build/run.sh` — assemble and launch.

## Building & running

Requires Java, KickAssembler 5.x, and VICE. Paths in `build/build.sh` can be
adjusted for your setup.

    ./build/build.sh src/harness/main.asm --d64
    ./build/run.sh build/out/main.prg

## Translation decisions worth knowing

### Ocean directives → KickAssembler

| Ocean       | KickAssembler         | Notes                         |
| ----------- | --------------------- | ----------------------------- |
| `ORG $x`    | `* = $x`              |                               |
| `ENT`       | (dropped)             | See harness for entry point.  |
| `EQU`       | `.label X = ...`      |                               |
| `DFB`       | `.byte`               | Doc typo resolved — 1 byte.   |
| `DFW`       | `.word`               |                               |
| `DFL / DFH` | `.byte <expr / >expr` |                               |
| `DFS n`     | `virtual` + `.fill`   | See ZP workspace notes below. |
| `DFM "…"`   | `.byte 'x','y',…`     | Explicit ASCII.               |

### Character literals and operators

- `&X` in Ocean → `'X'` in KickAssembler (ASCII byte).
- `^X` in Ocean (high byte, standalone) → `#>X` in KickAss (explicit
  immediate high-byte).
- Ocean's silent immediate-operand truncation (e.g. `LDX #256`) is made
  explicit here with `<` / `>` low/high-byte operators.

### Zero-page workspace

Galway uses `ORG ZEROn` + `DFS` to carve out zero-page allocations.
KickAssembler requires an explicit `virtual` segment so the labels receive
zero-page addresses without emitting bytes into the PRG.

### The `DFB $2C` skip-trick

Preserved byte-for-byte. The `$2C` emits a single byte that, at runtime,
becomes the opcode of a harmless `BIT absolute` whose operand is the
following 2-byte instruction. The jumps into `HANG0/HANG1/HANG2`,
`StopCl/StartCl`, and `sh5/sh6` rely on this.

### The `ADD` / `SUB` pseudo-instruction legacy

Galway's music-engine source has many `ADC PCn` sites (in `addcN`, `addnN`,
and the stack-saving `ADC PCn` inside `callN` / `forN`) that only give
correct PC advances if carry is clear on entry — yet the source writes no
`CLC` before them. The preceding dispatch `ADC #vtN-COM-1` in `read_byteN`
always leaves C=1 for valid opcodes in `$C0..$EA`, so with plain 6502
semantics every `lda #N / jmp addcN` advances PC by N+1 instead of N and
the dispatcher silently skips the next opcode.

Martin's 2026-04-20 update to `ocean_assembler_directives.txt` reveals why:
the Ocean in-house assembler had two pseudo-instructions absent from the
first release of the directives file:

> `ADD` — Packages a CLC with an ADC to save you some typing
> `SUB` — Packages an SEC with an SBC to save you some typing

Galway's original source almost certainly used `ADD PCn` at the affected
sites. Ocean's assembler expanded each `ADD` to `CLC; ADC`, which is what
the game binary actually executed. The version of `wizball.asm` shared
here was transcribed to standard 6502 mnemonics (all `ADC`, no `ADD`), and
in that conversion the implicit `CLC` was lost.

The port inserts 12 explicit `clc` instructions — one at each site where
Galway most likely wrote `ADD`. These are marked with `// PORT:` comments
in `src/port/wizball.asm`. The result is byte-faithful to what Ocean's
assembler would have produced from an `ADD`-containing original.

### Period-separated label names

Galway's Ocean source uses identifiers like `read.byte0`, `in.du.re.0`,
`get.tune.data`. KickAssembler reserves `.` for directive prefixes, so
periods in labels are mapped to `_` (`read_byte0`, `in_du_re_0`,
`get_tune_data`). Galway's deliberate naming asymmetries across channels are
preserved — e.g. `not_control0` on ch0 vs `not_ctrl1` / `not_ctrl2` on
ch1/ch2; `in_du_re_0` (trailing separator) vs `in_du_re1` / `in_du_re2` (no
trailing).

## Two harnesses

- **`main.asm` → `main.prg`** — boots straight into Galway's own `Start` at
  `$1000`, same boot experience as the 1987 rig. Auto-launches Filth Raid
  (tune B) on startup. Keyboard letters B-K select tunes, same dispatch
  logic he wrote. The visible "garbled" text on screen is `RefScreen1-4`
  dumping live engine state — Galway's real-time oscilloscope.
- **`player.asm` → `player.prg`** — listener-friendly harness for the retro
  scene. Shows a title, credits, and a printed key map. Runs its own
  raster-synced `REFRESH` loop and never calls `DREFRESH`, so the screen
  stays legible while the music plays. Uses Galway's own per-tune entry
  points (`FilthRaid`, `BonusMusic`, …) for track selection.

## Credits

- Music, engine, and original source: **Martin Galway** (1987, Ocean).
  Shared for preservation April 2026.
- KickAssembler: **Mads Nielsen**.
- KickAssembler port: **D. Westbury**.

arch snes.cpu

macro seek(variable offset) {
    origin (((offset - 0x2000) & 0x7fff))
    base 0x7e0000 | (offset)
}

output "snes-payload.bin", create

include "../asm-common/defs.asm"
include "../asm-common/gfx.asm

seek($2000)
    SNES_INIT(SLOWROM)
    sep #$30
    lda #%
MainLoop:
    WaitNMI()
    // insert vblank logic here


    // insert game logic here


    jmp MainLoop

GfxRegValsA:
    db $80, $02, $00, $00, $00, $09, $00, $60, $70, $80, $00, $00, $44

GfxRegValsB:
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $17, $00, $00, $00, $00, $00, $e0, $00
arch snes.cpu

macro seek(variable offset) {
    origin (((offset - 0x2000) & 0x7fff))
    base 0x7e0000 | (offset)
}

output "snes-payload.bin", create

include "../asm-common/defs.asm"

seek($2000)
    //SNES_INIT(SLOWROM)
    sep #$30
    lda.b #$00
    pha
    plb
    stz.w REG_CGWSEL
    stz.w REG_TM
    lda.b #%11111111
    sta.w REG_COLDATA
    lda.b #$20
    sta.w REG_CGADSUB
    lda.b #$0f
    sta.w REG_INIDISP
-;  bra -
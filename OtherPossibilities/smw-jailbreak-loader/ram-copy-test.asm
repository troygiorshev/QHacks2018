arch snes.cpu

macro seek(variable offset) {
  origin (offset & $7ff)
  base offset
}

// So we're gonna load from controller port 2

include "../asm-common/defs.asm"

output "smw-ram-copy-test.bin", create

constant dest($7fa000)

seek(0)
    fill $800

seek($ffff00)
    jmp test

seek($ffff10)
payload:
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

seek($ffff40)
test:
    sep #$34
    stz.w REG_NMITIMEN
    ldx.b #$20
-
    lda.l payload,x
    sta.l dest,x
    dex
    bpl -
    jml dest
arch snes.cpu

macro seek(variable offset) {
  origin (offset & $7ff)
  base offset
}

include "../asm-common/defs.asm"

output "smw.srm"

constant MEM_TMPBYTE($00)
constant MEM_DESTOFF($02)
constant MEM_LOOP($0f)
constant NUM_BYTES(18)
constant NUM_DATA_BYTES(16)

seek($ffff80)
    sei
    sep #$30
    lda.b #$80
    sta.w REG_INIDISP
    stz.w REG_NMITIMEN
    // interrupts disabled, screen off :)
    lda.b #$20
    sta.b MEM_DESTOFF+1
    stz.b MEM_DESTOFF
getData:
    lda.b #$01
    sta.w REG_JOYA
    jsr delayLoop
    stz.w REG_JOYA
    ldx.b #$00
-
    stz.b MEM_TMPBYTE
    ldy.b #$08
-
loadByte:
    lda.w REG_JOYB
    lsr
    lda.b MEM_TMPBYTE
    rol
    sta.b MEM_TMPBYTE
    jsr delayLoop
    dey
    bne -
afterLoadByte:
    sta.b $10,x
    inx
    cpx.b #(NUM_BYTES)
    bcc --

    lda.b $11
    ror
    bcc getData
    ror
    bcs runCode

    rep #$10
    lda.b #(NUM_DATA_BYTES-1)
    ldx.w #$0012
    ldy.b MEM_DESTOFF
    mvn $7e=$7e
    sty.b MEM_DESTOFF
    sep #$10
    bra getData

delayLoop:
    xba
    lda #$08
    -
    dec
    bne -
    xba
    rts

runCode:
    jml $7e2000

print origin()
print "\n"
if origin() >= 2048 {
    error "too big!!!\n"
}
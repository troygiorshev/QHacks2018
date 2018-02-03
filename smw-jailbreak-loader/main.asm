arch snes.cpu

macro seek(variable offset) {
  origin (offset & $7ff)
  base offset
}

// So we're gonna load from controller port 2

include "../asm-common/defs.asm"

output "smw.srm"

constant MEM_TMPBYTE($00)
constant MEM_SUMBYTE($01)
constant MEM_DESTPTR($02)
constant NUM_BYTES(12)

seek($ffff60)
    nop
    sei
    sep #$30
    lda.b #$80
    sta.w REG_INIDISP
    stz.w REG_NMITIMEN
getData:
    jsr waitForNMI
-
    lda.b #$01
    sta.w REG_JOYA
    ldx.b #$00 // this has to go in between to take up time
    stz.w REG_JOYA
-
    stz.b MEM_TMPBYTE
    stz.b MEM_SUMBYTE
    ldy.b #$08
-
    lda.w REG_JOYB // change to load from cont. 2
    lsr
    lda.b MEM_TMPBYTE
    rol
    sta.b MEM_TMPBYTE
    dey
    bne -
    sta.b $10,x
    clc
    adc.b MEM_SUMBYTE
    sta.b MEM_SUMBYTE
    inx
    cpx.b #(NUM_BYTES)
    bcc --

    lda.b MEM_SUMBYTE
    bne invalidPacket
    lda.b $10
    bne invalidPacket
    lda.b $11
    bit.b #$f2
    bne invalidPacket
    cmp.b #$0c
    bcc invalidPacket
    ror
    bcc getData

    // do processing
    lda.b $13

    cmp.b #$10
    bne +
    jmp [MEM_DESTPTR]
    +

    cmp.b #$11
    bne +
    ldx.b #$02
    -
    lda.b $14,x
    sta.b MEM_DESTPTR,x
    dex
    bmi getData
    +

    cmp.b #$12
    bne getData
    ldx.b #$00
    -
    lda.b $14,x
    sta [MEM_DESTPTR]
    inc.b MEM_DESTPTR
    bcc +
    inc.b (MEM_DESTPTR+1)
    +
    inx
    cpx.b #$08
    beq getData

invalidPacket:
    stz.w REG_CGWSEL
    stz.w REG_TM
    lda.b #%11101111
    sta.w REG_COLDATA
    lda.b #$0f
    sta.w REG_INIDISP
-;  bra -

waitForNMI:
-
    bit REG_RDNMI
    bpl -
    rts

print origin()
if origin() >= 2048 {
    error "too big!!!\n"
}
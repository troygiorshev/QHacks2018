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
constant MEM_DESTOFF($02)
constant MEM_LOOP($0f)
constant NUM_BYTES(12)

seek($ffff41)
patchB:
    jml $7e2000

seek($ffff46)
patchA:
    jsr delayLoop
    ldx.b #$00
    bra patchAA

seek($ffff50)
    rtl
    sei
    sep #$30
    lda.b #$80
    sta.w REG_INIDISP
    stz.w REG_NMITIMEN
getData:
//invalidPacket:
    jsr waitForNMI
-
    lda.b #$01
    sta.w REG_JOYA
    //ldx.b #$00 // this has to go in between to take up time
    // a2 00
    bra patchA
patchAA:
    stz.w REG_JOYA
    stz.b MEM_SUMBYTE
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
    clc
    adc.b MEM_SUMBYTE
    sta.b MEM_SUMBYTE
    inx
    cpx.b #(NUM_BYTES)
    bcc --

    lda.b MEM_SUMBYTE
    ora.b $10
    bne invalidPacket
    lda.b $11
    bit.b #$f2
    bne invalidPacket
    cmp.b #$0c
    bcc invalidPacket
    ror
    bcc getData

    // do processing
    lda.b $13 // overwritten with bra invalidPacket

    cmp.b #$10
    //bne +
    //jmp [MEM_DESTOFF]
    beq patchB
    nop
    nop
    //+

    cmp.b #$11
    bne +
    ldx.b #$02
    -
    lda.b $14,x
    sta.b MEM_DESTOFF,x
    dex
    bpl -
    bra getData
    +
    
    cmp.b #$12
    bne getData
    ldx.b #$00
    -
    lda.b $14,x
    sta [MEM_DESTOFF]
    inc.b MEM_DESTOFF
    bne +
    inc.b (MEM_DESTOFF+1)
    +
    inx
    cpx.b #$08
    bne -
    bra getData

 // latch is 12 us
invalidPacket:
greyScreen:
    // copy the packet for debugging purposes
    ldx.b #(NUM_BYTES-1)
-
    lda.b $10,x
    sta.w $0110,x
    dex
    bpl -

    // set screen colour
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

delayLoop:
    xba
    lda #$08
    -
    dec
    bne -
    xba
    rts

patchC:
    lda.b $14,x
    plx
    sta.l $7e2000,x
    bra patchCA

print origin()
print "\n"
if origin() >= 2048 {
    error "too big!!!\n"
}
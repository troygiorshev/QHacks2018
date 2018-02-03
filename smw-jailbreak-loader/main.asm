arch snes.cpu

macro seek(variable offset) {
  origin (offset & $FF)
  base offset
}

// So we're gonna load from controller port 2

seek($ffff80)
nop
sei
stz.w REG_NMITIMEN
rep #$10
sep #$20
ldx.w #$0000
-
lda.b #$01
sta.w REG_JOYSER1
nop ; nop
stz.w REG_JOYSER1
-
stz.b $00
ldy.w #$0008
-
lda.w REG_JOYSER1
lsr
lda.b $00
rol
sta.b $00
dey
bne -
sta.l $ffff70,x
inx
cpx.w #$0010
blt --
lda.b #$91
sta.w REG_NMITIMEN
arch snes.cpu

macro seek(variable offset) {
  origin ((offset & 0x7f0000) >> 1 | (offset & 0x7fff))
  base offset
}

output "snes-cart-loader.sfc", create

seek($008000)
fill $8000
seek($018000)
fill $8000

include "../asm-common/defs.asm"
include "../asm-common/header.asm"

seek($008000)
sei
clc
xce
rep #$30
lda.w #(payload.size-1)
ldx.w #(payload & 0xffff)
ldy.w #$2000
mvn $7e=(payload >> 16)
jml $7e2000

seek($018000)
insert payload, "../snes-payload/snes-payload.bin"
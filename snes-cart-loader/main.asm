arch snes.cpu

macro seek(variable offset) {
  origin (offset & $7ff)
  base offset
}

seek($8000)
fill $8000

include "../asm-common/defs.asm"
include "../asm-common/header.asm"

seek($8000)
sei
clc
xce

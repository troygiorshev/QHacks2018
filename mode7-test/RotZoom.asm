// SNES Mode7 Rotation & Zoom Demo by krom (Peter Lemon):
arch snes.cpu
output "RotZoom.sfc", create

macro seek(variable offset) {
  origin ((offset & $7F0000) >> 1) | (offset & $7FFF)
  base offset
}

seek($8000); fill $8000 // Fill Upto $7FFF (Bank 0) With Zero Bytes
include "LIB/SNES.INC"        // Include SNES Definitions
include "LIB/SNES_HEADER.ASM" // Include Header & Vector Table
include "LIB/SNES_GFX.INC"    // Include Graphics Macros
include "LIB/SNES_INPUT.INC"  // Include Input Macros

// Variable Data
seek(WRAM) // 8Kb WRAM Mirror ($0000..$1FFF)


seek($8000); Start:
  SNES_INIT(SLOWROM) // Run SNES Initialisation Routine

  LoadPAL(BGPal, $00, BGPal.size, 0) // Load Background Palette (BG Palette Uses 256 Colors)
  
  stz.w $2115
  lda.b #$00
  ldy.w #$0000
  -
  ldx.w #16
  sty.w $2116
  -
  sta.w $2118
  inc
  dex
  bne -
  sty.b $00
  pha
  lda.b #$80
  clc
  adc.b $00
  sta.b $00
  lda.b #$00
  adc.b $01
  sta.b $01
  ldy.b $00
  pla
  cmp.b #$00
  bne --

  lda.b #$01 // Enable Auto-Joypad
  sta.w REG_NMITIMEN
    
  // Setup Video
  lda.b #%00000111 // DCBAPMMM: M = Mode, P = Priority, ABCD = BG1,2,3,4 Tile Size
  sta.w REG_BGMODE // $2105: BG Mode 7, Priority 0, BG1 8x8 Tiles

  lda.b #$01   // Enable BG1
  sta.w REG_TM // $212C: Set BG1 To Main Screen Designation

  stz.w REG_M7SEL // $211A: Mode7 Settings

  sta.w $2115
  stz.w $2116
  stz.w $2117
  lda.b #$01
  sta.w $2119
  sta.w $2119
  sta.w $2119
  sta.w $2119
  sta.w $2119

  lda.b #$80
  sta.w $211b
  stz.w $211b
  stz.w $211c
  stz.w $211c
  stz.w $211d
  stz.w $211d
  sta.w $211e
  stz.w $211e

  stz.w REG_BG1HOFS // $210D: BG1 Position X Lo Byte
  stz.w REG_BG1HOFS // $210D: BG1 Position X Hi Byte

  lda.b #$ff
  sta.w REG_BG1VOFS // $210E: BG1 Position Y Lo Byte
  sta.w REG_BG1VOFS // $210E: BG1 Position Y Hi Byte

  stz.w REG_M7X // $211F: Mode7 Center Position X Lo Byte
  stz.w REG_M7X // $211F: Mode7 Center Position X Hi Byte

  stz.w REG_M7Y // $2120: Mode7 Center Position Y Lo Byte
  stz.w REG_M7Y // $2120: Mode7 Center Position Y Hi Byte

  lda.b #$F // Turn On Screen, Full Brightness
  sta.w REG_INIDISP // $2100: Screen Display



InputLoop: 
  WaitNMI() // Wait For Vertical Blank


  JoyA:
    ReadJOY({JOY_A}) // Test A Button
    beq JoyB // IF (A ! Pressed) Branch Down

  JoyB:
    ReadJOY({JOY_B}) // Test B Button
    beq JoyL // IF (B ! Pressed) Branch Down

  JoyL:
    ReadJOY({JOY_L}) // Test L Button
    beq JoyR // IF (L ! Pressed) Branch Down

  JoyR:
    ReadJOY({JOY_R}) // Test R Button
    beq JoyUp // IF (R ! Pressed) Branch Down

  JoyUp:
    ReadJOY({JOY_UP}) // Test Joypad UP Button
    beq JoyDown // IF (UP ! Pressed) Branch Down

  JoyDown:
    ReadJOY({JOY_DOWN}) // Test DOWN Button
    beq JoyLeft // IF (DOWN ! Pressed) Branch Down

  JoyLeft:
    ReadJOY({JOY_LEFT}) // Test LEFT Button
    beq JoyRight // IF (LEFT ! Pressed) Branch Down

  JoyRight:
    ReadJOY({JOY_RIGHT}) // Test RIGHT Button
    beq Finish // IF (RIGHT ! Pressed) Branch Down

Finish:
  jmp InputLoop


SetPixel:
  pha

  lda.b $00
  lsr
  sta.b $02
  and.b #$07
  sta.b $06

  lda.b $01
  lsr
  sta.b $04
  and.b #$07
  asl
  asl
  asl
  ora.b $06
  sta.b $06


// Character Data
// BANK 0
insert BGPal,   "GFX/BG.pal" // Include BG Palette Data (512 Bytes)

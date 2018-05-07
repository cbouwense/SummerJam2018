  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring
  

;;;;;;;;;;;;;;;

    
  .bank 0
  .org $C000 
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0200, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0300, x
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2


LoadPalettes:
  LDA $2002             ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006             ; write the high byte of $3F00 address
  LDA #$00
  STA $2006             ; write the low byte of $3F00 address
  LDX #$00              ; start out at 0
LoadPalettesLoop:
  LDA palette, x        ; load data from address (palette + the value in x)
                          ; 1st time through loop it will load palette+0
                          ; 2nd time through loop it will load palette+1
                          ; 3rd time through loop it will load palette+2
                          ; etc
  STA $2007             ; write to PPU
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
  BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down



LoadSprites:
  LDX #$00              ; start at 0
LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$20              ; Compare X to hex $20, decimal 32
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down
              
              

  LDA #%10000000   ; enable NMI, sprites from Pattern Table 1
  STA $2000

  LDA #%00010000   ; enable sprites
  STA $2001

Forever:
  JMP Forever     ;jump back to Forever, infinite loop
  

NMI:
  LDA #$00
  STA $2003       ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014       ; set the high byte (02) of the RAM address, start the transfer


LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       ; tell both the controllers to latch buttons


ReadA: 
  LDA $4016       ; player 1 - A
  AND #$01  ; only look at bit 0
  BEQ ReadADone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0203       ; load sprite X position
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $0203       ; save sprite X position
ReadADone:        ; handling this button is done
  

ReadB: 
  LDA $4016       ; player 1 - B
  AND #$01  ; only look at bit 0
  BEQ ReadBDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0203       ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $0203       ; save sprite X position
ReadBDone:        ; handling this button is done

ReadSelect:
  LDA $4016
  AND #$01
  BEQ ReadSelectDone
ReadSelectDone:

ReadStart:
  LDA $4016
  AND #$01
  BEQ ReadStartDone
ReadStartDone:

ReadUp:
  LDA $4016
  AND #$01
  BEQ ReadUpDone

UpPressed:
  LDX #$00
UpPressedLoop:
  LDA $0200, x    ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $0200, x    ; save sprite X position
  TXA             ; transfer value of x to a
  CLC             ; clear the carry bit
  ADC #$04        ; add 4 to contents of a
  TAX             ; transfer contents of a back to x
  CPX #$10        ; check if x is fifteen, if it is this means all the 
                  ; sprites have been moved
  BNE UpPressedLoop

ReadUpDone:

ReadDown:
  LDA $4016
  AND #$01
  BEQ ReadDownDone

DownPressed:
  LDX #$00
DownPressedLoop:
  LDA $0200, x    ; load sprite X position
  CLC             ; make sure carry flag is set
  ADC #$01        ; A = A + 1
  STA $0200, x    ; save sprite X position
  TXA             ; transfer value of x to a
  CLC             ; clear the carry bit
  ADC #$04        ; add 4 to contents of a
  TAX             ; transfer contents of a back to x
  CPX #$10        ; check if x is fifteen, if it is this means all the 
                  ; sprites have been moved
  BNE DownPressedLoop

ReadDownDone:

ReadLeft:

  LDA $4016
  AND #$01
  BEQ ReadLeftDone 

LeftPressed:
  LDX #$03
LeftPressedLoop:
  LDA $0200, x    ; load sprite X position
  SEC             ; make sure carry flag is set
  SBC #$01        ; A = A - 1
  STA $0200, x    ; save sprite X position
  TXA             ; transfer value of x to a
  CLC             ; clear the carry bit
  ADC #$04        ; add 4 to contents of a
  TAX             ; transfer contents of a back to x
  CPX #$13        ; check if x is fifteen, if it is this means all the 
                  ; sprites have been moved
  BNE LeftPressedLoop

ReadLeftDone:

ReadRight:
  LDA $4016
  AND #$01
  BEQ ReadRightDone
  
RightPressed:
  LDX #$03
RightPressedLoop:
  LDA $0200, x    ; load sprite X position
  CLC             ; make sure carry flag is set
  ADC #$01        ; A = A + 1
  STA $0200, x    ; save sprite X position
  TXA             ; transfer value of x to a
  CLC             ; clear the carry bit
  ADC #$04        ; add 4 to contents of a
  TAX             ; transfer contents of a back to x
  CPX #$13        ; check if x is fifteen, if it is this means all the 
                  ; sprites have been moved
  BNE RightPressedLoop

ReadRightDone:

  RTI             ; return from interrupt
 
;;;;;;;;;;;;;;  
  
  
  
  .bank 1
  .org $E000
palette:
  .db $0F,$17,$28,$39,$0F,$30,$26,$05,$0F,$20,$10,$00,$0F,$13,$23,$33
  .db $0F,$1C,$2B,$39,$0F,$06,$15,$36,$0A,$05,$26,$40,$22,$16,$27,$18

sprites:
     ;vert tile attr horiz
  .db $80, $00, $03, $80   ;sprite 0
  .db $80, $01, $03, $88   ;sprite 1
  .db $88, $02, $03, $80   ;sprite 2
  .db $88, $03, $03, $88   ;sprite 3

  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
  
  
;;;;;;;;;;;;;;  
  
  
  .bank 2
  .org $0000
  .incbin "mario.chr"   ;includes 8KB graphics file from SMB1
    .inesprg 1   ; 1x 16KB bank of PRG code
    .ineschr 1   ; 1x 8KB bank of CHR data
    .inesmap 0   ; mapper 0 = NROM, no bank swapping
    .inesmir 1   ; background mirroring (ignore for now)

    .bank 0
    .org $C000
;some code here

    .bank 1
    .org $E000
; more code here

    .bank 2
    .org $0000
; graphics here

    .bank 2
    .org $0000
    .incbin "mario.chr"   ;includes 8KB graphics file from SMB1

    .bank 1
    .org $FFFA     ;first of the three vectors starts here
    .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
    .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
    .dw 0          ;external interrupt IRQ is not used in this tutorial

    .bank 0
    .org $C000
RESET:
    SEI        ; disable IRQs
    CLD        ; disable decimal mode

    LDA %10000000   ;intensify blues
    STA $2001
Forever:
    JMP Forever     ;infinite loop
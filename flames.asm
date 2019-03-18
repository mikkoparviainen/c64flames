*=$1000
bsout=$ffd2
bkg=$d021
border=$d020
colmem=$d800
scrmem=$0400
rowstr=colmem+24*40
rowlen=40
        jsr init
        jsr flames
        rts
;scrptr  word $d800
;dataptr word array
flames  lda #<colors ; store color buffer ptr to cassette buffer
        sta $b2
        lda #>colors
        sta $b3

        lda #<rowstr ; first do the bottom line
        sta $fb
        lda #>rowstr
        sta $fc
        ldy #0
        lda #1
@loop   sta ($fb),y
        iny
        cpy #40
        bne @loop

        lda #<array ; $fb-$fc : ptr to array, $fd-$fe : ptr to colmem
        sta $fb
        lda #>array
        sta $fc
        lda #<colmem
        sta $fd
        lda #>colmem
        sta $fe

        ldx #24 ; never do the last row as it is white anyway
@outer  ldy #0 
@inner  lda ($fb),y
        sty tmpy

        lsr a
        lsr a
        lsr a
        lsr a
        tay
        lda ($b2),y

        ldy tmpy
        sta ($fd),y
        iny
        cpy #rowlen ; row
        bne @inner
        dex
        beq flamend
        clc
        lda $fb
        adc #rowlen
        sta $fb
        lda $fc
        adc #0
        sta $fc
        clc
        lda $fd
        adc #rowlen
        sta $fd
        lda $fe
        adc #0
        sta $fe
        jmp @outer
flamend rts
tmpy    byte 0

init    lda #0 ; 0 is black
        lda #5 ; 5 is green, for debug
        sta bkg
        lda #0 ; black for the border
        sta border
        lda #<scrmem
        sta $fb
        lda #>scrmem
        sta $fc
        lda #160 ; #160 block
        ;lda #230 ; #230 checkerboard pattern
        sta $fd
        jsr tuhat
        lda #<colmem
        sta $fb
        lda #>colmem
        sta $fc
        lda #$5
        sta $fd
        jsr tuhat
        rts

tuhat   ldx #4; $fb-$fc target, $fd number, x number of inner loops
touter  ldy #0
        lda $fd
tinner  sta ($fb),y
        iny
        cpy #250
        bne tinner
        dex
        beq tend
        lda $fb
        clc
        adc #250
        sta $fb
        lda $fc
        adc #0
        sta $fc
        jmp touter
tend    rts
array   dcb 40,0 ; stats for debug...
        dcb 40,$10
        dcb 40,$20
        dcb 40,$38
        dcb 40,$40
        dcb 40,$60
        dcb 360,$70
        dcb 40,$88
        dcb 80,$a0
        dcb 40,$b0
        dcb 40,$c8
        dcb 120,$e0
        dcb 40,$f0
        dcb 40,$ff
        ;dcb 24*40,0 ; start: 24 lines of empty
        ;dcb 40,1    ; and 1 line of white
colors  dcb 9,9,2,2,2,8,8,8,4,4,4,7,7,7,1,1
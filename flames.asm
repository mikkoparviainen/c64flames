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
flames  
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
@outer
        ldy #0 
@inner  lda ($fb),y
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
array   ;dcb 25*40,1 ; white for debug
        dcb 24*40,0 ; start: 24 lines of empty
        dcb 40,1    ; and 1 line of white

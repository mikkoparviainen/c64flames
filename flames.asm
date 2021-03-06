*=$1000
bsout=$ffd2
bkg=$d021
border=$d020
colmem=$d800
scrmem=$0400
rowstr=colmem+24*40
rowlen=40
decay=$10
randdecay=$5
randlimit=$f0
rand=$d41b ; sid voice 3 
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
        lda #1 ; 1 is white
@loop   sta ($fb),y
        iny
        cpy #40
        bne @loop

mainl   lda #<array ; $fb-$fc : ptr to array, $fd-$fe : ptr to colmem
        sta $fb
        lda #>array
        sta $fc
        lda #<colmem
        sta $fd
        lda #>colmem
        sta $fe

        ldx #24 ; never do the last row as it is white anyway
outer   ldy #0
inner   sty cur

        clc
        tya ; add 40 to y to point to the next row
        adc #rowlen ; never overflows because y goes only to rowlen (25)
        tay

        lda ($fb),y ; load the next row value
        cmp #$20
        bcs subt
        lda #0
        jmp cont
subt    sec
        sbc #decay
        jsr randsub
cont    pha ; save next row-$20 as current row on stack

        lsr a ; divide the number by 16 for an index into the
        lsr a ; color list
        lsr a
        lsr a
        tay
        lda ($b2),y

        ldy cur
        sta ($fd),y ; save the color to colmem

        pla ; get the current value from stack
        sta ($fb),y

        iny
        cpy #rowlen ; row
        ;cpy #2 ; debug with 2 columns
        beq noinner
        jmp inner
noinner dex
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
        jmp outer
flamend ;rts
        jmp mainl
cur     byte 0

randsub pha
        lda rand
        cmp #80
        bcs rand1
        pla
        rts
rand1   cmp #160
        bcs rand2
        pla
        jsr addl
        rts
rand2   pla
        jsr addl
        jsr addl
        rts

addl    cmp #randlimit
        bcc addreal
        lda #255
        rts
addreal clc
        adc #randdecay
        rts

init    lda #0 ; 0 is black
        ;lda #5 ; 5 is green, for debug
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
        lda #$0
        sta $fd
        jsr tuhat
        jsr randinit
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

randinit
        lda #$ff ; max freq for SID
        sta $d40e ; voice 3 freq low byte
        sta $d40f ; voice 3 freq hi byte
        lda #$80 ; noise waveform, gate bit off
        sta $d412 ; voice 3 control register
        rts

array   dcb 24*40,0 ; start: 24 lines of empty
        dcb 40,$ff    ; and 1 line of white
colors  dcb 0,0,12,15,9,9,2,2,8,8,8,7,7,7,1,1,1


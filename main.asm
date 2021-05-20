.nolist
.include "m2560def.inc"
.list
.def _checker  = r0
.def _temp1 = r16
.def _temp2 = r17
.def _temp3 = r18
.def _algo1 = r20 
.def _algo1_2 = r27
.def _algo2 = r21
.def _algo1_counter = r22
.def _algo2_counter = r23
.def _delay_temp4 = r24
.def _delay_temp5 = r25
.def _delay_temp6 = r26



    .CSEG 
	.org 0x00
  rjmp reset  
    .org OC3Aaddr 
  rjmp TIMER3_COMPA

TIMER3_COMPA:
  in _temp1, SREG 
  push _temp1
  sbrs _checker, 0
  rjmp algorithm
  cpi _algo1_counter, 4
  brlo paired_in_6_algo
  nop
  cpi _algo1_counter, 5
  brge unpaired_in_6_algo
  unpaired_in_6_algo:
    lsr _algo1_2
    out PORTA, _algo1_2
    lsr _algo1_2
    inc _algo1_counter
    rjmp algorithm
  
    
  clt 
  bld _checker, 0 
  rjmp algorithm
  
  paired_in_6_algo:
    out PORTA, _algo1 
    lsr _algo1
    lsr _algo1
    inc _algo1_counter

algorithm:
  sbrs _checker, 1 
  rjmp return
  cpi _algo2_counter, 9
  brlo in_algo_1
  
  clr _algo2
  out PORTC, _algo2
  clt
  bld _checker, 1
  rjmp return
  in_algo_1:
    out PORTC, _algo2
    lsl _temp3
    mov _algo2, _temp3
    inc _algo2_counter
return:
  pop _temp1
  out SREG, _temp1
  reti
;--------------------------------------------------------------------
reset:
  ldi  _temp1, low(RAMEND)
  out SPL, _temp1
  ldi _temp1, high(RAMEND)
  out SPH, _temp1
  ldi _temp1, 0xFF
  ldi _temp2, 0x00
  out DDRA, _temp1
  out DDRC, _temp1
  out PORTA, _temp2
  out PORTC, _temp2
  ldi _temp1, (1 << 3)|(1 << 5)
  sts DDRK, _temp2
  sts PORTK, _temp1
  sbi DDRD, 0
  cbi PORTD, 0
  ;-----------
  ldi _temp1, 0x0C
  ldi _temp2, 0x34
  sts  OCR3AH, _temp1
  sts OCR3AL, _temp2
  ldi _temp1, 0x00
  sts TCCR3A, _temp1
  ldi _temp1, (1 << WGM32) | (1 << CS32)
  sts TCCR3B, _temp1
  ldi _temp1, (1 << OCIE3A)
  sts TIMSK3, _temp1

  clr _checker
  clr _temp1
  clr _temp2
  clr _temp3
  clr _algo1
  clr _algo1_2
  clr _algo1_counter
  clr _algo2
  clr _algo2_counter
  clr _delay_temp4   
  clr _delay_temp5         
  clr _delay_temp6
  sei 

main:  
    clt
    lds  _temp2, PINK
    sbrc _temp2, 3
    rjmp next_button
    rcall delay
    lds  _temp2, PINK
    sbrs _temp2, 3
    rcall button_1_is_pressed
  next_button:
    lds  _temp2, PINK
    sbrc _temp2, 5
    rjmp main
    rcall delay
    lds  _temp2, PINK
    sbrs _temp2, 5
    rcall button_2_is_pressed
    rjmp main

button_1_is_pressed:
    clr _algo1_counter
    ldi _algo1, 1<<7
    ldi _algo1_2,1<<7 
    set
    bld _checker, 0
    rcall buzzer
    ret

button_2_is_pressed:
    clr _algo2_counter
    ldi _temp3, 1
    mov _algo2, _temp3
    set
    bld _checker, 1
    rcall buzzer
    ret
  
buzzer:
  sbi  PORTD, 0
  rcall delay
  cbi  PORTD, 0
  ret  
       
delay:       
  ldi _delay_temp4, 0xFF      
  ldi _delay_temp5, 0xFF
  ldi _delay_temp6, 1 
  del:                
    subi _delay_temp4, 1       
    sbci _delay_temp5, 0          
    sbci _delay_temp6, 0  
  brcc del     
ret               

; EEPROM
  .ESEG

;
; P1.asm
;
; Created: 07.10.2023 21:20:39
; Author : gx
;

; include proccessor library
.include "m328pdef.inc"

.cseg

; define consts
.equ F_CPU = 16000000
.equ Prescaler = 1024
.equ DelayCycles = (F_CPU / Prescaler) / 5 ; timer iterations for desired delay of 5 times per second

; init reset vector
.org 0x0000
	rjmp init

init:
	; init stack pointer
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16
	
	; set output of pa0-7 for DDRD and pa0-1 for DDRB
	ldi r16, 0b11111111
	out DDRD, r16
	ldi r16, 0b00000011
	out DDRB, r16

	; set timer control register to internal clk/1024 prescaler with ctc active / should skip one cycle at start to synchronize << 0b00010101
	ldi r18, (1 << WGM12) | (1 << CS10) | (1 << CS12)
	sts TCCR1B, r18

	; assign delay to automatic compare register
	ldi r18, high(DelayCycles)
	sts OCR1AH, r18

	ldi r18, low(DelayCycles)
	sts OCR1AL, r18

	; enter main
	rjmp main


main:
	; init reset and shifting light
	ldi r17, 0b00000000
	ldi r16, 0b00000001

	; init PORTD and PORTB lights to unset (probably not neccessary)
	; out PORTB, r17
	; out PORTD, r17

	; start infinite loop of shifting lights
	rcall lleft_portd


lleft_portd:
	; write to PORTD 0-7
	out PORTD, r16

	; shift active light left by one
	rol r16

	; delay action by specified time
	rcall delay

	; continue current loop if carry bit not set
	brcc lleft_portd
	
	; clear carry bit / rotate carry bit further
	rol r16

	; deactivate lights for PORTD
	out PORTD, r17

	; jump to PORTB set
	rjmp lleft_portb


lleft_portb:
	; check if last light on port is reached and jump to shifting right
	cpi r16, 0b00000010
	clc
	breq lright_portb

	; write to PORTB 0-1
	out PORTB, r16

	; shift active light left by one
	rol r16

	; delay action by specified cycles
	rcall delay

	; continue current loop if predefined end not reached
	rjmp lleft_portb


lright_portb:
	; write to PORTB 0-1
	out PORTB, r16

	; shift active light right by one
	ror r16

	; delay action by specified time
	rcall delay

	; continue current loop if carry bit not set
	brcc lright_portb
	
	; clear carry bit / rotate carry bit further
	ror r16

	; deactivate lights for PORTB
	out PORTB, r17

	; jump to PORTD set
	rjmp lright_portd


lright_portd:
	; check if last light on port is reached and jump to shifting left
	cpi r16, 0b00000001
	clc
	breq lleft_portd

	; write to PORTD 0-7
	out PORTD, r16

	; shift active light right by one
	ror r16

	; delay action by specified cycles
	rcall delay

	; continue current loop if predefined end not reached
	rjmp lright_portd

delay:
	; sbis skips next instuction if OCF1A bit is set inside of clock specific status register to end delay
	sbis TIFR1, OCF1A
	rjmp delay

	; clear register bit for the next time
	sbi TIFR1, OCF1A

	ret

end:
	; never reached

.exit
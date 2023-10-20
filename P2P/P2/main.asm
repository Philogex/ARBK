;
; P2.asm
;
; Created: 20.10.2023 16:57:17
; Author : gx
;


.include "m328pdef.inc"

.cseg

.def led_state_d0d9 = r17 ; 4bit d0-logic + 4bit d9-logic ; Reset idx3 (should never be set), Blink idx2, On idx1, Off idx0
.def led_output = r18
.def led_blinker = r19
.def d0_inverter = r20
.def d9_inverter = r21

.equ F_CPU = 16000000
.equ Prescaler = 1024
.equ DelayCycles = (F_CPU / Prescaler) / 5

.org 0x0000
    rjmp init

init:
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16

	ldi r16, (0 << DDD0) | (0 << DDD1) ; 0b00000000
	out DDRD, r16 ; PD0 / PD1 for SW1 / SW2 respectively

	ldi r16, 0b11111111
    out PORTD, r16 ; pullup for Input

    ldi r16, (1 << DDB0) | (1 << DDB1) ; 0b00000011
	out DDRB, r16 ; PB0 / PB1 for D0 / D9 LED output respectively 

	ldi d0_inverter, (1 << 0)
    ldi d9_inverter, (1 << 1)

	ldi led_state_d0d9, (1 << 4) | (1 << 0)

    ldi r16, (1 << WGM12) | (1 << CS10) | (1 << CS12) ; CTC and 1024 Prescaler
    sts TCCR1B, r16

    ldi r16, low(DelayCycles)
    sts OCR1AL, r16

    ldi r16, high(DelayCycles)
    sts OCR1AH, r16

main_loop:
    ; delay
    sbis TIFR1, OCF1A
    rjmp main_loop

    sbi TIFR1, OCF1A

	sbis PIND, 0
	rcall sw1_handler

	sbis PIND, 1
	rcall sw2_handler

    ; d0_off
    sbrc led_state_d0d9, 4
    ldi led_output, (0 << DDB0)
    ; d9_off
    sbrc led_state_d0d9, 0
    ldi led_output, (0 << DDB1)

    ; d0_on
    sbrc led_state_d0d9, 5
    ldi led_output, (1 << DDB0)
    ; d9_on
    sbrc led_state_d0d9, 1
    ldi led_output, (1 << DDB1)

    ; d0_blink
    sbrc led_state_d0d9, 6
    eor led_output, d0_inverter
    ; d9_blink
    sbrc led_state_d0d9, 2
    eor led_output, d9_inverter

    out PORTB, led_output

    rjmp main_loop

sw1_handler:
    sbrc led_state_d0d9, 4
	rjmp d0_on
	sbrc led_state_d0d9, 5
	rjmp d0_blink
	sbrc led_state_d0d9, 6
	rjmp d0_off
d0_on:
    ldi led_state_d0d9, (1 << 5) | (1 << 0)
	ret
d0_blink:
	ldi led_state_d0d9, (1 << 6) | (1 << 0)
	ret
d0_off:
	ldi led_state_d0d9, (1 << 4) | (1 << 0)
	ret

sw2_handler:
    sbrc led_state_d0d9, 0
	rjmp d9_on
	sbrc led_state_d0d9, 1
	rjmp d9_blink
	sbrc led_state_d0d9, 2
	rjmp d9_off
d9_on:
    ldi led_state_d0d9, (1 << 1) | (1 << 4)
	ret
d9_blink:
	ldi led_state_d0d9, (1 << 2) | (1 << 4)
	ret
d9_off:
	ldi led_state_d0d9, (1 << 0) | (1 << 4)
	ret

.exit
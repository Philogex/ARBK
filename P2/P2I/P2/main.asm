;
; P2.asm
;
; Created: 19.10.2023 17:15:13
; Author : gx
; Description: Uses PB0 and PB1 to control D0 and D9 respectively, as well as PD2 and PD3 as interrupt inputs connected to SW1 and SW2 respectively
;

.include "m328pdef.inc"

.cseg

.def led_state_d0d9 = r17 ; 4bit d0-logic + 4bit d9-logic ; Reset idx3 (should never be set), Blink idx2, On idx1, Off idx0
.def led_output = r18
.def led_blinker = r19
.def d0_inverter = r20
.def d9_inverter = r21
.def ret_addr = r22

.equ F_CPU = 16000000
.equ Prescaler = 1024
.equ DelayCycles = (F_CPU / Prescaler) / 5

.org 0x0000
    rjmp init

.org INT0addr
    rjmp int0_handler

.org INT1addr
    rjmp int1_handler

init:
	; init stack pointer
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16

	; set input
	ldi r16, (0 << DDD2) | (0 << DDD3) ; 0b00000000
	out DDRD, r16 ; PD2 / PD3 for SW1 / SW2 respectively
	ldi r16, 0b11111111
    out PORTD, r16 ; pullup for Input

	; set output
    ldi r16, (1 << DDB0) | (1 << DDB1) ; 0b00000011
	out DDRB, r16 ; PB0 / PB1 for D0 / D9 LED output respectively 

	; init inverter registers
	ldi d0_inverter, (1 << 0)
    ldi d9_inverter, (1 << 1)

	; init led FSM
	ldi led_state_d0d9, (1 << 4) | (1 << 0)

    ; init timer
    ldi r18, (1 << WGM12) | (1 << CS10) | (1 << CS12)
	sts TCCR1B, r18

    ; init compare register for timer
    ldi r18, high(DelayCycles)
	sts OCR1AH, r18
	ldi r18, low(DelayCycles)
	sts OCR1AL, r18

	; rising edge for both interrupts
	ldi r16, (1 << ISC01) | (1 << ISC11)
    sts EICRA, r16
	; enable external interrupt source INT0 and INT1 [EIFR (1 << INTF1) | (1 << INTF0) can be set now]
    ldi r16, (1 << INT1) | (1 << INT0)
    out EIMSK, r16

    ; enable interrupts
    sei

main_loop:
    ; keep in mind, that this main loop can be interrupted at any point, and has to be as fool proof as possible.

	rcall delay

    ; d0_off
    sbrc led_state_d0d9, 4
    andi led_output, ~(1 << PINB0)
    ; d9_off
    sbrc led_state_d0d9, 0
    andi led_output, ~(1 << PINB1)

    ; d0_on
    sbrc led_state_d0d9, 5
    ldi led_output, (1 << PINB0)
    ; d9_on
    sbrc led_state_d0d9, 1
    ldi led_output, (1 << PINB1)

    ; d0_blink
    sbrc led_state_d0d9, 6
    eor led_output, d0_inverter
    ; d9_blink
    sbrc led_state_d0d9, 2
    eor led_output, d9_inverter

    out PORTB, led_output

    rjmp main_loop

delay:
    sbis TIFR1, OCF1A
    rjmp delay

    sbi TIFR1, OCF1A

	ret

int0_handler:
	pop ret_addr
    sbrc led_state_d0d9, 4
	rjmp d0_on
	sbrc led_state_d0d9, 5
	rjmp d0_off
	sbrc led_state_d0d9, 6
	rjmp d0_blink
d0_on:
	ldi led_state_d0d9, (1 << 5) | (1 << 0)
	push ret_addr
	reti
d0_off:
	ldi led_state_d0d9, (1 << 6) | (1 << 0)
	push ret_addr
	reti
d0_blink:
	ldi led_state_d0d9, (1 << 4) | (1 << 0)
	push ret_addr
	reti

int1_handler:
	pop ret_addr
    sbrc led_state_d0d9, 0
	rjmp d9_on
	sbrc led_state_d0d9, 1
	rjmp d9_off
	sbrc led_state_d0d9, 2
	rjmp d9_blink
d9_on:
	ldi led_state_d0d9, (1 << 1) | (1 << 4)
	push ret_addr
	reti
d9_off:
	ldi led_state_d0d9, (1 << 2) | (1 << 4)
	push ret_addr
	reti
d9_blink:
	ldi led_state_d0d9, (1 << 0) | (1 << 4)
	push ret_addr
	reti

.exit
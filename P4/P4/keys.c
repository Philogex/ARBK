/*
 * keys.c
 *
 * Created: 22.10.2023 16:22:38
 *  Author: gx
 */ 

#include "keys.h"

void init() {
	//PORTD as output
	DDRD = 0b11111111;
	PORTD |= (1 << PIND0);
	
	//input for switches with pull up resistor
	DDRB = (0 << DDB0) | (0 << DDB1);
	PORTB |= (1 << PINB0) | (1 << PINB1);
	
	//cli();
	//allow interrupts for the two switches
	PCICR |= (1 << PCIE0);
	PCMSK0 |= (1 << PCINT0) | (1 << PCINT1);
	
	sei();
}
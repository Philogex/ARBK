/*
 * keys.c
 *
 * Created: 22.10.2023 16:22:38
 *  Author: gx
 */ 

void init() {
	// PORTD as output. *10 bit + 7 value bits
	DDRD |= 0b11111111;
	
	// input for switches with pull up resistor
	DDRB |= (0 << DDB0) | (0 << DDB1);
	PORTB |= (1 << DDB0) | (1 << DDB1);
	
	// allow interrupts for the two switches
	PCICR |= (1 << PCIE0) | (1 << PCIE1);
	PCMSK0 |= (1 << PCINT0) | (1 << PCINT1);
	
	sei();
}
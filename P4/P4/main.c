/*
 * P4.c
 *
 * Created: 22.10.2023 16:20:55
 * Author : gx
 * Description: Connect SW1 to PB0 and SW2 to PB1. Connect PD0 to a, PD1 to b, ..., PD6 to g and PD7 to A.
 */ 

#include <avr/io.h>

#include "keys.h"
#include "sevenseg.h" 


volatile uint8_t number1 = 0;
volatile uint8_t number2 = 0;

ISR(PCINT0_vect) {
	if(!(PINB & (1 << PB0))) {
		number1++;
		if(number1 == 10) {
			number1 = 0;
			number2++;
		}
		if(number2 == 10) {
			number1 = 0;
			number2 = 0;
		}
	}
	if(!(PINB & (1 << PB1))) {
		if(number1 == 0) {
			if(number2 == 0) {
				number1 = 9;
				number2 = 9;
			}
			else {
				number2--;
				number1 = 9;
			}
		}
		else {
			number1--;
		}
	}
}

int main(void)
{
	init();
	while(1) {
		display(number1, number2);
		_delay_ms(5);
	}
}


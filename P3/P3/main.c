/*
 * P3.c
 *
 * Created: 21.10.2023 02:11:29
 * Author : gx
 * Description: PB0 connected to any LED (ex. D0). i literally have no idea what the point of this is. we already had a timer, but put it into a function now
 */ 
#include <avr/io.h>

#define F_CPU 16000000UL
#define Prescaler 264

#include <avr/interrupt.h>
#include <util/delay.h>

volatile uint32_t systemClock = 0;

// compare match interrupt
ISR(TIMER1_COMPA_vect)
{
	systemClock++;
}

void init()
{
	// CTC mode, 64 Prescaler
	TCCR1B = (1 << WGM12) | (1 << CS11) | (1 << CS10);
	OCR1A = (F_CPU / Prescaler) / 1000;
	// enable interrupts for compare match
	TIMSK1 = (1 << OCIE1A);
	sei();
}

void waitFor(uint32_t ms)
{
	// error prone due to overflow during targetTime calculation. it still works, but not as expected
	uint32_t targetTime = systemClock + ms;
	while (systemClock < targetTime)
	;
}

void waitUntil(uint32_t ms)
{
	while (systemClock < ms)
	;
}

int main()
{
	init();
	DDRB |= (1 << DDB0);
	
	waitUntil(2000);
	while (1)
	{
		PORTB ^= (1 << DDB0);
		// one sec delay
		waitFor(1000);
	}

	return 0;
}


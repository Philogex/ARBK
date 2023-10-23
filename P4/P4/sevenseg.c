/*
 * sevenseg.c
 *
 * Created: 22.10.2023 16:21:47
 *  Author: gx
 */

#include "sevenseg.h"

//inverted 7-Segment Display
/*
6 5 4 3 2 1 0
g c b a f e d
*/
const uint8_t numbers[] = {
	0b01000000, //0
	0b01001111, //1
	0b00100100, //2
	0b00000110, //3
	0b00001011, //4
	0b00010010, //5
	0b00010000, //6
	0b01000111, //7
	0b00000000, //8
	0b00000010  //9
};

void display(uint8_t number1, uint8_t number2) {
	// lower number
	PORTD = numbers[number1] | (1 << 7);
	_delay_ms(5);
	// higher number
	PORTD = numbers[number2];
}
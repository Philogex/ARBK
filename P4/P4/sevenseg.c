/*
 * sevenseg.c
 *
 * Created: 22.10.2023 16:21:47
 *  Author: gx
 */

//inverted 7-Segment Display
const uint8_t numbers[] = {
	0b01000000,
	0b01111001,
	0b00100100,
	0b00110000,
	0b00011001,
	0b00010010,
	0b00000010,
	0b01111000,
	0b00000000,
	0b00010000
};

void display(const uint8_t number1, const uint8_t number2) {
	// lower number
	PORTD = numbers[number1];
	// higher number
	PORTD = numbers[number2] | (1 << 7);
}
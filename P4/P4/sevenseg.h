/*
 * sevenseg.h
 *
 * Created: 22.10.2023 16:22:08
 *  Author: gx
 */ 


#ifndef SEVENSEG_H_
#define SEVENSEG_H_

#define F_CPU 16000000UL

#include <avr/io.h>
#include <util/delay.h>

void display(const uint8_t number1, const uint8_t number2);

#endif /* SEVENSEG_H_ */
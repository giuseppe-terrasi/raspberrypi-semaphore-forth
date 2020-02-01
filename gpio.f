HEX
3F200000 CONSTANT GPFSEL0
3F20001C CONSTANT GPSET0
3F200028 CONSTANT GPCLR0
3F200034 CONSTANT GPLEV0

DECIMAL

\ GPIO ( n -- n ) takes GPIO pin number and test if is lower then 27 otherwise abort
: GPIO DUP 30 > IF ABORT THEN ;

\ MODE ( n -- a b c) takes GPIO pin number and leaves on the stack the number of left shift bit (a) required to set the corresponding GPIO control bits of GPFSELN,
\  where N is the register number, along with the GPFSELN register address (b) and the current value stored at (c) cleared by a MASK;
\ N ad (a) are calculated by dividing GPIO number by 10; N is the quotient multiplied by 4 while a is the reminder. Then GPFSELN is calculated by GPFSEL0 + N
\ ( e.g. GPIO 21 is controlled by GPFSEL2 so 21 / 10 --> N = 2 * 4, a = 1 --> GPFSEL0 + 8 = GPFSEL2 )
\ MASK is used to clear the 3 bits of GPFSEL register which controls GPIO states using INVERT AND and the value (a)
\ The mask is obtained by left shifting 7 (111 binary ) by 3 * (remainder of 10 division), e.g 21 / 10 -> 3 * 1 -> 7 left shifted by 3 ).
: MODE 10 /MOD 4 * GPFSEL0 + SWAP 3 * DUP 7 SWAP LSHIFT ROT DUP @ ROT INVERT AND ROT ;

\ OUTPUT (a b c -- ) taskes the output of MODE and then set the GPFSELN register of the corresponding GPIO as output.
\ The GPFSELN bit which controls GPIO output is set by the OR operation between the current value of GPFSELN, cleared by the mask, and a 1 left shifted by the reminder of 10
\ division multiplyed by 3. (001 value in the corresponding bit position of GPFSELN set GPIO as OUTPUT)
\ e.g with GPIO 21 AND @GPFSEL2: 011010--> 111000 011010 INVERT AND --> 000010 001000 OR --> 001010
: OUTPUT 1 SWAP LSHIFT OR SWAP ! ;

\ INPUT (a b c -- ) taskes the output of MODE and then set the GPFSELN register of the corresponding GPIO as input.
\ Same as OUTPUT but drop the not necessary shift value and the GPFSELN bit which controls GPIO input is set by the 
\ INVERT AND operation between the current value of GPFSELN, cleared by the mask,
: INPUT 1 SWAP LSHIFT INVERT AND SWAP ! ;

\ ON ( n -- ) takes GPIO pin number, left shift 1 by this number and set the corresponding bit of GPCLR0 register
: ON 1 SWAP LSHIFT GPCLR0 ! ;

\ OFF ( n -- ) takes GPIO pin number, left shift 1 by this number and set the corresponding bit of GPSET0 register
: OFF 1 SWAP LSHIFT GPSET0 ! ;

\ LEVEL ( n -- b ) takes GPIO pin number, left shift 1 by this number, get current value of GPLEV0 register and leaves on the stack the value of the corresponding 
\ GPIO pin number bit
: LEVEL 1 SWAP LSHIFT GPLEV0 @ SWAP AND ;
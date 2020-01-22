\ include jonesforth.f

HEX
3F200000 CONSTANT GPFSEL0
3F20001C CONSTANT GPSET0
3F200028 CONSTANT GPCLR0
3F200034 CONSTANT GPLEV0

100000 CONSTANT WAIT_TIME

DECIMAL

20 CONSTANT RED_LED_A
21 CONSTANT YELLOW_LED_A
26 CONSTANT GREEN_LED_A

19 CONSTANT RED_LED_P
13 CONSTANT YELLOW_LED_P
6  CONSTANT GREEN_LED_P

5  CONSTANT BUTTON

\ SET_GPIO_OUTPUT ( n -- ) takes GPIO pin number and set the corresponding bit of GPFSELN register where N is the register number which controls the GPIO.
\ N is calculated multipling the quotient of 10 division by 4 and add the result to GPFSEL0 ( e.g. GPIO 21 is controlled by GPFSEL2 so 21 / 10 --> GPFSEL0 + 8 = GPFSEL2 )
\ A Mask is used to clear the 3 bits of GPFSEL register which controls GPIO states using INVERT AND 
\   ( mask is obtained by left shifting 7 (111 binary ) by 3 * (remainder of 10 division), e.g 21 / 10 -> 3 * 1 -> 7 left shifted by 3 ).
\ The GPFSELN bit which controls GPIO output is set by the OR operation between the current value of GPFSELN, cleared by the mask, and a 1 left shifted by GPIO number position
\ e.g with GPIO 21 AND @GPFSEL2: 011010--> 111000 011010 INVERT AND --> 000010 001000 OR --> 001010

: SET_GPIO_OUTPUT 10 /MOD 4 * GPFSEL0 + SWAP 3 * 1 SWAP DUP ROT SWAP LSHIFT 7 ROT LSHIFT ROT DUP @ ROT INVERT AND ROT OR SWAP ! ;
: SET_GPIO_INPUT 10 /MOD 4 * GPFSEL0 + SWAP 3 * 7 SWAP LSHIFT SWAP DUP @ ROT INVERT AND ! ;


\ SET_GPIO_ON ( n -- ) takes GPIO pin number, left shift 1 by this number and set the corresponding bit of GPCLR0 register
: SET_GPIO_ON 1 SWAP LSHIFT GPCLR0 ! ;

\ SET_GPIO_ON ( n -- ) takes GPIO pin number, left shift 1 by this number and set the corresponding bit of GPSET0 register
: SET_GPIO_OFF 1 SWAP LSHIFT GPSET0 ! ;

\ SET_GPIO_ON ( n -- b ) takes GPIO pin number, left shift 1 by this number, get current value of GPLEV0 register and leaves on the stack the value of the corresponding GPIO pin number bit
: GET_GPIO_LEV 1 SWAP LSHIFT GPLEV0 @ SWAP AND ;

\ INIT_OUTPUT ( n -- ) set the output state to the semaphore's GPIO.
: INIT_OUTPUT RED_LED_A SET_GPIO_OUTPUT YELLOW_LED_A SET_GPIO_OUTPUT GREEN_LED_A SET_GPIO_OUTPUT RED_LED_P SET_GPIO_OUTPUT YELLOW_LED_P SET_GPIO_OUTPUT GREEN_LED_P SET_GPIO_OUTPUT ;

\ INIT_OUTPUT ( n -- ) initializes the state of the semaphore's LEDs.
: INIT_STATE  RED_LED_A SET_GPIO_ON YELLOW_LED_A SET_GPIO_OFF GREEN_LED_A SET_GPIO_OFF RED_LED_P SET_GPIO_OFF YELLOW_LED_P SET_GPIO_OFF GREEN_LED_P SET_GPIO_ON ;

: DELAY BEGIN 1 - DUP 0 = UNTIL DROP ;

: PEDESTRIAN_YELLOW GREEN_LED_P SET_GPIO_OFF YELLOW_LED_P SET_GPIO_ON ;
: PEDESTRIAN_RED RED_LED_P SET_GPIO_ON YELLOW_LED_P SET_GPIO_OFF RED_LED_A SET_GPIO_OFF GREEN_LED_A SET_GPIO_ON ;
: PEDESTRIAN_GREEN GREEN_LED_P SET_GPIO_ON RED_LED_P SET_GPIO_OFF YELLOW_LED_A SET_GPIO_OFF RED_LED_A SET_GPIO_ON ;
: AUTO_YELLOW  GREEN_LED_A SET_GPIO_OFF YELLOW_LED_A SET_GPIO_ON ;

: SEMAPHORE_ROUTINE 
." PEDESTRIAN_YELLOW " CR
 PEDESTRIAN_YELLOW WAIT_TIME DELAY 
 ." PEDESTRIAN_RED " CR 
 PEDESTRIAN_RED WAIT_TIME DELAY  
 ." AUTO_YELLOW " CR
 AUTO_YELLOW WAIT_TIME DELAY  
 ." PEDESTRIAN_GREEN " CR
 PEDESTRIAN_GREEN WAIT_TIME DELAY  
 
 MAIN ;

: CHECK ." Waiting for input... " CR BEGIN DUP GET_GPIO_LEV 0= UNTIL DROP SEMAPHORE_ROUTINE ;

: MAIN INIT_STATE BUTTON CHECK ;

INIT_OUTPUT

MAIN

\ variable used to keep track of last irq trigger execution
VARIABLE LASTRUN
\ variable used to keep track the start time of main loop (only for debug)
VARIABLE STARTTIME

\ The index action of the next one to be executed
VARIABLE ACTION_IDX
\ The duration of the next action to be executed
VARIABLE ACTION_LEN

\ The duration of a full semaphore routine
VARIABLE FULLSEMLEN

\ Array of actions
VARIABLE ACTIONS 

DECIMAL

\ Allocates space for the 6 semaphore actions and store the start address into 'ACTIONS' variable
6 CELLS ALLOT ACTIONS !

\ ACTION ( n -- addr ) Returns the addres of the action at index n
: ACTION CELLS ACTIONS @ + ;

\ FULLSEMLEN-- ( -- ) Decrements FULLSEMLEN variable by 1
: FULLSEMLEN-- 1 FULLSEMLEN -! ;

\ ACTION_IDX+ ( n -- ) Increments ACTION_IDX by n
: ACTION_IDX+ ACTION_IDX +! ;

\ ACTION_LEN! ( n -- ) Sets ACTION_LEN with n
: ACTION_LEN! ACTION_LEN ! ;

\ ACTION_LEN-- Decrements ACTION_LEN variable by 1
: ACTION_LEN-- 1 ACTION_LEN -! ;

\ ISCHED! ( -- ) Schedules TIMER_IRQ in 1 second
: ISCHED! 1 SEC SYSC1! ;

\ NEXTACTION! ( n m -- ) Increments ACTION_IDX by m and set ACTION_LEN with n
: NEXTACTION! ACTION_IDX+ ACTION_LEN! ISCHED! ;

\ 0ACTION ( -- ) Prints status message into LCD and set FULLSEMLEN to 30 seconds. This is the hidle state of the semaphore.
: 0ACTION LCDCLR S" P. RED CAN CALL " 0 1 LCDSTRING 30 FULLSEMLEN ! ;

\ 1ACTION ( -- ) Prints status message into LCD, 
\ Sets the configuration of the traffic light LEDs to be yellow for cars and red for the pedestrians and
\ Sets the next action to be executed (idx 2)
: 1ACTION S" CAR YELLOW       " 0 1 LCDSTRING
    GREEN CAR GPOFF! YELLOW CAR GPON! 
    5 1 NEXTACTION!
;

\ 2ACTION ( -- ) Prints status message into LCD, 
\ Sets the configuration of the traffic light LEDs to be red for cars and green for the pedestrians and
\ Sets the next action to be executed (idx 3)
: 2ACTION S" P. GREEN    " 0 1 LCDSTRING
    RED CAR GPON! YELLOW CAR GPOFF! RED PEDESTRIAN GPOFF! GREEN PEDESTRIAN GPON!
    19 1 NEXTACTION!
;

\ 3ACTION ( -- ) Prints status message into LCD, 
\ Sets the configuration of the traffic light LEDs to be red for cars and yellow for the pedestrians and
\ Sets the next action to be executed (idx 4)
: 3ACTION S" P. YELLOW " 0 1 LCDSTRING
    GREEN PEDESTRIAN GPOFF! YELLOW PEDESTRIAN GPON!
    4 1 NEXTACTION!
;

\ 4ACTION ( -- ) Prints status message into LCD, 
\ Sets the configuration of the traffic light LEDs to be green for cars and red for the pedestrians and
\ Sets the next action to be executed (idx 5). Moreover, sets FULLSEMLEN to 10 second, the manual call disable time after completing the main routine
: 4ACTION S" P. RED WAIT " 0 1 LCDSTRING
    RED PEDESTRIAN GPON! YELLOW PEDESTRIAN GPOFF! RED CAR OFF GREEN CAR ON
    10 FULLSEMLEN !
    9 1 NEXTACTION!
;

\ 5ACTION ( -- ) Sets the next action to be executed (idx 0) and enables the manual call
: 5ACTION 0 -5 NEXTACTION! ;

\ EXEC_NEXT ( -- ) Exec the next action which is stored at ACTION_IDX of ACTIONS array
: EXEC_NEXT ACTION_IDX @ ACTION @ EXECUTE ;

\ SETn word to store the address of nACTION to the n index of ACTIONS array
: SET0 ' 0ACTION 0 ACTION ! ;
: SET1 ' 1ACTION 1 ACTION ! ;
: SET2 ' 2ACTION 2 ACTION ! ;
: SET3 ' 3ACTION 3 ACTION ! ;
: SET4 ' 4ACTION 4 ACTION ! ;
: SET5 ' 5ACTION 5 ACTION ! ;

\ TIMER_ISR ( -- ) this is the user side of timer interrupt service routine. It prints to the second line of the LCD the time remaining for the semaphore routine
\ and if the action length is not expired it executes the next action in the sequence else it decrements the current action length and it Schedules TIMER_IRQ in 1 second
: TIMER_ISR 
    FULLSEMLEN @ 10 < IF  1 2 LCDLN! LCDSPACE THEN
    FULLSEMLEN @ 2 2 LCDNUMBER
    ACTION_LEN @ 
    0= IF EXEC_NEXT 
    ELSE ACTION_LEN-- ISCHED! THEN
    FULLSEMLEN--
;

\ GPIO_ISR ( -- ) this is the user side of GPIO interrupt service routine. It checks if the current action index is the one of the hidle state; if so, 
\ it starts the semaphore routine by calling 1ACTION with EXEC_NEXT
: GPIO_ISR ACTION_IDX @ 0= IF 1 ACTION_IDX+ EXEC_NEXT THEN ;

\ TIMER_ISR! ( -- ) word to store the address of TIMER_ISR into 'TIMER_ISR variable which address is stored into 'GENERIC_ISR by 
\ the low level interrupt handler if timer IRQ occurred
: TIMER_ISR! ' TIMER_ISR 'TIMER_ISR ! ;

\ GPIO_ISR! ( -- ) word to store the address of GPIO_ISR into 'GPIO_ISR variable which address is stored into 'GENERIC_ISR by 
\ the low level interrupt handler if GPIO IRQ occurred
: GPIO_ISR! ' GPIO_ISR 'GPIO_ISR ! ;

\ MAINLOOP ( -- ) Endless loop which checks if an interrupt occurred and call the corresponding user side ISR using vectored execution (see *)
: MAINLOOP 
    NOW STARTTIME !
    STARTTIME @ ITS !
    STARTTIME @ LASTRUN !
    EXEC_NEXT
    BEGIN
        NOW STARTTIME @ - 1 MIN < WHILE \ * For the sole purpose of debugging, a one minute finished loop was used
            LASTRUN @ ITS @ <> IF ITS @ LASTRUN ! 'GENERIC_ISR @ EXECUTE THEN
    REPEAT
;

\ INIT_ALL  ( -- )
: INIT_ALL 
    SET0
    SET1
    SET2
    SET3
    SET4
    SET5

    TIMER_ISR!
    GPIO_ISR!
    IRQHANDLER!

    SEMSETUP
    LCDSETUP

    SEMINIT
    LCDINIT

    0 ACTION_IDX !
    30 FULLSEMLEN !

    \ Enabling  async fall event for GPIO 5, the one used by the button
    5 GPAFEN!

    \ Enabling GPIO IRQ source
    IRQGPIO!

    \ Enabling Timer IRQ source
    IRQTIMER1!

    \ Enabling all IRQs
    +IRQ

;

\  --- END of definitions ---

\ Inizialize all
INIT_ALL 

\ Start of the endless loop
MAINLOOP
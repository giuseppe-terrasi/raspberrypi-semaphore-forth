HEX

3F003000 CONSTANT SYSCS  \ System Timer Control/Status register
3F003004 CONSTANT SYSCLO  \ System Timer Counter Lower 32 bits register
3F003008 CONSTANT SYSCHI  \ System Timer Counter Higher 32 bits register
3F003010 CONSTANT SYSC1  \ System Timer Compare 1 register
3F003018 CONSTANT SYSC3  \ System Timer Compare 3 register
3F00B210 CONSTANT IRQ1 \ Enable_IRQs_1 register 

\ NOW ( -- n ) get time passed from startup in microseconds
: NOW SYSCLO @ ;

DECIMAL

: USEC ;  \ microseconds
: MSEC 1000 * ; \ milliseconds
: SEC 1000 MSEC * ; \ seconds 
: MIN 60 SEC * ; \ seconds 

\ DELAY ( n -- ) wait for given time passed as input
: DELAY NOW + BEGIN DUP NOW - 0 <= UNTIL DROP ;

\ ( n -- ) set System Timer Compare 1 to n + now 
: SYSC1! NOW + SYSC1 ! ;

\ ( n -- ) set System Timer Compare 3 to n + now 
: SYSC3! NOW + SYSC3 ! ;

\ ( -- ) Enables IRQ1 for timer
: IRQTIMER1! IRQ1 @ 2 OR IRQ1 ! ;

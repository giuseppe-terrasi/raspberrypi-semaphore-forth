HEX

3F003004 CONSTANT SYS_CLO  \ Free runner register address of System Timer

\ NOW ( -- n ) get time passed from startup in microseconds
: NOW SYS_CLO @ ;

DECIMAL

: USEC ;  \ microseconds
: MSEC 1000 * ; \ milliseconds
: SEC 1000 MSEC * ; \ seconds 

\ DELAY ( n -- ) wait for given time passed as input
: DELAY NOW + BEGIN DUP NOW - 0 <= UNTIL DROP ;

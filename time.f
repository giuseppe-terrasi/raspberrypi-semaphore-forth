HEX

3F003004 CONSTANT SYS_CLO

: NOW SYS_CLO @ ;

DECIMAL

: USEC ;
: MSEC 1000 * ;
: SEC 1000 MSEC * ;

: DELAY NOW + BEGIN DUP NOW - 0 <= UNTIL DROP ;

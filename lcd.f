\ include gpio.f
\ inlcude time.f

DECIMAL

\ VSS     GND
\ VDD     +5V
\ VO      POT
25 CONSTANT LCDRS      
\ RW      GND
24 CONSTANT LCDE       
12 CONSTANT LCD0      
4  CONSTANT LCD1      
27 CONSTANT LCD2      
16 CONSTANT LCD3      
23 CONSTANT LCD4      
17 CONSTANT LCD5      
18 CONSTANT LCD6      
22 CONSTANT LCD7      
\ A       +5V
\ K       GND

HEX

80 CONSTANT LCDLN1
C0 CONSTANT LCDLN2

\ LCDSETUP ( -- ) Set LCD pins as output
: LCDSETUP 
    LCDE  GPFSELOUT!
    LCDRS GPFSELOUT!
    LCD0 GPFSELOUT!
    LCD1 GPFSELOUT!
    LCD2 GPFSELOUT!
    LCD3 GPFSELOUT!
    LCD4 GPFSELOUT!
    LCD5 GPFSELOUT!
    LCD6 GPFSELOUT!
    LCD7 GPFSELOUT!
;

\ +LCDE ( -- ) Set LCDE pin to high
: +LCDE LCDE GPON! ;

\ -LCDE ( -- ) Set LCDE pin to low
: -LCDE LCDE GPOFF! ;

\ LCDESIGN ( -- ) Send LCDE pin high low signal to LCD
: LCDESIGN 500 USEC DELAY +LCDE 500 USEC DELAY -LCDE 500 USEC DELAY ;

\ LCDDOFF! ( -- ) Set all LCD pins to low
: LCDDOFF!
    LCDE GPOFF!
    LCD0 GPOFF!
    LCD1 GPOFF!
    LCD2 GPOFF!
    LCD3 GPOFF!
    LCD4 GPOFF!
    LCD5 GPOFF!
    LCD6 GPOFF!
    LCD7 GPOFF!
;

\ BITSET ( n1 n2 -- flag ) Check if n2-bit of n1 is set and leaves a status flag into the stack 
: BITSET AND 0<> ;

\ ?LCDD ( flag n -- ) Check flag and set n-pin accordly to flag
: ?LCDD SWAP IF GPON! ELSE GPOFF! THEN ;

\ LCDWRITE ( n -- ) Write n to LCD in 8 bit mode. If n < 0x100 a command is sent otherwise data are sent.
: LCDWRITE
    DUP 100 BITSET LCDRS ?LCDD

    DUP 80 BITSET LCD7 ?LCDD
    DUP 40 BITSET LCD6 ?LCDD
    DUP 20 BITSET LCD5 ?LCDD
    DUP 10 BITSET LCD4 ?LCDD
    DUP 08 BITSET LCD3 ?LCDD
    DUP 04 BITSET LCD2 ?LCDD
    DUP 02 BITSET LCD1 ?LCDD 
        01 BITSET LCD0 ?LCDD 

    LCDESIGN
;

\ LCDWRITE ( n -- ) Write n to LCD in 4 bit mode. If n < 0x100 a command is sent otherwise data are sent.
: LCDWRITE4
    DUP 100 BITSET LCDRS ?LCDD
    
    \ set high bits
    DUP 80 BITSET LCD7 ?LCDD
    DUP 40 BITSET LCD6 ?LCDD
    DUP 20 BITSET LCD5 ?LCDD
    DUP 10 BITSET LCD4 ?LCDD
    
    LCDESIGN
    
    \ set low bits
    DUP 08 BITSET LCD7 ?LCDD
    DUP 04 BITSET LCD6 ?LCDD
    DUP 02 BITSET LCD5 ?LCDD
        01 BITSET LCD4 ?LCDD
    
    LCDESIGN
;

\ LCDCLR ( -- ) Clear LCD display
: LCDCLR 1 LCDWRITE ;

: LCDINIT
    33 LCDWRITE
    38 LCDWRITE
    6 LCDWRITE
    C LCDWRITE
    LCDCLR
;

\ LCDSTYPE ( addr n -- ) Print a string to LCD
: LCDSTYPE OVER + SWAP BEGIN 2DUP <> WHILE DUP c@ 100 + LCDWRITE 1+ REPEAT 2DROP ;

DECIMAL

\ LCDSTYPE ( n -- ) Print a string rappresentation of a number to LCD
: LCDNTYPE BEGIN 10 /MOD SWAP 304 + LCDWRITE DUP 0= UNTIL DROP ;

HEX

\ LCDLN ( n -- addr ) Gets the corresponding address of LCD line passed as input 
: LCDLN 1 = IF LCDLN1 ELSE LCDLN2 THEN ;

\ LCDLN ( n -- ) Set DDRAM addres of LCD line where cursor will start to write
: LCDLN! LCDLN + LCDWRITE ;

\ LCDCURL>R ( -- ) Set cursor move from left to right
: LCDCURL>R 6 LCDWRITE ;

\ LCDCURL<R ( -- ) Set cursor move from right to left
: LCDCURL<R 4 LCDWRITE ;

\ LCDSTRING ( addr n1 n2 n3 -- ) Print to LCD line based on n3 the string starting from addr and long n1 from an offset of n2 from the beginning of the line
: LCDSTRING LCDLN! LCDCURL>R LCDSTYPE ;

\ LCDNUMBER ( n1 n2 n3 -- ) Print to LCD line based on n3 the string rappresentation of n1 from an offset of n2 from the beginning of the line
: LCDNUMBER LCDLN! LCDCURL<R LCDNTYPE ;

\ LCDSPACE write a space to LCD
: LCDSPACE 120 LCDWRITE ;

DECIMAL

\ LCDLNCLR ( n -- ) Clear LCD line n
: LCDLNCLR 0 SWAP LCDLN! 16 0 BEGIN LCDSPACE 1 + 2DUP = UNTIL 2DROP ;


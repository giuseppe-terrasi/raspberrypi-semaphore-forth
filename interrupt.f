\ ( -- ) Save reference to jonesfort here
: JF-HERE   HERE ;

\ ( -- addr ) redefines here leaving on the stack the currend value of stack pointer
: HERE   JF-HERE @ ;

VARIABLE ITS
VARIABLE TIMER_ISR
VARIABLE GPIO_ISR
VARIABLE GENERIC_ISR

HEX

\ IRQ Handler machine code (disassebly of interrupt.s)
\ irq 
e92d500f , \ push	{r0, r1, r2, r3, ip, lr}
e59f0088 , \ ldr	r0, [pc, #136]	; 94 <addr_IRQ1_PENDING>
e5900000 , \ ldr	r0, [r0]
e2000002 , \ and	r0, r0, #2
e3500002 , \ cmp	r0, #2
0b000006 , \ bleq	34 <timer_isr>
e59f0078 , \ ldr	r0, [pc, #120]	; 98 <addr_IRQ2_PENDING>
e5900000 , \ ldr	r0, [r0]
e2000802 , \ and	r0, r0, #131072	; 0x20000
e3500802 , \ cmp	r0, #131072	; 0x20000
0b00000d , \ bleq	64 <gpio_isr>
e8bd500f , \ pop	{r0, r1, r2, r3, ip, lr}
e25ef004 , \ subs	pc, lr, #4

\ timer_isr
e59f0060 , \ ldr	r0, [pc, #96]	; 9c <addr_SYS_TIMER_CTRL_STATUS_REG>
e3a01002 , \ mov	r1, #2
e5801000 , \ str	r1, [r0]
e59f0048 , \ ldr	r0, [pc, #72]	; 90 <addr_GENERIC_FUNC>
e59f103c , \ ldr	r1, [pc, #60]	; 88 <addr_TIMER_FUNC>
e5911000 , \ ldr	r1, [r1]
e5801000 , \ str	r1, [r0]
e59f002c , \ ldr	r0, [pc, #44]	; 84 <addr_ITS>
e59f1044 , \ ldr	r1, [pc, #68]	; a0 <addr_SYS_TIMER_CLO_REG>
e5911000 , \ ldr	r1, [r1]
e5801000 , \ str	r1, [r0]
e12fff1e , \ bx	lr

\ gpio_isr
e59f0038 , \ ldr	r0, [pc, #56]	; a4 <addr_GPEDS0_REG>
e3a01020 , \ mov	r1, #32
e5801000 , \ str	r1, [r0]
e59f0018 , \ ldr	r0, [pc, #24]	; 90 <addr_GENERIC_FUNC>
e59f1010 , \ ldr	r1, [pc, #16]	; 8c <addr_GPIO_FUNC>
e5911000 , \ ldr	r1, [r1]
e5801000 , \ str	r1, [r0]
e12fff1e , \ bx	lr

\ data
ITS ,
TIMER_ISR ,
GPIO_ISR ,
GENERIC_ISR ,
3f00b204 , \ addr_IRQ1_PENDING
3f00b208 , \ addr_IRQ2_PENDING
3f003000 , \ addr_SYS_TIMER_CTRL_STATUS_REG
3f003004 , \ addr_SYS_TIMER_CLO_REG
3f200040 , \ addr_GPEDS0_REG

\ ( -- ) Sets the jump instruction to the IRQ Handler at address 0x18 which is the one read when an IRQ interrupt occurs. The jump instrucion is the disassebly of sethandler.s
\ which contains a branch to a PC offset. The offset is the difference beetween the address of the IRQ Handler (the one which points HERE before writing 
\ the machine code into the interpreter ) and 0x18.
: IRQHANDLER! ea007949 18 ! ;

: TEST 1 ;
: TEST2 2 ;
: SETTEST ' TEST TIMER_ISR ! ;
: SETTEST2 ' TEST2 GPIO_ISR ! ;
: SETGEN ' TEST2 GENERIC_ISR ! ;

SETTEST
SETTEST2
SETGEN
IRQHANDLER!
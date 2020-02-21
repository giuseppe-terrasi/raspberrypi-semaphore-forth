.data 
.balign 4
ITS: .word 0
TIMER_FUNC: .word 0
GPIO_FUNC: .word 0
GENERIC_FUNC: .word 0
SYS_TIMER_CTRL_STATUS_REG=0x3F003000
SYS_TIMER_CLO_REG=0x3F003004

IRQ1_PENDING=0x3F00B204
IRQ2_PENDING=0x3F00B208

GPEDS0_REG=0x3F200040

.text

.global _start

_start:
    push {r0-r3, r12, lr}

    ldr r0, addr_IRQ1_PENDING
    ldr r0, [r0]
    and r0, r0, #2
    cmp r0, #2
    bleq timer_isr

    ldr r0, addr_IRQ2_PENDING
    ldr r0, [r0]
    and r0, r0, #1<<17
    cmp r0, #1<<17
    bleq gpio_isr

    ldr r0, addr_ITS
    ldr r1, addr_SYS_TIMER_CLO_REG
    ldr r1, [r1]
    str r1, [r0]

    pop {r0-r3, r12, lr}
    subs pc, lr, #4

timer_isr:
    ldr r0, addr_SYS_TIMER_CTRL_STATUS_REG
    mov r1, #2
    str r1, [r0]

    ldr r0, addr_GENERIC_FUNC
    ldr r1, addr_TIMER_FUNC
    ldr r1, [r1]
    str r1, [r0]
    bx lr

gpio_isr:
    ldr r0, addr_GPEDS0_REG
    mov r1, #1<<5
    str r1, [r0]

    ldr r0, addr_GENERIC_FUNC
    ldr r1, addr_GPIO_FUNC
    ldr r1, [r1]
    str r1, [r0]

    bx lr

addr_ITS: .word ITS 
addr_TIMER_FUNC: .word TIMER_FUNC 
addr_GPIO_FUNC: .word GPIO_FUNC 
addr_GENERIC_FUNC: .word GENERIC_FUNC 
addr_IRQ1_PENDING: .word IRQ1_PENDING
addr_IRQ2_PENDING: .word IRQ2_PENDING
addr_SYS_TIMER_CTRL_STATUS_REG: .word SYS_TIMER_CTRL_STATUS_REG
addr_SYS_TIMER_CLO_REG: .word SYS_TIMER_CLO_REG 
addr_GPEDS0_REG: .word GPEDS0_REG

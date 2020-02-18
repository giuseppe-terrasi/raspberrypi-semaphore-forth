
dump:elf
	arm-none-eabi-objdump -d interrupt.elf > interrupt.elf.list
	arm-none-eabi-objdump -d sethandlerjump.elf > sethandlerjump.elf.list
	
obj:
	arm-none-eabi-as interrupt.s -o interrupt.o
	arm-none-eabi-as sethandlerjump.s -o sethandlerjump.o
elf:obj
	arm-none-eabi-ld -T kernel7.ld interrupt.o -o interrupt.elf
	arm-none-eabi-ld -T kernel7.ld sethandlerjump.o -o sethandlerjump.elf

clean:
	rm -f *.o  *.list *.elf

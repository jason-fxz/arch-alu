.PHONY: all
all:
	@echo 'Now testing: Ripple-Carry Adder'
	cat adder-ripple.v > adder.v
	iverilog test_adder.v
	./a.out
	echo '' > adder.v
	@echo 'Now testing: Carry-lookahead Adder'
	cat adder-carry.v > adder.v
	iverilog test_adder.v
	./a.out
	echo '' > adder.v

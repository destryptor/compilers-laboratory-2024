run: codegen sample.txt
	@echo "Enter the number of registers (default is 5, press Enter to maintain it): "
	@read -p "Number of registers: " num_registers; \
	if [ -z "$$num_registers" ]; then \
		num_registers=5; \
	fi; \
	./codegen < sample.txt $$num_registers; \
	echo "The three-address code has been written to output_intcode.txt, and the target code to output_target.txt."; \
	while true; do \
		echo "Would you like to view the output? (1 for output_intcode.txt, 2 for output_target.txt, Ctrl+C to exit)"; \
		read -p "Enter your choice: " choice; \
		if [ "$$choice" -eq 1 ]; then \
			clear; \
			cat output_intcode.txt; \
		elif [ "$$choice" -eq 2 ]; then \
			clear; \
			cat output_target.txt; \
		else \
			echo "Invalid choice, please enter 1 or 2."; \
		fi; \
	done

all: codegen.c lex.yy.c y.tab.c
	gcc codegen.c -o codegen

codegen: codegen.c lex.yy.c y.tab.c
	gcc codegen.c -o codegen

lex.yy.c: prog.l
	flex prog.l

y.tab.c: prog.y
	yacc -d prog.y

clean:
	rm -f codegen lex.yy.c y.tab.c y.tab.h output_intcode.txt output_target.txt
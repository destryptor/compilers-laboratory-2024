run: a.out
	./a.out < tests/TinyC3_22CS10084_22CS10088_test1.c > test_outputs/TinyC3_22CS10084_22CS10088_quads1.out
	./a.out < tests/TinyC3_22CS10084_22CS10088_test2.c > test_outputs/TinyC3_22CS10084_22CS10088_quads2.out
	./a.out < tests/TinyC3_22CS10084_22CS10088_test3.c > test_outputs/TinyC3_22CS10084_22CS10088_quads3.out
	./a.out < tests/TinyC3_22CS10084_22CS10088_test4.c > test_outputs/TinyC3_22CS10084_22CS10088_quads4.out
	./a.out < tests/TinyC3_22CS10084_22CS10088_test5.c > test_outputs/TinyC3_22CS10084_22CS10088_quads5.out
	@echo "Output files have been generated."
	@while true; do \
		echo -n "Do you wish to view the contents of the quads files? (y/n): "; \
		read answer; \
		if [ "$$answer" = "y" ]; then \
			echo -n "Enter output number to view (1-5) or type 'exit' to quit: "; \
			read num; \
			if [ "$$num" = "exit" ]; then \
				break; \
			elif [ "$$num" -ge 1 ] && [ "$$num" -le 5 ]; then \
				cat test_outputs/TinyC3_22CS10084_22CS10088_quads$$num.out; \
			else \
				echo "Invalid input. Please enter a number between 1 and 5 or 'exit'."; \
			fi; \
		elif [ "$$answer" = "n" ]; then \
			break; \
		else \
			echo "Please enter 'y' or 'n'."; \
		fi; \
	done

a.out: TinyC3_22CS10084_22CS10088_translator.cxx y.tab.c lex.yy.c
	g++ TinyC3_22CS10084_22CS10088_translator.cxx -o a.out

y.tab.c y.tab.h: TinyC3_22CS10084_22CS10088.y
	yacc -d TinyC3_22CS10084_22CS10088.y

lex.yy.c: TinyC3_22CS10084_22CS10088.l
	flex TinyC3_22CS10084_22CS10088.l

clean:
	rm -rf lex.yy.c y.tab.c y.tab.h a.out

run: input_22CS10084_22CS10088.c a.out
	./a.out < input_22CS10084_22CS10088.c > output_22CS10084_22CS10088.txt

a.out: tinyC2_22CS10084_22CS10088.c lex.yy.c y.tab.c
	gcc tinyC2_22CS10084_22CS10088.c -o a.out

lex.yy.c: tinyC2_22CS10088_22CS10084.l
	flex tinyC2_22CS10088_22CS10084.l

y.tab.c: tinyC2_22CS10088_22CS10084.y
	yacc -d tinyC2_22CS10088_22CS10084.y


clean:
	rm -rf lex.yy.c y.tab.c y.tab.h a.out output_22CS10084_22CS10088.txt
all: run

lex.yy.c: ass3_22CS10088_22CS10084.l
	lex ass3_22CS10088_22CS10084.l

a.out: lex.yy.c ass3_22CS10084_22CS10088.c
	gcc ass3_22CS10084_22CS10088.c -o a.out

run: a.out
	./a.out < ass3_22CS10084_22CS10088_test.c

clean:
	rm -f lex.yy.c a.out


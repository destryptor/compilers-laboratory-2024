all: run
run: a.out
	./a.out
a.out: main.c y.tab.c lex.yy.c
	gcc main.c -o a.out -lm 
y.tab.c y.tab.h: expr.y 
	yacc -d expr.y
lex.yy.c: expr.l y.tab.h 
	flex expr.l 
clean: 
	rm -f a.out y.tab.h y.tab.c lex.yy.c

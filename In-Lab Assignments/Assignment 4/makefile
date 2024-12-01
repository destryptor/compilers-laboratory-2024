run: a.out sample.txt
	./a.out < sample.txt

a.out: polyutils.c lex.yy.c y.tab.c
	gcc polyutils.c -lm -o a.out

lex.yy.c: poly.l
	flex poly.l

y.tab.c: poly.y
	yacc -d poly.y

clean:
	rm -f a.out y.tab.c y.tab.h lex.yy.c

all: run clean
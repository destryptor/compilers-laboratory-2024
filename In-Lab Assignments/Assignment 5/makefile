all: expr.l expr.y intcodegen.c
	flex expr.l
	yacc -d expr.y
	gcc intcodegen.c -o icgen

run: icgen sample.txt
	./icgen < sample.txt > intcode.c
	gcc intcode.c -lm -o ic
	./ic

icgen: all

clean:
	rm -f intcode.c icgen ic lex.yy.c y.tab.c y.tab.h

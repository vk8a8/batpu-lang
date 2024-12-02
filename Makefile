default: lex.l y.y
	bison -dv y.y
	lex lex.l
	gcc y.tab.c lex.yy.c -o mbvl

clean:
	rm y.tab.* lex.yy.c mbvl y.output

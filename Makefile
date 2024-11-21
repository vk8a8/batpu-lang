default: lex.l y.y
	bison -dv y.y
	lex lex.l
	gcc y.tab.c lex.yy.c
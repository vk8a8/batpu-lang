default: lex.l y.y
	bison -dv y.y
	lex lex.l
	gcc y.tab.c lex.yy.c -o mbvl

win-release: lex.l y.y
	bison -dv y.y
	lex lex.l
	x86_64-w64-mingw32-gcc y.tab.c lex.yy.c -o mbvl-win-x86_64.exe -O3

release: lex.l y.y
	bison -dv y.y
	lex lex.l
	gcc y.tab.c lex.yy.c -o mbvl-Linux-x86_64 -O3

clean:
	rm y.tab.* lex.yy.c mbvl* y.output

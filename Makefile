default: src/lex.l src/y.y
	bison -v src/y.y --header="include/y.tab.h" -o src/y.tab.c -Wcounterexamples
	lex src/lex.l
	mv lex.yy.c src/
	@if [ ! -d "build" ]; then\
		mkdir build;\
	fi
	gcc src/y.tab.c src/lex.yy.c -I include -o build/mbvl

clean:
	rm include/* src/*.c build/*

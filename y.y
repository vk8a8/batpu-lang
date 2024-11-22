%{
#include <stdio.h>
#include <stdint.h>

int yylex();
void yyerror(char* s);

struct node {
    struct node* left;
    struct node* right;
    char* token;
};

uint8_t reg = 1;
int lcounter = 0;

%}

%union {
    struct var_name {
        char name[32];
        struct node* nd;
    } nd_obj;
}

%token <nd_obj> ADD MEM ASM LABEL GOTO IDENT EQ_OP IF ENDIF
%type <nd_obj> expr program inlasm label goto_stmt endif

%%
program
: program program
| expr ';'
| inlasm
| label
| goto_stmt ';'
| endif
| /* empty */
;

endif
: ENDIF         { printf(".l%d\n", lcounter++); }

goto_stmt
: GOTO IDENT    { printf("jmp .%s\n", $2.name); }
;

label
: LABEL         { printf(".%s\n", $1); }
;

/* inline asm lol */
inlasm
: ASM           { printf("%s\n", $1); }
;

expr
: expr expr
| expr ADD expr { printf("add r%d r%d r%d\n", reg-2, reg-1, reg-2); reg--; }
| MEM           { printf("ldi r%d %s\n", reg++, $1); $$ = $1; }
;

%%

int main() {
    yyparse();
    return 0;
}

void yyerror(char* s) {
    fprintf(stderr, "yyerror: %s\n", s);
}
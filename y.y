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
extern FILE* yyin;

%}

%union {
    struct var_name {
        char name[32];
        struct node* nd;
    } nd_obj;
}

%token <nd_obj> ADD MEM ASM LABEL GOTO IDENT EQ_OP IF
%type <nd_obj> expr program inlasm label goto_stmt if_stmt

%%
program
: program program
| expr ';'
| inlasm
| label
| goto_stmt ';'
| if_stmt
| /* empty */
;

if_stmt
: IF '(' logic_cmp ')'
'{' program '}' { printf(".l%d ; IF \n", lcounter++);}
;

logic_cmp
: expr EQ_OP expr { printf("cmp r%d r%d\n", --reg, --reg);
                    printf("brh ne .l%d\n\n", lcounter);}
;

goto_stmt
: GOTO IDENT    { printf("jmp .%s\n\n", $2.name); }
;

label
: LABEL   { printf(".%s\n\n", $1); }
;

/* inline asm lol */
inlasm
: ASM           { printf("%s ; inline \n", $1); }
;

expr
: expr expr
| expr ADD expr {   printf("lod r%d r%d\nlod r%d r%d\n", reg-1, reg-1, reg, --reg); // The function parses the "--var" in backwards order
                    printf("add r%d r%d r%d\n\n", reg, reg - 1, reg); }
| MEM           { printf("ldi r%d %s\n", reg++, $1); $$ = $1; }
;

%%

int main(int argc, char* argv[]) {
    yyin = fopen(argv[1], "rb");
    
    yyparse();

    fclose(yyin);
    return 0;
}

void yyerror(char* s) {
    fprintf(stderr, "yyerror: %s\n", s);
}
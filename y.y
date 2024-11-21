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

%}

%union {
    struct var_name {
        char name[32];
        struct node* nd;
    } nd_obj;
}

%token <nd_obj> ADD MEM
%type <nd_obj> expr program

%%
program
: program expr ';'
| // empty
;

expr
: expr expr
| expr ADD expr
    { printf("%d\n", reg); }
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
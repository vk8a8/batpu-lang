%{
#include <stdio.h>

int yylex();
void yyerror(char* s);

struct node {
    struct node* left;
    struct node* right;
    char* token;
};

%}

%union {
    struct var_name {
        char name[32];
        struct node* nd;
    } nd_obj;
}

%token <nd_obj> ID ADD MEM
%type <nd_obj> expr program

%%
program
: program expr ';'
| // empty
;

expr
: expr expr
| expr ADD expr
    { printf(
    "LOD r1 %s\n"
    "LOD r2 %s\n"
    "ADD r1 r2 r15\n",
    $1.name, $3.name); }
| ID            { printf("%s\n", $1); $$ = $1; }
| MEM           { $$ = $1; }
;

%%

int main() {
    yyparse();
    return 0;
}

void yyerror(char* s) {
    fprintf(stderr, "yyerror: %s\n", s);
}
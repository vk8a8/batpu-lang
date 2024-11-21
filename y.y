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

%token <nd_obj> ID ADD
%type <nd_obj> expr

%%
program: stmt '\n';

stmt: expr ';';

expr
: expr ADD expr { printf("ADD %s %s\n", $1.name, $3.name); }
| ID            { $$ = $1; }
;

%%

int main() {
    yyparse();
    return 0;
}

void yyerror(char* s) {
    fprintf(stderr, "yyerror: %s\n", s);
}
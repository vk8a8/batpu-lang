%{
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "y.tab.h"

int yylex();
void yyerror(char* s);

struct node {
    struct node* left;
    struct node* right;
    char* token;
};

uint8_t reg = 1;
uint16_t lcounter = 0;
extern FILE* yyin;

%}

%union {
    struct var_name {
        char name[32];
        struct node* nd;
    } nd_obj;
}

%token <nd_obj> MEM ASM GOTO IDENT EQ_OP NE_OP IF INTLIT BW_NAND BW_NOR BW_XNOR
%type <nd_obj> expr mem assmt program inlasm label goto_stmt if_stmt ';'

%left '+' '-' '^' '&' '|' BW_NAND BW_NOR BW_XNOR
%nonassoc '~'

%%
full_program
: full_program program
| /* empty */
;

program
: expr ';'
| assmt ';'
| inlasm
| label
| goto_stmt ';'
| if_stmt
;

if_stmt
: IF '(' logic_cmp ')'
'{' full_program '}' { printf(".l%d ; IF \n", lcounter++);}
;

logic_cmp
: expr EQ_OP expr { printf("cmp r%d r%d\n", --reg, --reg);
                    printf("brh ne .l%d\n", lcounter);}
| expr NE_OP expr { printf("cmp r%d r%d\n", --reg, --reg);
                    printf("brh eq .l%d\n", lcounter);}
;

goto_stmt
: GOTO IDENT    { printf("jmp .%s\n", $2.name); }
;

label
: IDENT ':'     { printf(".%s\n", $1.name); }
;

/* inline asm lol */
inlasm
: ASM           { printf("%s ; inline \n", $1.name); }
;

expr
: mem
| expr '+' expr { printf("add r%d r%d r%d\n", reg - 1, reg, --reg - 1); }
| expr '+' INTLIT   { printf("adi r%d %s\n", reg - 1, $3.name); } %prec '+'
| INTLIT '+' expr   { printf("adi r%d %s\n", reg - 1, $1.name); } %prec '+'

| expr '-' expr     { printf("sub r%d r%d r%d\n", reg - 1, reg, --reg - 1); }
| expr '&' expr     { printf("and r%d r%d r%d\n", reg - 1, reg, --reg - 1); }
| expr '^' expr     { printf("xor r%d r%d r%d\n", reg - 1, reg, --reg - 1); }
| expr '|' expr     { printf("nor r%d r%d r%d\n", reg - 1, reg, --reg - 1);
                      printf("not r%d r%d\n", reg - 1, reg - 1); }

| expr BW_NAND expr { printf("and r%d r%d r%d\n", reg - 1, reg, --reg - 1);
                      printf("not r%d r%d\n", reg - 1, reg - 1); }
| expr BW_NOR expr  { printf("nor r%d r%d r%d\n", reg - 1, reg, --reg - 1); }
| expr BW_XNOR expr { printf("xor r%d r%d r%d\n", reg - 1, reg, --reg - 1);
                      printf("not r%d r%d\n", reg - 1, reg - 1); }

| '~' expr      { printf("not r%d r%d\n", reg - 1, reg - 1);}

| INTLIT        { printf("ldi r%d %s\n", reg++, $1.name); $$ = $1; }
| '(' expr ')'  { $$ = $2; }
;

assmt
: MEM '=' expr  { printf("ldi r%d %s\n", reg, $1.name);
                  printf("str r%d r%d\n", reg--, reg - 1); }  // Gah!!
;

mem
: MEM           { printf("ldi r%d %s\n", reg, $1.name);
                  printf("lod r%d r%d\n", reg++, reg); $$ = $1; }
;
%%

void printHelp();

int main(int argc, char* argv[]) {
    for (int i = 0; i < argc; ++i) {
        if (!strcmp(argv[i], "-h")) {
            printHelp();
            return 0;
        }
        else {
            yyin = fopen(argv[i], "rb");
        }
    }
    
    yyparse();

    fclose(yyin);
    return 0;
}

void yyerror(char* s) {
    extern int yylineno;
    fprintf(stderr, "yyerror on line %d: %s\n", yylineno, s);
}

void printHelp() {
    puts("Temporary help message.\n"
         "\t-o <file>: choose output file\n"
    );
}

%{
#include <stdio.h>
#include <stdint.h>
#include <string.h>

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

%token <nd_obj> MEM ASM LABEL GOTO IDENT EQ_OP NE_OP IF INTLIT
%type <nd_obj> expr term assmt program inlasm label goto_stmt if_stmt ';'

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
                    printf("brh ne .l%d\n\n", lcounter);}
| expr NE_OP expr { printf("cmp r%d r%d\n", --reg, --reg);
                    printf("brh eq .l%d\n\n", lcounter);}
;

goto_stmt
: GOTO IDENT    { printf("jmp .%s\n\n", $2.name); }
;

label
: LABEL         { printf(".%s\n\n", $1.name); }
;

/* inline asm lol */
inlasm
: ASM           { printf("%s ; inline \n", $1.name); }
;

expr
: term
| arit_expr
;

assmt
: MEM '=' expr  { printf("ldi r%d %s\n", reg, $1.name);
                  printf("str r%d r%d\n", reg--, reg - 1); }  // Gah!!
;

arit_expr
: arit_expr '+' term { printf("add r%d r%d r%d\n\n", reg - 1, reg, --reg - 1); }
| term '+' term { printf("add r%d r%d r%d\n\n", reg - 1, reg, --reg - 1); }
;

term
: MEM           { printf("ldi r%d %s\n", reg, $1.name);
                  printf("lod r%d r%d\n", reg++, reg); $$ = $1; }
| INTLIT        { printf("ldi r%d %s\n", reg++, $1.name); }
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
    fprintf(stderr, "yyerror: %s\n", s);
}

void printHelp() {
    puts("Temporary help message.\n"
         "\t-o <file>: choose output file\n"
    );
}
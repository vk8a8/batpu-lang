%{
#include "y.tab.h"
%}

digit [0-9]
name  [a-zA-Z_][a-zA-Z_0-9]*

%%
"goto"              { strcpy(yylval.nd_obj.name, yytext); return GOTO; }
"if"                { strcpy(yylval.nd_obj.name, yytext); return IF; }

"%".*               { strcpy(yylval.nd_obj.name, yytext + 1); return ASM; } // plus 1 because of dollar sign, same for others with preceeding symbols
":"{name}           { strcpy(yylval.nd_obj.name, yytext + 1); return LABEL; }
"$"{digit}+         { strcpy(yylval.nd_obj.name, yytext + 1); return MEM; }

"=="                { strcpy(yylval.nd_obj.name, yytext); return EQ_OP; }

"+"                 { strcpy(yylval.nd_obj.name, yytext); return ADD; }

{name}              { strcpy(yylval.nd_obj.name, yytext); return IDENT; }

" "                 { ; }
[\n]                { ; }
\/\/.*              { ; }
\/\*(.|\n)*\*\/     { ; }
.                   { return *yytext; }
%%

int yywrap() {
    return 1;
}
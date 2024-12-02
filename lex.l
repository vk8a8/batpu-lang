%{
#include "y.tab.h"
%}

%option yylineno

digit [0-9]
name  [a-zA-Z_][a-zA-Z_0-9]*

%%
"goto"              { return GOTO; }
"if"                { return IF; }

"%".*               { return ASM; } // plus 1 because of dollar sign, same for others with preceeding symbols
":"{name}           { strcpy(yylval.nd_obj.name, yytext + 1); return LABEL; }
"$"{digit}+         { strcpy(yylval.nd_obj.name, yytext + 1); return MEM; }

"=="                { return EQ_OP; }
"!="                { return NE_OP; }

{digit}+            { strcpy(yylval.nd_obj.name, yytext); return INTLIT; }
{name}              { strcpy(yylval.nd_obj.name, yytext); return IDENT; }

" "                 { ; }
[\t]*               { ; }
\r?[\n]             { yylineno++; }
\/\/.*              { ; }
\/\*(.|\n)*\*\/     { ; }
.                   { return *yytext; }
%%

int yywrap() {
    return 1;
}
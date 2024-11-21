%{
#include "y.tab.h"
%}

alpha [a-zA-Z]
digit [0-9]

%%
{alpha}({alpha}|{digit})*          { strcpy(yylval.nd_obj.name,(yytext)); return ID; }
"+"                                { strcpy(yylval.nd_obj.name,(yytext)); return ADD; }
[\n]           {;}
" "|"\t"             {;}
.               { return *yytext; }
%%

int yywrap() {
    return 1;
}
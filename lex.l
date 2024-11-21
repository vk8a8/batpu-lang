%{
#include "y.tab.h"
%}

digit [0-9]

%%
"$"{digit}+                         { strcpy(yylval.nd_obj.name, yytext + 1); return MEM;} // plus 1 because of dollar sign
"+"                                { strcpy(yylval.nd_obj.name, yytext); return ADD; }
[\n]           {;}
\/\/.*          {;}
\/\*(.|\n)*\*\/   {;}
.               { return *yytext; }
%%

int yywrap() {
    return 1;
}
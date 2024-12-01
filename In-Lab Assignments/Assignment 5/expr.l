%{
    #include <stdio.h>
    #include "y.tab.h"
%}

ID      [a-zA-Z_][a-zA-Z0-9_]*
NUM     [-]?[0-9]+
spaces  [ \t\n]

%%
"set"       {return set;}
{ID}        {yylval.id = strdup(yytext); return ID;}
{NUM}       {yylval.num = atoi(yytext); return NUM;}
"**"       {return '^';}
"("         {return '(';}
")"         {return ')';}
"+"         {return '+';}
"-"         {return '-';}
"*"         {return '*';}
"/"         {return '/';}
"%"         {return '%';}
{spaces}    {}
.           {}
%%
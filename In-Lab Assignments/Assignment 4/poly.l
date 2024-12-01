%{
    #include <stdio.h>
    #include "y.tab.h"
%}

DIGIT   [2-9]
ZERO    [0]
ONE     [1]
SPACES  [ \t\n]

%%

"-"         {return MINUS;}
"+"         {return PLUS;}
"^"         {return POW;}
"x"         {return x;}
{ZERO}      {yylval.intval = strdup(yytext); return ZERO;}
{ONE}       {yylval.intval = strdup(yytext); return ONE;}
{DIGIT}     {yylval.intval = strdup(yytext); return D;}
{SPACES}    {}

%%

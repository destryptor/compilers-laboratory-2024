%{
    #include "y.tab.h"
    #include <stdio.h>
%}

IDEN    [a-zA-Z_][a-zA-Z0-9_]*
NUMB    [+-]?([0]|[1-9][0-9]*)
SPACES  [ \t\n]+

%%
"set"       { return SET; }
"when"      { return WHEN; }
"loop"      { return LOOPS; }
"while"     { return WHILE; }
"("         { return LP; }
")"         { return RP; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MULT; }
"/"         { return DIV; }
"%"         { return MOD; }
"="         { return EQ; }
"/="        { return NEQ; }
"<"         { return LT; }
"<="        { return LE; }
">"         { return GT; }
">="        { return GE; }
{IDEN}      { yylval.strval = strdup(yytext); return IDEN; }
{NUMB}      { yylval.strval = strdup(yytext); return NUMB; }
{SPACES}    { ; }
%%
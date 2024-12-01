%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "TinyC3_22CS10084_22CS10088_translator.h"
    #include "y.tab.h"
    int lineCount = 1;
%}

SINGLE_LINE_COMM                  [/][/][^\n]*
OTHER                             ([^*]|[*][^/])*
MULTI_LINE_COMM                   [/][*]{OTHER}*[*][/]

ESC_SEQ        "\\\'"|"\\\""|"\\?"|"\\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"

ID              [A-Za-z_][A-Za-z0-9_]*

DIG                     [0-9]
DIG_SEQ                 {DIG}+
NONZERO_DIG             [1-9]
INT_CONST               {NONZERO_DIG}{DIG}*|"0"

EXP_PART                [eE]([+-]?){DIG_SEQ}
FRAC_CONST              {DIG_SEQ}?\.{DIG_SEQ}|{DIG_SEQ}\.
FLOAT_CONST             {FRAC_CONST}({EXP_PART}?)|{DIG_SEQ}{EXP_PART}

C_CHAR                  [^\'\n\\]|{ESC_SEQ}
C_CHAR_SEQ              {C_CHAR}+
CHAR_CONST              \'{C_CHAR_SEQ}\'

S_CHAR                  [^\"\n\\]|{ESC_SEQ}
S_CHAR_SEQ              {S_CHAR}+
STR_LITERAL             \"({S_CHAR_SEQ}?)\"

WHITESPACE              [ \t]
NEWLINE                 \n

%%

"auto"                          { return AUTO; }
"break"                         { return BREAK; }
"case"                          { return CASE; }
"char"                          { return CHARS; }
"const"                         { return CONST; }
"continue"                      { return CONTINUE; }
"default"                       { return DEFAULT; }
"do"                            { return DO; }
"double"                        { return DOUBLE; }
"else"                          { return ELSE; }
"extern"                        { return EXTERN; }
"float"                         { return FLOATS; }
"for"                           { return FOR; }
"goto"                          { return GOTO; }
"if"                            { return IF; }
"inline"                        { return INLINE; }
"int"                           { return INTS; }
"long"                          { return LONG; }
"register"                      { return REGISTER; }
"restrict"                      { return RESTRICT; }
"return"                        { return RETURN; }
"short"                         { return SHORT; }
"signed"                        { return SIGNED; }
"sizeof"                        { return SIZEOF; }
"static"                        { return STATIC; }
"struct"                        { return STRUCT; }
"switch"                        { return SWITCH; }
"typedef"                       { return TYPEDEF; }
"union"                         { return UNION; }
"unsigned"                      { return UNSIGNED; }
"void"                          { return VOIDS; }
"volatile"                      { return VOLATILE; }
"while"                         { return WHILE; }
"_Bool"                         { return BOOL; }
"_Complex"                      { return COMPLEX; }
"_Imaginary"                    { return IMAGINARY; }
"["                             { return LP_SQUARE; }
"++"                            { return INCREMENT; }
"/"                             { return DIV; }
"?"                             { return QUESTION_MARK; }
"="                             { return ASSIGNMENT; }
","                             { return COMMA; }
"]"                             { return RP_SQUARE; }
"("                             { return LP_ROUND; }
"{"                             { return LP_CURLY; }
"}"                             { return RP_CURLY; }
"."                             { return DOT; }
"->"                            { return ARROW; }
"*"                             { return MULT; }
"+"                             { return PLUS; }
"-"                             { return MINUS; }
"~"                             { return TILDE; }
"!"                             { return NOT; }
"%"                             { return MODULO; }
"<<"                            { return LEFT_SHIFT; }
">>"                            { return RIGHT_SHIFT; }
"<"                             { return LESS_THAN; }
">"                             { return GREATER_THAN; }
"<="                            { return LESS_THAN_EQUAL; }
">="                            { return GREATER_THAN_EQUAL; }
":"                             { return COLON; }
";"                             { return SEMI_COLON; }
"..."                           { return ELLIPSIS; }
"*="                            { return MULT_ASSGN; }
"/="                            { return DIV_ASSGN; }
"%="                            { return MODULO_ASSGN; }
"+="                            { return PLUS_ASSGN; }
"-="                            { return MINUS_ASSGN; }
"<<="                           { return LEFT_SHIFT_ASSGN; }
"#"                             { return HASH; }
"--"                            { return DECREMENT; }
")"                             { return RP_ROUND; }
"&"                             { return BITWISE_AND; }
"=="                            { return EQUALS; }
"^"                             { return BITWISE_XOR; }
"|"                             { return BITWISE_OR; }
"&&"                            { return LOGICAL_AND; }
"||"                            { return LOGICAL_OR; }
">>="                           { return RIGHT_SHIFT_ASSGN; }
"!="                            { return NOT_EQUALS; }
"&="                            { return BITWISE_AND_ASSGN; }
"|="                            { return BITWISE_OR_ASSGN; }
"^="                            { return BITWISE_XOR_ASSGN; }
{ID}                            { yylval.symbol = currtable->lookup(yytext); return ID; }
{INT_CONST}                     { yylval.intval = atoi(yytext); return INT_CONST; }
{FLOAT_CONST}                   { yylval.floatval = strdup(yytext); return FLOAT_CONST; }
{CHAR_CONST}                    { yylval.charval = strdup(yytext); return CHAR_CONST; }
{STR_LITERAL}                   { yylval.strval = strdup(yytext); return STR_LITERAL; }

{SINGLE_LINE_COMM}              { }
{MULTI_LINE_COMM}               { }

{WHITESPACE}                    { }
{NEWLINE}                       { lineCount++; }
.                               { printf("ERROR [Line %d] : Invalid token %s\n", lineCount, yytext); return INVALID_TOKEN; }

%%

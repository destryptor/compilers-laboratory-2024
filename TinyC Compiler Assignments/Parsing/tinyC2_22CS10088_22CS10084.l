%{
    #include <stdio.h>
    #include "y.tab.h"
%}

ID [a-zA-Z_][a-zA-Z0-9_]*

DIGIT [0-9]
INT_CONST {DIGIT}+
DIG_SEQ  {DIGIT}+
EXP_PART [eE][+-]?{DIG_SEQ}
FRAC_CONST ({DIG_SEQ}?\.{DIG_SEQ})|({DIG_SEQ}\.)
FLOAT_CONST ({FRAC_CONST}{EXP_PART}?)|({DIG_SEQ}{EXP_PART})

ESC_SEQ  "\'"|"\""|"\?"|"\\"|"\b"|"\n"|"\r"|"\v"|"\a"|"\t"|"\f"
C_CHAR   [^("\\"|"\'"|"\n")]|{ESC_SEQ}
CHAR_CONST  "\'"{C_CHAR}"\'"

CONST   {INT_CONST}|{FLOAT_CONST}|{CHAR_CONST}

S_CHAR  [^("\\"|"\""|"\n")]|{ESC_SEQ}
S_CHAR_SEQ {S_CHAR}*
STR_LITERAL "\""{S_CHAR_SEQ}"\""
PUNCT "["|"]"|"("|")"|"{"|"}"|"."|"->"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#"
SPACES [ \t\n]

SINGLE_LINE_COMM                  [/][/][^\n]*
OTHER                             ([^*]|[*][^/])*
MULTI_LINE_COMM                   [/][*]{OTHER}*[*][/]

%%

{SINGLE_LINE_COMM}                  { }
{MULTI_LINE_COMM}                   { }
"auto"                              { return AUTO; }
"break"                             { return BREAK; }
"case"                              { return CASE; }
"char"                              { return CHAR; }
"const"                             { return CONST; }
"continue"                          { return CONTINUE; }
"default"                           { return DEFAULT; }
"do"                                { return DO; }
"double"                            { return DOUBLE; }
"else"                              { return ELSE; }            
"extern"                            { return EXTERN; }
"float"                             { return FLOAT; }
"for"                               { return FOR; }
"goto"                              { return GOTO; }
"if"                                { return IF; }
"inline"                            { return INLINE; }
"int"                               { return INT; }
"long"                              { return LONG; }
"register"                          { return REGISTER; }
"restrict"                          { return RESTRICT; }
"return"                            { return RETURN; }
"short"                             { return SHORT; }
"signed"                            { return SIGNED; }
"sizeof"                            { return SIZEOF; }
"static"                            { return STATIC; }
"struct"                            { return STRUCT; }
"switch"                            { return SWITCH; }
"typedef"                           { return TYPEDEF; }
"union"                             { return UNION; }
"unsigned"                          { return UNSIGNED; }
"void"                              { return VOID; }
"volatile"                          { return VOLATILE; }
"while"                             { return WHILE; }
"_Bool"                             { return BOOL; }
"_Complex"                          { return COMPLEX; }
"_Imaginary"                        { return IMAGINARY; }
"("                                 { return LP_ROUND; }
")"                                 { return RP_ROUND; }
"{"                                 { return LP_CURLY; }
"}"                                 { return RP_CURLY; }
"["                                 { return LP_SQUARE; }
"]"                                 { return RP_SQUARE; }
"."                                 { return DOT; }
"->"                                { return ARROW; }
"++"                                { return INCREMENT; }
"--"                                { return DECREMENT; }
"&"                                 { return BIT_AND; }
"*"                                 { return MULT; }
"+"                                 { return PLUS; }
"-"                                 { return MINUS; }
"~"                                 { return BIT_NOT; }
"!"                                 { return NOT; }
"/"                                 { return DIV; }
"%"                                 { return MOD; }
"<<"                                { return LEFT_SHIFT; }
">>"                                { return RIGHT_SHIFT; }
"<"                                 { return LESS_THAN; }
">"                                 { return GREATER_THAN; }
"<="                                { return LESS_THAN_EQUAL; }
">="                                { return GREATER_THAN_EQUAL; }
"=="                                { return EQUAL; }
"!="                                { return NOT_EQUAL; }
"^"                                 { return BIT_XOR; }
"|"                                 { return BIT_OR; }
"&&"                                { return AND; }
"||"                                { return OR; }
"?"                                 { return QUESTION_MARK; }
":"                                 { return COLON; }
";"                                 { return SEMICOLON; }
"..."                               { return ELLIPSIS; }
"="                                 { return ASSIGN; }
"*="                                { return MULT_ASSIGN; }
"/="                                { return DIV_ASSIGN; }
"%="                                { return MOD_ASSIGN; }
"+="                                { return PLUS_ASSIGN; }
"-="                                { return MINUS_ASSIGN; }
"<<="                               { return LEFT_SHIFT_ASSIGN; }
">>="                               { return RIGHT_SHIFT_ASSIGN; }
"&="                                { return BIT_AND_ASSIGN; }
"^="                                { return BIT_XOR_ASSIGN; }
"|="                                { return BIT_OR_ASSIGN; }
","                                 { return COMMA; }
{ID}                                { return IDENTIFIER; }
{STR_LITERAL}                       { return STR_LITERAL; }
{CHAR_CONST}                        { return CHAR_CONST; }
{INT_CONST}                         { return INT_CONST; }
{FLOAT_CONST}                       { return FLOAT_CONST; }
{SPACES}                            {}


%%


%{
#define KEYWORD 1
#define ID 2
#define INT_CONST 3
#define FLOAT_CONST 4
#define CHAR_CONST 5
#define STR_LITERAL 6
#define PUNCT 7
#define SINGLE_LINE_COMM 8
#define MULTI_LINE_COMM 9
%}

KEYWORD  "auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"int"|"long"|"register"|"restrict"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while"|"_Bool"|"_Complex"|"_Imaginary"

ID [a-zA-Z_][a-zA-Z0-9_]*

DIGIT [0-9]
INT_CONST {DIGIT}+
DIG_SEQ  {DIGIT}+
EXP_PART [eE][+-]?{DIG_SEQ}
FRAC_CONST ({DIG_SEQ}?\.{DIG_SEQ})|({DIG_SEQ}\.)
FLOAT_CONST ({FRAC_CONST}{EXP_PART}?)|({DIG_SEQ}{EXP_PART})

ENUM  {ID}

ESC_SEQ  "\'"|"\""|"\?"|"\\"|"\b"|"\n"|"\r"|"\v"|"\a"|"\t"|"\f"
C_CHAR   [^("\\"|"\'"|"\n")]|{ESC_SEQ}
C_CHAR_SEQ  {C_CHAR}+
CHAR_CONST  "\'"{C_CHAR_SEQ}"\'"

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

{SINGLE_LINE_COMM}                { return SINGLE_LINE_COMM; }
{MULTI_LINE_COMM}                 { return MULTI_LINE_COMM; }
{KEYWORD}                           { return KEYWORD; }
{ID}                                { return ID; }
{PUNCT}                             { return PUNCT; }
{STR_LITERAL}                       { return STR_LITERAL; }
{CHAR_CONST}                        { return CHAR_CONST; }
{INT_CONST}                         { return INT_CONST; }
{FLOAT_CONST}                       { return FLOAT_CONST; }
{SPACES}                            {}


%%


%{
#define LP 1
#define RP 2
#define NUM 3
#define OP 4
#define ID 5
#define INVTOK 6
%}

space	[ \t\n]
spaces	{space}+
neg     [-]
digit	[0-9]
digits	{digit}+
number	{neg}?{digits}
id	    [a-zA-Z_][a-zA-Z0-9_]*

%%

{spaces}	{ }
{number}	{ return NUM; }
"("		    { return LP; }
")"		    { return RP; }
"+"		    { return OP; }
"-"		    { return OP; }
"*"		    { return OP; }
"/"		    { return OP; }
"%"		    { return OP; }
{id}		{ return ID; }
.           { return INVTOK; }

%%


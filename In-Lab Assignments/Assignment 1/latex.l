%{
    #define cmd 1
    #define envbegin 2
    #define envend 3
    #define inlinemath 4
    #define displaymath 5
    #define displaymathbegin 6
    #define displaymathend 7
    #define comment 8
%}

space [ \t\n]
spaces {space}+
letter [a-zA-Z]
letters {letter}+
tilde [~]
cmdname \\{letters}
singlecharcmd \\.
envbeginname \\[b][e][g][i][n]{spaces}?[{]{letter}+[}]
envendname \\[e][n][d]{spaces}?[{]{letter}+[}]
comment [%].*

%%
{spaces} {}
"$" {return(inlinemath);}
"$$" {return(displaymath);}
"\\[" {return(displaymathbegin);}
"\\]" {return(displaymathend);}
{tilde} {return(cmd);}
{envbeginname} {return(envbegin);}
{envendname} {return(envend);}
{cmdname} {return(cmd);}
{singlecharcmd} {return(cmd);}
{comment} {return(comment);}
. {}

%%

%{  
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    void yyerror(char* s);
    int yylex();
    int yywrap(void) {
        return 1;
    }
    extern char* yytext;

    typedef struct entry_ {
        char *id;
        int offset;
        struct entry_ *next;
    } entry;
    
    entry* head = NULL;
    int regIdx = 1;
    int memIdx = 0;
    // int currOffset;

    entry* addToTable(char* id);
    int getOffset(char* id);

    typedef struct arg_ {
        int type; // 0 for id, 1 for num, 2 for expr in reg, 3 for expr in mem;
        // char* id;
        int val;
        // int isInMem;
    } arg;

    int reg0used = 0;
    int reg1used = 0;
    int temporary = 0;
    int flagInMem = 0;
    // char* inMemId;

    void handleArg(arg* arg1, arg* arg2, arg* expr, char op);
%}

%union {arg argvar; int num; char* id; char op;}
%start PROGRAM
%token <num> NUM
%token set
%token <id> ID
%type <argvar> EXPRSTMT EXPR ARG 
%token <op> '+'
%token <op> '-'
%token <op> '*'
%token <op> '/'
%token <op> '^'
%token <op> '%'
%type <op> OP

%%
PROGRAM : STMT PROGRAM
        | STMT
        ;
STMT    : SETSTMT { regIdx = 1; }
        | EXPRSTMT { regIdx = 1; }
        ;
SETSTMT : '(' set  ID  NUM ')' {
            head = addToTable($3); 
            printf("\tMEM[%d] = %d;\n", getOffset($3), $4);
            printf("\tmprn(MEM, %d);\n", getOffset($3));
            }
        | '(' set  ID  ID ')'       {
            head = addToTable($3);
            head = addToTable($4);
            printf("\tR[0] = MEM[%d];\n", getOffset($4));
            printf("\tMEM[%d] = R[0];\n", getOffset($3));
            printf("\tmprn(MEM, %d);\n", getOffset($3));
            }
        | '(' set  ID  EXPR ')' {
              head = addToTable($3);
              if($4.type == 2) {
                printf("\tMEM[%d] = R[%d];\n", getOffset($3), $4.val);
              } else { 
                printf("\tR[0] = MEM[%d];\n", $4.val);
                printf("\tMEM[%d] = R[0];\n", getOffset($3));
            }
            printf("\tmprn(MEM, %d);\n",getOffset($3));
            }
          
        ;
EXPRSTMT: EXPR {
                $$ = $1;
                printf("\teprn(R, %d);\n", $1.val);
            }
        ;
EXPR    : '(' OP  ARG  ARG ')' {
            // flagInMem = 0;
            int reg1 = $3.val;
            int reg2 = $4.val;
            // printf("\texpr1 id: %s\n", $3.id);
            // printf("\texpr2 id: %s\n", $4.id);
            // printf("\treg1: %d\n", reg1);
            // printf("\treg2: %d\n", reg2);
            // if ($3.isInMem && $4.isInMem) {
            //     printf("\tMEMOPS\n");
            // }
            // printf("\treg1 type: %d, in Mem: %d\n", $3.type, $3.isInMem);
            // printf("\treg2 type: %d, in Mem: %d\n", $4.type, $4.isInMem);
            if(regIdx < 12 && !(regIdx == 11 && !($3.type == 2 || $4.type == 2))) {
                $$.type = 2;
                handleArg(&$3, &$4, &$$, $2);
            } else {
                // printf("\t//TEMP: %d\n", temporary);
                char buffer[50];
                sprintf(buffer, "%d", temporary);
                head = addToTable(buffer);
                $$.type = 3;
                $$.val = getOffset(buffer);

                handleArg(&$3, &$4, &$$, $2);
                temporary++;
            }
        }
        ;
OP      : '+' { $$ = '+'; }
        | '-' { $$ = '-'; }
        | '*' { $$ = '*'; }
        | '/' { $$ = '/'; }
        | '%' { $$ = '%'; }
        | '^' { $$ = '^'; }
        ;
ARG     : ID    { 
            int offset = getOffset($1);
            if (offset == -1) {
                head = addToTable($1);
            }
            $$.val = getOffset($1);
            // printf("\tset token: %s\n", $$.id);
            $$.type = 0;
            // printf("\tadded token: %s\n", id);
        }
        | NUM   {
            $$.val = $1;
            // printf("\tval: %d\n", val);
            $$.type = 1;
            // printf("\tset val: %d\n", val);
        }
        | EXPR  {
            $$.val = $1.val;
            $$.type = $1.type;
        }
        ;
%%

void yyerror(char* s) {
    printf("\tError: %s\n", s);
}
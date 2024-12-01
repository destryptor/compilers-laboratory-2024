%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yylex(void);
    void yyerror(char *s);
    int yyparse(void);
    int yywrap(void) {
        return 1;
    }
    
    typedef struct quad_ {
        char* op;
        char* arg1;
        char* arg2;
        char* result;
        int quadNo;
        int blockNo;
        int isLeader;
        struct quad_* next;
    } quad;

    typedef struct node_ {
        char* name;
        int offset;
        int value;
        int* registers;
        int isInMemory;
        struct node_* next;
    } node;

    quad* quadList = NULL;
    node* symbolTable = NULL;

    int instrNo = 0;
    int tempNo = 1;
    int offset = 0;
    int numRegisters = 5;
    int sizeOfSymbolTable = 0;
    int targetInstrNo = 0;

    void emit(char* op, char* arg1, char* arg2, char* result) {
        quad* newQuad = (quad*)malloc(sizeof(quad));

        newQuad->op = strdup(op);
        newQuad->arg1 = strdup(arg1);
        newQuad->arg2 = strdup(arg2);
        newQuad->result = strdup(result);
        newQuad->quadNo = ++instrNo;
        newQuad->blockNo = 0;
        newQuad->isLeader = 0;
        newQuad->next = NULL;

        if(!quadList) {
            quadList = newQuad;
        } else {
            quad* temp = quadList;
            while(temp->next) {
                temp = temp->next;
            }
            temp->next = newQuad;
        }
    }

    void addSymbol(char* name) {
        node* newNode = (node*)malloc(sizeof(node));
        newNode->name = strdup(name);
        newNode->offset = offset;
        newNode->registers = (int*)malloc(numRegisters * sizeof(int));
        for(int i = 0; i < numRegisters; i++) {
            newNode->registers[i] = 0;
        }
        newNode->isInMemory = 1;
        offset += 4;
        newNode->next = NULL;

        if(!symbolTable) {
            symbolTable = newNode;
        } else {
            node* temp = symbolTable;
            while(temp->next) {
                if(!strcmp(temp->name, name)) {
                    // printf("Variable %s already declared\n", name);
                    return;
                }
                temp = temp->next;
            }
            if(!strcmp(temp->name, name)) {
                    // printf("Variable %s already declared\n", name);
                    return;
            }
            temp->next = newNode;
            // printf("strcmp: %d", strcmp(temp->name, name));
            // printf("Variable %s added\n", name);
        }
    }

    // typedef struct stack_ {
    //     int data;
    //     struct stack_* next;
    // } stack;

    // stack* top = NULL;

    // void push(int data) {
    //     stack* newNode = (stack*)malloc(sizeof(stack));
    //     newNode->data = data;
    //     newNode->next = top;
    //     top = newNode;
    // }

    // int pop() {
    //     if(!top) {
    //         return -1;
    //     }
    //     int data = top->data;
    //     stack* temp = top;
    //     top = top->next;
    //     free(temp);
    //     return data;
    // }

    void backpatch(int quadNo) {
        quad* temp = quadList;
        while(temp) {
            if(temp->quadNo == quadNo) {
                char* strInst = (char*)malloc(50);
                sprintf(strInst, "%d", instrNo + 1);
                temp->result = strdup(strInst);
                free(strInst);
            }
            temp = temp->next;
        }
    }

    int blockNo = 1;

    typedef struct regdesc_ {
        int regNo;
        int* hasVar;
    } regdesc;

    regdesc* regDesc = NULL;

    typedef struct target_ {
        char* op;
        char* arg1;
        char* arg2;
        char* result;
        int targetNo;
        int blockNo;
        struct target_* next;
    } target;

    target* T = NULL;
    target* targetList = NULL;

    typedef struct leaderDesc_ {
        int quadNo;
        int targetNo;
    } leaderDesc;

    leaderDesc* leaders = NULL;

    typedef struct storeList_ {
        int num;
        struct storeList_* next;
    } storeList;

    storeList* toBeStored = NULL;

%}

%union {
    int numval;
    char* strval;
}

%token SET WHEN LOOPS WHILE LP RP PLUS MINUS MULT DIV MOD EQ NEQ LT LE GT GE 
%token <strval> IDEN NUMB

%type LIST STMT ASGN LOOP COND
%type <numval> M
%type <strval> ATOM OPER RELN BOOL EXPR
%start LIST


%%
LIST: STMT      
    | STMT LIST
    ;

STMT: ASGN
    | COND
    | LOOP
    ;

ASGN: LP SET IDEN ATOM RP {
        // printf("%s\n", $3); 
        addSymbol($3);
        emit("=", $4, "", $3);
    }
    ;

COND: LP WHEN BOOL M LIST RP { 
        backpatch($4 - 1);
    }
    ;

LOOP: LP LOOPS WHILE M BOOL M LIST RP {
        char* strInst = (char*)malloc(50);
        sprintf(strInst, "%d", $4);
        emit("goto", "", "", strInst);
        backpatch($6 - 1);
    }
    ;

M   :       { $$ = instrNo + 1; } 
    ;
    
EXPR: LP OPER ATOM ATOM RP  { 
        char* temp = (char*)malloc(50);
        sprintf(temp, "$%d", tempNo++);
        addSymbol(temp);
        emit($2, $3, $4, temp);
        $$ = strdup(temp);
        free(temp);
    }
    ;

BOOL: LP RELN ATOM ATOM RP  { 
        $$ = (char*)malloc(50);
        char* iff = (char*)malloc(50);
        sprintf(iff, "iffalse %s", $2);
        sprintf($$, "%s %s %s", $3, $2, $4);
        emit(iff, $3, $4, "");
        // push(instrNo);
        // free(temp);
        free(iff);
    }
    ;

ATOM: IDEN  { $$ = strdup($1); addSymbol($1); }
    | NUMB  { $$ = strdup($1); }
    | EXPR  { $$ = strdup($1); }
    ;

OPER: PLUS  { $$ = strdup("+"); }
    | MINUS { $$ = strdup("-"); }
    | MULT  { $$ = strdup("*"); }
    | DIV   { $$ = strdup("/"); }
    | MOD   { $$ = strdup("%"); }
    ;

RELN: EQ    { $$ = strdup("=="); }
    | NEQ   { $$ = strdup("!="); } 
    | LT    { $$ = strdup("<"); }
    | GT    { $$ = strdup(">"); }
    | LE    { $$ = strdup("<="); }
    | GE    { $$ = strdup(">="); }
    ;
%%

void yyerror(char *s) {
    printf("Error: %s\n", s);
}
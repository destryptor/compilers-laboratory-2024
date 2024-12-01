%{
    #define YYDEBUG 1
    extern int yydebug;
    
    void yyerror(char* s);
    int yylex();
    int yywrap(void) {
        return 1;
    }
    typedef struct Node_ {
        char* id;
        int val;
        struct Node_* next;
    } Node;
    Node* head = NULL;
    Node* tempHead = NULL;
    Node* tempCurr = NULL;

    typedef struct TreeNode_ {
        char* id;
        int val;
        struct TreeNode_* left;
        struct TreeNode_* right;
        struct TreeNode_* parent;
    } TreeNode;
    TreeNode* root = NULL;

    Node* addToTable(char* id_);
    Node* addToTempTable(char* id_, int val_);
    Node* setVal(char* id_, int val_);
    int getVal(char* id);
    
    TreeNode* createLeaf(char* id_, int val);
    TreeNode* addToTree(TreeNode* root, char* id_, int val_);
    int evalTree(TreeNode* root);
    TreeNode* buildTree(Node* head);
    int evaluate(char op, int arg1, int arg2);
%}

%union {int num; char* id; char op;}
%start PROGRAM
%token <num> NUM
%token set
%token <id> ID
%type <num> EXPR ARG EXPRSTMT
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
STMT    : SETSTMT
        | EXPRSTMT
        ;
SETSTMT : '(' set  ID  NUM ')' {head = addToTable($3); head = setVal($3, $4);}
        | '(' set  ID  ID ')'  {head = addToTable($3); int val = getVal($4); head = setVal($3, val);}
        | '(' set  ID  EXPR ')'   {head = addToTable($3); head = setVal($3, $4);}
        ;
EXPRSTMT: EXPR {TreeNode* root = buildTree(tempHead); printf("Standalone expression evaluates to: %d\n", $$); root = NULL;}
        ;
EXPR    : '(' OP  ARG  ARG ')' {$$ = evaluate($2, $3, $4);}
        ;
OP      : '+' { $$ = '+'; char* temp = (char*)malloc(sizeof(char)); temp[0] = $$; tempHead = addToTempTable(temp, 0);}
        | '-' { $$ = '-'; char* temp = (char*)malloc(sizeof(char)); temp[0] = $$; tempHead = addToTempTable(temp, 0);}
        | '*' { $$ = '*'; char* temp = (char*)malloc(sizeof(char)); temp[0] = $$; tempHead = addToTempTable(temp, 0);}
        | '/' { $$ = '/'; char* temp = (char*)malloc(sizeof(char)); temp[0] = $$; tempHead = addToTempTable(temp, 0);}
        | '%' { $$ = '%'; char* temp = (char*)malloc(sizeof(char)); temp[0] = $$; tempHead = addToTempTable(temp, 0);}
        | '^' { $$ = '^'; char* temp = (char*)malloc(sizeof(char)); temp[0] = $$; tempHead = addToTempTable(temp, 0);}
        ;
ARG     : ID    { $$ = getVal($1); tempHead = addToTempTable("---", $$);}
        | NUM   { $$ = $1; tempHead = addToTempTable("---", $$);}
        | EXPR  { $$ = $1; }
        ;
%%

void yyerror(char* s) {
    printf("Error: %s\n", s);
}
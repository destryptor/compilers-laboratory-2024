%{
    #define YYDEBUG 1
    extern int yydebug;

    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    #include <math.h>
    void yyerror(char* s);
    extern char* yytext;
    int yylex();
    int yywrap(void) {
        return 1;
    }

    struct TreeNode;

    struct TreeNode* create_node(char *name, int child_count, ...);

    void print_tree(struct TreeNode *node, int depth);

    void setattr(struct TreeNode* root);

    struct TreeNode *parse_tree_root;
%}

%union {char* intval; struct TreeNode* node;}

%token MINUS PLUS POW x
%token <intval> ZERO ONE D

%type <node> S P T X N M

%start S

%%
S   : P             {$$ = create_node("S", 1, $1); parse_tree_root = $$;}
    | PLUS P        {$$ = create_node("S", 2, create_node("+", 0), $2); parse_tree_root = $$;}
    | MINUS P       {$$ = create_node("S", 2, create_node("-", 0), $2); parse_tree_root = $$;}
    ;

P   : T             {$$ = create_node("P", 1, $1);}
    | T PLUS P      {$$ = create_node("P", 3, $1, create_node("+", 0), $3);}
    | T MINUS P     {$$ = create_node("P", 3, $1, create_node("-", 0), $3);}
    ;

T   : ONE           {$$ = create_node("T", 1, create_node("1", 0));}
    | N             {$$ = create_node("T", 1, $1);}
    | X             {$$ = create_node("T", 1, $1);}
    | N X           {$$ = create_node("T", 2, $1, $2);}

X   : x             {$$ = create_node("X", 1, create_node("x", 0));}
    | x POW N       {$$ = create_node("X", 3, create_node("x", 0),  create_node("^", 0), $3);}

N   : D             {$$ = create_node("N", 1, create_node($1, 0));}
    | ONE M         {$$ = create_node("N", 2, create_node("1", 0), $2);}
    | D M           {$$ = create_node("N", 2, create_node($1, 0), $2);}

M   : ZERO          {$$ = create_node("M", 1, create_node("0", 0));}
    | ONE           {$$ = create_node("M", 1, create_node("1", 0));}
    | D             {$$ = create_node("M", 1, create_node($1, 0));}
    | ZERO M        {$$ = create_node("M", 2, create_node("0", 0), $2);}     
    | ONE M         {$$ = create_node("M", 2, create_node("1", 0), $2);} 
    | D M           {$$ = create_node("M", 2, create_node($1, 0), $2);} 
%%

void yyerror(char* s) {
    printf("error\n%s", s);
}
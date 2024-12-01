%{
    #define YYDEBUG 1
    extern int yydebug;

    #include <stdlib.h>
    #include <string.h>
    #include <stdarg.h>
    void yyerror(char* s);
    int yylex();
    char* yytext;
    int yywrap(void) {
        return 1;
    }

    struct TreeNode {
        char *name;
        struct TreeNode **children;
        int child_count;
    };

    struct TreeNode* create_node(char *name, int child_count, ...) {
        struct TreeNode *node = malloc(sizeof(struct TreeNode));
        node->name = strdup(name);
        node->child_count = child_count;
        node->children = malloc(sizeof(struct TreeNode*) * child_count);
        if(node->children == NULL) {
            yyerror("Memory allocation failed");
            exit(1);
        }

        va_list args;
        va_start(args, child_count);
        for (int i = 0; i < child_count; i++) {
            node->children[i] = va_arg(args, struct TreeNode*);
        }
        va_end(args);

        return node;
    }

    void print_tree(struct TreeNode *node, int depth) {
        for (int i = 0; i < depth; i++) printf("\t");
        printf("---> %s\n", node->name);
        for (int i = 0; i < node->child_count; i++) {
            print_tree(node->children[i], depth + 1);
        }
    }

    struct TreeNode *parse_tree_root;

%}

%union { int intval; float floatval; char charval; char* strval; struct TreeNode* node; }

%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE EXTERN FLOAT FOR GOTO IF INLINE INT LONG REGISTER RESTRICT RETURN SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE BOOL COMPLEX IMAGINARY
%token LP_ROUND RP_ROUND LP_CURLY RP_CURLY LP_SQUARE RP_SQUARE
%token DOT ARROW INCREMENT DECREMENT
%token AND OR NOT
%token BIT_AND BIT_OR BIT_NOT BIT_XOR
%token MULT DIV MOD PLUS MINUS
%token LESS_THAN GREATER_THAN LESS_THAN_EQUAL GREATER_THAN_EQUAL EQUAL NOT_EQUAL LEFT_SHIFT RIGHT_SHIFT
%token ASSIGN PLUS_ASSIGN MINUS_ASSIGN MULT_ASSIGN DIV_ASSIGN MOD_ASSIGN LEFT_SHIFT_ASSIGN RIGHT_SHIFT_ASSIGN BIT_AND_ASSIGN BIT_XOR_ASSIGN BIT_OR_ASSIGN
%token SEMICOLON COLON COMMA QUESTION_MARK ELLIPSIS 

%token IDENTIFIER
%token <intval> INT_CONST
%token <floatval> FLOAT_CONST
%token <charval> CHAR_CONST
%token <strval> STR_LITERAL

%start translation_unit

%type <node> primary_expression constant postfix_expression argument_expression_list_opt argument_expression_list unary_expression unary_operator cast_expression multiplicative_expression additive_expression shift_expression relational_expression equality_expression AND_expression exclusive_OR_expression inclusive_OR_expression logical_AND_expression logical_OR_expression conditional_expression assignment_expression assignment_operator expression constant_expression declaration init_declarator_list_opt declaration_specifiers declaration_specifiers_opt init_declarator_list storage_class_specifier type_specifier specifier_qualifier_list specifier_qualifier_list_opt type_qualifier function_specifier declarator pointer_opt direct_declarator pointer type_qualifier_list parameter_type_list parameter_list parameter_declaration identifier_list_opt identifier_list type_name initializer initializer_list designation_opt designation designator_list designator labeled_statement compound_statement block_item_list_opt block_item_list block_item expression_statement expression_opt selection_statement iteration_statement jump_statement translation_unit external_declaration function_definition declaration_list_opt declaration_list statement type_qualifier_list_opt assignment_expression_opt init_declarator

%%

// 1. Expressions
primary_expression
    : IDENTIFIER { printf("primary-expression -> identifier\n"); 
    $$ = create_node("primary-expression", 1, create_node("identifier", 0)); }
    | constant { printf("primary-expression -> constant\n"); 
    $$ = create_node("primary-expression", 1, $1); }
    | STR_LITERAL { printf("primary-expression -> string-literal\n"); 
    $$ = create_node("primary-expression", 1, create_node("string-literal", 0)); }
    | LP_ROUND expression RP_ROUND { printf("primary-expression -> ( expression )\n"); 
    $$ = create_node("primary-expression", 3, create_node("(", 0), $2, create_node(")", 0)); }
    ;

constant
    : INT_CONST { printf("constant -> integer-constant\n"); 
    $$ = create_node("constant", 1, create_node("integer-constant", 0)); }
    | FLOAT_CONST { printf("constant -> floating-constant\n"); 
    $$ = create_node("constant", 1, create_node("floating-constant", 0)); }
    | CHAR_CONST { printf("constant -> character-constant\n"); 
    $$ = create_node("constant", 1, create_node("character-constant", 0)); }
    ;

postfix_expression
    : primary_expression { printf("postfix-expression -> primary-expression\n"); 
    $$ = create_node("postfix-expression", 1, $1); }
    | postfix_expression LP_SQUARE expression RP_SQUARE { printf("postfix-expression -> postfix-expression [ expression ]\n"); 
    $$ = create_node("postfix-expression", 4, $1, create_node("[", 0), $3, create_node("]", 0)); }
    | postfix_expression LP_ROUND RP_ROUND { printf("postfix-expression -> postfix-expression ( )\n"); 
    $$ = create_node("postfix-expression", 3, $1, create_node("(", 0), create_node(")", 0)); }
    | postfix_expression LP_ROUND argument_expression_list_opt RP_ROUND { printf("postfix-expression -> postfix-expression ( argument-expression-list )\n"); 
    $$ = create_node("postfix-expression", 4, $1, create_node("(", 0), $3, create_node(")", 0)); }
    | postfix_expression DOT IDENTIFIER { printf("postfix-expression -> postfix-expression . identifier\n"); 
    $$ = create_node("postfix-expression", 3, $1, create_node(".", 0), create_node("identifier", 0)); }
    | postfix_expression ARROW IDENTIFIER { printf("postfix-expression -> postfix-expression -> identifier\n"); 
    $$ = create_node("postfix-expression", 3, $1, create_node("->", 0), create_node("identifier", 0)); }
    | postfix_expression INCREMENT { printf("postfix-expression -> postfix-expression ++\n"); 
    $$ = create_node("postfix-expression", 2, $1, create_node("++", 0)); }
    | postfix_expression DECREMENT { printf("postfix-expression -> postfix-expression --\n"); 
    $$ = create_node("postfix-expression", 2, $1, create_node("--", 0)); }
    | LP_ROUND type_name RP_ROUND LP_CURLY initializer_list RP_CURLY { printf("postfix-expression -> ( type-name ) { initializer-list }\n"); 
    $$ = create_node("postfix-expression", 6, create_node("(", 0), $2, create_node(")", 0), create_node("{", 0), $5, create_node("}", 0)); }
    | LP_ROUND type_name RP_ROUND LP_CURLY initializer_list COMMA RP_CURLY { printf("postfix-expression -> ( type-name ) { initializer-list , }\n"); 
    $$ = create_node("postfix-expression", 7, create_node("(", 0), $2, create_node(")", 0), create_node("{", 0), $5, create_node(",", 0), create_node("}", 0)); }
    ;

argument_expression_list_opt
    : argument_expression_list { printf("argument-expression-list-opt -> argument-expression-list\n"); 
    $$ = create_node("argument-expression-list", 1, $1); }
    | { printf("argument-expression-list-opt -> epsilon\n"); 
    $$ = create_node("argument-expression-list", 1, create_node("epsilon", 0)); }
    ;

argument_expression_list 
    : assignment_expression { printf("argument-expression-list -> assignment-expression\n"); 
    $$ = create_node("argument-expression-list", 1, $1); }
    | argument_expression_list COMMA assignment_expression { printf("argument-expression-list -> argument-expression-list , assignment-expression\n"); 
    $$ = create_node("argument-expression-list", 3, $1, create_node(",", 0), $3); }
    ;

unary_expression
    : postfix_expression { printf("unary-expression -> postfix-expression\n"); 
    $$ = create_node("unary-expression", 1, $1); }
    | INCREMENT unary_expression { printf("unary-expression -> ++ unary-expression\n"); 
    $$ = create_node("unary-expression", 2, create_node("++", 0), $2); }
    | DECREMENT unary_expression { printf("unary-expression -> -- unary-expression\n"); 
    $$ = create_node("unary-expression", 2, create_node("--", 0), $2); }
    | unary_operator cast_expression { printf("unary-expression -> unary-operator cast-expression\n"); 
    $$ = create_node("unary-expression", 2, $1, $2); }
    | SIZEOF unary_expression { printf("unary-expression -> sizeof unary-expression\n"); 
    $$ = create_node("unary-expression", 2, create_node("sizeof", 0), $2); }
    | SIZEOF LP_ROUND type_name RP_ROUND { printf("unary-expression -> sizeof ( type-name )\n"); 
    $$ = create_node("unary-expression", 4, create_node("sizeof", 0), create_node("(", 0), $3, create_node(")", 0)); }
    ;

unary_operator
    : BIT_AND { printf("unary-operator -> &\n"); 
    $$ = create_node("unary-operator", 1, create_node("&", 0)); }
    | MULT { printf("unary-operator -> *\n"); 
    $$ = create_node("unary-operator", 1, create_node("*", 0)); }
    | PLUS { printf("unary-operator -> +\n"); 
    $$ = create_node("unary-operator", 1, create_node("+", 0)); }
    | MINUS { printf("unary-operator -> -\n"); 
    $$ = create_node("unary-operator", 1, create_node("-", 0)); }
    | BIT_NOT { printf("unary-operator -> ~\n"); 
    $$ = create_node("unary-operator", 1, create_node("~", 0)); }
    | NOT { printf("unary-operator -> !\n"); 
    $$ = create_node("unary-operator", 1, create_node("!", 0)); }
    ;

cast_expression
    : unary_expression { printf("cast-expression -> unary-expression\n"); 
    $$ = create_node("cast-expression", 1, $1); }
    | LP_ROUND type_name RP_ROUND cast_expression { printf("cast-expression -> ( type-name ) cast-expression\n"); 
    $$ = create_node("cast-expression", 4, create_node("(", 0), $2, create_node(")", 0), $4); }
    ;

multiplicative_expression
    : cast_expression { printf("multiplicative-expression -> cast-expression\n"); 
    $$ = create_node("multiplicative-expression", 1, $1); }
    | multiplicative_expression MULT cast_expression { printf("multiplicative-expression -> multiplicative-expression * cast-expression\n"); 
    $$ = create_node("multiplicative-expression", 3, $1, create_node("*", 0), $3); }
    | multiplicative_expression DIV cast_expression { printf("multiplicative-expression -> multiplicative-expression / cast-expression\n"); 
    $$ = create_node("multiplicative-expression", 3, $1, create_node("/", 0), $3); }
    | multiplicative_expression MOD cast_expression { printf("multiplicative-expression -> multiplicative-expression %% cast-expression\n"); 
    $$ = create_node("multiplicative-expression", 3, $1, create_node("%", 0), $3); }
    ;

additive_expression
    : multiplicative_expression { printf("additive-expression -> multiplicative-expression\n"); 
    $$ = create_node("additive-expression", 1, $1); }
    | additive_expression PLUS multiplicative_expression { printf("additive-expression -> additive-expression + multiplicative-expression\n"); 
    $$ = create_node("additive-expression", 3, $1, create_node("+", 0), $3); }
    | additive_expression MINUS multiplicative_expression { printf("additive-expression -> additive-expression - multiplicative-expression\n"); 
    $$ = create_node("additive-expression", 3, $1, create_node("-", 0), $3); }
    ;

shift_expression
    : additive_expression { printf("shift-expression -> additive-expression\n"); 
    $$ = create_node("shift-expression", 1, $1); }
    | shift_expression LEFT_SHIFT additive_expression { printf("shift-expression -> shift-expression << additive-expression\n"); 
    $$ = create_node("shift-expression", 3, $1, create_node("<<", 0), $3); }
    | shift_expression RIGHT_SHIFT additive_expression { printf("shift-expression -> shift-expression >> additive-expression\n"); 
    $$ = create_node("shift-expression", 3, $1, create_node(">>", 0), $3); }
    ;

relational_expression
    : shift_expression { printf("relational-expression -> shift-expression\n"); 
    $$ = create_node("relational-expression", 1, $1); }
    | relational_expression LESS_THAN shift_expression { printf("relational-expression -> relational-expression < shift-expression\n"); 
    $$ = create_node("relational-expression", 3, $1, create_node("<", 0), $3); }
    | relational_expression GREATER_THAN shift_expression { printf("relational-expression -> relational-expression > shift-expression\n"); 
    $$ = create_node("relational-expression", 3, $1, create_node(">", 0), $3); }
    | relational_expression LESS_THAN_EQUAL shift_expression { printf("relational-expression -> relational-expression <= shift-expression\n"); 
    $$ = create_node("relational-expression", 3, $1, create_node("<=", 0), $3); }
    | relational_expression GREATER_THAN_EQUAL shift_expression { printf("relational-expression -> relational-expression >= shift-expression\n"); 
    $$ = create_node("relational-expression", 3, $1, create_node(">=", 0), $3); }
    ;

equality_expression
    : relational_expression { printf("equality-expression -> relational-expression\n"); 
    $$ = create_node("equality-expression", 1, $1); }
    | equality_expression EQUAL relational_expression { printf("equality-expression -> equality-expression == relational-expression\n"); 
    $$ = create_node("equality-expression", 3, $1, create_node("==", 0), $3); }
    | equality_expression NOT_EQUAL relational_expression { printf("equality-expression -> equality-expression != relational-expression\n"); 
    $$ = create_node("equality-expression", 3, $1, create_node("!=", 0), $3); }
    ;

AND_expression
    : equality_expression { printf("AND-expression -> equality-expression\n"); 
    $$ = create_node("AND-expression", 1, $1); }
    | AND_expression BIT_AND equality_expression { printf("AND-expression -> AND-expression & equality-expression\n"); 
    $$ = create_node("AND-expression", 3, $1, create_node("&", 0), $3); }
    ;

exclusive_OR_expression
    : AND_expression { printf("exclusive-OR-expression -> AND-expression\n"); 
    $$ = create_node("exclusive-OR-expression", 1, $1); }
    | exclusive_OR_expression BIT_XOR AND_expression { printf("exclusive-OR-expression -> exclusive-OR-expression ^ AND-expression\n"); 
    $$ = create_node("exclusive-OR-expression", 3, $1, create_node("^", 0), $3); }
    ;

inclusive_OR_expression
    : exclusive_OR_expression { printf("inclusive-OR-expression -> exclusive-OR-expression\n"); 
    $$ = create_node("inclusive-OR-expression", 1, $1); }
    | inclusive_OR_expression BIT_OR exclusive_OR_expression { printf("inclusive-OR-expression -> inclusive-OR-expression | exclusive-OR-expression\n"); 
    $$ = create_node("inclusive-OR-expression", 3, $1, create_node("|", 0), $3); }
    ;

logical_AND_expression
    : inclusive_OR_expression { printf("logical-AND-expression -> inclusive-OR-expression\n"); 
    $$ = create_node("logical-AND-expression", 1, $1); }
    | logical_AND_expression AND inclusive_OR_expression { printf("logical-AND-expression -> logical-AND-expression && inclusive-OR-expression\n"); 
    $$ = create_node("logical-AND-expression", 3, $1, create_node("&&", 0), $3); }
    ;

logical_OR_expression
    : logical_AND_expression { printf("logical-OR-expression -> logical-AND-expression\n"); 
    $$ = create_node("logical-OR-expression", 1, $1); }
    | logical_OR_expression OR logical_AND_expression { printf("logical-OR-expression -> logical-OR-expression || logical-AND-expression\n"); 
    $$ = create_node("logical-OR-expression", 3, $1, create_node("||", 0), $3); }
    ;

conditional_expression
    : logical_OR_expression { printf("conditional-expression -> logical-OR-expression\n"); 
    $$ = create_node("conditional-expression", 1, $1); }
    | logical_OR_expression QUESTION_MARK expression COLON conditional_expression { printf("conditional-expression -> logical-OR-expression ? expression : conditional-expression\n"); 
    $$ = create_node("conditional-expression", 5, $1, create_node("?", 0), $3, create_node(":", 0), $5); }
    ;

assignment_expression
    : conditional_expression { printf("assignment-expression -> conditional-expression\n"); 
    $$ = create_node("assignment-expression", 1, $1); }
    | unary_expression assignment_operator assignment_expression { printf("assignment-expression -> unary-expression assignment-operator assignment-expression\n"); 
    $$ = create_node("assignment-expression", 3, $1, $2, $3); }
    ;

assignment_operator
    : ASSIGN { printf("assignment-operator -> =\n"); 
    $$ = create_node("assignment-operator", 1, create_node("=", 0)); }
    | MULT_ASSIGN { printf("assignment-operator -> *=\n"); 
    $$ = create_node("assignment-operator", 1, create_node("*=", 0)); }
    | DIV_ASSIGN { printf("assignment-operator -> /=\n"); 
    $$ = create_node("assignment-operator", 1, create_node("/=", 0)); }
    | MOD_ASSIGN { printf("assignment-operator -> %%=\n"); 
    $$ = create_node("assignment-operator", 1, create_node("%=", 0)); }
    | PLUS_ASSIGN { printf("assignment-operator -> +=\n"); 
    $$ = create_node("assignment-operator", 1, create_node("+=", 0)); }
    | MINUS_ASSIGN { printf("assignment-operator -> -=\n"); 
    $$ = create_node("assignment-operator", 1, create_node("-=", 0)); }
    | LEFT_SHIFT_ASSIGN { printf("assignment-operator -> <<=\n"); 
    $$ = create_node("assignment-operator", 1, create_node("<<=", 0)); }
    | RIGHT_SHIFT_ASSIGN { printf("assignment-operator -> >>=\n"); 
    $$ = create_node("assignment-operator", 1, create_node(">>=", 0)); }
    | BIT_AND_ASSIGN { printf("assignment-operator -> &=\n"); 
    $$ = create_node("assignment-operator", 1, create_node("&=", 0)); }
    | BIT_XOR_ASSIGN { printf("assignment-operator -> ^=\n"); 
    $$ = create_node("assignment-operator", 1, create_node("^=", 0)); }
    | BIT_OR_ASSIGN { printf("assignment-operator -> |=\n"); 
    $$ = create_node("assignment-operator", 1, create_node("|=", 0)); }
    ;

expression
    : assignment_expression { printf("expression -> assignment-expression\n"); 
    $$ = create_node("expression", 1, $1); }
    | expression COMMA assignment_expression { printf("expression -> expression , assignment-expression\n"); 
    $$ = create_node("expression", 3, $1, create_node(",", 0), $3); }
    ;

constant_expression
    : conditional_expression { printf("constant-expression -> conditional-expression\n"); 
    $$ = create_node("constant-expression", 1, $1); }
    ;


// 2. Declarations
declaration
    : declaration_specifiers init_declarator_list_opt SEMICOLON { printf("declaration -> declaration-specifiers init-declarator-list-opt ;\n"); 
    $$ = create_node("declaration", 3, $1, $2, create_node(";", 0)); }
    ;

init_declarator_list_opt
    : init_declarator_list { printf("init-declarator-list-opt -> init-declarator-list\n"); 
    $$ = create_node("init-declarator-list", 1, $1); }
    | { printf("init-declarator-list-opt -> epsilon\n"); 
    $$ = create_node("init-declarator-list", 1, create_node("epsilon", 0)); }
    ;

declaration_specifiers
    : storage_class_specifier declaration_specifiers_opt { printf("declaration-specifiers -> storage-class-specifier declaration-specifiers-opt\n"); 
    $$ = create_node("declaration-specifiers", 2, $1, $2); }
    | type_specifier declaration_specifiers_opt { printf("declaration-specifiers -> type-specifier declaration-specifiers-opt\n"); 
    $$ = create_node("declaration-specifiers", 2, $1, $2); }
    | type_qualifier declaration_specifiers_opt { printf("declaration-specifiers -> type-qualifier declaration-specifiers-opt\n"); 
    $$ = create_node("declaration-specifiers", 2, $1, $2); }
    | function_specifier declaration_specifiers_opt { printf("declaration-specifiers -> function-specifier declaration-specifiers-opt\n"); 
    $$ = create_node("declaration-specifiers", 2, $1, $2); }
    ;

declaration_specifiers_opt
    : declaration_specifiers { printf("declaration-specifiers-opt -> declaration-specifiers\n"); 
    $$ = create_node("declaration-specifiers", 1, $1); }
    | { printf("declaration-specifiers-opt -> epsilon\n"); 
    $$ = create_node("declaration-specifiers", 1, create_node("epsilon", 0)); }
    ;

init_declarator_list 
    : init_declarator { printf("init-declarator-list -> init-declarator\n"); 
    $$ = create_node("init-declarator-list", 1, $1); }
    | init_declarator_list COMMA init_declarator { printf("init-declarator-list -> init-declarator-list , init-declarator\n"); 
    $$ = create_node("init-declarator-list", 3, $1, create_node(",", 0), $3); }
    ;

init_declarator
    : declarator { printf("init-declarator -> declarator\n"); 
    $$ = create_node("init-declarator", 1, $1); }
    | declarator ASSIGN initializer { printf("init-declarator -> declarator = initializer\n"); 
    $$ = create_node("init-declarator", 3, $1, create_node("=", 0), $3); }
    ;

storage_class_specifier
    : EXTERN { printf("storage-class-specifier -> extern\n"); 
    $$ = create_node("storage-class-specifier", 1, create_node("extern", 0)); }
    | STATIC { printf("storage-class-specifier -> static\n"); 
    $$ = create_node("storage-class-specifier", 1, create_node("static", 0)); }
    | AUTO { printf("storage-class-specifier -> auto\n"); 
    $$ = create_node("storage-class-specifier", 1, create_node("auto", 0)); }
    | REGISTER { printf("storage-class-specifier -> register\n"); 
    $$ = create_node("storage-class-specifier", 1, create_node("register", 0)); }
    ;

type_specifier
    : VOID { printf("type-specifier -> void\n"); 
    $$ = create_node("type-specifier", 1, create_node("void", 0)); }
    | CHAR { printf("type-specifier -> char\n"); 
    $$ = create_node("type-specifier", 1, create_node("char", 0)); }
    | SHORT { printf("type-specifier -> short\n"); 
    $$ = create_node("type-specifier", 1, create_node("short", 0)); }
    | INT { printf("type-specifier -> int\n"); 
    $$ = create_node("type-specifier", 1, create_node("int", 0)); }
    | LONG { printf("type-specifier -> long\n"); 
    $$ = create_node("type-specifier", 1, create_node("long", 0)); }
    | FLOAT { printf("type-specifier -> float\n"); 
    $$ = create_node("type-specifier", 1, create_node("float", 0)); }
    | DOUBLE { printf("type-specifier -> double\n"); 
    $$ = create_node("type-specifier", 1, create_node("double", 0)); }
    | SIGNED { printf("type-specifier -> signed\n"); 
    $$ = create_node("type-specifier", 1, create_node("signed", 0)); }
    | UNSIGNED { printf("type-specifier -> unsigned\n"); 
    $$ = create_node("type-specifier", 1, create_node("unsigned", 0)); }
    | BOOL { printf("type-specifier -> _Bool\n"); 
    $$ = create_node("type-specifier", 1, create_node("_Bool", 0)); }
    | COMPLEX { printf("type-specifier -> _Complex\n"); 
    $$ = create_node("type-specifier", 1, create_node("_Complex", 0)); }
    | IMAGINARY { printf("type-specifier -> _Imaginary\n"); 
    $$ = create_node("type-specifier", 1, create_node("_Imaginary", 0)); }
    ;

specifier_qualifier_list
    : type_specifier specifier_qualifier_list_opt { printf("specifier-qualifier-list -> type-specifier specifier-qualifier-list-opt\n"); 
    $$ = create_node("specifier-qualifier-list", 2, $1, $2); }
    | type_qualifier specifier_qualifier_list_opt { printf("specifier-qualifier-list -> type-qualifier specifier-qualifier-list-opt\n"); 
    $$ = create_node("specifier-qualifier-list", 2, $1, $2); }
    ;

specifier_qualifier_list_opt
    : specifier_qualifier_list { printf("specifier-qualifier-list-opt -> specifier-qualifier-list\n"); 
    $$ = create_node("specifier-qualifier-list", 1, $1); }
    | { printf("specifier-qualifier-list-opt -> epsilon\n"); 
    $$ = create_node("specifier-qualifier-list", 1, create_node("epsilon", 0)); }
    ;

type_qualifier
    : CONST { printf("type-qualifier -> const\n"); 
    $$ = create_node("type-qualifier", 1, "const"); }
    | RESTRICT { printf("type-qualifier -> restrict\n"); 
    $$ = create_node("type-qualifier", 1, "restrict"); }
    | VOLATILE { printf("type-qualifier -> volatile\n"); 
    $$ = create_node("type-qualifier", 1, "volatile"); }
    ;

function_specifier
    : INLINE { printf("function-specifier -> inline\n"); 
    $$ = create_node("function-specifier", 1, "inline"); }
    ;

declarator
    : pointer_opt direct_declarator { printf("declarator -> pointer-opt direct-declarator\n"); 
    $$ = create_node("declarator", 2, $1, $2); }
    ;

pointer_opt
    : pointer { printf("pointer-opt -> pointer\n"); 
    $$ = create_node("pointer", 1, $1); }
    | { printf("pointer-opt -> epsilon\n"); 
    $$ = create_node("pointer", 1, create_node("epsilon", 0)); }
    ;

direct_declarator
    : IDENTIFIER { printf("direct-declarator -> identifier\n"); 
    $$ = create_node("direct-declarator", 1, create_node("identifier", 0)); }
    | LP_ROUND declarator RP_ROUND { printf("direct-declarator -> ( declarator )\n"); 
    $$ = create_node("direct-declarator", 3, create_node("(", 0), $2, create_node(")", 0)); }
    | direct_declarator LP_SQUARE type_qualifier_list_opt assignment_expression_opt RP_SQUARE { printf("direct-declarator -> direct-declarator [ type-qualifier-list-opt assignment-expression-opt ]\n"); 
    $$ = create_node("direct-declarator", 5, $1, create_node("[", 0), $3, $4, create_node("]", 0)); }
    | direct_declarator LP_SQUARE STATIC type_qualifier_list_opt assignment_expression RP_SQUARE { printf("direct-declarator -> direct-declarator [ static type-qualifier-list-opt assignment-expression ]\n"); 
    $$ = create_node("direct-declarator", 6, $1, create_node("[", 0), create_node("static", 0), $4, $5, create_node("]", 0)); }
    | direct_declarator LP_SQUARE type_qualifier_list STATIC assignment_expression RP_SQUARE { printf("direct-declarator -> direct-declarator [ type-qualifier-list static assignment-expression ]\n"); 
    $$ = create_node("direct-declarator", 6, $1, create_node("[", 0), $3, create_node("static", 0), $5, create_node("]", 0)); }
    | direct_declarator LP_SQUARE type_qualifier_list_opt MULT RP_SQUARE { printf("direct-declarator -> direct-declarator [ type-qualifier-list-opt * ]\n"); 
    $$ = create_node("direct-declarator", 5, $1, create_node("[", 0), $3, create_node("*", 0), create_node("]", 0)); }
    | direct_declarator LP_ROUND parameter_type_list RP_ROUND { printf("direct-declarator -> direct-declarator ( parameter-type-list )\n"); 
    $$ = create_node("direct-declarator", 4, $1, create_node("(", 0), $3, create_node(")", 0)); }
    | direct_declarator LP_ROUND identifier_list_opt RP_ROUND { printf("direct-declarator -> direct-declarator ( identifier-list-opt )\n"); 
    $$ = create_node("direct-declarator", 4, $1, create_node("(", 0), $3, create_node(")", 0)); }
    ;

identifier_list_opt
    : identifier_list { printf("identifier-list-opt -> identifier-list\n"); 
    $$ = create_node("identifier-list", 1, $1); }
    | { printf("identifier-list-opt -> epsilon\n"); 
    $$ = create_node("identifier-list", 1, create_node("epsilon", 0)); }
    ;

assignment_expression_opt
    : assignment_expression { printf("assignment-expression-opt -> assignment-expression\n"); 
    $$ = create_node("assignment-expression", 1, $1); }
    | { printf("assignment-expression-opt -> epsilon\n"); 
    $$ = create_node("assignment-expression", 1, create_node("epsilon", 0)); }
    ;

type_qualifier_list_opt
    : type_qualifier_list { printf("type-qualifier-list-opt -> type-qualifier-list\n"); 
    $$ = create_node("type-qualifier-list", 1, $1); }
    | { printf("type-qualifier-list-opt -> epsilon\n"); 
    $$ = create_node("type-qualifier-list", 1, create_node("epsilon", 0)); }
    ;

pointer 
    : MULT type_qualifier_list_opt { printf("pointer -> * type-qualifier-list-opt\n"); 
    $$ = create_node("pointer", 2, create_node("*", 0), $2); }
    | MULT type_qualifier_list_opt pointer { printf("pointer -> * type-qualifier-list-opt pointer\n"); 
    $$ = create_node("pointer", 3, create_node("*", 0), $2, $3); }
    ;

type_qualifier_list
    : type_qualifier { printf("type-qualifier-list -> type-qualifier\n"); 
    $$ = create_node("type-qualifier-list", 1, $1); }
    | type_qualifier_list type_qualifier { printf("type-qualifier-list -> type-qualifier-list type-qualifier\n"); 
    $$ = create_node("type-qualifier-list", 2, $1, $2); }
    ;

parameter_type_list
    : parameter_list { printf("parameter-type-list -> parameter-list\n"); 
    $$ = create_node("parameter-type-list", 1, $1); }
    | parameter_list COMMA ELLIPSIS { printf("parameter-type-list -> parameter-list , ...\n"); 
    $$ = create_node("parameter-type-list", 3, $1, create_node(",", 0), create_node("...", 0)); }
    ;

parameter_list
    : parameter_declaration { printf("parameter-list -> parameter-declaration\n"); 
    $$ = create_node("parameter-list", 1, $1); }
    | parameter_list COMMA parameter_declaration { printf("parameter-list -> parameter-list , parameter-declaration\n"); 
    $$ = create_node("parameter-list", 3, $1, create_node(",", 0), $3); }
    ;

parameter_declaration
    : declaration_specifiers declarator { printf("parameter-declaration -> declaration-specifiers declarator\n"); 
    $$ = create_node("parameter-declaration", 2, $1, $2); }
    | declaration_specifiers { printf("parameter-declaration -> declaration-specifiers\n"); 
    $$ = create_node("parameter-declaration", 1, $1); }
    ;

identifier_list
    : IDENTIFIER { printf("identifier-list -> identifier\n"); 
    $$ = create_node("identifier-list", 1, create_node("identifier", 0)); }
    | identifier_list COMMA IDENTIFIER { printf("identifier-list -> identifier-list , identifier\n"); 
    $$ = create_node("identifier-list", 3, $1, create_node(",", 0), create_node("identifier", 0)); }
    ;

type_name
    : specifier_qualifier_list { printf("type-name -> specifier-qualifier-list\n"); 
    $$ = create_node("type-name", 1, $1); }
    ;

initializer
    : assignment_expression { printf("initializer -> assignment-expression\n"); 
    $$ = create_node("initializer", 1, $1); }
    | LP_CURLY initializer_list RP_CURLY { printf("initializer -> { initializer-list }\n"); 
    $$ = create_node("initializer", 3, create_node("{", 0), $2, create_node("}", 0)); }
    | LP_CURLY initializer_list COMMA RP_CURLY { printf("initializer -> { initializer-list , }\n"); 
    $$ = create_node("initializer", 4, create_node("{", 0), $2, create_node(",", 0), create_node("}", 0)); }
    ;

initializer_list
    : designation_opt initializer { printf("initializer-list -> designation-opt initializer\n"); 
    $$ = create_node("initializer-list", 2, $1, $2); }
    | initializer_list COMMA designation_opt initializer { printf("initializer-list -> initializer-list , designation-opt initializer\n"); 
    $$ = create_node("initializer-list", 4, $1, create_node(",", 0), $3, $4); }
    ;

designation_opt
    : designation { printf("designation-opt -> designation\n"); 
    $$ = create_node("designation", 1, $1); }
    | { printf("designation-opt -> epsilon\n"); 
    $$ = create_node("designation", 1, create_node("epsilon", 0)); }
    ;

designation
    : designator_list ASSIGN { printf("designation -> designator-list =\n"); 
    $$ = create_node("designation", 2, $1, create_node("=", 0)); }
    ;

designator_list
    : designator { printf("designator-list -> designator\n"); 
    $$ = create_node("designator-list", 1, $1); }
    | designator_list designator { printf("designator-list -> designator-list designator\n"); 
    $$ = create_node("designator-list", 2, $1, $2); }
    ;

designator
    : LP_SQUARE constant_expression RP_SQUARE { printf("designator -> [ constant-expression ]\n"); 
    $$ = create_node("designator", 3, create_node("[", 0), $2, create_node("]", 0)); }
    | DOT IDENTIFIER { printf("designator -> . identifier\n"); 
    $$ = create_node("designator", 2, create_node(".", 0), create_node("identifier", 0)); }
    ;

// 3. Statements
statement 
    : labeled_statement { printf("statement -> labeled-statement\n"); 
    $$ = create_node("statement", 1, $1); }
    | compound_statement { printf("statement -> compound-statement\n"); 
    $$ = create_node("statement", 1, $1); }
    | expression_statement { printf("statement -> expression-statement\n"); 
    $$ = create_node("statement", 1, $1); }
    | selection_statement { printf("statement -> selection-statement\n"); 
    $$ = create_node("statement", 1, $1); }
    | iteration_statement { printf("statement -> iteration-statement\n"); 
    $$ = create_node("statement", 1, $1); }
    | jump_statement { printf("statement -> jump-statement\n");
    $$ = create_node("statement", 1, $1); 
    }
    ;

labeled_statement
    : IDENTIFIER COLON statement { printf("labeled-statement -> identifier : statement\n"); 
    $$ = create_node("labeled-statement", 3, create_node("identifier", 0), create_node(":", 0), $3); }
    | CASE constant_expression COLON statement { printf("labeled-statement -> case constant-expression : statement\n"); 
    $$ = create_node("labeled-statement", 4, create_node("case", 0), $2, create_node(":", 0), $4); }
    | DEFAULT COLON statement { printf("labeled-statement -> default : statement\n"); 
    $$ = create_node("labeled-statement", 3, create_node("default", 0), create_node(":", 0), $3); }
    ;

compound_statement
    : LP_CURLY block_item_list_opt RP_CURLY { printf("compound-statement -> { block-item-list-opt }\n"); 
    $$ = create_node("compound-statement", 3, create_node("{", 0), $2, create_node("}", 0)); }
    ;

block_item_list_opt
    : block_item_list { printf("block-item-list-opt -> block-item-list\n"); 
    $$ = create_node("block-item-list-opt", 1, $1); }
    | { printf("block-item-list-opt -> epsilon\n"); 
    $$ = create_node("block-item-list-opt", 1, create_node("epsilon", 0)); }
    ;

block_item_list
    : block_item { printf("block-item-list -> block-item\n"); 
    $$ = create_node("block-item-list", 1, $1); }
    | block_item_list block_item { printf("block-item-list -> block-item-list block-item\n"); 
    $$ = create_node("block-item-list", 2, $1, $2); }
    ;

block_item
    : declaration { printf("block-item -> declaration\n"); 
    $$ = create_node("block-item", 1, $1); }
    | statement { printf("block-item -> statement\n"); 
    $$ = create_node("block-item", 1, $1); }
    ;

expression_statement
    : expression_opt SEMICOLON { printf("expression-statement -> expression-opt ;\n"); 
    $$ = create_node("expression-statement", 2, $1, create_node(";", 0)); }
    ;

expression_opt
    : expression { printf("expression-opt -> expression\n"); 
    $$ = create_node("expression-opt", 1, $1); }
    | { printf("expression-opt -> epsilon\n"); 
    $$ = create_node("expression-opt", 1, create_node("epsilon", 0)); }
    ;

selection_statement
    : IF LP_ROUND expression RP_ROUND statement { printf("selection-statement -> if ( expression ) statement\n"); 
    $$ = create_node("selection-statement", 5, create_node("if", 0), create_node("(", 0), $3, create_node(")", 0), $5); }
    | IF LP_ROUND expression RP_ROUND statement ELSE statement { printf("selection-statement -> if ( expression ) statement else statement\n"); 
    $$ = create_node("selection-statement", 7, create_node("if", 0), create_node("(", 0), $3, create_node(")", 0), $5, create_node("else", 0), $7); }
    | SWITCH LP_ROUND expression RP_ROUND statement { printf("selection-statement -> switch ( expression ) statement\n"); 
    $$ = create_node("selection-statement", 5, create_node("switch", 0), create_node("(", 0), $3, create_node(")", 0), $5); }
    ;

iteration_statement
    : WHILE LP_ROUND expression RP_ROUND statement { printf("iteration-statement -> while ( expression ) statement\n"); 
    $$ = create_node("iteration-statement", 5, create_node("while", 0), create_node("(", 0), $3, create_node(")", 0), $5); }
    | DO statement WHILE LP_ROUND expression RP_ROUND SEMICOLON { printf("iteration-statement -> do statement while ( expression ) ;\n"); 
    $$ = create_node("iteration-statement", 7, create_node("do", 0), $2, create_node("while", 0), create_node("(", 0), $5, create_node(")", 0), create_node(";", 0)); }
    | FOR LP_ROUND expression_opt SEMICOLON expression_opt SEMICOLON expression_opt RP_ROUND statement { printf("iteration-statement -> for ( expression-opt ; expression-opt ; expression-opt ) statement\n"); 
    $$ = create_node("iteration-statement", 9, create_node("for", 0), create_node("(", 0), $3, create_node(";", 0), $5, create_node(";", 0), $7, create_node(")", 0), $9); }
    | FOR LP_ROUND declaration expression_opt SEMICOLON expression_opt RP_ROUND statement { printf("iteration-statement -> for ( declaration expression-opt ; expression-opt ) statement\n"); 
    $$ = create_node("iteration-statement", 8, create_node("for", 0), create_node("(", 0), $3, $4, create_node(";", 0), $6, create_node(")", 0), $8); }
    ;

jump_statement
    : GOTO IDENTIFIER SEMICOLON { printf("jump-statement -> goto identifier ;\n"); 
    $$ = create_node("jump-statement", 3, create_node("goto", 0), create_node("identifier", 0), create_node(";", 0)); }
    | CONTINUE SEMICOLON { printf("jump-statement -> continue ;\n"); 
    $$ = create_node("jump-statement", 2, create_node("continue", 0), create_node(";", 0)); }
    | BREAK SEMICOLON { printf("jump-statement -> break ;\n"); 
    $$ = create_node("jump-statement", 2, create_node("break", 0), create_node(";", 0)); }
    | RETURN expression_opt SEMICOLON { printf("jump-statement -> return expression-opt ;\n"); 
    $$ = create_node("jump-statement", 3, create_node("return", 0), $2, create_node(";", 0)); }
    ;


// 4. External definitions
translation_unit
    : external_declaration { printf("translation-unit -> external-declaration\n");
    $$ = create_node("translation-unit", 1, $1); 
    parse_tree_root = $$;}
    | translation_unit external_declaration { printf("translation-unit -> translation-unit external-declaration\n");
    $$ = create_node("translation-unit", 2, $1, $2); 
    parse_tree_root = $$;}
    ;

external_declaration
    : function_definition { printf("external-declaration -> function-definition\n"); $$ = create_node("external-declaration", 1, $1); }
    | declaration { printf("external-declaration -> declaration\n"); $$ = create_node("external-declaration", 1, $1); }
    ;

function_definition
    : declaration_specifiers declarator declaration_list_opt compound_statement { printf("function-definition -> declaration-specifiers declarator declaration-list-opt compound-statement\n"); 
    $$ = create_node("function-definition", 4, $1, $2, $3, $4); }
    ;

declaration_list_opt
    : declaration_list { printf("declaration-list-opt -> declaration-list\n"); 
    $$ = create_node("declaration-list-opt", 1, $1); }
    | { printf("declaration-list-opt -> epsilon\n"); 
    $$ = create_node("declaration-list-opt", 1, create_node("epsilon", 0)); }
    ;

declaration_list
    : declaration { printf("declaration-list -> declaration\n"); 
    $$ = create_node("declaration-list", 1, $1); }
    | declaration_list declaration { printf("declaration-list -> declaration-list declaration\n"); 
    $$ = create_node("declaration-list", 2, $1, $2); }
    ;

%%

void yyerror(char* s) {
    printf("Error: %s\n", s);
    printf("Text: %s\n", yytext);
}
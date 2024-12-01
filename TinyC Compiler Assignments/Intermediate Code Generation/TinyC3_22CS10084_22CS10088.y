/*
One shortcoming which we had is that we are not able to translate the code properly for branching statements such as if(x) .
But instead of if(x) if we have used if(x!=0) the code is translating as desired 
*/


%{
    #include "TinyC3_22CS10084_22CS10088_translator.h"
    extern int yylex();
    extern int lineCount;
    void yyerror(string);
    int yywrap() {
        return 1;
    }
%}

// symbol table: stores variables/functions in a scope
// symbol type (symType): represents type info (e.g., int, float)
// symbol: represents variable/function in a table
// quad: represents a 3-address code operation
// expression: holds info about an expression
// array: represents array expression with type and symbol info
// statement: represents a generic statement with backpatching list


// The attributes for the above types have been explained properly in the .h file with their definitions
// The remaining types in the union are primitive types

%union {
    int intval; char *floatval; char *charval; char *strval; char *idval; char *unaryOp; int instrNo; int numparam; expression *expr; statement *stmt; Array *array; symbType *symType; Symbol *symbol;
}

%token AUTO BREAK CASE CHARS CONST CONTINUE DEFAULT DO DOUBLE ELSE EXTERN FLOATS FOR GOTO IF INLINE INTS LONG REGISTER RESTRICT RETURN SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOIDS VOLATILE WHILE BOOL COMPLEX IMAGINARY

%token<symbol> ID
%token<intval> INT_CONST
%token<floatval> FLOAT_CONST
%token<charval> CHAR_CONST
%token<strval> STR_LITERAL

%token ASSIGNMENT ARROW BITWISE_AND BITWISE_AND_ASSGN BITWISE_OR BITWISE_OR_ASSGN BITWISE_XOR BITWISE_XOR_ASSGN COLON COMMA DECREMENT DIV DIV_ASSGN DOT ELLIPSIS EQUALS GREATER_THAN GREATER_THAN_EQUAL HASH INCREMENT LESS_THAN LESS_THAN_EQUAL LP_CURLY LP_ROUND LP_SQUARE MINUS MULT MULT_ASSGN NOT NOT_EQUALS PLUS PLUS_ASSGN QUESTION_MARK RP_CURLY RP_SQUARE RP_ROUND RIGHT_SHIFT RIGHT_SHIFT_ASSGN SEMI_COLON TILDE MODULO MODULO_ASSGN LOGICAL_AND LOGICAL_OR LEFT_SHIFT LEFT_SHIFT_ASSGN MINUS_ASSGN

%token INVALID_TOKEN

%start translation_unit
%right THEN ELSE


//unaryOp is of type char* which is for storing strings
%type<unaryOp> unary_operator


//numparam is of type int
%type<numparam> argument_expression_list argument_expression_list_opt


// expr is type of expression* whose attributes are properly mentioned in the .h file along with the class definition
%type<expr> expression primary_expression multiplicative_expression additive_expression shift_expression relational_expression equality_expression AND_expression exclusive_OR_expression inclusive_OR_expression logical_AND_expression logical_OR_expression conditional_expression assignment_expression expression_statement expression_opt

// array is a pointer of the class array whose attributes are properly mentioned along with its definition in the .h file
%type<array> postfix_expression unary_expression cast_expression

// stmt is a pointer of the class statement whose attributes are properly explained along with its definition in the  .h file
%type <stmt> statement compound_statement selection_statement iteration_statement labeled_statement jump_statement block_item block_item_list block_item_list_opt N


//symType is of the class symbType whose attributes are described properly along with the class definition in the .h file
%type<symType> pointer

//symbol if of the class Symbol whose attributes are described properly along with the class definition in the .h file
%type<symbol> initialiser direct_declarator init_declarator declarator


//instrNO is of the type int 
%type <instrNo> M

%%

primary_expression: 
                    ID  {
                            $$ = new expression();
                            $$->symbol = $1;
                            $$->type = "nonboolean"; 
                        }
                    | INT_CONST  {
                            $$ = new expression();
                            $$->symbol = gentemp("int", toString($1));
                            emit("=", $$->symbol->name, $1);
                        }
                    | FLOAT_CONST  {
                            $$ = new expression();
                            $$->symbol = gentemp("float", $1);
                            emit("=", $$->symbol->name, $1);
                        }
                    | CHAR_CONST  {
                            $$ = new expression();
                            $$->symbol = gentemp("char", $1);
                            emit("=", $$->symbol->name, $1);
                        }
                    | STR_LITERAL  {
                            $$ = new expression();
		                    $$->symbol = gentemp("pointer", $1);
		                    $$->symbol->type->arrtype = new symbType("char");
                            emit("=", $$->symbol->name, $1);
                        }
                    | LP_ROUND expression RP_ROUND {
                            $$ = $2;
                        }
                    ;

postfix_expression:
                    primary_expression {
                            $$ = new Array();
                            $$->symbol = $1->symbol;
                            $$->temp = $$->symbol;
                            $$->subType = $1->symbol->type;
                        }
                    | postfix_expression LP_SQUARE expression RP_SQUARE {
                            $$ = new Array();
                            $$->symbol = $1->symbol;
                            $$->subType = $1->subType->arrtype;
                            $$->temp = gentemp("int");
                            $$->type = "array";

                            if($1->type == "array") {
                                Symbol *sym = gentemp("int");
                                emit("*", sym->name, $3->symbol->name, toString($$->subType->getSize()));
                                emit("+", $$->temp->name, $1->temp->name, sym->name);
                            } else {
                                emit("*", $$->temp->name, $3->symbol->name, toString($$->subType->getSize()));
                            }

                        }
                    | postfix_expression LP_ROUND argument_expression_list_opt RP_ROUND {
                            $$ = new Array();
                            $$->symbol = gentemp($1->symbol->type->type);
                            emit("call", $$->symbol->name, $1->symbol->name, toString($3));
                        }
                    | postfix_expression DOT ID { }
                    | postfix_expression ARROW ID { }
                    | postfix_expression INCREMENT {
                            $$ = new Array();
                            $$->symbol = gentemp($1->symbol->type->type);
                            emit("=", $$->symbol->name, $1->symbol->name);
                            emit("+", $1->symbol->name, $1->symbol->name, toString(1)); 
                        }
                    | postfix_expression DECREMENT {
                            $$ = new Array();
                            $$->symbol = gentemp($1->symbol->type->type);
                            emit("=", $$->symbol->name, $1->symbol->name);
                            emit("-", $1->symbol->name, $1->symbol->name, toString(1));
                        }
                    | LP_ROUND type_name RP_ROUND LP_CURLY initialiser_list RP_CURLY { }
                    | LP_ROUND type_name RP_ROUND LP_CURLY initialiser_list COMMA RP_CURLY { }
                    ;


argument_expression_list_opt:
                                argument_expression_list {
                                        $$ = $1;
                                    }
                                |  {
                                        $$ = 0;
                                    }
                                ;

argument_expression_list:
                            assignment_expression {
                                    emit("param", $1->symbol->name);
                                    $$ = 1;
                                }
                            | argument_expression_list COMMA assignment_expression {
                                    emit("param", $3->symbol->name);
                                    $$ = $1 + 1; 
                                }
                            ;

unary_expression:
                    postfix_expression {
                            $$ = $1;
                        }
                    | INCREMENT unary_expression {
                            $$ = $2;
                            emit("+", $2->symbol->name, $2->symbol->name, toString(1));
                        }
                    | DECREMENT unary_expression {
                            $$ = $2;
                            emit("-", $2->symbol->name, $2->symbol->name, toString(1));
                        }
                    | unary_operator cast_expression {
                            if(strcmp($1, "&") == 0) {
                                $$ = new Array();
                                $$->symbol = gentemp("pointer");
                                $$->symbol->type->arrtype = $2->symbol->type;
                                emit("=&", $$->symbol->name, $2->symbol->name);
                            } else if(strcmp($1, "*") == 0) {
                                $$ = new Array();
                                $$->symbol = $2->symbol;
                                $$->temp = gentemp($2->temp->type->arrtype->type);
                                $$->temp->type->arrtype = $2->temp->type->arrtype->arrtype;
                                $$->type = "pointer";
                                emit("=*", $$->temp->name, $2->temp->name);
                            } else if(strcmp($1, "+") == 0) {
                                $$ = $2;
                            } else { // for -, ~ and !
                                $$ = new Array();
                                $$->symbol = gentemp($2->symbol->type->type);
                                emit($1, $$->symbol->name, $2->symbol->name);
                            }
                        }
                    | SIZEOF unary_expression { }
                    | SIZEOF LP_ROUND type_name RP_ROUND { }
                    ;

unary_operator:
                BITWISE_AND {
                        $$ = strdup("&"); 
                    }
                | MULT {
                        $$ = strdup("*"); 
                    }
                | PLUS {
                        $$ = strdup("+"); 
                    }
                | MINUS {
                        $$ = strdup("=-"); 
                    }
                | TILDE {
                        $$ = strdup("~"); 
                    }
                | NOT {
                        $$ = strdup("!"); 
                    }
                ;

cast_expression:
                unary_expression {
                        $$ = $1;
                    }
                | LP_ROUND type_name RP_ROUND cast_expression {
                        $$ = new Array();
                        $$->symbol = $4->symbol->convert(currtype);
                    }
                ;

/*
This step is critical in the translation process, where we convert an array into an expression.
First, we extract the base type of the array. If it’s an array type, we access the value by indexing,
using the symbol name, the temporary variable for location, and then assign it to a newly created temporary variable.

If it’s a pointer or a standard array, we simply equate it to the symbol.

Once this is done, we perform the required operation (*, /, or %) after appropriate type checking.

For additive and shift expressions, we follow the same process: check types, create a temporary variable, and store the operation result
in the newly created temporary variable.
*/

multiplicative_expression:
                            cast_expression { 
                                    symbType *baseType = $1->symbol->type;
                                    while(baseType->arrtype)
                                        baseType = baseType->arrtype;
                                     
                                    $$ = new expression();
                                    if($1->type == "array") {
                                        $$->symbol = gentemp(baseType->type);
                                        emit("=[]", $$->symbol->name, $1->symbol->name, $1->temp->name);
                                    } else if($1->type == "pointer") {
                                        $$->symbol = $1->temp;
                                    } else {
                                        $$->symbol = $1->symbol;
                                    }
                                }
                            | multiplicative_expression MULT cast_expression { 
                                    symbType *baseType = $3->symbol->type;
                                    while(baseType->arrtype)
                                        baseType = baseType->arrtype;
                                    Symbol *temp;
                                    if($3->type == "array") {
                                        temp = gentemp(baseType->type);
                                        emit("=[]", temp->name, $3->symbol->name, $3->temp->name);
                                    } else if($3->type == "pointer") {
                                        temp = $3->temp;
                                    } else {
                                        temp = $3->symbol;
                                    }
                                     
                                    if(typeCheck($1->symbol, temp)) {
                                        $$ = new expression();
                                        $$->symbol = gentemp($1->symbol->type->type);
                                        emit("*", $$->symbol->name, $1->symbol->name, temp->name);
                                    } else {
                                        yyerror("Type error.");
                                    }
                                }
                            | multiplicative_expression DIV cast_expression { 
                                    symbType *baseType = $3->symbol->type;
                                    while(baseType->arrtype)
                                        baseType = baseType->arrtype;
                                    Symbol *temp;
                                    if($3->type == "array") {
                                        temp = gentemp(baseType->type);
                                        emit("=[]", temp->name, $3->symbol->name, $3->temp->name);
                                    } else if($3->type == "pointer") {
                                        temp = $3->temp;
                                    } else {
                                        temp = $3->symbol;
                                    }
                                    
                                    if(typeCheck($1->symbol, temp)) {
                                        $$ = new expression();
                                        $$->symbol = gentemp($1->symbol->type->type);
                                        emit("/", $$->symbol->name, $1->symbol->name, temp->name);
                                    } else {
                                        yyerror("Type error.");
                                    }
                                }
                            | multiplicative_expression MODULO cast_expression { 
                                    symbType *baseType = $3->symbol->type;
                                    while(baseType->arrtype)
                                        baseType = baseType->arrtype;
                                    Symbol *temp;
                                    if($3->type == "array") {
                                        temp = gentemp(baseType->type);
                                        emit("=[]", temp->name, $3->symbol->name, $3->temp->name);
                                    } else if($3->type == "pointer") {
                                        temp = $3->temp;
                                    } else {
                                        temp = $3->symbol;
                                    }
                                     
                                    if(typeCheck($1->symbol, temp)) {
                                        $$ = new expression();
                                        $$->symbol = gentemp($1->symbol->type->type);
                                        emit("%", $$->symbol->name, $1->symbol->name, temp->name);
                                    } else {
                                        yyerror("Type error.");
                                    }
                                }
                            ;

additive_expression:
                    multiplicative_expression {
                            $$ = $1;
                        }
                    | additive_expression PLUS multiplicative_expression {
                            if(typeCheck($1->symbol, $3->symbol)) {
                                $$ = new expression();
                                $$->symbol = gentemp($1->symbol->type->type);
                                emit("+", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    | additive_expression MINUS multiplicative_expression {
                            if(typeCheck($1->symbol, $3->symbol)) {
                                $$ = new expression();
                                $$->symbol = gentemp($1->symbol->type->type);
                                emit("-", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    ;

shift_expression:
                    additive_expression {
                            $$ = $1;
                        }
                    | shift_expression LEFT_SHIFT additive_expression {
                            if($3->symbol->type->type == "int") {
                                $$ = new expression();
                                $$->symbol = gentemp("int");
                                emit("<<", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    | shift_expression RIGHT_SHIFT additive_expression {
                            if($3->symbol->type->type == "int") {
                                $$ = new expression();
                                $$->symbol = gentemp("int");
                                emit(">>", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    ;

/*
For the next set of translations, a boolean expression is generated, 
and the appropriate logical or relational operation is applied.
The trueList and falseList are also created here, which will later be used 
for backpatching with their respective target labels.
*/

relational_expression:
                        shift_expression {
                                $$ = $1;
                            }
                        | relational_expression LESS_THAN shift_expression {
                                if(typeCheck($1->symbol, $3->symbol)) {
                                    $$ = new expression();
                                    $$->type = "boolean";
                                    $$->trueList = makeList(nextInstruction());
			                        $$->falseList = makeList(nextInstruction() + 1);
                                    emit("<", "", $1->symbol->name, $3->symbol->name);
                                    emit("goto", "");
                                } else {
                                    yyerror("Type error.");
                                }
                            }
                        | relational_expression GREATER_THAN shift_expression {
                                if(typeCheck($1->symbol, $3->symbol)) {
                                    $$ = new expression();
                                    $$->type = "boolean";
                                    $$->trueList = makeList(nextInstruction());
			                        $$->falseList = makeList(nextInstruction() + 1);
                                    emit(">", "", $1->symbol->name, $3->symbol->name);
                                    emit("goto", "");
                                } else {
                                    yyerror("Type error.");
                                }
                            }
                        | relational_expression LESS_THAN_EQUAL shift_expression {
                                if(typeCheck($1->symbol, $3->symbol)) {
                                    $$ = new expression();
                                    $$->type = "boolean";
                                    $$->trueList = makeList(nextInstruction());
			                        $$->falseList = makeList(nextInstruction() + 1);
                                    emit("<=", "", $1->symbol->name, $3->symbol->name);
                                    emit("goto", "");
                                } else {
                                    yyerror("Type error.");
                                }
                            }
                        | relational_expression GREATER_THAN_EQUAL shift_expression {
                                if(typeCheck($1->symbol, $3->symbol)) {
                                    $$ = new expression();
                                    $$->type = "boolean";
                                    $$->trueList = makeList(nextInstruction());
			                        $$->falseList = makeList(nextInstruction() + 1);
                                    emit(">=", "", $1->symbol->name, $3->symbol->name);
                                    emit("goto", "");
                                } else {
                                    yyerror("Type error.");
                                }
                            }
                        ;

equality_expression:
                    relational_expression {
                            $$ = $1;
                        }
                    | equality_expression EQUALS relational_expression {
                            if(typeCheck($1->symbol, $3->symbol)) {
                                $1->toInt();
                                $3->toInt();
                                $$ = new expression();
                                $$->type = "boolean";
                                $$->trueList = makeList(nextInstruction());
			                    $$->falseList = makeList(nextInstruction() + 1);
                                emit("==", "", $1->symbol->name, $3->symbol->name);
                                emit("goto", "");
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    | equality_expression NOT_EQUALS relational_expression {
                            if(typeCheck($1->symbol, $3->symbol)) {
                                $1->toInt();
                                $3->toInt();
                                $$ = new expression();
                                $$->type = "boolean";
                                $$->trueList = makeList(nextInstruction());
			                    $$->falseList = makeList(nextInstruction() + 1);
                                emit("!=", "", $1->symbol->name, $3->symbol->name);
                                emit("goto", "");
                            } else {
                                yyerror("Type error.");
                            }
                        }
                    ;

/*
For the next set of translations, a non-boolean expression is generated, 
with type conversion applied to ensure the expression is of INT type.
At this stage, the trueList and falseList are no longer valid.
A new temporary variable is created, the appropriate operations are applied, 
and the result is stored in the newly generated temporary.
*/

AND_expression:
                equality_expression {
                        $$ = $1;
                    }
                | AND_expression BITWISE_AND equality_expression {
                        $1->toInt();
                        $3->toInt();
                        $$ = new expression();
                        $$->type = "nonboolean";
                        $$->symbol = gentemp("int");
                        emit("&", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                    }
                ;

exclusive_OR_expression:
                        AND_expression {
                                $$ = $1;
                            }
                        | exclusive_OR_expression BITWISE_XOR AND_expression {
                                $1->toInt();
                                $3->toInt();
                                $$ = new expression();
                                $$->type = "nonboolean";
                                $$->symbol = gentemp("int");
                                emit("^", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            }
                        ;

inclusive_OR_expression:
                        exclusive_OR_expression {
                                $$ = $1;
                            }
                        | inclusive_OR_expression BITWISE_OR exclusive_OR_expression {
                                $1->toInt();
                                $3->toInt();
                                $$ = new expression();
                                $$->type = "nonboolean";
                                $$->symbol = gentemp("int");
                                emit("|", $$->symbol->name, $1->symbol->name, $3->symbol->name);
                            }
                        ;

/*
Marker Rule:
M -> stores the address of the next instruction (quad location) generated at M, 
which will later be used for backpatching.

Fall-Through Marker Rule:
N -> nextlist, a list of indices representing dangling exits at N, 
to be backpatched at a later stage.
*/

M:   {
            $$ = nextInstruction();
        }   
    ;

N:  {
            $$ = new statement();
            $$->nextList = makeList(nextInstruction());
            emit("goto", "");
        }
	;

/*
The backpatching and merging done in the next three translations follow the process discussed in class.
Each expression is converted to BOOL, and the necessary backpatching is applied.

For logical AND:
backpatch(B1.truelist, M.instr);
B.truelist = B2.truelist;
B.falselist = merge(B1.falselist, B2.falselist);

For logical OR:
backpatch(B1.falselist, M.instr);
B.truelist = merge(B1.truelist, B2.truelist);
B.falselist = B2.falselist;

For the ternary operator (? :):
E.loc = gentemp();
E.type = E2.type;  // Assume E2.type == E3.type
emit(E.loc = E3.loc);  // Control reaches here by fall-through
l = makelist(nextinstr);
emit(goto ...);
backpatch(N2.nextlist, nextinstr);
emit(E.loc = E2.loc);
l = merge(l, makelist(nextinstr));
emit(goto ...);
backpatch(N1.nextlist, nextinstr);
convInt2Bool(E1);
backpatch(E1.truelist, M1.instr);
backpatch(E1.falselist, M2.instr);
backpatch(l, nextinstr);
*/

logical_AND_expression:
                        inclusive_OR_expression { 
                                $$ = $1;
                            }
                        | logical_AND_expression LOGICAL_AND M inclusive_OR_expression {
                                $1->toBool();
                                $4->toBool();
                                $$ = new expression();
                                $$->type = "boolean";
                                backpatch($1->trueList, $3);
                                $$->trueList = $4->trueList;
                                $$->falseList = merge($1->falseList, $4->falseList);
                            }
                        ;

logical_OR_expression:
                        logical_AND_expression {   
                                $$ = $1;
                            }
                        | logical_OR_expression LOGICAL_OR M logical_AND_expression {
                                $1->toBool();
                                $4->toBool();
                                $$ = new expression();
                                $$->type = "boolean";
                                backpatch($1->falseList, $3);
                                $$->trueList = merge($1->trueList, $4->trueList);
                                $$->falseList = $4->falseList;
                            }
                        ;

conditional_expression:
                        logical_OR_expression { 
                                $$ = $1;
                            }
                        | logical_OR_expression N QUESTION_MARK M expression N COLON M conditional_expression {
                                $$->symbol = gentemp($5->symbol->type->type);
                                emit("=", $$->symbol->name, $9->symbol->name);
                                list<int> l = makeList(nextInstruction());
                                emit("goto", "");
                                backpatch($6->nextList, nextInstruction());
                                emit("=", $$->symbol->name, $5->symbol->name);
                                l = merge(l, makeList(nextInstruction()));
                                emit("goto", "");
                                backpatch($2->nextList, nextInstruction());
                                $1->toBool();
                                backpatch($1->trueList, $4);
                                backpatch($1->falseList, $8);
                                backpatch(l, nextInstruction());
                            }
                        ;

assignment_expression:
                        conditional_expression { 
                                $$ = $1;
                            }
                        | unary_expression assignment_operator assignment_expression {
                                if($1->type == "array") {
                                    $3->symbol = $3->symbol->convert($1->subType->type);
                                    emit("[]=", $1->symbol->name, $1->temp->name, $3->symbol->name);
                                } else if($1->type == "pointer") {
                                    $3->symbol = $3->symbol->convert($1->temp->type->type);
                                    emit("*=", $1->temp->name, $3->symbol->name);
                                } else {
                                    $3->symbol = $3->symbol->convert($1->symbol->type->type);
			                        emit("=", $1->symbol->name, $3->symbol->name);
                                }
                                $$ = $3;
                            }
                        ;

assignment_operator:
                    ASSIGNMENT { }
                    | MULT_ASSGN { }
                    | DIV_ASSGN { }
                    | MODULO_ASSGN { }
                    | PLUS_ASSGN { }
                    | MINUS_ASSGN { }
                    | LEFT_SHIFT_ASSGN { }
                    | RIGHT_SHIFT_ASSGN { }
                    | BITWISE_AND_ASSGN { }
                    | BITWISE_XOR_ASSGN { }
                    | BITWISE_OR_ASSGN { }
                    ;

expression:
            assignment_expression { 
                    $$ = $1;
                }
            | expression COMMA assignment_expression { }
            ;

constant_expression:
                    conditional_expression { }
                    ;

// 2. Declarations

declaration:
            declaration_specifiers init_declarator_list_opt SEMI_COLON { }
            ;

init_declarator_list_opt:
                            init_declarator_list { }
                            | { }
                            ;

declaration_specifiers:
                        storage_class_specifier declaration_specifiers_opt { }
                        | type_specifier declaration_specifiers_opt { }
                        | type_qualifier declaration_specifiers_opt { }
                        | function_specifier declaration_specifiers_opt { }
                        ;

declaration_specifiers_opt:
                            declaration_specifiers { }
                            | { }
                            ;

init_declarator_list:
                        init_declarator { }
                        | init_declarator_list COMMA init_declarator { }
                        ;

init_declarator:
                declarator {
                        $$ = $1;
                    }
                | declarator ASSIGNMENT initialiser { 
                        if($3->initialval != "") 
                            $1->initialval = $3->initialval;
		                emit("=", $1->name, $3->name);
                    }
                ;

storage_class_specifier:
                        EXTERN { }
                        | STATIC { }
                        | AUTO { }
                        | REGISTER { }
                        ;

type_specifier:
                VOIDS {
                        currtype = "void";
                    }
                | CHARS {
                        currtype = "char";
                    }
                | SHORT { }
                | INTS {
                        currtype = "int";
                    }
                | LONG { }
                | FLOATS {
                        currtype = "float";
                    }
                | DOUBLE { }
                | SIGNED { }
                | UNSIGNED { }
                | BOOL { }
                | COMPLEX { }
                | IMAGINARY { }
                ;

specifier_qualifier_list:
                            type_specifier specifier_qualifier_list_opt { }
                            | type_qualifier specifier_qualifier_list_opt { }
                            ;

specifier_qualifier_list_opt:
                                specifier_qualifier_list { }
                                |  { }
                                ;

type_qualifier:
                CONST { }
                | RESTRICT { }
                | VOLATILE { }
                ;

function_specifier:
                    INLINE { }
                    ;

declarator:
            pointer direct_declarator {
                    symbType *it = $1;
                    while(it->arrtype != NULL) 
                        it = it->arrtype;
                    it->arrtype = $2->type;
                    $$ = $2->update($1);
                }
            | direct_declarator { }
            ;

change_scope: {
                        if(currsymbol->nested == NULL) {
                            changeTable(new symbTable(""));
                        }
                        else {
                            changeTable(currsymbol->nested);
                            emit("label", currtable->name);
                        }
                    }
	            ;

direct_declarator:
                    ID  { 
                            $$ = $1->update(new symbType(currtype));
                            currsymbol = $$;
                        }
                    | LP_ROUND declarator RP_ROUND {
                            $$ = $2;
                        }
                    | direct_declarator LP_SQUARE type_qualifier_list assignment_expression RP_SQUARE { }
                    | direct_declarator LP_SQUARE type_qualifier_list RP_SQUARE { }
                    | direct_declarator LP_SQUARE assignment_expression RP_SQUARE {
                            symbType *it1 = $1->type, *it2 = NULL;
                            while(it1->type == "array") {
                                it2 = it1;
                                it1 = it1->arrtype;
                            }
                            if(it2 != NULL) {
                                it2->arrtype =  new symbType("array", it1, atoi($3->symbol->initialval.c_str()));	
                                $$ = $1->update($1->type);
                            }
                            else {
                                $$ = $1->update(new symbType("array", $1->type, atoi($3->symbol->initialval.c_str())));
                            }
                        }
                    | direct_declarator LP_SQUARE RP_SQUARE {
                            symbType *it1 = $1->type, *it2 = NULL;
                            while(it1->type == "array") {
                                it2 = it1;
                                it1 = it1->arrtype;
                            }
                            if(it2 != NULL) {
                                it2->arrtype =  new symbType("array", it1, 0);	
                                $$ = $1->update($1->type);
                            }
                            else {
                                $$ = $1->update(new symbType("array", $1->type, 0));
                            }
                        }
                    | direct_declarator LP_SQUARE STATIC type_qualifier_list assignment_expression RP_SQUARE { }
                    | direct_declarator LP_SQUARE STATIC assignment_expression RP_SQUARE { }
                    | direct_declarator LP_SQUARE type_qualifier_list STATIC assignment_expression RP_SQUARE { }
                    | direct_declarator LP_SQUARE type_qualifier_list MULT RP_SQUARE { }
                    | direct_declarator LP_SQUARE MULT RP_SQUARE { }
                    | direct_declarator LP_ROUND change_scope parameter_type_list RP_ROUND {
                            currtable->name = $1->name;
                            if($1->type->type != "void") {
                                currtable->lookup("return")->update($1->type);
                            }
                            // move back to the global table and set the nested table for the function
                            $1->nested = currtable;
                            currtable->parent = globtable;
                            changeTable(globtable);
                            currsymbol = $$;
                        }
                    | direct_declarator LP_ROUND identifier_list RP_ROUND { }
                    | direct_declarator LP_ROUND change_scope RP_ROUND {
                            currtable->name = $1->name;
                            if($1->type->type != "void") {
                                currtable->lookup("return")->update($1->type);
                            }
                            // move back to the global table and set the nested table for the function
                            $1->nested = currtable;
                            currtable->parent = globtable;
                            changeTable(globtable);
                            currsymbol = $$;
                        }
                    ;

type_qualifier_list_opt:
                        type_qualifier_list { }
                        | { }
                        ;

pointer:
        MULT type_qualifier_list_opt { 
                $$ = new symbType("pointer");
            }
        | MULT type_qualifier_list_opt pointer { 
                $$ = new symbType("pointer", $3);
            }
        ;

type_qualifier_list:
                    type_qualifier { }
                    | type_qualifier_list type_qualifier { }
                    ;

parameter_type_list:
                    parameter_list { }
                    | parameter_list COMMA ELLIPSIS { }
                    ;

parameter_list:
                parameter_declaration { }
                | parameter_list COMMA parameter_declaration { }
                ;

parameter_declaration:
                        declaration_specifiers declarator { }
                        | declaration_specifiers { }
                        ;

identifier_list:
                ID  { }
                | identifier_list COMMA ID { }
                ;

type_name:
            specifier_qualifier_list { }
            ;

initialiser:
            assignment_expression { 
                    $$ = $1->symbol;
                }
            | LP_CURLY initialiser_list RP_CURLY { }  
            | LP_CURLY initialiser_list COMMA RP_CURLY { }
            ;

initialiser_list:
                    designation_opt initialiser { }
                    | initialiser_list COMMA designation_opt initialiser { }
                    ;

designation_opt:
                designation { }
                | { }
                ;

designation:
            designator_list ASSIGNMENT { }
            ;

designator_list:
                designator { }
                | designator_list designator { }
                ;

designator:
            LP_SQUARE constant_expression RP_SQUARE { }
            | DOT ID { }   
            ;

// 3. Statements

statement:
            labeled_statement { }
            | compound_statement { 
                    $$ = $1; 
                }
            | expression_statement { 
                    $$ = new statement();
                    $$->nextList = $1->nextList;
                }
            | selection_statement { 
                    $$ = $1;
                }
            | iteration_statement { 
                    $$ = $1;
                }
            | jump_statement { 
                    $$ = $1;
                }
            ;

labeled_statement:
                    ID COLON statement { }
                    | CASE constant_expression COLON statement { }    
                    | DEFAULT COLON statement { }
                    ;

/*
change_block Used to update the symbol table when a new block is encountered,
enabling the creation of a hierarchy of symbol tables.
*/


change_block:  {
                        string name = currtable->name + "_" + toString(tblcnt);
                        tblcnt++;
                        Symbol *s = currtable->lookup(name);
                        s->nested = new symbTable(name, currtable);
                        s->type = new symbType("block");
                        currsymbol = s;
                    } 
                ;

compound_statement:
                    LP_CURLY change_block change_scope block_item_list_opt RP_CURLY { 
                            $$ = $4;
                            changeTable(currtable->parent);
                        }
                    ;

block_item_list_opt:
                    block_item_list { 
                            $$ = $1;
                        }
                    | { 
                            $$ = new statement();
                        }
                    ;

block_item_list:
                block_item {
                        $$ = $1;
                    }
                | block_item_list M block_item { 
                        $$ = $3;
                        backpatch($1->nextList,$2);
                    }
                ;

block_item:
            declaration { 
                    $$ = new statement();
                }
            | statement { 
                    $$ = $1;
                }
            ;

expression_statement:
                        expression_opt SEMI_COLON { 
                                $$ = $1;
                            }
                        ;

expression_opt:
                expression { 
                        $$ = $1;
                    }
                | { 
                        $$ = new expression();
                    }
                ;

/*
IF-ELSE

-> The %prec THEN directive is used to resolve conflicts during translation.

Markers M and N have been added as discussed in class.

For IF without ELSE:
S -> if (B) M S1 N
backpatch(B.truelist, M.instr);
S.nextlist = merge(B.falselist, merge(S1.nextlist, N.nextlist));

For IF with ELSE:
S -> if (B) M1 S1 N else M2 S2
backpatch(B.truelist, M1.instr);
backpatch(B.falselist, M2.instr);
S.nextlist = merge(merge(S1.nextlist, N.nextlist), S2.nextlist);
*/

selection_statement:
                    IF LP_ROUND expression RP_ROUND M statement N %prec THEN { 
                            $$ = new statement();
                            $3->toBool();
                            backpatch($3->trueList, $5);
                            $$->nextList = merge($3->falseList, merge($6->nextList, $7->nextList));
                        }
                    | IF LP_ROUND expression RP_ROUND M statement N ELSE M statement { 
                            $$ = new statement();
                            $3->toBool();
                            backpatch($3->trueList, $5);
                            backpatch($3->falseList, $9);
                            $$->nextList = merge($10->nextList, merge($6->nextList, $7->nextList));
                        }
                    | SWITCH LP_ROUND expression RP_ROUND statement { }
                    ;

/*
LOOPS

For WHILE loop:
while M1 (B) M2 S1
backpatch(S1.nextlist, M1.instr);
backpatch(B.truelist, M2.instr);
S.nextlist = B.falselist;
emit("goto", M1.instr);

For DO-WHILE loop:
do M1 S1 M2 while (B);
backpatch(B.truelist, M1.instr);
backpatch(S1.nextlist, M2.instr);
S.nextlist = B.falselist;

For FOR loop:
for (E1; M1 B; M2 E2 N) M3 S1
backpatch(B.truelist, M3.instr);
backpatch(N.nextlist, M1.instr);
backpatch(S1.nextlist, M2.instr);
emit("goto", M2.instr);
S.nextlist = B.falselist;
*/

iteration_statement:
                    WHILE M LP_ROUND expression RP_ROUND M statement { 
                            $$ = new statement();
                            $4->toBool();
                            backpatch($7->nextList, $2);
                            backpatch($4->trueList, $6);
                            $$->nextList = $4->falseList;
                            emit("goto", toString($2));
                        }
                    | DO M statement M WHILE LP_ROUND expression RP_ROUND SEMI_COLON { 
                            $$ = new statement();
                            $7->toBool();
                            backpatch($7->trueList, $2);
                            backpatch($3->nextList, $4);
                            $$->nextList = $7->falseList;
                        }
                    | FOR LP_ROUND expression_opt SEMI_COLON M expression_opt SEMI_COLON M expression_opt N RP_ROUND M statement { 
                            $$ = new statement();
                            $6->toBool();
                            backpatch($6->trueList, $12);
                            backpatch($10->nextList, $5);
                            backpatch($13->nextList, $8);
                            emit("goto", toString($8));
                            $$->nextList = $6->falseList;
                        }
                    | FOR LP_ROUND declaration expression_opt SEMI_COLON expression_opt RP_ROUND statement { }
                    ;

jump_statement:
                GOTO ID SEMI_COLON { }    
                | CONTINUE SEMI_COLON { }
                | BREAK SEMI_COLON { }
                | RETURN expression_opt SEMI_COLON {
                        $$ = new statement();
                        if($2->symbol != NULL) {
                            emit("return", $2->symbol->name);
                        } else {
                            emit("return", "");
                        }
                    }
                ;

// 4. External definitions

translation_unit:
                    external_declaration { }
                    | translation_unit external_declaration { }
                    ;

external_declaration:
                        function_definition { }
                        | declaration { }
                        ;

function_definition:
                    declaration_specifiers declarator declaration_list_opt change_scope LP_CURLY block_item_list_opt RP_CURLY {
                            tblcnt = 0;
                            $2->isFunc = true;
                            changeTable(globtable);
                        }
                    ;

declaration_list_opt:
                        declaration_list { }
                        | { }
                        ;

declaration_list:
                    declaration { }
                    | declaration_list declaration { }
                    ;

%%

void yyerror(string s) {
    printf("ERROR [Line %d] : %s\n", lineCount, s.c_str());
}

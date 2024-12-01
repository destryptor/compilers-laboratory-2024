#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <string.h>
#include <iostream>
#include <string>
#include <vector>
#include <list>
#include <map>
#include <iomanip>
#include <functional>

using namespace std;

// constants defining sizes for data types
#define SIZE_OF_VOID 0
#define SIZE_OF_CHAR 1
#define SIZE_OF_INT 4
#define SIZE_OF_FLOAT 8
#define SIZE_OF_PTR 4
#define SIZE_OF_FUNC 0

class symbTable; // forward declaration for symbol table class
class symbType;  // forward declaration for symbol type class
class Symbol;    // forward declaration for symbol class
class quad;      // forward declaration for quad (3-address code) class
class label;     // forward declaration for label handling

extern int yyparse(); // parse function for syntax analysis

// symbol table: stores variables/functions in a scope
class symbTable
{
public:
    string name;                                    // table name
    map<string, Symbol> symbol;                     // symbol name to symbol mapping
    symbTable *parent;                              // parent table in case of nested scopes
    symbTable(string = "NULL", symbTable * = NULL); // default constructor
    Symbol *lookup(string);                         // looks up symbol in table
    void print();                                   // prints symbol table
    void update();                                  // updates offsets, etc.
};

// symbol type: represents type info (e.g., int, float)
class symbType
{
public:
    string type;                                       // type name (e.g., "int")
    int width;                                         // width in bytes
    symbType *arrtype;                                 // for array types
    symbType(string = "", symbType * = NULL, int = 1); // default constructor
    int getSize();                                     // returns size of type
    string toString();                                 // returns string representation
};

// symbol: represents variable/function in a table
class Symbol
{
public:
    string name;                                 // symbol name
    int size, offset;                            // size and memory offset
    string initialval;                           // initial value, if any
    symbType *type;                              // type of symbol
    symbTable *nested;                           // nested table for functions
    bool isFunc;                                 // true if symbol is a function
    Symbol(string, string = "int", string = ""); // default constructor
    Symbol *update(symbType *);                  // updates type of symbol
    Symbol *convert(string);                     // converts symbol type
};

// quad: represents a 3-address code operation
class quad
{
public:
    string op;     // operation (e.g., "+", "=", "if")
    string arg1;   // first argument
    string arg2;   // second argument
    string result; // operation result

    quad(string, string, string = "=", string = ""); // constructor with strings
    quad(string, int, string = "=", string = "");    // constructor with int
    void print();                                    // prints quad instruction

private:
    void binary_print();                 // prints binary ops
    void relation_print();               // prints relational ops
    void shift_print();                  // prints shift ops
    void shift_print_(const string &tp); // helper for shift print
};

// expression: holds info about an expression
class expression
{
public:
    Symbol *symbol;                          // symbol for expression
    string type;                             // type of expression
    list<int> trueList, falseList, nextList; // lists for backpatching

    void toInt();  // converts to int type
    void toBool(); // converts to bool type
};

// array: represents array expression with type and symbol info
class Array
{
public:
    Symbol *temp;      // temp symbol for indexing
    string type;       // array type
    Symbol *symbol;    // array symbol
    symbType *subType; // element type
};

// statement: represents a generic statement with backpatching list
class statement
{
public:
    list<int> nextList; // list for backpatching
};

// utility functions for code generation and backpatching
Symbol *gentemp(string, string = ""); // generates temp symbol
void changeTable(symbTable *);        // changes current table
bool typeCheck(Symbol *&, Symbol *&); // checks type compatibility

void emit(string, string, string = "", string = ""); // emits quad instruction
void emit(string, string, int, string = "");         // emits quad with int

void backpatch(list<int>, int); // backpatches instructions

list<int> makeList(int);               // creates new backpatch list
list<int> merge(list<int>, list<int>); // merges two backpatch lists

int nextInstruction(); // gets index of next instruction

// utility functions for type conversion to string
string toString(int);   // int to string
string toString(float); // float to string
string toString(char);  // char to string

// global extern variables
extern Symbol *currsymbol;   // current symbol
extern string currtype;      // current type
extern symbTable *currtable; // current symbol table
extern symbTable *globtable; // global symbol table

extern vector<quad *> quadarr; // array of quad instructions

extern int tblcnt;  // table counter
extern int tempcnt; // temp symbol counter

#endif

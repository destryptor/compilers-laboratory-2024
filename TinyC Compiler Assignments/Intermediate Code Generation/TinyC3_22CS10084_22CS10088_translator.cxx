#include "TinyC3_22CS10084_22CS10088_translator.h"
#include "lex.yy.c"
#include "y.tab.c"

/*
LIST OF FUNCTIONS AND THEIR PURPOSE

Symbol::Symbol(string name, string type, string init) - constructor to initialize a Symbol with given name, type, and initial value.

Symbol *Symbol::update(symbType *type) - updates the symbol's type and size.

Symbol *Symbol::convert(string type_) - converts the current symbol's type to the specified type, if applicable, emitting the necessary conversion code.

symbTable::symbTable(string name, symbTable *parent) - constructor to initialize a symbol table with a name and an optional parent.

Symbol *symbTable::lookup(string name) - searches for a symbol in the current table and its parent tables. Adds a new symbol if not found in the current table.

void symbTable::update() - updates the offsets for each symbol in the table and recursively updates nested tables.

void symbTable::print() - prints the contents of the symbol table, including name, type, initial value, offset, size, and any child table name.

symbType::symbType(string type, symbType *arrtype, int width) - constructor for symbol types, supporting arrays and other types.

int symbType::getSize() - returns the size of the type based on its kind (e.g., int, float, char, pointer).

string symbType::toString() - converts the symbol type to a string representation (e.g., "int", "float", "pointer").

quad::quad(string result, string arg1, string op, string arg2) - constructor for a quad with a string argument.

quad::quad(string result, int arg1, string op, string arg2) - constructor for a quad with an integer argument.

void quad::print() - prints the quad based on the operation type (e.g., assignment, goto, arithmetic, relation, etc.).

void quad::binary_print() - helper function to print binary operations.

void quad::relation_print() - helper function to print relational operations with conditional jumps.

void quad::shift_print() - helper function to print operations that involve pointer shifting.

void quad::shift_print_(const string& tp) - helper function to print unary operations.

Symbol *gentemp(string type, string s) - creates a temporary symbol with the specified type and initial value.

void changeTable(symbTable *table) - sets the current symbol table to a new table.

bool typeCheck(Symbol *&a, Symbol *&b) - checks if two symbols have compatible types and converts them if needed.

void emit(string op, string result, string arg1, string arg2) - creates a new quad with string arguments and adds it to the quad array.

void emit(string op, string result, int arg1, string arg2) - overloaded emit function to support integer arguments in quads.

void backpatch(list<int> list_, int addr) - backpatches a list of addresses to a specified instruction address.

list<int> makeList(int base) - creates a list with a single element, used for backpatching.

list<int> merge(list<int> first, list<int> second) - merges two lists of instruction addresses for backpatching.

int nextInstruction() - returns the index of the next instruction to be generated.

string toString(int i) - converts an integer to a string.

string toString(float f) - converts a float to a string.

string toString(char c) - converts a character to a string.

void expression::toInt() - converts an expression of boolean type to an integer, generating the necessary code.

void expression::toBool() - converts an expression of non-boolean type to a boolean, generating the necessary code.
*/


vector<quad *> quadarr;  
symbTable *currtable, *globtable; 
Symbol *currsymbol;  
string currtype; 
int tblcnt, tempcnt; 

Symbol::Symbol(string name, string type, string init) : name(name), type(new symbType(type)), offset(0), nested(NULL), initialval(init), isFunc(false)
{
    size = this->type->getSize();
}


Symbol *Symbol::update(symbType *type)
{
    this->type = type;
    size = this->type->getSize();
    return this;
}

Symbol *Symbol::convert(string type_) {
    auto convertAndEmit = [this](const std::string& conversionFunc, Symbol* fin_) {
        emit("=", fin_->name, conversionFunc + "(" + this->name + ")");
        return fin_;
    };

    Symbol *fin_ = nullptr;


    if(this->type->type=="float")
    {
        if (type_ == "int") {
                fin_ = gentemp(type_);
                return convertAndEmit("Float_TO_Char", fin_);
            }
    }
    else if(this->type->type=="float")
    {
         fin_ = gentemp(type_);
            if (type_ == "float") {
                return convertAndEmit("INT_TO_Float", fin_);
            } else if (type_ == "char") {
                return convertAndEmit("INT_TO_Char", fin_);
            }
    }
    else if(this->type->type=="char")
    {
        fin_ = gentemp(type_);
        if (type_ == "int") {
            return convertAndEmit("Char_TO_Int", fin_);
        } else if (type_ == "float") {
            return convertAndEmit("Char_TO_Float", fin_);
        }
    }


    return this;
}

symbTable::symbTable(string name, symbTable *parent) : name(name), parent(parent) {}

Symbol *symbTable::lookup(string name) {
    auto it = this->symbol.find(name);
    if (it != this->symbol.end()) {
        return &(it->second);
    }

    if (this->parent != nullptr) {
        Symbol *ret_ptr = this->parent->lookup(name);
        if (ret_ptr) {
            return ret_ptr;
        }
    }

    if (this == currtable) {
        this->symbol.emplace(name, Symbol(name));
        return &(this->symbol.find(name)->second);
    }

    return nullptr; 
}


void symbTable::update() {
    vector<symbTable *> visited; 
    int offset = 0;

    for (auto &map_entry : this->symbol) {
        map_entry.second.offset = offset;
        offset += map_entry.second.size;

        if (map_entry.second.nested) {
            visited.push_back(map_entry.second.nested);
        }
    }

    for (auto *table : visited) {
        table->update();
    }
}

void symbTable::print() {
    cout << string(140, '=') << endl;
    cout << "Table Name: " << this->name 
         << "\t\t Parent Name: " << (this->parent ? this->parent->name : "None") << endl;
    cout << string(140, '=') << endl;

    cout << setw(20) << "Name" 
         << setw(40) << "Type" 
         << setw(20) << "Initial Value" 
         << setw(20) << "Offset" 
         << setw(20) << "Size" 
         << setw(20) << "Child" << "\n" << endl;

    vector<symbTable *> tovisit;

    for (const auto &map_entry : this->symbol) {
        cout << setw(20) << map_entry.first;
        fflush(stdout);
        cout << setw(40) << (map_entry.second.isFunc ? "function" : map_entry.second.type->toString());
        cout << setw(20) << map_entry.second.initialval 
             << setw(20) << map_entry.second.offset 
             << setw(20) << map_entry.second.size;
        cout << setw(20) << (map_entry.second.nested ? map_entry.second.nested->name : "NULL") << endl;

        if (map_entry.second.nested) {
            tovisit.push_back(map_entry.second.nested);
        }
    }

    cout << string(140, '-') << endl;
    cout << "\n" << endl;

    for (const auto &table : tovisit) {
        table->print();
    }
}

symbType::symbType(string type, symbType *arrtype, int width) : type(type), width(width), arrtype(arrtype) {}

int symbType::getSize()
{
    if (type == "char") {
        return 1;
    } else if (type == "int") {
        return 4;
    } else if (type == "float") {
        return 8;
    } else if (type == "pointer") {
        return 4;
    } else if (type == "array") {
        return width * (arrtype->getSize());
    } else
        return 0;
}

string symbType::toString() {
    if(this->type=="void")
    {
        return "void";
    }
    else if(this->type=="char")
    {
        return "char";
    }
    else if (this->type=="int")
    {
        return "int";
    }
    else if(this->type=="float")
    {
        return "float";
    }
    else if(this->type=="pointer")
    {
        return "pointer";
    }
    else if(this->type=="function")
    {
        return "function";
    }
    else if (this->type=="array")
    {
        return "array";
    }
    else if(this->type=="block")
    {
        return "block";
    }
    return "";
}

quad::quad(string result, string arg1, string op, string arg2) : result(result), op(op), arg1(arg1), arg2(arg2) {}
quad::quad(string result, int arg1, string op, string arg2) : result(result), op(op), arg1(toString(arg1)), arg2(arg2) {}

void quad::print()
{
    if (this->op == "=")
    {
        cout << "\t" << this->result << " = " << this->arg1 << endl;
    }
    else if (this->op == "goto")
    {
        cout << "\tgoto " << this->result << endl;
    }
    else if (this->op == "return")
    {
        cout << "\treturn " << this->result << endl;
    }
    else if (this->op == "call")
    {
        cout << "\t" << this->result << " = call " << this->arg1 << ", " << this->arg2 << endl;
    }
    else if (this->op == "param")
    {
        cout << "\t" << "param " << this->result << endl;
    }
    else if (this->op == "label")
    {
        cout << this->result << endl;
    }
    else if (this->op == "=[]")
    {
        cout << "\t" << this->result << " = " << this->arg1 << "[" << this->arg2 << "]" << endl;
    }
    else if (this->op == "[]=")
    {
        cout << "\t" << this->result << "[" << this->arg1 << "] = " << this->arg2 << endl;
    }
    else if (this->op == "+" || this->op == "-" || this->op == "*" || this->op == "/" || this->op == "%" || this->op == "|" || this->op == "^" || this->op == "&" || this->op == "<<" || this->op == ">>")
    {
        binary_print();
    }
    else if (this->op == "==" || this->op == "!=" || this->op == "<" || this->op == ">" || this->op == "<=" || this->op == ">=")
    {
        relation_print();
    }
    else if (this->op == "=&" || this->op == "=*")
    {
        shift_print();
    }
    else if(this->op == "*=")
    {
        cout << "\t" << "*" << this->result << " = " << this->arg1 << endl;
    }
    else if (this->op == "=-")
    {
        shift_print_("= -");
    }
    else if (this->op == "~")
    {
        shift_print_("= ~");
    }
    else if (this->op == "!")
    {
        shift_print_("= !");
    }
    else
    {
        cout << this->op << this->arg1 << this->arg2 << this->result << endl;
        cout << "INVALID OPERATOR\n";
    }
}


void quad::binary_print() {
    cout << "\t" << result << " = " << arg1 << " " << op << " " << arg2 << endl;
}

void quad::relation_print() {
    cout << "\tif " << arg1 << " " << op << " " << arg2 << " goto " << result << endl;
}

void quad::shift_print() {
    cout << "\t" << result << " " << op[0] << " " << op[1] << arg1 << endl;
}

void quad::shift_print_(const string& tp) {
    cout << "\t" << result << " " << tp << " " << arg1 << endl;
}

Symbol *gentemp(string type, string s) {
    Symbol *temp = new Symbol("t" + toString(tempcnt++), type, s);
    currtable->symbol.insert({temp->name, *temp});
    return temp;
}

void changeTable(symbTable *table) {
    currtable = table;
}

bool typeCheck(Symbol *&a, Symbol *&b) {
    std::function<bool(symbType *, symbType *)> type_comp = [&](symbType *first, symbType *second) -> bool {
        if (!first && !second) 
            return true;
        if (!first || !second || first->type != second->type)
            return false;
        return type_comp(first->arrtype, second->arrtype);
    };

    if (type_comp(a->type, b->type)) {
        return true;
    }

    if (a->type->type == "float" || b->type->type == "float") {
        a = a->convert("float");
        b = b->convert("float");
        return true;
    }

    if (a->type->type == "int" || b->type->type == "int") {
        a = a->convert("int");
        b = b->convert("int");
        return true;
    }

    return false;
}


void emit(string op, string result, string arg1, string arg2)
{
    quad *q = new quad(result, arg1, op, arg2);
    quadarr.emplace_back(q);
}

void emit(string op, string result, int arg1, string arg2)
{
    quad *q = new quad(result, arg1, op, arg2);
    quadarr.emplace_back(q);
}

void backpatch(list<int> list_, int addr)
{
    for (auto &i : list_)
    {
        quadarr[i-1]->result = toString(addr);
    }
}

list<int> makeList(int base)
{
    return {base};
}

list<int> merge(list<int> first, list<int> second)
{
    list<int> ret = first;
    ret.merge(second);
    return ret;
}

int nextInstruction()
{
    return quadarr.size() + 1;
}

string toString(int i) {
    return to_string(i);
}
string toString(float f) {
    return to_string(f);
}

string toString(char c) {
    return string(1, c);
}

void expression::toInt() {
    if (this->type == "boolean") {
        this->symbol = gentemp("int");

        backpatch(this->trueList, static_cast<int>(quadarr.size() + 1));
        emit("=", this->symbol->name, "true");

        emit("goto", toString(static_cast<int>(quadarr.size() + 2)));

        backpatch(this->falseList, static_cast<int>(quadarr.size() + 1));
        emit("=", this->symbol->name, "false");
    }
}

void expression::toBool() {
    if (this->type == "nonboolean") {
        this->falseList = makeList(static_cast<int>(quadarr.size() + 1));
        emit("==", "", this->symbol->name, "0");

        this->trueList = makeList(static_cast<int>(quadarr.size() + 1));
        emit("goto", "");
    }
}


int main() {
    globtable = new symbTable("global");
    currtable = globtable;

    tblcnt = 0;
    tempcnt = 0;

    cout << left; 
    yyparse();

    int ins = 1;
    cout << "Three Address Code\n" << "=================================================================" << '\n';
    for(auto it : quadarr) {
        cout<<setw(4)<<ins++<<": "; it->print();
    }
    
    globtable->update();
    globtable->print();
    return 0;
}
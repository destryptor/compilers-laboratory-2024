#include <stdio.h>
#include "y.tab.c"
#include "lex.yy.c"

int main()
{
    printf("Order of Shifts and Reductions (Parse Tree is after these):\n");
    printf("-------------------------------\n");
    yyparse();
    printf("\n\n\n");
    printf("Parse Tree:\n");
    printf("-----------\n");
    print_tree(parse_tree_root, 0);
    return 0;
}
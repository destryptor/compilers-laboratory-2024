#include <stdio.h>
#include "lex.yy.c"

int yywrap()
{
    return 1;
}

typedef struct _node {
   char *id;
   char *val;
   struct _node *next;
} node;

typedef node *symboltable;

symboltable addtbl ( symboltable T, char *id, char* val )
{
   node *p;
   p = T;
   if(T==NULL)
   {
   p = (node *)malloc(sizeof(node));
   p -> id = (char *)malloc((strlen(id)+1) * sizeof(char));
   strcpy(p -> id, id);
   p -> val = (char *)malloc((strlen(val)+1) * sizeof(char));
   strcpy(p -> val, val);
   p->next=NULL;
   T=p;
   return T;
   }
   while (p) {
      if (!strcmp(p->id, id) && !(strcmp(p->val, val))) {
        return T;
      }
      if(!p->next)
      {  
        node*newn;
        newn= (node *)malloc(sizeof(node));
        newn-> id = (char *)malloc((strlen(id)+1) * sizeof(char));
        strcpy(newn -> id, id);
        newn -> val = (char *)malloc((strlen(val)+1) * sizeof(char));
        strcpy(newn-> val, val);
        p -> next = newn;
        return T;
      }
      p = p -> next;
   }
   return p;
}

int main()
{
    int nextok;
    symboltable table = NULL;
    while ((nextok = yylex()))
    {
        switch (nextok)
        {
        case KEYWORD:
            printf("<Keyword: %s  >\n", yytext);
            break;
        case ID:
            printf("<Identifier: %s  >\n", yytext);
            table=addtbl(table, "Identifier", yytext);
            break;
        case INT_CONST:
            printf("<Integer constant: %s  >\n", yytext);
            table=addtbl(table, "Integer constant", yytext);
            break;
        case FLOAT_CONST:
            printf("<Floating constant: %s  >\n", yytext);
            table=addtbl(table, "Floating constant", yytext);
            break;
        case CHAR_CONST:
            printf("<Char const: %s  >\n", yytext);
            table=addtbl(table, "Char const", yytext);
            break;
        case STR_LITERAL:
            printf("<String literal: %s  >\n", yytext);
            table=addtbl(table, "String literal", yytext);
            break;
        case PUNCT:
            printf("<Punctuator: %s  >\n", yytext);
            break;
         case SINGLE_LINE_COMM:
            printf("<Single line comment: %s \n", yytext);
            break;
        case MULTI_LINE_COMM:
            printf("<Multiline comment: %s  >\n", yytext);
            break;
        default:
            printf("<Invalid nextok: %s >\n", yytext);
            break;
        }
    }

    printf("\n\n\nPrinting symbol table...\n");
    node* temp = table;
    while(temp) {
        printf("%s : %s\n", temp->id, temp->val);
        temp = temp->next;
    }
    return 0;
}
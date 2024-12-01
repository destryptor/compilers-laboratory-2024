#include "y.tab.c"
#include "lex.yy.c"

entry *addToTable(char *id)
{
    if (!head)
    {
        head = (entry *)malloc(sizeof(entry));
        head->id = strdup(id);
        // currOffset = memIdx;
        head->offset = memIdx++;
        head->next = NULL;
        return head;
    }
    entry *temp = head;
    while (temp)
    {
        if (!strcmp(temp->id, id))
        {
            // currOffset = temp->offset;
            return head;
        }
        if (!temp->next)
            break;
        temp = temp->next;
    }
    entry *newNode = (entry *)malloc(sizeof(entry));
    if (!newNode)
    {
        printf("\tMemory allocation failed\n");
        exit(1);
    }
    newNode->id = strdup(id);
    // currOffset = memIdx;
    newNode->offset = memIdx++;
    newNode->next = NULL;
    temp->next = newNode;
    return head;
}

int getOffset(char *id)
{
    entry *temp = head;
    while (temp)
    {
        if (!strcmp(id, temp->id))
        {
            return temp->offset;
        }
        if (!temp->next)
            break;
        temp = temp->next;
    }
    return -1;
}

void handleArg(arg *arg1, arg *arg2, arg *expr, char op)
{
    if (op == '^')
    {
        if (arg1->type == 0 && arg2->type == 0)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[%d]= pwr(R[0], R[1]);\n", expr->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[0]= pwr(R[0], R[1]);\n");
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 0 && arg2->type == 1)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[%d]= pwr(R[0], %d);\n", expr->val, arg2->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[0]= pwr(R[0], %d);\n", arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 0 && arg2->type == 2)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[%d]= pwr(R[0], R[%d]);\n", expr->val, arg2->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[0]= pwr(R[0], R[%d]);\n", arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 0 && arg2->type == 3)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[%d]= pwr(R[0], R[1]);\n", expr->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[0]= pwr(R[0], R[1]);\n");
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 1 && arg2->type == 0)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[%d]= pwr(%d, R[0]);\n", expr->val, arg1->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[0]= pwr(%d, R[0]);\n", arg1->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 1 && arg2->type == 1)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[%d]= pwr(%d, %d);\n", expr->val, arg1->val, arg2->val);
            }
            else
            {
                printf("\tR[0] = pwr(%d, %d);\n", arg1->val, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 1 && arg2->type == 2)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx;
                printf("\tR[%d]= pwr(%d, R[%d]);\n", expr->val, arg1->val, arg2->val);
            }
            else
            {
                printf("\tR[0]= pwr(%d, R[%d]);\n", arg1->val, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 1 && arg2->type == 3)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[%d]= pwr(%d, R[0]);\n", expr->val, arg1->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[0]= pwr(%d, R[0]);\n", arg1->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 2 && arg2->type == 1)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx;
                printf("\tR[%d]= pwr(R[%d], %d);\n", expr->val, arg1->val, arg2->val);
            }
            else
            {
                printf("\tR[0]= pwr(R[%d], %d);\n", arg1->val, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 2 && arg2->type == 2)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx - 1;
                printf("\tR[%d]= pwr(R[%d], R[%d]);\n", expr->val, arg1->val, arg2->val);
            }
            else
            {
                printf("\tR[0]= pwr(R[%d], R[%d]);\n", arg1->val, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 2 && arg2->type == 3)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx;
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[%d]= pwr(R[%d], R[0]);\n", expr->val, arg1->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[0]= pwr(R[%d], R[0]);\n", arg1->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 3 && arg2->type == 0)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[%d]= pwr(R[0], R[1]);\n", expr->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[0]= pwr(R[0], R[1]);\n");
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 3 && arg2->type == 1)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[%d]= pwr(R[0], %d);\n", expr->val, arg2->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[0]= pwr(R[0], %d);\n", arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 3 && arg2->type == 2)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[%d]= pwr(R[0], R[%d]);\n", expr->val, arg2->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[0]= pwr(R[0], R[%d]);\n", arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 3 && arg2->type == 3)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[%d]= pwr(R[0], R[1]);\n", expr->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[0]= pwr(R[0], R[1]);\n");
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
    }
    else
    {
        if (arg1->type == 0 && arg2->type == 0)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[%d] = R[0] %c R[1];\n", expr->val, op);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[0] = R[0] %c R[1];\n", op);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 0 && arg2->type == 1)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[%d] = R[0] %c %d;\n", expr->val, op, arg2->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[0] = R[0] %c %d;\n", op, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 0 && arg2->type == 2)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[%d] = R[0] %c R[%d];\n", expr->val, op, arg2->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[0] = R[0] %c R[%d];\n", op, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 0 && arg2->type == 3)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[%d]=R[0] %c R[1];\n", expr->val, op);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[0] = R[0] %c R[1];\n", op);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 1 && arg2->type == 0)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[%d] = %d %c R[0];\n", expr->val, arg1->val, op);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[0] = %d %c R[0];\n", arg1->val, op);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 1 && arg2->type == 1)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[%d] = %d %c %d;\n", expr->val, arg1->val, op, arg2->val);
            }
            else
            {
                printf("\tR[0] = %d %c %d;\n", arg1->val, op, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 1 && arg2->type == 2)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx;
                printf("\tR[%d] = %d %c R[%d];\n", expr->val, arg1->val, op, arg2->val);
            }
            else
            {
                printf("\tR[0] = %d %c R[%d];\n", arg1->val, op, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 1 && arg2->type == 3)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[%d] = %d %c R[0];\n", expr->val, arg1->val, op);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[0] = %d %c R[0];\n", arg1->val, op);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 2 && arg2->type == 0)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx;
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[%d] = R[%d] %c R[0];\n", expr->val, arg1->val, op);
            }
            if (expr->type == 3)
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[0] = R[%d] %c R[0];\n", arg1->val, op);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 2 && arg2->type == 1)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx;
                printf("\tR[%d] = R[%d] %c %d;\n", expr->val, arg1->val, op, arg2->val);
            }
            else
            {
                printf("\tR[0] = R[%d] %c %d;\n", arg1->val, op, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 2 && arg2->type == 2)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx - 1;
                printf("\tR[%d] = R[%d] %c R[%d];\n", expr->val, arg1->val, op, arg2->val);
            }
            else
            {
                printf("\tR[0] = R[%d] %c R[%d];\n", arg1->val, op, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 2 && arg2->type == 3)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx;
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[%d] = R[%d] %c R[0];\n", expr->val, arg1->val, op);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg2->val);
                printf("\tR[0] = R[%d] %c R[0];\n", arg1->val, op);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 3 && arg2->type == 0)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[%d] = R[0] %c R[1];\n", expr->val, op);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[0] = R[0] %c R[1];\n", op);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 3 && arg2->type == 1)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[%d] = R[0] %c %d;\n", expr->val, op, arg2->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[0] = R[0] %c %d;\n", op, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 3 && arg2->type == 2)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[%d] = R[0] %c R[%d];\n", expr->val, op, arg2->val);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[0]=R[0] %c R[%d];\n", op, arg2->val);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
        else if (arg1->type == 3 && arg2->type == 3)
        {
            // printf("\t// expr->val = %d\n", expr->val);
            if (expr->type == 2)
            {
                expr->val = regIdx + 1;
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[%d] = R[0] %c R[1];\n", expr->val, op);
            }
            else
            {
                printf("\tR[0] = MEM[%d];\n", arg1->val);
                printf("\tR[1] = MEM[%d];\n", arg2->val);
                printf("\tR[0]=R[0] %c R[1];\n", op);
                printf("\tMEM[%d] = R[0];\n", expr->val);
            }
        }
    }
    if (expr->type == 2)
        regIdx = expr->val;
}

int main()
{
    printf("#include <stdio.h>\n");
    printf("#include <stdlib.h>\n");
    printf("#include \"aux.c\"\n\n");

    printf("int main()\n");
    printf("{\n");

    printf("\tint R[12];\n");
    printf("\tint MEM[65536];\n\n");

    yyparse();

    printf("\n\texit(0);\n");
    printf("}\n");
}
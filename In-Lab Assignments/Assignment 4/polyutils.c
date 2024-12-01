#include <stdio.h>
#include "y.tab.c"
#include "lex.yy.c"

struct TreeNode
{
    char *name;
    long long int val;
    char *inh;
    struct TreeNode **children;
    int child_count;
};

struct TreeNode *create_node(char *name, int child_count, ...)
{
    struct TreeNode *node = malloc(sizeof(struct TreeNode));
    node->name = strdup(name);
    node->child_count = child_count;
    node->children = malloc(sizeof(struct TreeNode *) * child_count);
    if (node->children == NULL)
    {
        yyerror("Memory allocation failed");
        exit(1);
    }

    va_list args;
    va_start(args, child_count);
    for (int i = 0; i < child_count; i++)
    {
        node->children[i] = va_arg(args, struct TreeNode *);
    }
    va_end(args);

    return node;
}

void print_tree(struct TreeNode *node, int depth)
{
    for (int i = 0; i < depth; i++)
        printf("\t");
    printf("==> %s ", node->name);
    if (!strcmp(node->name, "S") || !strcmp(node->name, "-") || !strcmp(node->name, "+") || !strcmp(node->name, "X") || !strcmp(node->name, "x") || !strcmp(node->name, "^"))
        printf("[ ]\n");
    else if (!strcmp(node->name, "P") || !strcmp(node->name, "T"))
    {
        printf("[inh = %s]\n", node->inh);
    }
    else if (!strcmp(node->name, "M"))
    {
        printf("[inh = %s, val = %lld]\n", node->inh, node->val);
    }
    else
    {
        printf("[val = %lld]\n", node->val);
    }
    for (int i = 0; i < node->child_count; i++)
    {
        print_tree(node->children[i], depth + 1);
    }
}

void setattr(struct TreeNode *root)
{
    if (!strcmp(root->name, "S"))
    {
        if (root->child_count == 1)
        {
            root->children[0]->inh = strdup("+");
        }
        else
        {
            root->children[1]->inh = strdup(root->children[0]->name);
        }
    }
    else if (!strcmp(root->name, "P"))
    {
        if (root->child_count == 1)
        {
            root->children[0]->inh = strdup(root->inh);
        }
        else
        {
            root->children[0]->inh = strdup(root->inh);
            root->children[2]->inh = strdup(root->children[1]->name);
        }
    }
    else if (!strcmp(root->name, "N"))
    {
        if (root->child_count == 2)
        {
            root->children[1]->inh = strdup(root->children[0]->name);
        }
    }
    else if (!strcmp(root->name, "M"))
    {
        if (root->child_count == 2)
        {
            char *mVal = strdup(root->inh);
            char *digVal = strdup(root->children[0]->name);
            char *total = (char *)malloc((strlen(mVal) + 2) * sizeof(char));
            strcpy(total, mVal);
            strcat(total, digVal);
            root->children[1]->inh = strdup(total);
        }
    }

    int i;
    for (i = 0; i < root->child_count; i++)
    {
        setattr(root->children[i]);
    }

    if (!(strcmp(root->name, "M")))
    {
        if (root->child_count == 1)
        {
            root->val = atoi(root->inh) * 10 + root->children[0]->val;
        }
        else
        {
            root->val = root->children[1]->val;
        }
    }
    else if (!(strcmp(root->name, "N")))
    {
        if (root->child_count == 1)
        {
            root->val = root->children[0]->val;
        }
        else
        {
            root->val = root->children[1]->val;
        }
    }
    else if (!strcmp(root->name, "S") || !strcmp(root->name, "P") || !strcmp(root->name, "T") || !strcmp(root->name, "X"))
    {
    }
    else
    {
        root->val = atoi(root->name);
    }
}

long long int evalpoly(struct TreeNode *root, int param)
{
    if (!strcmp(root->name, "x"))
    {
        root->val = param;
    }

    int i;
    for (i = 0; i < root->child_count; i++)
    {
        evalpoly(root->children[i], param);
    }

    if (!strcmp(root->name, "X"))
    {
        if (root->child_count == 1)
        {
            root->val = root->children[0]->val;
        }
        else
        {
            root->val = (long long int)pow(root->children[0]->val, root->children[2]->val);
        }
    }
    else if (!strcmp(root->name, "T"))
    {
        if (root->child_count == 1)
        {
            root->val = root->children[0]->val;
        }
        else
        {
            root->val = root->children[0]->val * root->children[1]->val;
        }

        if (root->inh && !strcmp(root->inh, "-"))
            root->val = -root->val;
    }
    else if (!strcmp(root->name, "P"))
    {
        if (root->child_count == 1)
        {
            root->val = root->children[0]->val;
        }
        else
        {
            root->val = root->children[0]->val + root->children[2]->val;
        }
    }
    else if (!strcmp(root->name, "S"))
    {
        if (root->child_count == 1)
        {
            root->val = root->children[0]->val;
        }
        else
        {
            // if (!strcmp(root->children[1]->inh, "+"))
            // {
            root->val = root->children[1]->val;
            // }
            // else
            // {
            //     root->val = root->children[1]->val * -1;
            // }
        }
        return root->val;
    }
}

int printFlag = 0;
void printderivative(struct TreeNode *node)
{
    if(!strcmp(node->name, "T")) {
        if(node->child_count == 2) {
            if(printFlag && !strcmp(node->inh, "+")) {
                printf("+ ");
            } else if(!strcmp(node->inh, "-")) {
                printf("- ");
            }
            printf("%lld", node->children[0]->val * node->children[1]->children[2]->val);
            if(node->children[1]->children[2]->val > 2) {
                printf("x^%lld ", node->children[1]->children[2]->val - 1);
            } else if(node->children[1]->children[2]->val == 2) {
                printf("x ");
            } else if(node->children[1]->children[2]->val == 1) {
                printf(" ");
            }
        } else if(!strcmp(node->children[0]->name, "X")) {
            if(printFlag && !strcmp(node->inh, "+")) {
                printf("+ ");
            } else if(!strcmp(node->inh, "-")) {
                printf("- ");
            }
            if(node->children[0]->child_count == 1) {
                printf("1 ");
            } else {
                printf("%lldx^%lld ", node->children[0]->children[2]->val, node->children[0]->children[2]->val - 1);
            }
        }
        printFlag = 1;
    }
    int i;
    for(i = 0; i < node->child_count; i++) {
        printderivative(node->children[i]);
    }
}

int main()
{
    yyparse();
    setattr(parse_tree_root);
    printf("+++ The annotated parse tree is\n");
    print_tree(parse_tree_root, 1);
    printf("\n");

    int i;
    for (int i = -5; i < 6; i++)
    {
        long long int value = evalpoly(parse_tree_root, i);
        printf("+++ f(%2d) = %12lld\n", i, value);
    }

    printf("\n+++ f'(x) = ");
    printderivative(parse_tree_root);
    printf("\n");
    return 0;
}

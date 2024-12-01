#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <math.h>
#include "y.tab.c"
#include "lex.yy.c"

Node *addToTable(char *id_)
{
    // printf("Adding to table: %s\n", id_);
    Node *curr = head;
    while (curr)
    {
        if (!strcmp(curr->id, id_))
        {
            // printf("Already in table: %s\n", id_);
            return head;
        }
        // printf("Curr val: %s, %d\n", curr->id, curr->val);
        curr = curr->next;
    }
    // printf("Not in table: %s\n", id_);
    Node *newNode = (Node *)malloc(sizeof(Node));
    // printf("Allocated memory\n");
    newNode->id = (char *)malloc(sizeof(char) * (strlen(id_) + 1));
    // printf("Allocated memory for id\n");
    strcpy(newNode->id, id_);
    // printf("Copied id\n");
    // printf("Added to table: %s\n", newNode->id);
    newNode->val = INT_MIN;
    newNode->next = head;
    return newNode;
}

Node *addToTempTable(char *id_, int val_)
{
    // printf("Adding to table: %s\n", id_);
    Node *curr = tempHead;
    while (curr)
    {
        if (!strcmp(curr->id, id_))
        {
            // printf("Already in table: %s\n", id_);
            return tempHead;
        }
        // printf("Curr val: %s, %d\n", curr->id, curr->val);
        curr = curr->next;
    }
    // printf("Not in table: %s\n", id_);
    Node *newNode = (Node *)malloc(sizeof(Node));
    // printf("Allocated memory\n");
    newNode->id = (char *)malloc(sizeof(char) * (strlen(id_) + 1));
    // printf("Allocated memory for id\n");
    strcpy(newNode->id, id_);
    // printf("Copied id\n");
    // printf("Added to table: %s\n", newNode->id);
    newNode->val = INT_MIN;
    newNode->next = tempHead;
    return newNode;
}

Node *setVal(char *id_, int val_)
{
    // printf("Setting value of %s to %d\n", id_, val_);
    Node *curr = head;
    while (curr)
    {
        if (!strcmp(curr->id, id_))
        {
            curr->val = val_;
            printf("Value of %s set to %d\n", curr->id, curr->val);
            return head;
        }
        // printf("Curr val: %s, %d\n", curr->id, curr->val);
        curr = curr->next;
    }
    Node *newNode = (Node *)malloc(sizeof(Node));
    newNode->id = (char *)malloc(sizeof(char) * (strlen(id_) + 1));
    strcpy(newNode->id, id_);
    newNode->val = val_;
    newNode->next = head;
    printf("Value of %s set to %d\n", newNode->id, newNode->val);
    return newNode;
}
// TreeNode* addToTree(string id_ = "", )
int getVal(char *id)
{
    // printf("Getting value of %s\n", id);
    Node *curr = head;
    while (curr)
    {
        if (!strcmp(curr->id, id))
        {
            // printf("Returning: %s, %d\n", curr->id, curr->val);
            return curr->val;
        }
        // printf("Curr val: %s, %d\n", curr->id, curr->val);
        curr = curr->next;
    }
    // return INT_MIN;
    printf("Value not in table: %s\n ERROR!!!\n", id);
    exit(-1);
}
int evaluate(char op, int arg1, int arg2)
{
    // printf("Evaluating %d %c %d\n", arg1, op, arg2);
    switch (op)
    {
    case '+':
        return arg1 + arg2;
    case '-':
        return arg1 - arg2;
    case '*':
        return arg1 * arg2;
    case '/':
        return arg1 / arg2;
    case '%':
        return arg1 % arg2;
    case '^':
        return pow(arg1, arg2);
    }
    return INT_MIN;
}

TreeNode *createLeaf(char *id_, int val_) {
    TreeNode* newNode = (TreeNode*)malloc(sizeof(TreeNode));
    newNode->id = (char *)malloc(sizeof(char) * (strlen(id_) + 1));
    strcpy(newNode->id, id_);
    newNode->val = val_;
    newNode->left = NULL;
    newNode->right = NULL;
    newNode->parent = NULL;
    return newNode;
}

TreeNode *addToTree(TreeNode *root, char *id_, int val_) {
    TreeNode* newNode = createLeaf(id_, val_);
    if(!root) {
        return newNode;
    }
    if(!strcmp(root->id, "/") || !strcmp(root->id, "+") || !strcmp(root->id, "-") || !strcmp(root->id, "*")|| !strcmp(root->id, "%") || !strcmp(root->id, "^")) {
        if(!root->left) {
            root->left = newNode;
            newNode->parent = root;
             if(!strcmp(id_, "/") || !strcmp(id_, "+") || !strcmp(id_, "-") || !strcmp(id_, "*") || !strcmp(id_, "%") || !strcmp(id_, "^") ) root=root->left;
        }
        else if(!root->right) {
            root->right = newNode;
            newNode->parent = root;
             if(!strcmp(id_, "/") || !strcmp(id_, "+") || !strcmp(id_, "-") || !strcmp(id_, "*") || !strcmp(id_, "%") || !strcmp(id_, "^") ) root=root->right;
        } else {
            return addToTree(root->parent, id_, val_);
        }
    }
    return root;
}

int evalTree(TreeNode *root) {
    if(!root) return 0;
    if(!strcmp(root->id, "/") || !strcmp(root->id, "+") || !strcmp(root->id, "-") || !strcmp(root->id, "*")|| !strcmp(root->id, "%") || !strcmp(root->id, "^"))
    {   
        int left = evalTree(root->left);
        int right = evalTree(root->right);

        if(!strcmp(root->id, "/")) return left / right;
        if(!strcmp(root->id, "+")) return left + right;
        if(!strcmp(root->id,"-")) return left - right;
        if(!strcmp(root->id,"*")) return left * right;
        if(!strcmp(root->id,"%")) return left % right;
        if(!strcmp(root->id,"^")) return (int)pow(left, right);
    }
    else if(!strcmp(root->id,"---"))
    {
        return root->val;
    }
    return -1;
}

TreeNode *buildTree(Node *head) {
    Node* temp = head;
    TreeNode* root = NULL;
    TreeNode* curr = NULL;

    while(temp) {
        if(!root) {
            curr = addToTree(curr, temp->id, temp->val);
            root = curr;
        }
        else curr = addToTree(curr, temp->id, temp->val);
        temp = temp->next;
    }

    return root;
}

int main()
{
    /* yydebug = 1; */
    yyparse();
    return 0;
}
#include <bits/stdc++.h>
#include "lex.yy.c"
using namespace std;

int nums[100];
// string ids[100];
class Node
{
public:
    string name;
    int occurences;
    int val;
    Node *next;
    Node(string name1, int value = 0)
    {
        name = name1;
        val = value;
        occurences = 1;
        next = nullptr;
    }
};

Node *refId;
Node *addToList(Node *list, string name, int value = 0)
{
    Node *curr = list;
    while (curr)
    {
        if (curr->name == name)
        {
            curr->occurences++;
            refId = curr;
            return list;
        }
        curr = curr->next;
    }
    curr = new Node(name, value);
    curr->next = list;
    refId = curr;
    return curr;
}

class ConstNode
{
public:
    int val;
    ConstNode *next;
    int occurences;
    ConstNode(int val)
    {
        this->val = val;
        occurences = 1;
        next = nullptr;
    }
};
ConstNode *refConst;
ConstNode *addConst(ConstNode *head, int val)
{
    ConstNode *curr = head;
    while (curr)
    {
        if (curr->val == val)
        {
            curr->occurences++;
            refConst = curr;
            return head;
        }
        curr = curr->next;
    }
    curr = new ConstNode(val);
    curr->next = head;
    refConst = curr;
    return curr;
}

class TreeNode
{
public:
    string type;
    Node *refID;
    ConstNode *refConst;
    string op;
    TreeNode *left;
    TreeNode *right;
    TreeNode *parent;
    // bool isFull;
    TreeNode(string type, Node *refID = nullptr, ConstNode *refConst = nullptr, string op = "-1", TreeNode *left = nullptr, TreeNode *right = nullptr)
    {
        this->type = type;
        this->refID = refID;
        this->refConst = refConst;
        this->op = op;
        this->left = left;
        this->right = right;
        this->parent = parent;
        // this->isFull = false;
    }
};

int yywrap()
{
    return 1;
}
TreeNode *root;
TreeNode *addToTree(TreeNode *curr, string type, Node *refID, ConstNode *refConst, string op)
{
    TreeNode *newNode = new TreeNode(type, refID, refConst, op);
    if (!curr)
    {
        // cout << "ROOT" << '\n';
        root = newNode;
        return newNode;
    }
    if (!curr->left)
    {
        curr->left = newNode;
        newNode->parent = curr; // Set parent
        if (newNode->op == "+" || newNode->op == "-" || newNode->op == "/" || newNode->op == "*")
            curr = curr->left;
        // cout << "LEFT CHILD" << '\n';
        return curr;
    }
    else if (!curr->right)
    {
        curr->right = newNode;
        newNode->parent = curr; // Set parent
        if (newNode->op == "+" || newNode->op == "-" || newNode->op == "/" || newNode->op == "*")
            curr = curr->right;
        // cout << "RIGHT CHILD" << '\n';
        return curr;
    }
    else
    {
        // curr->isFull = true;
        curr = curr->parent;
        // cout << "PARENT" << '\n';
        return addToTree(curr, type, refId, refConst, op);
    }
}

class varToVal
{
public:
    string name;
    int val;
    varToVal()
    {
        name = "\0";
        val = 0;
    }
};

varToVal ids[100];

void printParseTree(TreeNode *root, int depth = 0)
{
    if (!root)
        return;

    for (int i = 0; i < depth; ++i)
    {
        cout << "\t";
    }
    if (root->op == "+" || root->op == "-" || root->op == "/" || root->op == "*")
    {
        cout << "---> " << "OP(" << root->op << ")" << '\n';
    }
    else if (root->op[0] == '-' || isdigit(root->op[0]))
    {
        cout << "---> " << "NUM(" << root->op << ")" << '\n';
    }
    else
    {
        cout << "---> " << "ID(" << root->op << ")" << '\n';
    }

    printParseTree(root->left, depth + 1);
    printParseTree(root->right, depth + 1);
}

int evaluateExpression(TreeNode *root)
{
    if (!root)
    {
        cout << "EMPTY" << '\n';
        return 0;
    }
    if (root->op == "+")
    {
        return evaluateExpression(root->left) + evaluateExpression(root->right);
    }
    else if (root->op == "-")
    {
        return evaluateExpression(root->left) - evaluateExpression(root->right);
    }
    else if (root->op == "*")
    {
        return evaluateExpression(root->left) * evaluateExpression(root->right);
    }
    else if (root->op == "/")
    {
        return evaluateExpression(root->left) / evaluateExpression(root->right);
    }
    else if (root->type == "NUM")
    {
        // cout << root->name << "\n";
        return root->refConst->val;
    }
    else
    {
        for (int i = 0; i < 100; i++)
        {
            if (ids[i].name == root->refID->name)
            {
                return ids[i].val;
            }
        }
    }
    return 0;
}

string MTable[3][9];
void fill()
{
    for (int i = 0; i < 3; i++)
    {
        for (int j = 0; j < 9; j++)
        {
            MTable[i][j] = "^";
        }
    }
    MTable[1][0] = "+";
    MTable[1][1] = "*";
    MTable[1][2] = "/";
    MTable[1][3] = "%";
    MTable[1][4] = "-";
    MTable[2][5] = "ID";
    MTable[2][6] = "NUM";
    MTable[2][7] = "EXPR";
    MTable[0][7] = "( OP ARG ARG )";
}

int main()
{
    fill();
    for (int i = 0; i < 100; i++)
    {
        ids[i].name = "-1";
        ids[i].val = 0;
    }
    int nextok;
    Node *list = nullptr;
    ConstNode *consts = nullptr;
    TreeNode *parsetree = nullptr;
    int lp = 0, rp = 0;

    string expr;

    stack<string> st;
    st.push("EXPR");
    int count = 0;
    int varCnt = 0;

    while ((nextok = yylex()))
    {
        // cout << nextok << '\n';
        if (lp == rp && lp &&
            ((yytext[0] == '-' && isdigit(yytext[1])) || isdigit(yytext[0])))
        {
            if (yytext[0] != '\n' && yytext[0] != EOF)
            {
                // cout << yytext[0] << '\n';
                // cout << "YYTEXT: " << yytext << '\n';
                ids[count++].val = stoi(yytext);
                while (nextok == yylex())
                {
                    ids[count++].val = stoi(yytext);
                }
            }
        }
        else if (nextok == INVTOK)
        {
            cout << "Invalid token " << yytext << " found" << '\n';
            exit(-1);
        }
        else if (nextok == LP)
        {
            lp++;
            // cout << "LP" << '\n';
            while (st.top() != "(")
            {
                // cout << "STACK TOP: " << st.top() << '\n';
                if (st.top() == "EXPR")
                {
                    st.pop();
                    st.push(")");
                    st.push("ARG");
                    st.push("ARG");
                    st.push("OP");
                    st.push("(");
                }
                else if (st.top() == "ARG")
                {
                    st.pop();
                    st.push("EXPR");
                }
                else if (st.top() == "(")
                    st.pop();
                else
                {
                    cout << "*** Error: " << ((st.top() == "ARG") ? "ID/NUM/LP" : (st.top() == "OP") ? "Operator"
                                                                                                     : st.top())
                         << " expected in place of " << yytext << '\n';
                    exit(-1);
                }
            }
            if (st.top() == "(")
            {
                st.pop();
            }
            else
            {
                cout << "*** Error: " << ((st.top() == "ARG") ? "ID/NUM/LP" : (st.top() == "OP") ? "Operator"
                                                                                                 : st.top())
                     << " expected in place of " << yytext << '\n';
                exit(-1);
            }
        }
        else if (nextok == OP)
        {
            // cout << "OP" << '\n';
            while (st.top() != yytext)
            {
                // cout << "STACK TOP: " << st.top() << '\n';
                if (st.top() == "OP")
                {
                    st.pop();
                    parsetree = addToTree(parsetree, "OP", nullptr, nullptr, yytext);
                    break;
                }
                else
                {
                    cout << "*** Error: " << ((st.top() == "ARG") ? "ID/NUM/LP" : (st.top() == "OP") ? "Operator"
                                                                                                     : st.top())
                         << " expected in place of " << yytext << '\n';
                    exit(-1);
                }
            }
        }
        else if (nextok == RP)
        {
            rp++;
            // if(lp == rp) break;
            // cout << "RP" << '\n';
            // cout << "STACK TOP: " << st.top() << '\n';

            if (st.top() == ")")
            {
                st.pop();
            }
            else
            {
                cout << "*** Error: " << ((st.top() == "ARG") ? "ID/NUM/LP" : (st.top() == "OP") ? "Operator"
                                                                                                 : st.top())
                     << " expected in place of " << yytext << '\n';
                exit(-1);
            }
        }
        else if (nextok == ID)
        {
            // cout << "ID" << '\n';
            // cout << "STACK TOP: " << st.top() << '\n';
            bool flag = false;
            for (varCnt = 0; varCnt < 100; varCnt++)
            {
                // cout << ids[varCnt].name << '\n';
                if (ids[varCnt].name == "-1")
                    break;
                if (ids[varCnt].name == yytext)
                {
                    flag = true;
                    break;
                }
            }
            // cout << varCnt << '\n';
            if (!flag)
                ids[varCnt].name = yytext;
            // cout << "Added to arr" << '\n';

            list = addToList(list, yytext);
            // cout << "Added to list" << '\n';
            if (st.top() == "ARG")
            {
                st.pop();
                parsetree = addToTree(parsetree, "ID", refId, nullptr, "-1");
            }
            else
            {
                cout << "*** Error: " << ((st.top() == "ARG") ? "ID/NUM/LP" : (st.top() == "OP") ? "Operator"
                                                                                                 : st.top())
                     << " expected in place of " << yytext << '\n';
                exit(-1);
            }
        }
        else if (nextok == NUM)
        {
            // cout << "NUM" << '\n';
            // cout << "STACK TOP: " << st.top() << '\n';

            if (st.top() == "ARG")
            {
                st.pop();
                consts = addConst(consts, stoi(yytext));
                parsetree = addToTree(parsetree, "NUM", nullptr, refConst, "-1");
            }
            else
            {
                cout << "*** Error: " << ((st.top() == "ARG") ? "ID/NUM/LP" : (st.top() == "OP") ? "Operator"
                                                                                                 : st.top())
                     << " expected in place of " << yytext << '\n';
                exit(-1);
            }
        }
    }

    TreeNode *temp = root;
    cout << "Parsing is successful\n";
    printParseTree(temp);

    if (count > 0)
        cout << "Reading variable values from the input\n";
    for (int i = 0; ids[i].name != "-1"; i++)
    {
        cout << ids[i].name << " = " << ids[i].val << '\n';
    }
    cout << "Result: " << evaluateExpression(root) << '\n';

    return 0;
}
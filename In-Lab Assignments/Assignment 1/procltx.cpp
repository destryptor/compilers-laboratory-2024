#include <bits/stdc++.h>
#include "lex.yy.c"
using namespace std;

class Node {
public:
    string name;
    int occurences;
    Node* next;
    Node(string name1) {
        name = name1;
        occurences = 1;
        next = nullptr;
    }
};

Node* addToList(Node* list, string name) {
    Node* curr = list;
    while(curr) {
        if(curr->name == name) {
            curr->occurences++;
            return list;
        }
        curr = curr->next;
    }
    curr = new Node(name);
    curr->next = list;
    return curr;
}

class EnvNode {
public:
    string name;
    EnvNode* next;
    int occurences;
    EnvNode(string name) {
        this->name = name;
        occurences = 1;
        next = nullptr;
    }
};

EnvNode* addEnv(EnvNode* head, string name) {
    EnvNode* curr = head;
    auto it = name.find('{');
    string temp;

    for(auto it2 = it + 1; it2 < name.size() - 1; it2++) {
        temp += name[it2];
    }
    while(curr) {
        if(curr->name == temp) {
            curr->occurences++;
            return head;
        }
        curr = curr->next;
    }
    curr = new EnvNode(temp);
    curr->next = head;
    return curr;
}

int yywrap() {
    return 1;
}

int main() {
    int nextok;
    Node* list = nullptr;
    EnvNode* envnames = nullptr;
    int singleDollar = 0;
    int doubleDollar = 0;
    int dispBegin = 0;
    int dispEnd = 0;


    while((nextok = yylex())) {
        switch(nextok) {
            case cmd : list = addToList(list, string(yytext)); break;
            case inlinemath: singleDollar++; break;
            case displaymath: doubleDollar++; break;
            case displaymathbegin: dispBegin++; break;
            case displaymathend: dispEnd++; cout << string(yytext) << endl; break;
            case envbegin : envnames = addEnv(envnames, string(yytext)); break;
            default: break;
        }
    }

    cout << "Commands used: " << '\n';
    while(list) {
        cout << '\t' << list->name << "  " << '(' << list->occurences << ')' << '\n';
        list = list->next;
    }

    cout << "Environments used: " << '\n';
    while(envnames) {
        cout << '\t' << envnames->name << "  " << '(' << envnames->occurences << ')' << '\n';
        envnames = envnames->next;
    }

    cout << singleDollar / 2 << " math equations found\n";
    cout << doubleDollar / 2 + min(dispBegin, dispEnd) << " displayed equations found\n";

    return 0;
}
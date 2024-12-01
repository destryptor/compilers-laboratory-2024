#include "lex.yy.c"
#include "y.tab.c"

typedef struct list_ {
    int data;
    struct list_* next;
} leaderList;

leaderList* leader = NULL;

void addLeaders() {
    leaderList* temp = leader;
    while(temp) {
        quad* tempQuad = quadList;
        while(tempQuad) {
            if(tempQuad->quadNo == temp->data) {
                // printf("Leader: %d\n", tempQuad->quadNo);
                tempQuad->isLeader = 1;
                break;
            }
            tempQuad = tempQuad->next;
        }
        temp = temp->next;
    }
}

void createBlocks() {
    quad* temp = quadList;
    while(temp) {
        if(temp->quadNo == 1) {
            temp->isLeader = 1;
        } else if(temp->op[0] == 'i') {
            temp->next->isLeader = 1;
            leaderList* newNode = (leaderList*)malloc(sizeof(leaderList));
            newNode->data = atoi(temp->result);
            newNode->next = leader;
            leader = newNode;
        } else if(!strcmp("goto", temp->op)) {
            leaderList* newNode = (leaderList*)malloc(sizeof(leaderList));
            newNode->data = atoi(temp->result);
            newNode->next = leader;
            leader = newNode;
        }
        temp = temp->next;
    }
    addLeaders();
}

void initReg() {
    regDesc = (regdesc*)malloc(numRegisters * sizeof(regdesc));
    node* temp = symbolTable;
    while(temp) {
        sizeOfSymbolTable++;
        temp = temp->next;
    }
    // printf("SIZE: %d\n", sizeOfSymbolTable);
    for(int i = 0; i < numRegisters; i++) {
        regDesc[i].regNo = i + 1;
        regDesc[i].hasVar = (int*)malloc(sizeOfSymbolTable * sizeof(int));
        for(int j = 0; j < sizeOfSymbolTable; j++) {
            regDesc[i].hasVar[j] = 0;
        }
    }
}

void insertToBeStored(int value) {
    storeList* temp = (storeList*)malloc(sizeof(storeList));
    temp->num = value;
    temp->next = NULL;
    if(!toBeStored) {
        toBeStored = temp;
    } else {
        storeList* ptr = toBeStored;
        while(ptr->next) ptr = ptr->next;
        ptr->next = temp;
    }
}

storeList* deleteToBeStored() {
    storeList* temp;
    while(toBeStored) {
        temp = toBeStored;
        toBeStored = toBeStored->next;
        free(temp);
    }
    return toBeStored;
}

void emitTarget(char* op, char* arg1, char* arg2, char* result) {
    // printf("LALALALALALAL\n");
    target* newTarget = (target*)malloc(sizeof(target));
    if (!newTarget) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    // printf("LALALALAL\n");
    newTarget->op = strdup(op);
    newTarget->arg1 = strdup(arg1);
    newTarget->arg2 = strdup(arg2);
    newTarget->result = strdup(result);
    newTarget->blockNo = 0;
    newTarget->targetNo = ++targetInstrNo;

    if(!T) {
        T = newTarget;
    } else {
        target* temp = T;
        while(temp->next) {
            temp = temp->next;
        }
        temp->next = newTarget;
    }
}

int positionInSymbolTable(char* name) {
    node* temp = symbolTable;
    int pos = 0;

    while(temp) {
        if(!strcmp(name, temp->name)) {
            return pos;
        }
        temp = temp->next;
        pos++;
    }

    return -1;
}

int freeReg() {
    for(int i = 0; i < numRegisters; i++) {
        // printf("Register %d: ", i);
        int isEmpty = 1;
        for(int j = 0; j < sizeOfSymbolTable; j++) {
            // printf("%d, ", regDesc[i].hasVar[j]);
            if(regDesc[i].hasVar[j]) {
                isEmpty = 0;
                break;
            }
        }
        // printf("\n");
        if(isEmpty) {
            return i;
        }
    }
    return -1;
}

void freeRegForSym(int pos) {
    node* temp = symbolTable;
    int i = 0;
    while (temp) {
        if (i == pos) break;
        temp = temp->next;
        i++;
    }
    for(int j = 0; j < numRegisters; j++) {
        if(temp->registers[j]) {
            temp->registers[j] = 0;
            regDesc[j].hasVar[pos] = 0;
        }
    }
    // printf("DONE FREEING\n");

    temp->isInMemory = 1;
}

void updateReg(char* name, int pos) {
    node* temp = symbolTable;
    while(temp) {
        if(!strcmp(temp->name, name)) {
            temp->registers[pos] = 1;
        }
        temp = temp->next;
    }
}

// int checkInMem() {
//     for(int i = 0; i < numRegisters, i++) {
//         int allInMem = 1;
//         for(int j = 0; j < sizeOfSymbolTable; j++) {
//             if(regDesc[i].hasVar[j] == 1) {
//                 int temp = 0;
//                 node* tempNode = symbolTable;
//                 while(temp != j) {
//                     temp++;
//                     tempNode = tempNode->next;
//                 }
//                 if(tempNode->isInMemory == 0) {
//                     allInMem = 0;
//                     break;
//                 }
//             }
//         }
//         if(allInMem) {
//             for(int j = 0; j < sizeOfSymbolTable; j++) {
//                 if(regDesc[i].hasVar[j] == 1) {
//                     int temp = 0;
//                     node* tempNode = symbolTable;
//                     while(temp != j) {
//                         temp++;
//                         tempNode = tempNode->next;
//                     }
//                     tempNode->registers[i] = 0;
//                 }
//             }
//             return i;
//         }
//     }
//     return -1;
// }

void insertTarget(target* newTarget) {
    emitTarget(newTarget->op, newTarget->arg1, newTarget->arg2, newTarget->result);
}

void insertTargetNew(target* newTarget) {
    target* temp = targetList;
    if(!temp) {
        targetList = newTarget;
        return;
    }
    while(temp->next) {
        temp = temp->next;
    }
    temp->next = newTarget;
}

int getReg(int quadNo, char* name, int blockNo) {
    node *temp = symbolTable;
    int position = 0;

    while (temp) {
        if (!strcmp(name, temp->name)) {
            break;
        }
        temp = temp->next;
        position++;
    }

    int reg = -1;

    // case 1: already in reg 
    for(int i = 0; i < numRegisters; i++) {
        if(regDesc[i].hasVar[position]) {
            reg = i;
            break;
        }
    }

    if(reg != -1) {
        node* temp = symbolTable;
        while(temp) {
            if(!strcmp(temp->name, name)) {
                temp->registers[reg] = 1;
            }
            temp = temp->next;
        }
        // if(blockNo == 7) printf("CASE 1: returned %d\n", reg);
        return reg;
    }

    // case 2: free reg
    if(strcmp("", name)) {
        int freeR = freeReg();
        // printf("FREEEEEEE %d\n", freeR);
        if(freeR != -1) {
            reg = freeR;
            regDesc[reg].hasVar[position] = 1;
        }
    }


    if(reg != -1) {
        node* temp = symbolTable;
        while(temp) {
            if(!strcmp(temp->name, name)) {
                temp->registers[reg] = 1;
                // printf("STORED IN REG %d\n", reg);
            }
            temp = temp->next;
        }
        // if(blockNo == 7) printf("CASE 2: returned %d\n", reg);
        return reg;
    }

    // case 3: all vars in mem
    for(int i = 0; i < numRegisters; i++) {
        int allInMem = 1;
        for(int j = 0; j < sizeOfSymbolTable; j++) {
            if(regDesc[i].hasVar[j]) {
                int pos = 0;
                node* temp = symbolTable;
                while(temp) {
                    if(j == pos) break;
                    temp = temp->next;
                    pos++;
                }

                if(temp->isInMemory == 0) {
                    allInMem = 0;
                    break;
                }  
            }
        }
        if(allInMem) {
            for (int j = 0; j < sizeOfSymbolTable; j++) {
                if (regDesc[i].hasVar[j]) {
                    int pos = 0;
                    node *temp = symbolTable;
                    while (temp) {
                        if (j == pos) break;
                        temp = temp->next;
                        pos++;
                    }
                    temp->registers[i] = 0;
                    int isInReg = 0;
                    for(int i = 0; i < numRegisters; i++) {
                        if(temp->registers[i]) {
                            isInReg = 1;
                            break;
                        }
                    }

                    if(!isInReg) {
                        temp->isInMemory = 1;
                    }
                    regDesc[i].hasVar[j] = 0;
                }
            }
            regDesc[i].hasVar[position] = 1;
            reg = i;
            break;
        }
    }

    if(reg != -1) {
        node* temp = symbolTable;
        while(temp) {
            if(!strcmp(temp->name, name)) {
                temp->registers[reg] = 1;
            }
            temp = temp->next;
        }
        // if(blockNo == 7) printf("CASE 3: returned %d\n", reg);
        return reg;
    }

    // case 4: TODO

    // case 5: all temps not used further in block
    for (int i = 0; i < numRegisters; i++) {
        int hasAllTemps = 1;
        for(int j = 0; j < sizeOfSymbolTable; j++) {
            if(regDesc[i].hasVar[j]) {
                int pos = 0;
                node *temp = symbolTable;
                while (temp) {
                    if (j == pos) break;
                    temp = temp->next;
                    pos++;
                }
                if(temp->name[0] != '$') {
                    hasAllTemps = 0;
                    break;
                }
            }
        }
        if(hasAllTemps) {
            int noFurtherUse = 1;
            quad* tempq = quadList;
            while(tempq && tempq->blockNo <= blockNo) {
                if(tempq->quadNo > quadNo && tempq->blockNo == blockNo) {
                    char* arg1 = strdup(tempq->arg1);
                    char* arg2 = strdup(tempq->arg2);
                    char* result = strdup(tempq->result);

                    int positionArg1 = -1;
                    int positionArg2 = -1;
                    int positionRes = -1;

                    node* temp = symbolTable;
                    int i = 0;
                    while(temp) {
                        if(!strcmp(temp->name, arg1)) {
                            positionArg1 = i;
                        }
                        if(!strcmp(temp->name, arg2)) {
                            positionArg2 = i;
                        }
                        if(!strcmp(temp->name, result)) {
                            positionRes = i;
                        }
                        i++;
                        temp = temp->next;
                    }

                    if(positionArg1 != -1 && regDesc[i].hasVar[positionArg1]) {
                        noFurtherUse = 0;
                        break;
                    }
                    if(positionArg2 != -1 && regDesc[i].hasVar[positionArg2]) {
                        noFurtherUse = 0;
                        break;
                    }
                    if(positionRes != -1 && regDesc[i].hasVar[positionRes]) {
                        noFurtherUse = 0;
                        break;
                    }

                    // free(arg1); free(arg2); free(result);
                }
                tempq = tempq->next;
            }

            if(noFurtherUse) {
                for (int j = 0; j < sizeOfSymbolTable; j++) {
                    if (regDesc[i].hasVar[j]) {
                        int pos = 0;
                        node *temp = symbolTable;
                        while (temp) {
                            if (j == pos) break;
                            temp = temp->next;
                            pos++;
                        }
                        temp->registers[i] = 0;
                        int isInReg = 0;
                        for(int i = 0; i < numRegisters; i++) {
                            if(temp->registers[i]) {
                                isInReg = 1;
                                break;
                            }
                        }

                        if(!isInReg) {
                            temp->isInMemory = 1;
                        }
                        regDesc[i].hasVar[j] = 0;
                    }
                }
                regDesc[i].hasVar[position] = 1;
                reg = i;
                break;
            }
        }
    }
    
    if(reg != -1) {
        node* temp = symbolTable;
        while(temp) {
            if(!strcmp(temp->name, name)) {
                temp->registers[reg] = 1;
            }
            temp = temp->next;
        }
        // if(blockNo == 7) printf("CASE 5: returned %d\n", reg);
        return reg;
    }

    // case 6: score classification
    int minScore = 1e9;
    int regWithMinScore = -1;
    for(int i = 0; i < numRegisters; i++) {
        int score = 0;
        for(int j = 0; j < sizeOfSymbolTable; j++) {
            score += regDesc[i].hasVar[j];
        }
        if(score < minScore) {
            minScore = score;
            regWithMinScore = i;
        }
    }

    for(int i = 0; i < sizeOfSymbolTable; i++) {
        if(regDesc[regWithMinScore].hasVar[i]) {
            int pos = 0;
            node *temp = symbolTable;
            while (temp) {
                if (i == pos) break;
                temp = temp->next;
                pos++;
            }
            temp->registers[regWithMinScore] = 0;
            temp->isInMemory = 1;
            regDesc[regWithMinScore].hasVar[i] = 0;
        }
    }

    reg = regWithMinScore;
    // printf("REG %d\n ", reg);
    regDesc[regWithMinScore].hasVar[position] = 1;

    node* temp1 = symbolTable;
    while(temp1) {
        if(!strcmp(temp1->name, name)) {
            temp1->registers[reg] = 1;
        }
        temp1 = temp1->next;
    }
    // if(blockNo == 7) printf("CASE 6: returned %d\n", reg);
    return reg;
}

target* createTarget(char* op, char* arg1, char* arg2, char* result) {
    target* newTarget = (target*)malloc(sizeof(target));
    newTarget->op = strdup(op);
    newTarget->arg1 = strdup(arg1);
    newTarget->arg2 = strdup(arg2);
    newTarget->result = strdup(result);
    // newTarget->blockNo = 0;
    // newTarget->targetNo = ++targetInstrNo;
    // newTarget->next = NULL;
    return newTarget;
}

// void createTargetList(quad* head) {
//     int blockNo = head->blockNo;
//     int quadNo = head->quadNo;

//     int positionArg1 = -1;
//     int positionArg2 = -1;
//     int positionRes = -1;
//     // printf("%s, %s, %s\n", head->arg1, head->arg2, head->result);
//     target* res;
//     node* temp = symbolTable;
//     int i = 0;
//     while(temp) {
//         if(!strcmp(temp->name, head->arg1)) {
//             positionArg1 = i;
//         }
//         if(!strcmp(temp->name, head->arg2)) {
//             positionArg2 = i;
//         }
//         if(!strcmp(temp->name, head->result)) {
//             positionRes = i;
//         }
//         i++;
//         temp = temp->next;
//     }
    
// }

void convertToTarget(quad* head) {
    // printf("BRUH\n");
    // printf("%s, %s, %s\n", head->arg1, head->arg2, head->result);
    // char* arg1 = strdup(head->arg1);
    // char* arg2 = strdup(head->arg2);
    // char* result = strdup(head->result);
    // char* op = strdup(head->op);
    int blockNo = head->blockNo;
    int quadNo = head->quadNo;

    int positionArg1 = -1;
    int positionArg2 = -1;
    int positionRes = -1;
    // printf("%s, %s, %s\n", head->arg1, head->arg2, head->result);
    target* res;
    node* temp = symbolTable;
    int i = 0;
    while(temp) {
        if(!strcmp(temp->name, head->arg1)) {
            positionArg1 = i;
        }
        if(!strcmp(temp->name, head->arg2)) {
            positionArg2 = i;
        }
        if(!strcmp(temp->name, head->result)) {
            positionRes = i;
        }
        i++;
        temp = temp->next;
    }
    // printf("done\n");
    // printf("%d, %d, %d\n", positionArg1, positionArg2, positionRes);

    if(!strcmp(head->op, "=")) {
        if(positionArg1 != -1) {
            // printf("BLAAAA1\n");
            int src1 = getReg(quadNo, head->arg1, blockNo);
            freeRegForSym(positionRes);
            regDesc[src1].hasVar[positionRes] = 1;
            updateReg(head->result, src1);
            node* temp1 = symbolTable;
            int pos = 0;
            while(temp1) {
                if(pos == positionRes) {
                    break;
                }
                temp1 = temp1->next;
                pos++;
            }
            temp1->isInMemory = 0;
            insertToBeStored(positionRes);
            // printf("BLASS1\n");
        } else {
            // printf("BLAAAA2\n");
            int dest = getReg(quadNo, head->result, blockNo);
            // printf("BLAAAA2.5\n");
            freeRegForSym(positionRes);
            // printf("BLAAAA2.6\n");
            regDesc[dest].hasVar[positionRes] = 1;
            updateReg(head->result, dest);
            // printf("BLAAAA2.7\n");
            char* temp2 = (char*)malloc(50);
            // printf("BLAAAA2.75\n");
            sprintf(temp2, "R%d", dest + 1);
            // printf("BLAAAA2.76\n");
            emitTarget("LDI", temp2, "", head->arg1);
            // printf("BLAAAA2.8\n");
            insertToBeStored(positionRes);
            // printf("BLASS2\n");
        }
    } else if(head->op[0] == 'i') {
        // printf("BLAAAA3\n");
        int src1 = -1;
        char* temp1 = (char*)malloc(50);
        if(positionArg1 != -1) {
            src1 = getReg(quadNo, head->arg1, blockNo);
            sprintf(temp1, "R%d", src1 + 1);
            if(head->arg1[0] != '$') {
                res = createTarget("LD", temp1, "", head->arg1);
                insertTargetNew(res);
            }
        } else {
            sprintf(temp1, "%s", head->arg1);
        }

        int src2 = -1;
        char* temp2 = (char*)malloc(50);
        if(positionArg2 != -1) {
            src2 = getReg(quadNo, head->arg2, quadNo);
            sprintf(temp2, "R%d", src2 + 1);
            if(head->arg2[0] != '$') {
                res = createTarget("LD", temp2, "", head->arg2);
                insertTargetNew(res);
            }
        } else {
            sprintf(temp2, "%s", head->arg2);
        }

        if(!strcmp(head->op, "iffalse ==")) {
            res = createTarget("JNE", temp1, temp2, head->result);
            insertTargetNew(res);
        } else if(!strcmp(head->op, "iffalse !=")) {
            res = createTarget("JEQ", temp1, temp2, head->result);
            insertTargetNew(res);
        } else if(!strcmp(head->op, "iffalse <")) {
            res = createTarget("JGE", temp1, temp2, head->result);
            insertTargetNew(res);
        } else if(!strcmp(head->op, "iffalse >")) {
            res = createTarget("JLE", temp1, temp2, head->result);
            insertTargetNew(res);
        } else if(!strcmp(head->op, "iffalse <=")) {
            res = createTarget("JGT", temp1, temp2, head->result);
            insertTargetNew(res);
        } else if(!strcmp(head->op, "iffalse >=")) {
            res = createTarget("JLT", temp1, temp2, head->result);
            insertTargetNew(res);
        }
        // printf("BLASS3\n");
    } else if(!strcmp(head->op, "goto")) {
        // printf("BLAAAA4\n");
        res = createTarget("JMP", "", "", head->result);
        insertTargetNew(res);
        // printf("BLASS4\n");
    } else {
        // printf("BLAAAA5\n");
        int src1 = -1;
        char* temp1 = (char*)malloc(50);
        if(positionArg1 != -1) {
            src1 = getReg(quadNo, head->arg1, blockNo);
            sprintf(temp1, "R%d", src1 + 1);
            if(head->arg1[0] != '$') {
                emitTarget("LD", temp1, "", head->arg1);
            }
        } else {
            sprintf(temp1, "%s", head->arg1);
        }

        int src2 = -1;
        char* temp2 = (char*)malloc(50);
        if(positionArg2 != -1) {
            src2 = getReg(quadNo, head->arg2, quadNo);
            sprintf(temp2, "R%d", src2 + 1);
            if(head->arg2[0] != '$') {
                emitTarget("LD", temp2, "", head->arg2);
            }
        } else {
            sprintf(temp2, "%s", head->arg2);
        }

        int dest;
        char* temp3 = (char*)malloc(50);
        if(!strcmp(head->result, head->arg1)) {
            dest = src1;
        } else if(!strcmp(head->result, head->arg2)) {
            dest = src2;
        } else {
            dest = getReg(quadNo, head->result, blockNo);
        }

        freeRegForSym(positionRes);
        regDesc[dest].hasVar[positionRes] = 1;
        updateReg(head->result, dest);
        sprintf(temp3, "R%d", dest + 1);

        if(!strcmp(head->op, "+")) {
            emitTarget("ADD", temp1, temp2, temp3);
        } else if(!strcmp(head->op, "-")) {
            emitTarget("SUB", temp1, temp2, temp3);
        } else if(!strcmp(head->op, "*")) {
            emitTarget("MUL", temp1, temp2, temp3);
        } else if(!strcmp(head->op, "/")) {
            emitTarget("DIV", temp1, temp2, temp3);
        } else if(!strcmp(head->op, "%")) {
            emitTarget("REM", temp1, temp2, temp3);
        }

        insertToBeStored(positionRes);
        // printf("BLASS5\n");
    }
    // free(arg1); free(arg2); free(result); free(op);
}

void backpatchTarget() {
    target* temp = T;
    while(temp) {
        if(temp->op[0] == 'J') {
            int quadNo = atoi(temp->result);
            int targetNo = 1;
            for(int i = 0; i <= blockNo; i++) {
                if(leaders[i].quadNo == quadNo) {
                    targetNo = leaders[i].targetNo;
                    break;
                }
            }

            char* temp1 = (char*)malloc(50);
            sprintf(temp1, "%d", targetNo);
            temp->result = strdup(temp1);
        }
        temp = temp->next;
    }
}    

int main(int argc, char* argv[]) {
    if(argc == 2) {
        numRegisters = atoi(argv[1]);
    }
    // printf("Number of registers: %d\n", numRegisters);
    yyparse();
    createBlocks();

    FILE *intcode_file = fopen("output_intcode.txt", "w");
    FILE *target_file = fopen("output_target.txt", "w");

    quad* temp = quadList;
    while(temp) {
        if(temp->isLeader) {
            if(blockNo != 1){
                fprintf(intcode_file, "\nBlock %d\n", blockNo++);
            }
            else fprintf(intcode_file, "Block %d\n", blockNo++);
        }
        temp->blockNo = blockNo;
        /* printf("BLOCK: %d\n", temp->blockNo); */
        if(temp->op[0] == 'i') {
            char* op_ = (char*)calloc(4, sizeof(char));
            if (strlen(temp->op) >= 8) {
                for (int i = 8; i < strlen(temp->op); i++) {
                    op_[i - 8] = temp->op[i];
                }
            }
            fprintf(intcode_file, "    %-4d: iffalse (%s %s %s) goto %s\n", temp->quadNo, temp->arg1, op_, temp->arg2, temp->result);
            free(op_);
        }
        else if (!strcmp("goto", temp->op)) {
            fprintf(intcode_file, "    %-4d: %s %s\n", temp->quadNo, temp->op, temp->result);
        } else if (!strcmp("=", temp->op)) {
            fprintf(intcode_file, "    %-4d: %s %s %s\n", temp->quadNo, temp->result, temp->op, temp->arg1);
        } else if (!strcmp("", temp->op)) {
            fprintf(intcode_file, "    %-4d: \n", temp->quadNo);
        } else {
            fprintf(intcode_file, "    %-4d: %s = %s %s %s\n", temp->quadNo, temp->result, temp->arg1, temp->op, temp->arg2);
        }
        temp = temp->next;
    }
    fprintf(intcode_file, "\n    %-5d: \n", instrNo + 1);
    fclose(intcode_file);
    /* printf("%d\n", numRegisters); */

    node* temp1 = symbolTable;
    while(temp1) {
        temp1->registers = (int*)malloc(numRegisters * sizeof(int));
        for(int i = 0; i < numRegisters; i++) {
            temp1->registers[i] = 0;
        }
        temp1 = temp1->next;
    }

    /* printf("YUHH\n"); */

    initReg();
    /* printf("YUHH\n"); */

    /* printf("CURRBLOCK: %d\n", blockNo); */
    leaders = (leaderDesc*)malloc((blockNo + 1) * sizeof(leaderDesc));
    temp = quadList;
    int cnt = 0;

    emit("", "", "", "");

    while(temp) {
        if(temp->isLeader) {
            leaders[cnt++].quadNo = temp->quadNo;
        }
        temp = temp->next;
    }

    /* printf("YUHH\n"); */

    /* printf("\n");
    printf("Symbol Table\n");
    node* temp100 = symbolTable;
    while(temp100) {
        printf("%s\n", temp100->name);
        temp100 = temp100->next;
    }
    printf("\n"); */

    cnt = 0;
    quad* temp2 = quadList;

    while(temp2->next) {
        if(temp2->isLeader) {
            /* printf("LEADER\n"); */
            leaders[cnt++].targetNo = targetInstrNo + 1;
    /* printf("YUHH\n"); */

        }
        convertToTarget(temp2);

        if(!temp2->next->next) {
            storeList* temp10 = toBeStored;
            /* storeList* temp69 = toBeStored;
            printf("BLOCK NO: %d\n", temp2->blockNo);
            printf("TO BE STORED: \n");
            while(temp69) {
                printf("%d ", temp69->num);
                temp69 = temp69->next;
            }
            printf("\n\n"); */
            while(temp10) {
                node* symbol = symbolTable;
                int i = 0;
                while(i != temp10->num) {
                    symbol = symbol->next;
                    i++;
                }
                int symbolPos = 0;
                node* symbol2 = symbolTable;
                while(symbol2) {
                    if(!strcmp(symbol->name, symbol2->name)) {
                        break;
                    }
                    symbolPos++;
                    symbol2 = symbol2->next;
                }


                if(symbol->name[0] != '$') {
                    /* printf("register contents\n"); */
                    /* for(int m = 0; m < numRegisters; m++) {
                        printf("%d", symbol->registers[m]);

                    } */
                    /* printf("STORE %s\n", symbol->name);
                    printf("POS %d\n", symbolPos); */
                    int reg = -1;
                    for(int i1 = 0; i1 < numRegisters; i1++) {
                        /* printf("REG %d\n", i1); */
                        if(symbol->registers[i1]) {
                            reg = i1;
                            break;
                        }
                    }
                    /* printf("STORE RG: %d\n", reg); */

                    char* temp5 = (char*)malloc(50);
                    sprintf(temp5, "R%d", reg + 1);
                    emitTarget("ST", temp5, "", symbol->name);
                }
                freeRegForSym(symbolPos);
                temp10 = temp10->next;
            }

            for(int i = 0; i < numRegisters; i++) {
                for(int j = 0; j < sizeOfSymbolTable; j++) {
                    regDesc[i].hasVar[j] = 0;
                }
            }
            toBeStored = deleteToBeStored();
        } else if(temp2->next && (temp2->blockNo != temp2->next->blockNo)) {
            storeList* temp10 = toBeStored;
            while(temp10) {
                node* symbol = symbolTable;
                int i = 0;
                while(i != temp10->num) {
                    symbol = symbol->next;
                    i++;
                }
                int symbolPos = 0;
                node* symbol2 = symbolTable;
                while(symbol2) {
                    if(!strcmp(symbol->name, symbol2->name)) {
                        break;
                    }
                    symbolPos++;
                    symbol2 = symbol2->next;
                }


                if(symbol->name[0] != '$') {
                    /* printf("register contents\n"); */
                    /* for(int m = 0; m < numRegisters; m++) {
                        printf("%d", symbol->registers[m]);

                    } */
                    /* printf("STORE %s\n", symbol->name);
                    printf("POS %d\n", symbolPos); */
                    int reg = -1;
                    for(int i1 = 0; i1 < numRegisters; i1++) {
                        /* printf("REG %d\n", i1); */
                        if(symbol->registers[i1]) {
                            reg = i1;
                            break;
                        }
                    }
                    /* printf("STORE RG: %d\n", reg); */

                    char* temp5 = (char*)malloc(50);
                    sprintf(temp5, "R%d", reg + 1);
                    emitTarget("ST", temp5, "", symbol->name);
                }
                freeRegForSym(symbolPos);
                temp10 = temp10->next;
            }

            for(int i = 0; i < numRegisters; i++) {
                for(int j = 0; j < sizeOfSymbolTable; j++) {
                    regDesc[i].hasVar[j] = 0;
                }
            }
            toBeStored = deleteToBeStored();
        }

        if(temp2->op[0] == 'i' || !strcmp("goto", temp2->op)) {
            /* printf("HAAAAAAAAAAAAAAAA %s\n", temp2->op); */
            target* res = targetList;
            while(res) {
                insertTarget(res);
                res = res->next;
            }
            targetList = NULL;
        }
        temp2 = temp2->next;
    }
    emitTarget("", "", "", "");
    leaders[blockNo].targetNo = targetInstrNo;
    leaders[blockNo].quadNo = instrNo;

    backpatchTarget();
    // printf("\n");
    target* temp3 = T;
    int blockNoTarget = 0;

    /* for(int i = 0; i < blockNo + 1; i++) {
        printf("%d", leaders[i].quadNo);
        printf(" %d\n", leaders[i].targetNo);
    } */

    while(temp3) {
        for(int i = 0; i < blockNo; i++) {
            if(leaders[i].targetNo == temp3->targetNo) {
                if(blockNoTarget == 0) {
                    fprintf(target_file, "Block %d\n", ++blockNoTarget);
                }
                else fprintf(target_file, "\nBlock %d\n", ++blockNoTarget);
            }
        }
        if(!strcmp("", temp3->op)) {
            fprintf(target_file, "\n    %-4d: \n", temp3->targetNo);
        } else if(!strcmp("ST", temp3->op)) {
            fprintf(target_file, "    %-4d: %s %s %s\n", temp3->targetNo, temp3->op, temp3->result, temp3->arg1);
        } else if(!strcmp(temp3->op, "JMP")) {
            fprintf(target_file, "    %-4d: %s %s\n", temp3->targetNo, temp3->op, temp3->result);
        } else if(temp3->op[0] == 'J') {
            fprintf(target_file, "    %-4d: %s %s %s %s\n", temp3->targetNo, temp3->op, temp3->arg1, temp3->arg2, temp3->result);
        } else if(temp3->op[0] == 'L') {
            fprintf(target_file, "    %-4d: %s %s %s\n", temp3->targetNo, temp3->op, temp3->arg1, temp3->result);
        } else {
            fprintf(target_file, "    %-4d: %s %s %s %s\n", temp3->targetNo, temp3->op, temp3->result, temp3->arg1, temp3->arg2);
        }

        temp3 = temp3->next;
    }

    fclose(target_file);
    return 0;
}
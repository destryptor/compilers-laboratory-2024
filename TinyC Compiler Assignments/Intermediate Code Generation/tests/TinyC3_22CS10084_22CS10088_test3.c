//comment for testing
int main() {
    int l1, l2, l3;
    l3 = 40;
    l2 = 90;
    l1 = 56;
    if (l1 != 0 && l2 != 0) {
        l3 = l1 + l2 + 4;
    }
    while (l3 > 0) {
        if (l1 == 0 || l2 == 0) {
            int temp = l1+l2;
            l1 += l3;
        }
        l1 = l3 >> l2;
        l2 = l1 << l1;
    }
    return 0;
}
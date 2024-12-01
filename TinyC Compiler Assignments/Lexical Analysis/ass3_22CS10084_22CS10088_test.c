
// Single-line comment: Test single-line comment

/*
  Multi-line comment:
  This is a test for multi-line comment.
*/

// Keywords
auto intVar = 10;
extern float externVar;
static int staticVar = 20;
void functionName(void);
volatile int volatileVar;

// Identifiers
int main() {
    // Constants
    int integerConst = 100;
    float floatingConst = 10.5e-2;
    char charConst = 'a';
    const char* strLiteral = "This is a string literal";

    // Punctuators
    int a = 5, b = 10;
    int c = a + b;
    c++;
    c *= 2;
    if (a < b) {
        a = b;
    } else {
        b = a;
    }

    // Comments to test multi-line and single-line comments
    /* Multi-line comment:
       Continuing the multi-line comment.
    */
    // Single-line comment again

    // Keyword usage in control structures
    while (a > 0) {
        a--;
    }

    for (int i = 0; i < 5; i++) {
        continue;
    }

    if (a == b) {
        return 1;
    } else {
        return 0;
    }
}

void functionName(void) {
    // More examples of different lexical elements
    long long int largeInt = 1234567890LL;
    double largeFloat = 1.23e45;
    char anotherChar = 'b';
    const char* anotherStr = "Another string literal";

    enum colors { RED, GREEN, BLUE };
    enum colors color = RED;

    int* pointerVar = &largeInt;
    *pointerVar = 42;

    printf("Color: %d, String: %s\n", color, anotherStr);
}

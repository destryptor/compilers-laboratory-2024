/*
    Test File for Tiny C Parser
    Made by: Sharanya Chakraborty (22CS10088), Shiva Chaitanya (22CS10084)
*/

void swap(int* x, int* y)
{
    int temp = *x;
    *x = *y;
    *y = temp;

    return;
}

int ispow2(int x)
{
    return x && (!(x & (x - 1)));
}

int numDig(int x)
{
    return floor(log10(x)) + 1;
}

int MSD(int x)
{
    return x / pow(10, numDig(x) - 1);
}

int GCD(int x, int y)
{
    return y == 0 ? x : GCD(y, x % y);
}

int LCM(int x, int y)
{
    return x * y / GCD(x, y);
}

int fact(int x)
{
    return (x == 1 || x == 0) ? 1 : x * fact(x - 1);
}

int nCr(int n, int r)
{
    return fact(n) / (fact(r) * fact(n - r));
}

int nPr(int n, int r)
{
    return fact(n) / fact(n - r);
}

int power(int x, int y)
{
    int res = 1;
    x = x % 100000009;
    if (x == 0)
        return 0;
    while (y > 0)
    {
        if (y & 1)
            res = (res * x) % 100000009;
        y = y >> 1;
        x = (x * x) % 100000009;
    }
    return res;
}

int modInverse(int x)
{
    return power(x, 100000007);
}

int modDivide(int x, int y)
{
    return (x * modInverse(y)) % 100000009;
}

int main()
{
    int a = 6;
    float b = 9.0;
    auto c = a * b;

    a = a >> 1;
    c += 2;
    a -= 3;
    c *= 4;

    a++;

    int x = a & c;
    x = a | c;
    x = a ^ c;

    long long int d = 1e9;
    d /= 1000;
    short int e = 1;

    double f = 1.0;
    long double g;

    
    g = 1.0e-10;

    char* str = "Welcome to the test file";
    char h = 'z';

    do {
        a++;
    } while (a < 10);

    while (a < 10)
    {
        a++;
    }

    for (int i = 0; i < 10; i++)
    {
        continue;
    }

    if (a == 10)
    {
        a = b;
    }
    else
    {
        a = c;
    }

    int x, y;

    x = 10;
    y = 20;

    x = x && y;
    x = x || y;
    x = !y;
    x = x < y;
    x = x > y;
    x = x <= y;
    x = x >= y;
    x = x == y;
    x = x != y;
    x = x << y;
    x = x >> y;

    return 0;
}
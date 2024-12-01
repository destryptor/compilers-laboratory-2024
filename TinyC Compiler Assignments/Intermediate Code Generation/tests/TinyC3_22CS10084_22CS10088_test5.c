int main() {
    int *n1, *n2, *n3;
    int a,b;
    n1=&a;
    n2=&b;
    n1=n2;
    n3=&b;
    int c;
    float d;
    c=a*d;
    d=c*a;
    float s=(a+b+c)/2.0;
    float halfareasquare;
    halfareasquare = (s*(s-a)*(s-b)*(s-c))/2.0;
    int y=0;
    if(a+b>c && b+c>a && c+a>b)
    {
        y=1;
    }
    else
    {
        y=-1;
    }
    return 0;
}
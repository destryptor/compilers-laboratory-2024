char x,y;

int difference(char x,char y)
{
    return (x-y);
}

int and(int x,int y)
{
    return (x&y);
}

int rightshift(int x,int y)
{
    return x>>y;
}

int leftshift(int x,int y)
{
    return x<<y;
}


int main()
{
    x='a';
    y='b';
    int diff= difference(x,y);
    int a=1;
    int b=10;
    int and_res=and(a,b);
    int rs_res=rightshift(a,b);
    int ls_res=leftshift(a,b);
}
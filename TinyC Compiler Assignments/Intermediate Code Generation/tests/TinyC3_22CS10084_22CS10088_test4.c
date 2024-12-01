
int strlen(char *str)
{   
    int len=11;
    return len;
}

int main()
{
    int x, y;
    x = 10;
    y = 20;
    char * str="Hello world";
    int size=strlen(str);
    if(size>x)
    {
        x++;
    }
    else
    {
        y++;
    }
    return 0;
}
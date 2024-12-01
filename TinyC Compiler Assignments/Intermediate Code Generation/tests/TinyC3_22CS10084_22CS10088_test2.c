

int find_max(int a[],int n)
{   
    int max=-1;
    int i;
    for(i=0;i<n;i++)
    {
        if(a[i]>max)max=a[i];
    }
    return max;
}

int find_min(int a[],int n)
{
    int min=10000;
    int i;
    for(i=0;i<n;i++)
    {
        if(a[i]<min)min=a[i];
    }
    return min;
}

int find_sum(int *a,int n)
{
    int sum=0;
    int i;
    for(i=0;i<n;i++)
    {
        sum+=a[i];
    }
    return sum;
}


int main()
{   
    int a[100];
    int minval=find_min(a,100);
    int maxval=find_max(a,100);
    int sumval=find_sum(a,100);

}
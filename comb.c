void comb(int m,int k)
{
    int i,j,l;
    int finished=0;/*是否列举完毕标志 */
    for(i=0;i<k;i++)
	C[i]=i+1;
    for(i=0;i<k;i++)
	printf("%d ",C[i]);
    printf("");

    while(!finished)
    {
	j=k-1;
	while(C[j]>=m-k+j+1)j--;/*自后向前寻找第一个不够大的数的下标*/
	l=C[j];
	for(i=j;i<k;i++)
	{/*从寻找到的下标处始,后面的元素都比前面元素大1*/
	    C[i]=l+i-j+1;

	}
	for(i=0;i<k;i++)
	    printf("%d ",C[i]);
	printf("");
	if(C[0]==m-k+1)finished=1;/*循环结束条件*/

    }
}


void comb(int m,int k)
{
    int i,j,l;
    int finished=0;/*�Ƿ��о���ϱ�־ */
    for(i=0;i<k;i++)
	C[i]=i+1;
    for(i=0;i<k;i++)
	printf("%d ",C[i]);
    printf("");

    while(!finished)
    {
	j=k-1;
	while(C[j]>=m-k+j+1)j--;/*�Ժ���ǰѰ�ҵ�һ��������������±�*/
	l=C[j];
	for(i=j;i<k;i++)
	{/*��Ѱ�ҵ����±괦ʼ,�����Ԫ�ض���ǰ��Ԫ�ش�1*/
	    C[i]=l+i-j+1;

	}
	for(i=0;i<k;i++)
	    printf("%d ",C[i]);
	printf("");
	if(C[0]==m-k+1)finished=1;/*ѭ����������*/

    }
}


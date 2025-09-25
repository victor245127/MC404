#include <stdio.h>

char inbuf[12];
char outbuf[36];

int dec(char *inbuf){
    int num = 0, pos = 0, i = 1;
    if (inbuf[0] != '-') pos = 1, i = 0;
    while (inbuf[i] >= '0' && inbuf[i] <= '9') num = num * 10 + (inbuf[i]-'0'), i++;
    if (!pos) return -num;
    return num;
}

int dec_to_bin(int num, char *outbuf){
    outbuf[0] = '0';
    outbuf[1] = 'b';
    unsigned int mask = 1 << 31;
    int i, contagem = 0;
    for (i = 2; i < 34; i++) outbuf[i] = (num & mask) ? '1' : '0', mask>>=1;
    outbuf[34] = '\n';
    for (i = 2; i < 34 && outbuf[i] != '1'; i++) contagem++;
    for (i = 2; i < 34 && outbuf[i] != '\n'; i++) outbuf[i] = outbuf[i+contagem]; 
    outbuf[i] = '\n';
    outbuf[i+1] = '\0'; 
    return i+1;
}

int dec_to_hex(int num, char *outbuf){
    outbuf[0] = '0';
    outbuf[1] = 'x';
    int i, contagem = 8, nibble;
    for (i = 2; i < contagem+2; i++){
        nibble = (num >> (4*(contagem-i+1))) & 0xF;
        if (nibble < 10) outbuf[i] = nibble + '0';
        else outbuf[i] = (nibble-10) + 'a';
    }
    outbuf[i] = '\n';
    for (i = 2, contagem = 0; i < 34 && outbuf[i] == '0'; i++) contagem++;
    for (i = 2; i < 34 && outbuf[i] != '\n'; i++) outbuf[i] = outbuf[i+contagem];
    outbuf[i] = '\n';
    outbuf[i+1] = '\0';
    return i+1;
}

int hex_to_dec(char *inbuf, char *outbuf){
    int div = 1, num = 0, bit;
    int i;
    for (i = 3; i < 11 && ((inbuf[i] >= '0' && inbuf[i] <= '9') || (inbuf[i] >= 'a' && inbuf[i] <= 'f')); i++) div*=16;
    for (i = 2; i < 11 && div; i++) 
    {
      bit = (inbuf[i] >= 'a' && inbuf[i] <= 'f') ? (inbuf[i]-'a'+10) : (inbuf[i]-'0');
      num += bit*div;
      div/=16;
    }
    i=0;
    while (num != 0) outbuf[i++] = num % 10 + '0', num/=10;
    char temp;
    for (int j = 0, k = i - 1; j < k; j++, k--) {
        temp = outbuf[j];
        outbuf[j] = outbuf[k];
        outbuf[k] = temp;
    }
    outbuf[i] = '\n';
    outbuf[i+1] = '\0';
    return i+1;
}

int hex_to_bin(char *inbuf, char *outbuf){
    int x = hex_to_dec(inbuf, outbuf);
    return dec_to_bin(dec(outbuf), outbuf);
}

int endian_swap(unsigned int *num, char *outbuf) {
    unsigned int n = *num;
    *num = ((n >> 24) & 0x000000FF) |
            ((n >> 8)  & 0x0000FF00) |
            ((n << 8)  & 0x00FF0000) |
            ((n << 24) & 0xFF000000);
    int i=0;
    n = *num;
    char temp;
    while (n > 0) outbuf[i++] = (n % 10) + '0', n/=10; 
    for (int j = 0, k = i - 1; j < k; j++, k--) {
        temp = outbuf[j];
        outbuf[j] = outbuf[k];
        outbuf[k] = temp;
    }
    outbuf[i] = '\n';
    outbuf[i+1] = '\0';
    return i+1;
}

int main()
{
    char inbuf[12];
    char outbuf[40];
    scanf("%s", inbuf);
    //int n = dec(inbuf);
    //unsigned int un = (unsigned int) n;
    int num = hex_to_dec(inbuf, outbuf);
    return 0;
}

// testes: 2 3 5 7 8 9 10
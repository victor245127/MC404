#include <stdio.h>

int str_to_int(char *inbuf, int *index_i){
    int num = 0, pos = 0, index_f = *index_i+4;
    if (inbuf[*index_i] == '+') pos = 1;
    *index_i += 1;
    while (*index_i <= index_f) num = num * 10 + (inbuf[*index_i]-'0'), (*index_i)++;
    if (!pos) return -num;
    return num;
}

unsigned int int_shift(int *num){
    unsigned int i = 0, mask = 0xFFE00000;
    i = ((num[4] << 21) & mask);
    mask = 0x001F0000;
    i = ((num[3] << 16) & mask) | i;
    mask = 0x0000F800;
    i = ((num[2] << 11) & mask) | i;
    mask = 0x000007FC;
    i = ((num[1] << 3) & mask) | i;
    mask = 0x00000007;
    i = (num[0] & mask) | i;
    return i;
}

int main(){
    char inbuf[30];
    int nums[5];
    scanf("%[^\n]", inbuf);
    inbuf[29] = '\n';
    for (int i = 0, j = 0; i < 5; i++, j++) nums[i] = str_to_int(inbuf, &j);
    unsigned int shift = int_shift(nums);
    printf("%u", shift);
    return 0;
}

// 0111 1101 0001 1110 1100 1111 1111 0011
//              i      i     i         i
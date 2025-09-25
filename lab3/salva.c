int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (93) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}

#define STDIN_FD  0
#define STDOUT_FD 1

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
    int div = 1, num = 0, bit, i, j;
    for (i = 3; i < 11 && ((inbuf[i] >= '0' && inbuf[i] <= '9') || (inbuf[i] >= 'a' && inbuf[i] <= 'f')); i++) div*=16;
    for (i = 2; i < 11 && div; i++) 
    {
      bit = (inbuf[i] >= 'a' && inbuf[i] <= 'f') ? (inbuf[i]-'a'+10) : (inbuf[i]-'0');
      num += bit*div;
      div/=16;
    }
    if (num < 0) num = -num, i = 1, j = 1, outbuf[0] = '-';
    else i=0, j = 0;
    while (num != 0) outbuf[i++] = num % 10 + '0', num/=10;
    char temp;
    for (int k = i - 1; j < k; j++, k--) {
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
  int n = read(STDIN_FD, inbuf, 11), b;
  inbuf[n] = '\0';
  if (inbuf[0] != '0' || inbuf[1] != 'x') {
        int num = dec(inbuf);
        b = dec_to_bin(num, outbuf);
        write(STDOUT_FD, outbuf, b);

        write(STDOUT_FD, inbuf, n);

        b = dec_to_hex(num, outbuf);
        write(STDOUT_FD, outbuf, b);

        unsigned int unum = (unsigned int) num;
        b = endian_swap(&unum, outbuf);
        write(STDOUT_FD, outbuf, b);
    } else {
        b = hex_to_bin(inbuf, outbuf);
        write(STDOUT_FD, outbuf, b);

        b = hex_to_dec(inbuf, outbuf);
        write(STDOUT_FD, outbuf, b);

        write(STDOUT_FD, inbuf, n); 
        
        unsigned int num = (unsigned int) dec(outbuf);
        b = endian_swap(&num, outbuf);
        write(STDOUT_FD, outbuf, b);
    }
  return 0;
}

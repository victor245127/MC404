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

void hex_code(unsigned int val){
    char hex[11];
    unsigned int aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = val % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        val = val / 16;
    }
    write(1, hex, 11);
} // Função hexcode converte inteiro sem sinal para hexadecimal

int str_to_int(char *inbuf, int *index_i){
    int num = 0, pos = 0, index_f = *index_i+4;
    if (inbuf[*index_i] == '+') pos = 1;
    *index_i += 1;
    while (*index_i <= index_f) num = num * 10 + (inbuf[*index_i]-'0'), (*index_i)++;
    if (!pos) return -num;
    return num;
} // Função que converte string para inteiro

unsigned int int_shift(int *num){
  // Máscara sempre possui 1 apenas nos dígitos a receberem shift
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
} // Função que faz as operações exigidas usando máscara de bits e desempacotamento

#define STDIN_FD  0
#define STDOUT_FD 1

char inbuf[30];

int main(){
  int n = read(STDIN_FD, inbuf, 30);
  inbuf[n] = '\n';
  int numeros[5]; // Array dos números presentes na string
  for (int i = 0, j = 0; i < 5; i++, j++) numeros[i] = str_to_int(inbuf, &j);
  unsigned int num = int_shift(numeros);
  hex_code(num);
  return 0;
}
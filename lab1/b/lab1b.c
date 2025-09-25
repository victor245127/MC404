int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
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
    "li a7, 93           # syscall exit (64) \n"
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

char input_buffer[6];
char output_buffer[2];

int main()
{
  int num_bytes = read(STDIN_FD, (void*) input_buffer, 6);

  int calc, s1 = input_buffer[0] - '0', s2 = input_buffer[4] - '0';
  char op = input_buffer[2];

  switch (op){
  case '+':
    calc = s1 + s2;
    break;
  case '-':
    calc = s1 - s2;
    break;
  case '*':
    calc = s1 * s2;
    break;
  default:
    break;
  }

  output_buffer[0] = (char)(calc + '0');

  output_buffer[1] = '\n';
  write(STDOUT_FD, output_buffer, 2);

  return 0;
}

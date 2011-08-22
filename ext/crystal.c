#include <stdio.h>
#include <math.h>

long crystal_class_object_id(long x) { return x; }

int crystal_eq_bool(int x, int y) { return x == y; }
int crystal_and_bool_bool(int x, int y) { return x & y; }
int crystal_or_bool_bool(int x, int y) { return x | y; }
int crystal_xor_bool_bool(int x, int y) { return x ^ y; }

int crystal_add_int_int(int x, int y) { return x + y; }
int crystal_sub_int_int(int x, int y) { return x - y; }
int crystal_mul_int_int(int x, int y) { return x * y; }
int crystal_div_int_int(int x, int y) { return x / y; }
int crystal_lt_int_int(int x, int y) { return x < y; }
int crystal_let_int_int(int x, int y) { return x <= y; }
int crystal_eq_int_int(int x, int y) { return x == y; }
int crystal_shl_int_int(int x, int y) { return x << y; }
int crystal_shr_int_int(int x, int y) { return x >> y; }
int crystal_mod_int_int(int x, int y) { return x % y; }
int crystal_and_int_int(int x, int y) { return x & y; }
int crystal_or_int_int(int x, int y) { return x | y; }
int crystal_xor_int_int(int x, int y) { return x ^ y; }
int crystal_pow_int_int(int x, int y) { return (int) pow(x, y); }

long crystal_eq_long_long(long x, long y) { return x == y; }

float crystal_add_float_float(float x, float y) { return x + y; }
float crystal_sub_float_float(float x, float y) { return x - y; }
float crystal_mul_float_float(float x, float y) { return x * y; }
float crystal_div_float_float(float x, float y) { return x / y; }
int crystal_lt_float_float(float x, float y) { return x < y; }
int crystal_let_float_float(float x, float y) { return x <= y; }
int crystal_eq_float_float(float x, float y) { return x == y; }

float crystal_add_int_float(int x, float y) { return x + y; }
float crystal_sub_int_float(int x, float y) { return x - y; }
float crystal_sub_float_int(float x, int y) { return x - y; }
float crystal_mul_int_float(int x, float y) { return x * y; }
float crystal_div_int_float(int x, float y) { return x / y; }
float crystal_div_float_int(float x, int y) { return x / y; }
int crystal_lt_float_int(float x, int y) { return x < y; }
int crystal_lt_int_float(int x, float y) { return x < y; }
int crystal_let_float_int(float x, int y) { return x <= y; }
int crystal_let_int_float(int x, float y) { return x <= y; }
int crystal_eq_int_float(int x, float y) { return x == y; }

char crystal_eq_char_char(char x, char y) { return x == y; }

void puts_bool(int x) {
  if (x == 0) {
    printf("false\n");
  } else {
    printf("true\n");
  }
}

void puts_char(char x) {
  printf("%c\n", x);
}

void puts_int(int x) {
  printf("%d\n", x);
}

void puts_float(float x) {
  printf("%f\n", x);
}

void print_bool(int x) {
  if (x == 0) {
    printf("true");
  } else {
    printf("false");
  }
}

void print_char(char x) {
  printf("%c", x);
}

void print_int(int x) {
  printf("%d", x);
}

void print_float(float x) {
  printf("%f", x);
}

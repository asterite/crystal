#include <stdio.h>

long crystal_class_object_id(long x) { return x; }

int crystal_eq_bool(int x, int y) { return x == y; }

int crystal_add_int_int(int x, int y) { return x + y; }
int crystal_sub_int_int(int x, int y) { return x - y; }
int crystal_mul_int_int(int x, int y) { return x * y; }
int crystal_div_int_int(int x, int y) { return x / y; }
int crystal_lt_int_int(int x, int y) { return x < y; }
int crystal_let_int_int(int x, int y) { return x <= y; }
int crystal_eq_int_int(int x, int y) { return x == y; }
int crystal_gt_int_int(int x, int y) { return x > y; }
int crystal_get_int_int(int x, int y) { return x >= y; }

long crystal_eq_long_long(long x, long y) { return x == y; }

float crystal_add_float_float(float x, float y) { return x + y; }
float crystal_sub_float_float(float x, float y) { return x - y; }
float crystal_mul_float_float(float x, float y) { return x * y; }
float crystal_div_float_float(float x, float y) { return x / y; }
int crystal_lt_float_float(float x, float y) { return x < y; }
int crystal_let_float_float(float x, float y) { return x <= y; }
int crystal_eq_float_float(float x, float y) { return x == y; }
int crystal_gt_float_float(float x, float y) { return x > y; }
int crystal_get_float_float(float x, float y) { return x >= y; }

void putb(int x) {
  if (x == 0) {
    printf("true\n");
  } else {
    printf("false\n");
  }
}

void puti(int x) {
  printf("%d\n", x);
}

void putf(float x) {
  printf("%f\n", x);
}

void putchari(int x) {
  printf("%c", x);
}

void putcharf(float x) {
  putchar((char) x);
}

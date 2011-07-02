#include <stdio.h>

int crystal_add_int_int(int x, int y) { return x + y; }
int crystal_sub_int_int(int x, int y) { return x - y; }
int crystal_mul_int_int(int x, int y) { return x * y; }
int crystal_div_int_int(int x, int y) { return x / y; }
int crystal_lt_int_int(int x, int y) { return x < y; }
int crystal_let_int_int(int x, int y) { return x <= y; }
int crystal_eq_int_int(int x, int y) { return x == y; }
int crystal_gt_int_int(int x, int y) { return x > y; }
int crystal_get_int_int(int x, int y) { return x >= y; }

int putb(int x) {
  if (x == 0) {
    printf("true\n");
  } else {
    printf("false\n");
  }
  return x;
}

int puti(int x) {
  printf("%d\n", x);
  return x;
}

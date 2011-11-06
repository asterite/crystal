#include <stdio.h>

int main() {
  int x;
  for(x = 1; x <= 10000; x++) {
    if (prime(x)) {
      printf("%d\n", x);
    }
  }
  return 0;
}

int prime(int x) {
  int i;
  for(i = 2; i <= x - 1; i++) {
    if (divisible_by(x, i)) return 0;
  }
  return 1;
}

int divisible_by(int x, int y) {
  return x % y == 0;
}

#include <stdio.h>

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

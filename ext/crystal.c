#include <stdio.h>

int putb(int x) {
  if (x) {
    printf("true");
  } else {
    printf("false");
  }
  return x;
}

int puti(int x) {
  printf("%d\n", x);
  return x;
}

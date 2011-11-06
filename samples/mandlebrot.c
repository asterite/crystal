#include <stdio.h>

void print_density(int d) {
  if (d > 8) {
    printf(" ");
  } else if (d > 4) {
    printf(".");
  } else if (d > 2) {
    printf("+");
  } else {
    printf("*");
  }
}

int mandel_converger(float real, float imag, int iters, float creal, float cimag) {
  if (iters > 255 || real*real + imag*imag >= 4) {
    return iters;
  } else {
    return mandel_converger(real*real - imag*imag + creal, 2*real*imag + cimag, iters + 1, creal, cimag);
  }
}

int mandel_converge(float real, float imag) {
  return mandel_converger(real, imag, 0, real, imag);
}

void mandel_help(float xmin, float xmax, float xstep, float ymin, float ymax, float ystep) {
  float x;
  while (ymin < ymax) {
    x = xmin;
    while(x < xmax) {
      print_density(mandel_converge(x, ymin));
      x += xstep;
    }
    printf("\n");
    ymin += ystep;
  }
}

void mandel(float realstart, float imagstart, float realmag, float imagmag) {
  mandel_help(realstart, realstart + realmag*78, realmag, imagstart, imagstart + imagmag*40, imagmag);
}

int main() {
  int i;
  for(i = 0; i < 20; i++) {
    mandel(-2.3, -1.3, 0.05, 0.07);
  }
  return 0;
}


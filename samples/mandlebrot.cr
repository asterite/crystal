def printdensity(d)
  if d > 8.0
    C.putcharf 32.0
  elsif d > 4.0
    C.putcharf 46.0
  elsif d > 2.0
    C.putcharf 43.0
  else
    C.putcharf 42.0
  end
end

def mandelconverger(real, imag, iters, creal, cimag)
  if iters > 255.0 || real*real + imag*imag >= 4.0
    iters
  else
    mandelconverger real*real - imag*imag + creal, 2.0*real*imag + cimag, iters + 1.0, creal, cimag
  end
end

def mandelconverge(real, imag)
  mandelconverger real, imag, 0.0, real, imag
end

def mandelhelp(xmin, xmax, xstep, ymin, ymax, ystep)
  y = ymin
  while y < ymax
    x = xmin
    while x < xmax
      printdensity(mandelconverge x, y)
      x = x + xstep
    end
    C.putcharf 10.0
    y = y + ystep
  end
end

def mandel(realstart, imagstart, realmag, imagmag)
  mandelhelp realstart, realstart + realmag*78.0, realmag, imagstart, imagstart + imagmag*40.0, imagmag
end

mandel -2.3, -1.3, 0.05, 0.07

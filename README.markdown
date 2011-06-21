Joy
===

Joy is a programming language that compiles to native code.
It has a syntax strongly inspired by Ruby:
  * No need to declare types: everything is inferred.
  * Classes and Modules can be opened: at compile time everything is mixed together
  * String interpolation
  * Regular expression interpolation
  * Instance variables start with @
  * Global variables start with $
  * Constants start with Capital Letters
  * Functions can be evaluated at compile time as long as they are assigned to a Constant.

Examples:

1. Hello World

    puts "Hello World"

2. Fibbonacci

    def fib n
      if n <= 2
        1
      else
        fib(n - 1) + fib(n - 2)
      end
    end

    Value = fib 6
    puts Value

    # Compiles to...
    # puts 8

3. Constants as arguments

    def static N, x
      if N == 1
        2 * x
      else
        3 * x
      end
    end

    puts static(2, 6)

    # Compiles to...
    def static_2 x
     3 * x
    end

    puts static_2(6)

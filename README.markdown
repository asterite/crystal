Crystal
=======

Crystal is a programming language that compiles to native code.
It has a syntax strongly inspired by Ruby:

*   No need to declare types: everything is inferred.
*   Classes and Modules can be opened: at compile time everything is mixed together
*   String interpolation
*   Regular expression interpolation
*   Instance variables start with @
*   Global variables start with $
*   Constants start with Capital Letters
*   Functions can be evaluated at compile time as long as they are assigned to a Constant.

How to run it in your machine
-----------------------------

Clone, run bundle, but ruby-llvm should be version 2.9.2. Now, that
version was not released and is not in RubyGems, you can get it from
here: [http://jvoorhis.com/ruby-llvm/ruby-llvm-2.9.2.gem](http://jvoorhis.com/ruby-llvm/ruby-llvm-2.9.2.gem)

The only problem is... the native extensions don't seem to compile
anymore. So if anyone finds a solution for this: very, very welcome! :-)

Then you'll have five executables:

*   bin/compile => compiles a given file.cr down to machine down
*   bin/dump => shows the unoptimized llvm file for a a given file.cr
*   bin/icr => interactive crystal shell
*   bin/interpret => interprets a given file.cr
*   bin/ll => shows the optimized llvm file for a given file.ll

Examples
--------

Hello World

    puts "Hello World"

Fibbonacci

    def fib n
      if n <= 2
        1
      else
        fib(n - 1) + fib(n - 2)
      end
    end

    Value = fib 6
    puts Value

Compiles to...

    puts 8

Constants as arguments

    def static N, x
      if N == 1
        2 * x
      else
        3 * x
      end
    end

    puts static(2, 6)

Compiles to...

    def static_2 x
     3 * x
    end

    puts static_2(6)

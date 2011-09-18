def assert_true(expression)
  unless expression
    print 'F'
    print '\n'
  end
end

def assert_false(expression)
  if expression
    print 'F'
    print '\n'
  end
end

def assert_equal(expected, actual)
  if expected != actual
    print expected
    print ' '
    print '!'
    print '='
    print ' '
    print actual
    print '\n'
  end
end

# Test Bool op Bool
assert_false true == false
assert_true true == true
assert_true !false
assert_false !true
assert_false false && true
assert_true true && true
assert_false false || false
assert_true false || true
assert_false false & true
assert_true true & true
assert_false false | false
assert_true false | true
assert_false true ^ true
assert_true false ^ true
assert_equal -2, ~1

# Test op Int
assert_equal 1, + 1
assert_equal -1, - 1

# Test Int op Int
assert_equal 3, 1 + 2
assert_equal -1, 1 - 2
assert_equal 6, 2 * 3
assert_equal 2, 10 / 4
assert_equal 4, 10 % 6
assert_false 8 < 4
assert_true 4 < 8
assert_false 8 <= 7
assert_true 7 <= 8
assert_false 4 > 8
assert_true 8 > 4
assert_false 4 >= 8
assert_true 8 >= 4
assert_false 8 == 4
assert_true 4 == 4
assert_false 4 != 4
assert_true 8 != 4
assert_equal 8, 1 << 3
assert_equal 2, 4 >> 1
assert_equal 4, 12 & 5
assert_equal 5, 4 | 1
assert_equal 1, 5 ^ 4
assert_equal 16, 2 ** 4

# Test Int op Float
assert_equal 3.0, 1 + 2.0
assert_equal -1.0, 1 - 2.0
assert_equal 6.0, 2 * 3.0
assert_equal 2.5, 10 / 4.0
assert_false 8 < 4.0
assert_true 4 < 8.0
assert_false 8 <= 7.0
assert_true 7 <= 8.0
assert_false 4 > 8.0
assert_true 8 > 4.0
assert_false 4 >= 8.0
assert_true 8 >= 4.0
assert_false 8 == 4.0
assert_true 4 == 4.0
assert_false 4 != 4.0
assert_true 8 != 4.0
assert_equal 16.0, 2 ** 4.0

# Test op Float
assert_equal 1.0, + 1.0
assert_equal -1.0, - 1.0

# Test Float op Int
assert_equal 3.0, 1.0 + 2
assert_equal -1.0, 1.0 - 2
assert_equal 6.0, 2.0 * 3
assert_equal 2.5, 10.0 / 4
assert_false 8.0 < 4
assert_true 4.0 < 8
assert_false 8.0 <= 7
assert_true 7.0 <= 8
assert_false 4.0 > 8
assert_true 8.0 > 4
assert_false 4.0 >= 8
assert_true 8.0 >= 4
assert_false 8.0 == 4
assert_true 4.0 == 4
assert_false 4.0 != 4
assert_true 8.0 != 4
assert_equal 16.0, 2.0 ** 4

# Test Float op Float
assert_equal 3.0, 1.0 + 2.0
assert_equal -1.0, 1.0 - 2.0
assert_equal 6.0, 2.0 * 3.0
assert_equal 2.5, 10.0 / 4.0
assert_false 8.0 < 4.0
assert_true 4.0 < 8.0
assert_false 8.0 <= 7.0
assert_true 7.0 <= 8.0
assert_false 4.0 > 8.0
assert_true 8.0 > 4.0
assert_false 4.0 >= 8.0
assert_true 8.0 >= 4.0
assert_false 8.0 == 4.0
assert_true 4.0 == 4.0
assert_false 4.0 != 4.0
assert_true 8.0 != 4.0
assert_equal 16.0, 2.0 ** 4.0

# Test parenthesis
assert_equal 14, 2 * (3 + 4)

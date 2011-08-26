def assert_equal(expected, actual)
  if expected != actual
    print expected
    print ' '
    print '!'
    print '='
    print ' '
    print actual
  end
end

assert_equal 3, 1 + 2
assert_equal 6, 2 * 3

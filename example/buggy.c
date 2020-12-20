int foo() {
  int a = 1;
  // undefined `c`
  int b = c;
  // redefined `a`
  int a = 2;
  // type mismatched, expected `int` but got `char`
  int d = 'c';

  // type mismatched, expected `int` but got `double`
  return 1.2;
}

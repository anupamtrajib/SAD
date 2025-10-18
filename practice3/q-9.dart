import 'dart:io';

num maxNumber(num a, num b, num c) {
  if(a>b&&a>c) return a;
  if(b>a &&b>c) return b;
  return c;
}

void main() {
  num num1 = num.parse(stdin.readLineSync()!);
  num num2 = num.parse(stdin.readLineSync()!);
  num num3 = num.parse(stdin.readLineSync()!);

  num maxnum = maxNumber(num1, num2, num3);
  print("maximum number is $maxnum");
}
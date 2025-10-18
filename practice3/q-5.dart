import 'dart:math';
import 'dart:io';

void function(double r) {
  double area = pi * r * r;

  print("Area of the circle with radius $r: $area");
}

void main() {
  print("Enter radius: ");
  double r = double.parse(stdin.readLineSync()!);

  function(r);
}
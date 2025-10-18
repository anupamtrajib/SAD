import 'dart:io';

void printEvenNumbers(int a, int b) {
  for (int i = a; i <= b; i++) {
    if (i % 2 == 0) {
      print(i);
    }
  }
}

void main() {
  int num1 = int.parse(stdin.readLineSync()!);
  int num2 = int.parse(stdin.readLineSync()!);
 printEvenNumbers(num1, num2);
}
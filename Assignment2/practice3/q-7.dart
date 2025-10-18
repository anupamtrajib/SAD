import 'dart:io';

void powerCalculator(int a, int b) {
  int ans = 1;
  for (int i = 1; i <= b; i++) {
    ans *= a;
  }
  print("$a to the power $b is equal to:$ans");
}

void main() {
  int base = int.parse(stdin.readLineSync()!);
  int power = int.parse(stdin.readLineSync()!);

powerCalculator(base, power);

}
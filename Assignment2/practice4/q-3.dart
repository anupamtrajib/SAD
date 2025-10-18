import 'dart:io';

void main() {
  int n = int.parse(stdin.readLineSync()!);
  List<double> exp = [];

  for (int i = 0; i < n; i++) {
    double amount = double.parse(stdin.readLineSync()!);
    exp.add(amount);
  }

  double total = 0;
  for (double e in exp) {
    total += e;
  }

  print("Total: $total");
}
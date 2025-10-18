import 'dart:io';

bool isEven(int number) {
  return number % 2 == 0;
}

void main() {
  int num = int.parse(stdin.readLineSync()!);
  bool res=isEven(num);
  if (res) {
    print("$num is even.");
  } else {
    print("$num is not even.");
  }
}
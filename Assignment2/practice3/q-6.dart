import 'dart:io';

String reverseString(String s) {
  String reversed = "";
  for (int i = s.length - 1; i >= 0; i--) {
    reversed += s[i];
  }
  return reversed;
}

void main() {
  stdout.write("Enter the string: ");
  String str = stdin.readLineSync()!;

  String reversedStr = reverseString(str);
  print("Reversed string: $reversedStr");
}
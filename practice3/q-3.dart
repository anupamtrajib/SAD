import 'dart:io';

void greet(String name) {
  print(' "Hello ${name}". ');
}

main() {
  String? name = stdin.readLineSync()!;
  greet(name);
}
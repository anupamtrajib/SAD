import 'dart:math';
import 'dart:io';

void main() {
 stdout.write(" Enter desired password length: ");
int length = int.parse(stdin.readLineSync()!);

   String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
   String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   String numbers = '0123456789';
   String special = '!@#%^&*=+()[]{}<>?';

  String finalChars = lowerCase + upperCase + numbers + special;
  String password='';
  for (int i = 0; i < length; i++) {
    password += finalChars[Random().nextInt(finalChars.length)];
  }

  print("Generated Password: $password");
}
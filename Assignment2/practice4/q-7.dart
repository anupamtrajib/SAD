void main() {
  Map<String, String> contacts = {
    "ATR": "017254545",
    "Mashrafi": "0175",
    "Jihan": "01955255852",
    "Proyas": "015545455522",
  };

  var finalcontacts = contacts.entries
      .where((entry) => entry.value.length == 4)
      .map((entry) => entry.key);

  print("Keys with phone number length 4:");
  for (var key in finalcontacts) {
    print(key);
  }
}
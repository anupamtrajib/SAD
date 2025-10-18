void main() {
  Map<String, dynamic> person = {
    "name": "Anupam Talukder",
    "address": "Kazirbazar",
    "age": 23,
    "country": "Bangladesh",
  };

  person["country"] = "USA";

  person.forEach((key, value) {
    print("$key: $value");
  });
}
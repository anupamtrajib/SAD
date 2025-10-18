double calculateArea({double length = 1, double width = 1}) {
  return length * width;
}

void main() {
  double area=calculateArea(length: 3, width: 2);
  print(
    "Area  ${area}",
  );
}
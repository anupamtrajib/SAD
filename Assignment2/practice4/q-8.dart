import 'dart:io';

void main() {
  List<String> tasks = [];

  while (true) {
    print("1. Add Task");
    print("2. View Tasks");
    print("3. Exit");
    stdout.write("Enter your choice: ");
    String? choice = stdin.readLineSync();

    if (choice == '1') {
      stdout.write("Enter a task: ");
      String? task = stdin.readLineSync();
      if (task != null && task.isNotEmpty) {
        tasks.add(task);
        print("Task added!");
      } else {
        print("Invalid task!");
      }
    } else if (choice == '2') {
      if (tasks.isEmpty) {
        print("No tasks found!");
      } else {
        print("\nYour Tasks:");
        for (int i = 0; i < tasks.length; i++) {
          print("${i + 1}. ${tasks[i]}");
        }
      }
    } else if (choice == '3') {
      print("Goodbye!");
      break;
    } else {
      print("Please enter 1, 2, or 3.");
    }
  }
}

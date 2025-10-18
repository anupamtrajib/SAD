  void main(){
    List<String> friends = ['Anupam', 'Rahul', 'Arif', 'Borna', 'Asif', 'Tania', 'Amit'];

  var names = friends.where((name) => name.toLowerCase().startsWith('a'));

  for (String name in names) {
    print(name);
  }

  }